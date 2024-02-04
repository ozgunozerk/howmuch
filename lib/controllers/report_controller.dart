import 'package:get/get.dart';
import 'package:how_much/controllers/helpers/date.dart';
import 'package:tuple/tuple.dart';

import 'package:how_much/controllers/snapshots_controller.dart';
import 'package:how_much/controllers/user_assets_controller.dart';
import 'package:how_much/custom_types.dart';
import 'package:how_much/util/parsing.dart';

class ReportController extends GetxController {
  final _snapshotsController = Get.find<SnapshotsController>();
  final _userAssetsController = Get.find<UserAssetsController>();
  final _dateController = Get.find<DateController>();

  // ignore: prefer_collection_literals
  CategoryMap _categoryMap = CategoryMap();

  final _dataPointsOfAllAssets = <double>[].obs;
  final _dataPointsPerCategory = <Category, List<double>>{}.obs;

  final _dateRange =
      const Tuple2('', '').obs; // these dates are in yyyy-MM-dd-hh format

  SnapshotMap _filteredSnapshots = SnapshotMap();
  Assets _startSnapshotContent = Assets.empty();
  Assets _endSnapshotContent = Assets.empty();

  final _report = Report.empty().obs;

  final _topGainers = <AssetItem>[].obs;
  final _soldAssets = <AssetItem>[].obs;

  // date controller will set the dates,
  // we need to be sure that `ever()` subscription is in place before
  // `DateController` is set
  final loading = true.obs;

  @override
  void onInit() {
    super.onInit();

    if (_snapshotsController.newUser) {
      // set the controller's date BEFORE subscribing to date changes
      // so it won't trigger `calculateAll`, because we don't have snapshots yet
      _dateRange.value = _dateController.getStartAndEndDatesUtc();
      ever(_dateRange, (_) => calculateAll());
    } else {
      // set the controller's date AFTER subscribing to date changes
      // so it will trigger `calculateAll`, because we have snapshots
      ever(_dateRange, (_) => calculateAll());
      _dateRange.value = _dateController.getStartAndEndDatesUtc();
    }

    loading.value = false;
  }

  void calculateAll() {
    // reset the previous report
    _report.value = Report.empty();

    _updateCategories();
    _setStartAndEndSnapshots();
    _setDataPointsOfAllAssets();
    _fillReport();
    _calculateTopGainers();
    _setSoldAssets();
    _setDataPointsPerCategory();
  }

  void _updateCategories() {
    _categoryMap = _userAssetsController.categoryMap;
  }

  void _setStartAndEndSnapshots() {
    SnapshotMap snapshots = _snapshotsController.snapshots.snapshotMap;

    List<MapEntry<String, Assets>> filteredSnapshotEntries =
        snapshots.entries.where((snapshotDateString) {
      DateTime snapshotDate = parseDateWithHour(snapshotDateString.key);
      DateTime startDate = parseDateWithHour(_dateRange.value.item1);
      DateTime endDate = parseDateWithHour(_dateRange.value.item2);

      // Include snapshots falling on or between the start and end dates
      return snapshotDate.isAtSameMomentAs(startDate) ||
          (snapshotDate.isAfter(startDate) && snapshotDate.isBefore(endDate)) ||
          snapshotDate.isAtSameMomentAs(endDate);
    }).toList();

    if (filteredSnapshotEntries.length == 1) {
      // it could be that the client has only 1 snapshot yet.
      // In order to generate a report, we have to fake a first one with 0 balance
      DateTime lastSnapshotDate =
          parseDateWithHour(filteredSnapshotEntries.first.key);
      String firstSnapshotKey = formatDateWithHour(
          lastSnapshotDate.subtract(const Duration(hours: 6)));

      filteredSnapshotEntries.insert(
          0, MapEntry(firstSnapshotKey, Assets.empty()));
    } else if (filteredSnapshotEntries.isEmpty) {
      // should be unreachable
      // we forced users to add an asset for the start
      // they should have at least 1 snapshot
    }

    // set start and end snapshot content, they will be useful later
    _startSnapshotContent = filteredSnapshotEntries.first.value;
    _endSnapshotContent = filteredSnapshotEntries.last.value;

    _filteredSnapshots = SnapshotMap.fromEntries(filteredSnapshotEntries);
  }

  Tuple2<String, String> get dateRange => _dateRange.value;

  // this is in yyyy-MM-dd-hh format
  set dateRange(Tuple2<String, String> range) {
    _dateRange.value = range;
  }

  void _setDataPointsOfAllAssets() {
    _dataPointsOfAllAssets.clear();
    for (Assets userAssetsData in _filteredSnapshots.values) {
      _dataPointsOfAllAssets.add(userAssetsData.totalSumOfAssets());
    }
  }

  List<double> get dataPointsOfAllAssets => _dataPointsOfAllAssets.toList();

  void _setDataPointsPerCategory() {
    _dataPointsPerCategory.clear();

    for (Assets assets in _filteredSnapshots.values) {
      Map<Category, double> categorySums = assets.sumPerCategory(_categoryMap);

      for (Category category in _categoryMap.keys) {
        // if that category is not yet created in `_dataPointsPerCategory`
        if (!_dataPointsPerCategory.containsKey(category)) {
          // create it
          _dataPointsPerCategory[category] = <double>[];
        }
        // then append the list with the category sum
        // user might have sold all assets in the category after some time
        // for that case, we insert `0` to the data points
        _dataPointsPerCategory[category]!.add(categorySums[category] ?? 0.0);
      }
    }

    // handle the edge case
    // if there is only 1 item, prepend `0.0` to the list
    // to have the first value of `0.0` instead of having a single value,
    // for the plot generation
    for (Category category in _dataPointsPerCategory.keys) {
      if (_dataPointsPerCategory[category]!.length == 1) {
        _dataPointsPerCategory[category]!.insert(0, 0.0);
      }
    }
  }

  Map<Category, List<double>> get dataPointsPerCategory =>
      _dataPointsPerCategory.toJson();

  double get totalDeposits => _report.value.netDeposit;

  double get totalSumOfAssets => _report.value.endValue;

  double get totalAssetsProfit => _report.value.profit;

  double get totalAssetsRateChange => _report.value.rateChange;

  double categoryTotalDeposits(Category category) =>
      _report.value.categories[category]!.netDeposit;

  double categoryTotalSumOfAssets(Category category) =>
      _report.value.categories[category]!.endValue;

  double categoryTotalAssetsProfit(Category category) =>
      _report.value.categories[category]!.profit;

  double categoryTotalAssetsRateChange(Category category) =>
      _report.value.categories[category]!.rateChange;

  Map<Category, double> get sumPerCategory {
    return _report.value.categories
        .map((key, categoryReport) => MapEntry(key, categoryReport.endValue));
  }

  Map<Category, double> get profitPerCategory {
    return _report.value.categories
        .map((key, categoryReport) => MapEntry(key, categoryReport.profit));
  }

  Map<Category, double> get rateChangePerCategory {
    return _report.value.categories
        .map((key, categoryReport) => MapEntry(key, categoryReport.rateChange));
  }

  void _fillReport() {
    // 1. by iterating over snapshots, fill the assets `startValue` field.
    // And, fill the `withdraw`, and `deposit` fields for assets, categories, and the report
    List<MapEntry<String, Assets>> filteredSnapshotList =
        _filteredSnapshots.entries.toList();

    // filteredSnapshotList.length - 1 ->
    // because we are looking at `nextSnapshots` in each iteration
    for (int i = 0; i < filteredSnapshotList.length - 1; i++) {
      MapEntry<String, Assets> currentSnapshot = filteredSnapshotList[i];
      MapEntry<String, Assets> nextSnapshot = filteredSnapshotList[i + 1];

      // For each category, get the assets of the snapshots:
      for (Category category in _categoryMap.keys) {
        Map<AssetUid, Asset> currentAssets = {};
        Map<AssetUid, Asset> nextAssets = {};

        for (AssetUid assetUid in _categoryMap[category]!) {
          Asset? asset =
              currentSnapshot.value.typeMap[assetUid.item1]?[assetUid.item2];
          if (asset != null) {
            currentAssets[assetUid] = asset;
          }
          asset = nextSnapshot.value.typeMap[assetUid.item1]?[assetUid.item2];
          if (asset != null) {
            nextAssets[assetUid] = asset;
          }
        }

        // Union set of asset keys
        Set<AssetUid> allAssetKeys = {
          ...currentAssets.keys,
          ...nextAssets.keys
        };

        for (AssetUid assetUid in allAssetKeys) {
          Asset? currentAssetData = currentAssets[assetUid];
          Asset? nextAssetData = nextAssets[assetUid];

          CategoryReport categoryReport = _report.value.categories.putIfAbsent(
            category,
            () => CategoryReport(
                endValue: 0,
                startValue: 0,
                deposit: 0,
                withdrawal: 0,
                assets: {}),
          );

          // the assets in the first snapshot, we take them as startValue, not deposit.
          double startValue = (currentAssetData != null) && (i == 0)
              ? currentAssetData.value
              : 0;

          AssetReport assetReport = categoryReport.assets.putIfAbsent(
            assetUid,
            () => AssetReport(
              endValue: 0,
              amount: 0,
              startValue: startValue,
              deposit: 0,
              withdrawal: 0,
            ),
          );

          // we set `endValue` and `amount` later
          if (assetUid.item2 == 'link' || assetUid.item2 == 'chainlink') {
            print("price: ${currentAssetData!.price}, for i: $i");
          }

          // Calculate the deposit/withdrawal for each asset, category, and report
          double amountDiff;
          double priceDiff;
          if (nextAssetData == null) {
            // means, we have sold this completely
            amountDiff = -currentAssetData!.amount;
            priceDiff = -amountDiff * currentAssetData.price;
            assetReport.withdrawal += priceDiff;
            categoryReport.withdrawal += priceDiff;
            _report.value.withdrawal += priceDiff;
          } else if (currentAssetData == null) {
            // means, we have bought this (new asset)
            amountDiff = nextAssetData.amount;
            priceDiff = amountDiff * nextAssetData.price;
            assetReport.deposit += priceDiff;
            categoryReport.deposit += priceDiff;
            _report.value.deposit += priceDiff;
          } else {
            // means the asset exists on both current and next
            amountDiff = nextAssetData.amount - currentAssetData.amount;

            if (amountDiff > 0) {
              // means we bought some more, so use endAssetPrice
              priceDiff = amountDiff * nextAssetData.price;
              assetReport.deposit += priceDiff;
              categoryReport.deposit += priceDiff;
              _report.value.deposit += priceDiff;
            } else {
              // means we sold some, so use startAssetPrice
              priceDiff = -amountDiff * currentAssetData.price;
              assetReport.withdrawal += priceDiff;
              categoryReport.withdrawal += priceDiff;
              _report.value.withdrawal += priceDiff;
            }
          }
        }
      }
    }

    // 2. fill the `startValue` and `endValue` fields of each category and the report
    for (Category category in _report.value.categories.keys) {
      // get the assets for each category, within `start` and `end` snapshot's assets
      Map<AssetUid, Asset> endAssets = {};
      Map<AssetUid, Asset> startAssets = {};
      for (AssetUid assetUid in _categoryMap[category]!) {
        Asset? asset =
            _endSnapshotContent.typeMap[assetUid.item1]?[assetUid.item2];

        if (asset != null) {
          endAssets[assetUid] = asset;
        }

        asset = _startSnapshotContent.typeMap[assetUid.item1]?[assetUid.item2];

        if (asset != null) {
          startAssets[assetUid] = asset;
        }
      }

      _report.value.categories[category]!.startValue = startAssets.values
          .fold<double>(0.0, (sum, asset) => sum + asset.value);

      _report.value.categories[category]!.endValue =
          endAssets.values.fold<double>(0.0, (sum, asset) => sum + asset.value);

      // we don't need `endValue` and `amount` for sold Assets, so leaving them as `0` is fine
      for (MapEntry<AssetUid, Asset> asset in endAssets.entries) {
        _report.value.categories[category]!.assets[asset.key]!.endValue =
            asset.value.value;
        _report.value.categories[category]!.assets[asset.key]!.amount =
            asset.value.amount;
      }

      // Add the category's `startValue` and `endValue` to `report`
      _report.value.startValue +=
          _report.value.categories[category]!.startValue;

      _report.value.endValue += _report.value.categories[category]!.endValue;
    }

    // now we have filled every field necessary in our classes!
  }

  void _setSoldAssets() {
    _soldAssets.value = _snapshotsController
        .getLastSnapshot()!
        .typeMap
        .entries
        .expand((typeEntry) => typeEntry.value.entries
                .where((assetEntry) => assetEntry.value.amount == 0)
                .map((assetEntry) {
              AssetType assetType = typeEntry.key;
              AssetId assetId = assetEntry.key;
              Category category = assetEntry.value.category;
              AssetReport assetReport = _report.value.categories[category]!
                  .assets[AssetUid(assetType, assetId)]!;

              return AssetItem(assetId, assetReport, category, assetType);
            }))
        .toList();

    _report.value.categories.entries
        .where((categoryEntry) => categoryEntry.key == 'crypto')
        .forEach((categoryEntry) {
      categoryEntry.value.assets.entries
          .where((assetEntry) =>
              assetEntry.key.item2 == 'chainlink' ||
              assetEntry.key.item2 == 'link')
          .forEach((assetEntry) {
        print("start value: ${assetEntry.value.startValue}");
        print("end value: ${assetEntry.value.endValue}");
        print("deposit: ${assetEntry.value.deposit}");
        print("withdrawal: ${assetEntry.value.withdrawal}");
        print("net deposit: ${assetEntry.value.netDeposit}");
        print("profit: ${assetEntry.value.profit}");
        print("rate change: ${assetEntry.value.rateChange}");
      });
    });
  }

  void _calculateTopGainers() {
    List<AssetItem> assets = _report.value.categories.entries
        .expand((categoryEntry) =>
            categoryEntry.value.assets.entries.map((assetEntry) {
              return AssetItem(
                assetEntry.key.item2,
                assetEntry.value,
                categoryEntry.key,
                assetEntry.key.item1,
              );
            }))
        .toList();

    // Sort the assets by rate change
    assets.sort((a, b) {
      // Compare rate change in descending order
      return b.report.rateChange.compareTo(a.report.rateChange);
    });

    _topGainers.value = assets;
  }

  List<AssetItem> get topGainers => _topGainers
      .where((element) =>
          element.report.rateChange.isGreaterThan(0) &&
          element.report.amount > 0)
      .take(5)
      .toList();

  List<AssetItem> get topLosers => _topGainers.reversed
      .where((element) =>
          element.report.rateChange.isNegative && element.report.amount > 0)
      .take(5)
      .toList();

  List<AssetItem> get soldAssets => _soldAssets.toList();

  List<AssetItem> categoryAssets(Category category) {
    return _report.value.categories[category]!.assets.entries
        .where((assetEntry) => assetEntry.value.amount > 0)
        .map((assetEntry) => AssetItem(
              assetEntry.key.item2,
              assetEntry.value,
              category,
              assetEntry.key.item1,
            ))
        .toList();
  }
}
