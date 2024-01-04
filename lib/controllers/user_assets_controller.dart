import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart' as foundation;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

import 'package:how_much/controllers/snapshots_controller.dart';
import 'package:how_much/custom_types.dart';
import 'package:how_much/util/firebase_init.dart';
import 'package:how_much/util/helper_funcs.dart';

class UserAssetsController extends GetxController {
  final SnapshotsController _snapshotsController =
      Get.find<SnapshotsController>();

  final _firebaseService = FirebaseService();

  final _userAssets = UserAssets.empty().obs;
  final _transactions = Transactions.empty().obs;
  CategoryMap _oldCategories = {};
  final _isThereAnyCategoryChange = false.obs;

  final _categoryNameValid = false.obs;

  final loading = true.obs;

  @override
  void onInit() async {
    super.onInit();

    // Check if already not loading
    if (_snapshotsController.loading.value) {
      // Wait until _snapshotsController.loading becomes false
      await _snapshotsController.loading.stream
          .firstWhere((isLoading) => isLoading == false);
    }

    final UserAssets? maybeCachedUserAssets = await _loadUserAssetsFromDevice();

    final maybeLastSnapshot = _snapshotsController.getLastSnapshot();

    if (maybeCachedUserAssets != null) {
      // if we can find a cached `UserAssets` instance, use it
      _userAssets.value = maybeCachedUserAssets;
      _oldCategories = cloneCategoryMap(_userAssets.value.categoryMap);
    } else if (maybeLastSnapshot != null) {
      // it could be that user has transactions in the server, but this device is new,
      // in that case, set the user assets to the content of the last snapshot
      // with default categories

      // get the last snapshots content
      Assets assets = maybeLastSnapshot.clone();

      // create a categoryMap that consists of default values
      CategoryMap categoryMap = {};
      assets.typeMap.forEach((assetType, assetMap) {
        categoryMap[assetType.name] = {};
        assetMap.forEach((assetId, _) {
          categoryMap[assetType.name]!.add(Tuple2(assetType, assetId));
        });
      });

      // set the user assets
      _userAssets.value = UserAssets(assets: assets, categoryMap: categoryMap);
      _oldCategories = cloneCategoryMap(_userAssets.value.categoryMap);
    } else {
      // means we are facing with a new user, don't do anything
    }
    loading.value = false;
  }

  bool get categoryNameValid => _categoryNameValid.value;

  set categoryNameValid(newValue) => _categoryNameValid.value = newValue;

  updateAssetAmount(
      Category category, AssetType assetType, String assetId, double amount) {
    _userAssets.update((userAssets) {
      userAssets!.updateAssetAmount(category, assetType, assetId, amount);
    });
    _transactions.update((transactions) {
      transactions!.addTransaction(assetType, assetId, amount);
    });
  }

  changeAssetCategory(
    String assetId,
    AssetType assetType,
    Category oldCategory,
    Category newCategory,
  ) {
    _userAssets.update((userAssets) {
      userAssets!
          .changeAssetCategory(oldCategory, assetId, assetType, newCategory);
    });
    _isThereAnyCategoryChange.value = true;
  }

  addCategory(Category category) {
    _userAssets.update((userAssets) {
      userAssets!.addNewCategory(category.toLowerCase());
    });
    _isThereAnyCategoryChange.value = true;
  }

  updateCategoryName(Category oldCategory, Category newCategory) {
    _userAssets.update((userAssets) {
      userAssets!.updateCategoryName(oldCategory, newCategory.toLowerCase());
    });
    _isThereAnyCategoryChange.value = true;
  }

  addNewAsset(AssetType assetType, String assetId, double amount, double price,
      Category category) {
    _userAssets.update((userAssets) {
      userAssets!.addNewAsset(assetId, amount, price, assetType, category);
    });
    _transactions.update((transactions) {
      transactions!.addTransaction(assetType, assetId, amount);
    });
  }

  deleteAsset(Category category, AssetType assetType, AssetId assetId) {
    double previousAmount =
        _userAssets.value.assets.typeMap[assetType]![assetId]!.amount;

    try {
      // if asset exists in previous snapshot, don't delete it, but only make it's amount 0
      DateTime now = DateTime.now();
      DateTime nowUTC = now.subtract(now.timeZoneOffset);
      String prevSnapshotDateUtc = getPreviousUpdateTime(nowUTC);

      _snapshotsController.snapshots.snapshotMap[prevSnapshotDateUtc]!
          .typeMap[assetType]![assetId]!;
      _userAssets.update((userAssets) {
        userAssets!.assets.typeMap[assetType]![assetId]!.amount = 0;
      });
    } catch (_) {
      // if asset does not exist in previous snapshot,
      // then it is safe to literally delete this asset
      _userAssets.update((userAssets) {
        userAssets!.assets.typeMap[assetType]!.remove(assetId);
        userAssets.categoryMap[category]!.remove(Tuple2(assetType, assetId));
      });
    }

    /*
    1. asset exists in previous snapshot, and we deleted the asset (made the amount 0):
      - we should send a transaction with `-amount` of change for this asset
    2. asset does not exist in previous snapshot, but present in the user assets.
      2.a: asset was added recently, and haven't sent to server yet (in the uncommitted transactions)
          - we should send a transaction with `-amount` of change for this asset,
            that will cancel the previous transaction, and everything will be fine
      2.b: asset was added recently, and sent to server as a transaction (committed),
           but we haven't took a snapshot of it yet
          - we should send a transaction with `-amount` of change for this asset,
            when we fetch the transactions from the server and process them, client will do the necessary pruning
     outcome: we should send a transaction with `-amount` of change for this asset in every case
     */
    _transactions.update((transactions) {
      transactions!.addTransaction(assetType, assetId, -previousAmount);
    });
  }

  bool assetExists(AssetType assetType, AssetId assetId) {
    return _userAssets.value.checkIfAssetExists(assetType, assetId);
  }

  bool isThereAnyAsset() => _userAssets.value.assets.typeMap.isNotEmpty;

  bool _isThereAnyTransaction() => _transactions.value.transactions.isNotEmpty;

  bool isThereAnyChange() =>
      _isThereAnyTransaction() || _isThereAnyCategoryChange.value;

  Future<void> saveAssets() async {
    if (_isThereAnyTransaction()) {
      final HttpsCallable callable =
          _firebaseService.functions.httpsCallable('addTransactions');
      try {
        await callable.call(_transactions.value.toMap());
      } catch (e) {
        showErrorDialog("Couldn't send transaction to server", "$e");
        return;
      }

      // Update snapshots controller
      String nextSnapshotDateUtc = getNextUpdateTime();
      LinkedHashMap<String, Assets> snapshotsMap =
          _snapshotsController.snapshots.snapshotMap;
      if (snapshotsMap.containsKey(nextSnapshotDateUtc)) {
        snapshotsMap[nextSnapshotDateUtc] = _userAssets.value.assets.clone();
      } else {
        snapshotsMap[nextSnapshotDateUtc] = _userAssets.value.assets.clone();
        _snapshotsController.setLastSnapshotDate();
        await _snapshotsController.storeSnapshotsOnDevice();
      }
    }

    if (isThereAnyChange()) {
      // applying category updates even when there are only transaction changes
      // is not harmful, and `isThereAnyChange` check eliminates code duplication
      // and extra checks for differentiating between category and transaction changes

      _userAssets.value.pruneEmptyCategoriesOnSave();
      _oldCategories = cloneCategoryMap(_userAssets.value.categoryMap);
      _isThereAnyCategoryChange.value = false;
      _transactions.value = Transactions.empty();
      await _saveUserAssetsToDevice(_userAssets.value);
    }
  }

  discardChanges() {
    _userAssets.value.categoryMap = cloneCategoryMap(_oldCategories);
    _isThereAnyCategoryChange.value = false;
    _transactions.value = Transactions.empty();
    _userAssets.value.assets = _snapshotsController.getLastSnapshot()!.clone();
  }

  Assets get userAssets => _userAssets.value.assets;

  CategoryMap get categoryMap => _userAssets.value.categoryMap;

  Set<Category> get categorySet => _userAssets.value.categorySet;

  Map<Category, Map<AssetUid, Asset>> get categoryAssetMap {
    Map<Category, Map<AssetUid, Asset>> categoryMappings = {};
    for (MapEntry<String, Set<Tuple2<AssetType, String>>> entry
        in _userAssets.value.categoryMap.entries) {
      categoryMappings.putIfAbsent(entry.key, () => {});
      for (Tuple2<AssetType, String> assetUid in entry.value) {
        categoryMappings[entry.key]![assetUid] =
            _userAssets.value.assets.typeMap[assetUid.item1]![assetUid.item2]!;
      }
    }
    return categoryMappings;
  }

  Future<void> _saveUserAssetsToDevice(UserAssets data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userAssets', jsonEncode(data.toMap()));
  }

  Future<UserAssets?> _loadUserAssetsFromDevice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userAssetsJson = prefs.getString('userAssets');

    if (userAssetsJson != null) {
      try {
        return UserAssets.fromMap(jsonDecode(userAssetsJson));
      } catch (e) {
        if (foundation.kDebugMode) {
          // ignore: avoid_print
          print("could not parse user assets json from device, because: $e");
        }
      }
    }
    return null;
  }
}
