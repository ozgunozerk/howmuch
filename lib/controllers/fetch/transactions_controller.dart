import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';

import 'package:how_much/custom_types.dart';
import 'package:how_much/controllers/fetch/price_tables_controller.dart';
import 'package:how_much/controllers/snapshots_controller.dart';
import 'package:how_much/util/firebase_init.dart';
import 'package:how_much/util/helper_funcs.dart';
import 'package:how_much/util/parsing.dart';

class TransactionsController extends GetxController {
  final _firebaseService = FirebaseService();

  final _snapshotsController = Get.find<SnapshotsController>();
  final _priceTablesController = Get.find<PriceTablesController>();

  // return true if there were transactions, false otherwise
  Future<bool> fetchAndProcessTransactions() async {
    try {
      final HttpsCallable callable =
          _firebaseService.functions.httpsCallable('fetchTransactions');
      final HttpsCallableResult result = await callable.call();

      if (result.data is! Map) {
        throw "transaction data is not a map";
      }

      if (result.data.isEmpty) {
        // server returns an empty object if there are no transactions
        return false;
      }

      // iterate through each transaction
      Map<String, dynamic> transactions = result.data;
      await _processTransactions(transactions);
    } catch (e) {
      if (kDebugMode) {
        print("Failed to fetch transactions due to: $e");
      }
      showErrorDialog("Failed to fetch transactions", "$e");
    }
    return true;
  }

  Future<void> _processTransactions(Map<String, dynamic> transactions) async {
    Snapshots snapshots = _snapshotsController.snapshots;

    // sort the transactions w.r.t their date
    List<String> sortedKeys = transactions.keys.toList(growable: false)..sort();

    LinkedHashMap<String, dynamic> sortedTransactions =
        LinkedHashMap.fromIterable(
      sortedKeys,
      key: (k) => k,
      value: (v) => transactions[v],
    );

    await _fetchPriceTablesWithDate(sortedKeys.first);

    // we use this value to compare how many snapshots were in between current
    // and last transaction. Since the current transaction may not be finalized
    // we need to add at least 6 hours to `now` to ensure this check will work
    // correctly for the first time. We could have made this null, but then
    // we would need additional null checks for every iteration.
    DateTime lastCreatedSnapshotDate =
        DateTime.now().add(const Duration(days: 1));

    sortedTransactions.forEach((date, transactionData) {
      // Extract transaction details
      double amount = (transactionData['amount'] as num).toDouble();
      AssetId assetId = transactionData['assetId'];
      AssetType type = AssetTypeHelper.fromString(transactionData['assetType']);

      // parse the original, find the next 6th multiple (00, 06, 12, 18)
      DateTime originalDate = DateTime.parse(date);
      int roundedDownHour = (originalDate.hour ~/ 6) * 6;
      DateTime previousSnapshotDate = DateTime(originalDate.year,
          originalDate.month, originalDate.day, roundedDownHour);
      DateTime nextSnapshotDate =
          previousSnapshotDate.add(const Duration(hours: 6));
      String nextSnapshotDateString = formatDateWithHour(nextSnapshotDate);

      if (nextSnapshotDate.difference(lastCreatedSnapshotDate).inHours > 0) {
        // means we need to create a new snapshot
        _snapshotsController.generateMissingSnapshots(nextSnapshotDate);
      }
      lastCreatedSnapshotDate = nextSnapshotDate;

      _findOrCreateAssetInSnapshot(nextSnapshotDateString, type, assetId);

      // Update the asset amount
      double newAmount = snapshots.snapshotMap[nextSnapshotDateString]!
          .typeMap[type]![assetId]!.amount += amount;

      // if the asset amount is 0 after the transaction, and it doesn't exist in the previous snapshot, delete it
      _pruneAssetIfAmount0(newAmount, previousSnapshotDate,
          nextSnapshotDateString, type, assetId);

      // after each transaction, update the last snapshot date, we will use it in `generateMissingSnapshots`
      _snapshotsController.setLastSnapshotDate();
    });
    _snapshotsController.setFirstSnapshotDate();
    _snapshotsController.setFinalizedDateAfterProcessingTransactions();
    await _snapshotsController.storeSnapshotsOnDevice();
  }

  void _findOrCreateAssetInSnapshot(
      String nextSnapshotDateString, AssetType type, AssetId assetId) {
    Snapshots snapshots = _snapshotsController.snapshots;

    // find the asset in the snapshot, if couldn't find, create them
    snapshots.snapshotMap[nextSnapshotDateString] ??= Assets.empty();
    snapshots.snapshotMap[nextSnapshotDateString]!.typeMap[type] ??= {};
    snapshots.snapshotMap[nextSnapshotDateString]!.typeMap[type]![assetId] ??=
        Asset(
      amount: 0,
      price: _priceTablesController.getPriceForAsset(type, assetId,
          priceTableDateString: nextSnapshotDateString)!,
      category: type.name,
    );
  }

  void _pruneAssetIfAmount0(double newAmount, DateTime previousSnapshotDate,
      String nextSnapshotDateString, AssetType type, AssetId assetId) {
    Snapshots snapshots = _snapshotsController.snapshots;
    // we need to delete the entry in the below scenario:
    // asset was added, and sent to server as a transaction (committed),
    // in the next commit, asset was sold. Within that 2 commits, no snapshot was taken
    // if this asset does not exist in the previous snapshot, it was bought and sold within the time
    // of taking a snapshot. In other words, no need to store this in the snapshots.
    if (newAmount == 0) {
      String prevSnapshotDateString = formatDateWithHour(previousSnapshotDate);

      try {
        // if can reach to asset, don't do anything
        snapshots.snapshotMap[prevSnapshotDateString]!.typeMap[type]![assetId]!;
      } catch (_) {
        // Asset does not exist in the previous snapshot, delete the entry
        snapshots.snapshotMap[nextSnapshotDateString]!.typeMap[type]!
            .remove(assetId);
      }
    }
  }

  Future<void> _fetchPriceTablesWithDate(String timestamp) async {
    // fetchPriceTable returns the price tables AFTER the given date,
    // so we should use the previous snapshot date, in order to fetch the correct price tables

    // find the previous update time for that timestamp with rounding down
    // we subtract 6 for the case the transaction may not be finalized,
    // if so, we will need the previous price table
    String previousUpdateTime = getPreviousUpdateTime(
        DateTime.parse(timestamp).subtract(const Duration(hours: 6)));

    await _priceTablesController.fetchPriceTables(previousUpdateTime);
  }
}
