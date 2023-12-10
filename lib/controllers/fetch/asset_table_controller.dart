import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:how_much/custom_types.dart';
import 'package:how_much/util/firebase_init.dart';
import 'package:how_much/util/helper_funcs.dart';
import 'package:how_much/util/parsing.dart';

class AssetTableController extends GetxController {
  final _firebaseService = FirebaseService();

  final assetTable = AssetTable().obs;

  @override
  void onInit() async {
    super.onInit();

    final maybeLoadedTable = await _loadAssetTableFromDevice();
    if (maybeLoadedTable != null) {
      final DateTime now = DateTime.now();
      final DateTime lastFetch = (await _getLastFetchTimestamp())!;
      if (now.difference(lastFetch).inDays < 14) {
        // Last fetch was less than 14 days ago, no need to fetch again.
        // recall: asset table does not include prices, but only names of the assets
        // we don't expect frequent updates on that
        assetTable.value = maybeLoadedTable;
      } else {
        // if it has been more than 14 days
        await _fetchAssetTable();
      }
    } else {
      // if we couldn't find a local asset table
      await _fetchAssetTable();
    }
  }

  Future<void> _fetchAssetTable() async {
    try {
      final HttpsCallable callable =
          _firebaseService.functions.httpsCallable('fetchAssetTable');

      final HttpsCallableResult result = await callable.call();

      if (result.data is! Map) {
        throw 'Data is not a map';
      }

      final Map<String, dynamic> dataMap = {};

      for (final entry in (result.data as Map).entries) {
        if (entry.key is! String) {
          throw 'One of the keys is not a string';
        }
        dataMap[entry.key as String] = entry.value;
      }

      assetTable.value = AssetTable.fromMap(dataMap);
      await _saveAssetTableToDevice(assetTable.value);
      await _setLastFetchTimestamp(DateTime.now());
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch asset table: $e');
      }
      showErrorDialog(
          "There was a problem communicating with the server. Please try again later.");
    }
  }

  Map<String, dynamic> getAssetsPerType(AssetType assetType) {
    // due to coingecko api being different, we have to handle crypto assetType differently
    if (assetType == AssetType.crypto) {
      Map<String, Map<String, String>> cryptoMap = {};

      assetTable.value.data[assetType]?.forEach((key, value) {
        if (value is Map) {
          cryptoMap[key] = {
            'symbol': value['symbol'] as String,
            'name': value['name'] as String,
          };
        }
      });

      return cryptoMap;
    } else {
      return assetTable.value.data[assetType]?.cast<String, String>() ?? {};
    }
  }

  String getCryptoAssetSymbol(String assetId) {
    // there is no way client can query this function with invalid assetId
    return assetTable.value.data[AssetType.crypto]![assetId]!["symbol"];
  }

  Future<void> _setLastFetchTimestamp(DateTime timestamp) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final formattedDate = formatDate(timestamp);
    await prefs.setString('last_fetch', formattedDate);
  }

  Future<DateTime?> _getLastFetchTimestamp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastFetchDate = prefs.getString('last_fetch');

    if (lastFetchDate != null) {
      return parseDate(lastFetchDate);
    }
    return null;
  }

  Future<void> _saveAssetTableToDevice(AssetTable table) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('asset_table', jsonEncode(table.toMap()));
  }

  Future<AssetTable?> _loadAssetTableFromDevice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? assetTableJson = prefs.getString('asset_table');

    if (assetTableJson != null) {
      try {
        return AssetTable.fromMap(jsonDecode(assetTableJson));
      } catch (e) {
        if (kDebugMode) {
          print("cannot parse asset table json from device, because: $e");
        }
        showErrorDialog("Couldn't parse asset table json from device.");
      }
    }
    return null;
  }
}
