import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:how_much/custom_types.dart';
import 'package:how_much/controllers/fetch/price_tables_controller.dart';
import 'package:how_much/controllers/fetch/transactions_controller.dart';
import 'package:how_much/util/helper_funcs.dart';
import 'package:how_much/util/parsing.dart';

class SnapshotsController extends GetxController {
  // ignore: prefer_collection_literals
  Snapshots snapshots = Snapshots.empty();

  final PriceTablesController _priceTablesController =
      Get.find<PriceTablesController>();

  // Below dates are string, instead of DateTime. Because they need to be compatible with
  // transaction dates, which are strings, due to how they are being stored in Firebase
  String _firstSnapshotDateUTC = '';
  String _lastSnapshotDateUTC = '';
  String _lastFinalizedSnapshotDateUTC = '';

  bool newUser = false;

  Timer? _updateTimer;

  final loading = true.obs;

  @override
  void onInit() async {
    super.onInit();

    bool foundSnapshots = await _loadSnapshotsFromDevice();
    if (!foundSnapshots) {
      // couldn't find any local snapshot, fetch transactions from the server
      TransactionsController transactionsController =
          Get.put(TransactionsController());

      // if there are no transactions, it means we are dealing with a new user
      bool wereThereAnyTransactions =
          await transactionsController.fetchAndProcessTransactions();
      newUser = !wereThereAnyTransactions;
    }

    // Fetch user price tables upon controller initialization
    await _fetchServerSideUpdates();

    // after that, start a timer that will fetch updates regularly if needed
    _startContinuousTimer();

    loading.value = false;
  }

  void _startContinuousTimer() {
    // Cancel any existing timer
    _updateTimer?.cancel();

    // Start a new timer that runs every 1 minutes
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _handleTimerTick();
    });
  }

  void _handleTimerTick() {
    // Convert the current time to UTC
    DateTime now = DateTime.now().toUtc();
    DateTime nowUTC = now.subtract(now.timeZoneOffset);

    // fetch updates every 6 hours
    if (nowUTC.hour % 6 == 0) {
      _fetchServerSideUpdates(); // do not await, this should not be blocking
    }
  }

  Future<bool> _loadSnapshotsFromDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedSnapshots = prefs.getString('snapshots');

    if (storedSnapshots == null) {
      return false;
    } else {
      // there are snapshots on device, load them
      try {
        snapshots = Snapshots.fromMap(jsonDecode(storedSnapshots));
        setFirstSnapshotDate();
        setLastSnapshotDate();

        _lastFinalizedSnapshotDateUTC = prefs.getString('finalized')!;
      } catch (e) {
        if (kDebugMode) {
          print("loading/setting snapshots from device failed with error: $e");
        }
        showErrorDialog("cannot load snapshots from device!");
      }
      return true;
    }
  }

  Future<void> storeSnapshotsOnDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('snapshots', jsonEncode(snapshots.toMap()));
    await prefs.setString('finalized', _lastFinalizedSnapshotDateUTC);
  }

  Future<void> _fetchServerSideUpdates() async {
    // all the dates should be in UTC time for server related things
    // `toUtc` is dangerous, we have to create a new DateTime object.
    DateTime now = DateTime.now();
    DateTime nowUTC = now.subtract(now.timeZoneOffset);
    String previousUpdateTime = getPreviousUpdateTime(nowUTC);

    if (_lastSnapshotDateUTC == '') {
      // means we don't have any assets/snapshots yet

      if (_priceTablesController.lastPriceTableDateUTC != previousUpdateTime) {
        // fetchPriceTables retrieves the price tables after the given date (excluding)
        // so, we have to deduce another 6 hours to fetch the ones we want
        previousUpdateTime =
            getPreviousUpdateTime(nowUTC.subtract(const Duration(hours: 6)));
        await _priceTablesController.fetchPriceTables(previousUpdateTime);
      }
      return;
    }
    // last snapshot date was present
    DateTime lastSnapshotDateUTC = parseDateWithHour(_lastSnapshotDateUTC);
    int hourDiff = nowUTC.difference(lastSnapshotDateUTC).inHours;

    if (hourDiff >= 6) {
      if (_priceTablesController.lastPriceTableDateUTC != previousUpdateTime) {
        // price tables are not up to date, fetch the new ones
        await _priceTablesController
            .fetchPriceTables(_priceTablesController.lastPriceTableDateUTC);
      }

      // it could be that we don't have a finalized snapshot, although we have snapshots present
      DateTime? lastFinalizedSnapshotDateUTC = _getFinalizedDate();

      // finalize snapshots
      snapshots
          .getNonFinalizedSnapshotDates(lastFinalizedSnapshotDateUTC)
          .forEach((dateString) async {
        await finalizeSnapshot(dateString);
      });

      // even after finalizing snapshots, we could be missing some snapshots
      await generateMissingSnapshots(nowUTC);

      setLastSnapshotDate();
      updateFinalizedDate();
      await storeSnapshotsOnDevice();
    } else {
      // means there are no updates yet, don't do anything
    }
  }

  void setFirstSnapshotDate() {
    _firstSnapshotDateUTC = snapshots.snapshotMap.keys.toList().first;
  }

  void setLastSnapshotDate({shouldSetFirstDate = true}) {
    _lastSnapshotDateUTC = snapshots.snapshotMap.keys.last;
  }

  void updateFinalizedDate() {
    _lastFinalizedSnapshotDateUTC = _lastSnapshotDateUTC;
  }

  DateTime? _getFinalizedDate() {
    DateTime? lastFinalizedSnapshotDateUTC;
    try {
      lastFinalizedSnapshotDateUTC =
          parseDateWithHour(_lastFinalizedSnapshotDateUTC);
    } catch (_) {
      lastFinalizedSnapshotDateUTC = null;
    }
    return lastFinalizedSnapshotDateUTC;
  }

  void setFinalizedDateAfterProcessingTransactions() {
    // after processing transactions, only the last snapshot may be non-finalized
    DateTime lastSnapshotDateUTC = parseDateWithHour(_lastSnapshotDateUTC);
    DateTime now = DateTime.now();
    DateTime nowUTC = now.subtract(now.timeZoneOffset);
    if (lastSnapshotDateUTC.difference(nowUTC).inHours > 0) {
      // last snapshot is later than `now`, means it is NOT finalized
      // find the previous snapshot's date by subtracting 6 hours
      _lastFinalizedSnapshotDateUTC = formatDateWithHour(
          lastSnapshotDateUTC.subtract(const Duration(hours: 6)));
    } else {
      _lastFinalizedSnapshotDateUTC = _lastSnapshotDateUTC;
    }
  }

  String getLastSnapshotDate() {
    return _convertUtcToLocalDate(_lastSnapshotDateUTC);
  }

  String getFirstSnapshotDate() {
    return _convertUtcToLocalDate(_firstSnapshotDateUTC);
  }

  // we will display the available dates for report generation to the user,
  // since we will display them to user, they should be in local time,
  String _convertUtcToLocalDate(String snapshotDate) {
    if (snapshotDate.isEmpty) {
      return "";
    }

    DateTime utc = parseDateWithHour(snapshotDate);
    DateTime local = utc.toLocal();

    String formattedLastDate = formatDateWithHour(local);

    return formattedLastDate;
  }

  // can only be null during `onInit` stage for new users
  Assets? getLastSnapshot() {
    if (snapshots.snapshotMap.isNotEmpty) {
      return snapshots.snapshotMap[_lastSnapshotDateUTC]!;
    }
    return null;
  }

  updateAssetsWithPriceTable(Assets assets, String priceTableDateUtc) {
    assets.typeMap.forEach((assetType, assetMap) {
      assetMap.forEach((assetId, asset) {
        double price = _priceTablesController.getPriceForAsset(
            assetType, assetId,
            priceTableDate: priceTableDateUtc)!;
        assets.typeMap[assetType]![assetId]!.price = price;
      });
    });
  }

  Future<void> finalizeSnapshot(String snapshotDate) async {
    Assets snapshotContent = snapshots.snapshotMap[snapshotDate]!;
    Assets assets = snapshotContent.clone();

    updateAssetsWithPriceTable(assets, snapshotDate);
    snapshots.snapshotMap[snapshotDate] = assets;
  }

  Future<void> generateMissingSnapshots(DateTime tillDate) async {
    // calculate how many snapshots we have to generate
    DateTime lastSnapshotDateUTC = parseDateWithHour(_lastSnapshotDateUTC);
    int hourDiff = tillDate.difference(lastSnapshotDateUTC).inHours;

    int missedSnapshotCount = hourDiff ~/ 6;

    Assets lastSnapshotContent = getLastSnapshot()!;

    for (int counter = 1; counter <= missedSnapshotCount; counter++) {
      Assets assets = lastSnapshotContent.clone();
      DateTime newDate = lastSnapshotDateUTC.add(Duration(hours: 6 * counter));
      String newDateString = formatDateWithHour(newDate);

      updateAssetsWithPriceTable(assets, newDateString);
      snapshots.snapshotMap[newDateString] = assets;
    }
  }

  @override
  void onClose() {
    _updateTimer?.cancel();

    super.onClose();
  }
}
