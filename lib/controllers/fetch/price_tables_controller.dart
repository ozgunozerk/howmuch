import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:how_much/custom_types.dart';
import 'package:how_much/util/firebase_init.dart';
import 'package:how_much/util/helper_funcs.dart';
import 'package:how_much/util/parsing.dart';

class PriceTablesController extends GetxController with WidgetsBindingObserver {
  final _firebaseService = FirebaseService();

  PriceTables priceTables = PriceTables.empty();

  String lastPriceTableDateUTC = '';

  final loading = true.obs;

  @override
  void onInit() async {
    super.onInit();

    await _loadPriceTablesFromDevice();

    loading.value = false;
  }

  Future<void> _loadPriceTablesFromDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPriceTables = prefs.getString('priceTables');

    if (storedPriceTables != null) {
      if (storedPriceTables.isEmpty) {
        return;
      }
      try {
        priceTables = PriceTables.fromMap(jsonDecode(storedPriceTables));
        lastPriceTableDateUTC = priceTables.priceTableMap.keys.last;
      } catch (e) {
        if (kDebugMode) {
          print("cannot parse price tables json from device, because: $e");
        }
        showErrorDialog("cannot parse price tables from device", "$e");
      }
    } else {
      // there may be no local priceTable in device (i.e. first install)
      // in this case, we don't need to do anything
    }
  }

  Future<void> _storePriceTablesOnDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('priceTables', jsonEncode(priceTables.toMap()));
  }

  // fetches price tables that are after the given date (not including)
  Future<void> fetchPriceTables(String knownPriceTableDateUTC) async {
    try {
      final HttpsCallable callable =
          _firebaseService.functions.httpsCallable('fetchPriceTables');
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          // to retrieve not all, but only the missing price tables,
          // we can provide this optional parameter
          'latestPriceTableDate': knownPriceTableDateUTC,
        },
      );

      PriceTables newPriceTables = PriceTables.fromMap(result.data);

      // append the new price tables to the observable variable
      priceTables.priceTableMap.addAll(newPriceTables.priceTableMap);
      lastPriceTableDateUTC = priceTables.priceTableMap.keys.last;

      await _storePriceTablesOnDevice();
    } catch (e) {
      if (kDebugMode) {
        print("fetching and setting the price tables failed due to error: $e");
      }
      showErrorDialog("fetching and setting price tables", "$e");
    }
  }

  /// takes an optional parameter for price table date
  /// if provided, queries the given price table
  /// if not, queries the current (the newest) price table
  double? getPriceForAsset(AssetType assetType, String assetId,
      {String priceTableDateString = ""}) {
    if (priceTableDateString == "") {
      return priceTables
          .priceTableMap.values.last.data[assetType]?.entries[assetId];
    } else {
      DateTime priceTableDateUTC = parseDateWithHour(priceTableDateString);
      DateTime now = DateTime.now();
      DateTime nowUTC = now.subtract(now.timeZoneOffset);
      if (priceTableDateUTC.difference(nowUTC).inHours > 0) {
        // last price table date is later than `now`, means we are dealing
        // with a non-finalized snapshot, and this price table does not exist yet
        // use the previous price table for now
        // this can only happen when we are processing a non-finalized transaction
        priceTableDateString = formatDateWithHour(
            priceTableDateUTC.subtract(const Duration(hours: 6)));
      }

      final PriceTable? priceTable =
          priceTables.priceTableMap[priceTableDateString];
      if (priceTable == null) {
        throw Exception('Price table for $priceTableDateString not found.');
      } else {
        final PriceTableEntries? assetData = priceTable.data[assetType];
        if (assetData == null) {
          throw Exception(
              'Asset type $assetType not found in $priceTableDateString.');
        } else {
          final double? entry = assetData.entries[assetId];
          if (entry == null) {
            throw Exception(
                'Entry with assetId $assetId is null in $priceTableDateString.');
          } else {
            return entry;
          }
        }
      }
    }
  }
}
