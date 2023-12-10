import 'dart:collection';

import 'package:how_much/util/parsing.dart';
import 'package:tuple/tuple.dart';

/// Each asset has a type, these are defined on server,
/// and let us have a hierarchy on the server side for grouping assets
enum AssetType { nasdaq, crypto, forex, bist }

extension AssetTypeHelper on AssetType {
  static AssetType fromString(String assetType) {
    switch (assetType) {
      case 'nasdaq':
        return AssetType.nasdaq;
      case 'crypto':
        return AssetType.crypto;
      case 'forex':
        return AssetType.forex;
      case 'bist':
        return AssetType.bist;
      default:
        throw ArgumentError('Asset type $assetType is not recognized.');
    }
  }
}

// for being more declarative :)
typedef AssetId = String;
typedef Category = String;
typedef AssetUid = Tuple2<AssetType, AssetId>;

/// maps categories to the assets along with their IDs and AssetTypes
typedef CategoryMap = Map<Category, Set<AssetUid>>;

/// maps types to the assets.
typedef TypeMap = Map<AssetType, Map<AssetId, Asset>>;

/// class for storing an asset in it's raw form (without the report data)
class Asset {
  /// represents the total amount of the asset
  double amount;

  /// price of the asset
  double price;

  /// to be able to reach the `Category` of the asset
  Category category;

  // we don't need to store `AssetType`, because asset's are stored w.r.t `AssetType` hierarchy
  // `AssetType` info should be deducible from the context

  Asset({
    required this.amount,
    required this.price,
    required this.category,
  });

  Asset clone() {
    return Asset(
      amount: amount,
      price: price,
      category: category,
    );
  }

  double get value => amount * price;

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      amount: (map['amount'] as num).toDouble(),
      price: (map['price'] as num).toDouble(),
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'price': price,
      'category': category,
    };
  }
}

/// `Assets` is meant to be read only `typeMap`, check `UserAssets` for editable and extended version
/// we need the readonly assets for reading the contents of the snapshots,
/// we need the editable assets for the current assets of the user
class Assets {
  TypeMap typeMap;

  Assets({
    required this.typeMap,
  });

  // to prevent shallow-copy on assignment, we need `clone`
  Assets clone() {
    return Assets(
      typeMap: typeMap.map((assetType, idAndAssetMap) {
        return MapEntry(
          assetType,
          idAndAssetMap.map((assetId, asset) {
            return MapEntry(assetId, asset.clone());
          }),
        );
      }),
    );
  }

  factory Assets.fromMap(Map<String, dynamic> mapObject) {
    TypeMap typeMap = mapObject.map((type, idAndAsset) {
      AssetType assetType = AssetTypeHelper.fromString(type);
      if (idAndAsset is! Map) {
        throw "incorrect inner type for idAndAsset";
      }
      return MapEntry(
          assetType,
          Map<String, dynamic>.from(idAndAsset).map((assetId, asset) {
            if (asset is! Map) {
              throw 'asset should have been a map';
            }
            return MapEntry(
                assetId, Asset.fromMap(Map<String, dynamic>.from(asset)));
          }));
    });

    return Assets(
      typeMap: typeMap,
    );
  }

  Map<String, Map<String, dynamic>> toMap() {
    Map<String, Map<String, dynamic>> mapObject = typeMap.map(
        (assetType, idAndAsset) => MapEntry(
            assetType.name,
            idAndAsset
                .map((assetId, asset) => MapEntry(assetId, asset.toMap()))));

    return mapObject;
  }

  Assets.empty() : typeMap = {};

  double totalSumOfAssets() {
    return typeMap.values
        .expand((element) => element.values)
        .fold(0, (double sum, Asset asset) => sum + asset.value);
  }

  Map<Category, double> sumPerCategory(CategoryMap categoryMap) {
    return categoryMap.map((category, assets) => MapEntry(
        category,
        assets.fold(0, (sum, asset) {
          double assetValue = typeMap[asset.item1]?[asset.item2]?.value ?? 0;
          return sum + assetValue;
        })));
  }
}

/// `UserAsset` is the editable and extended version of read-only `Assets`,
/// we need the readonly assets for reading the contents of the snapshots,
/// we need the editable assets for the current assets of the user
class UserAssets {
  Assets assets;
  CategoryMap categoryMap;

  UserAssets({required this.assets, required this.categoryMap});

  // to prevent shallow-copy on assignment, we need `clone`
  UserAssets clone() {
    return UserAssets(
      categoryMap: categoryMap.map(
        (category, assetUid) => MapEntry(category, {...assetUid}),
      ),
      assets: assets.clone(),
    );
  }

  factory UserAssets.fromMap(Map<String, dynamic> mapObject) {
    Map<String, dynamic> typeMap =
        Map<String, dynamic>.from(mapObject['typeMap']);

    Assets assets = Assets.fromMap(typeMap);

    CategoryMap categoryMap =
        CategoryMap.from(mapObject['categoryMap'].map((category, assetUidList) {
      if (assetUidList is! List) {
        throw "assetUidList is not a List";
      }
      Set<AssetUid> assetUidSet = assetUidList.map((assetEntry) {
        if (assetEntry is! Map) {
          throw "assetEntry is not a Map";
        }
        AssetType assetType = AssetTypeHelper.fromString(assetEntry.keys.first);
        AssetId assetId = assetEntry.values.first;
        return AssetUid(assetType, assetId);
      }).toSet();
      return MapEntry(category, assetUidSet);
    }));

    return UserAssets(assets: assets, categoryMap: categoryMap);
  }

  Map<String, dynamic> toMap() {
    Map<String, Map<String, dynamic>> typeMap = assets.toMap();

    Map<String, List<Map<String, String>>> categoryMap =
        this.categoryMap.map((category, assetUidSet) => MapEntry(
              category,
              assetUidSet
                  .map((assetUid) => {assetUid.item1.name: assetUid.item2})
                  .toList(),
            ));

    return {
      'typeMap': typeMap,
      'categoryMap': categoryMap,
    };
  }

  UserAssets.empty()
      : categoryMap = {},
        assets = Assets.empty();

  addNewAsset(AssetId assetId, double amount, double price, AssetType assetType,
      Category category) {
    assets.typeMap.putIfAbsent(assetType, () => {});
    categoryMap.putIfAbsent(category, () => {});

    if (assets.typeMap[assetType]!.containsKey(assetId)) {
      final asset = assets.typeMap[assetType]![assetId]!;
      asset.amount += amount;
      final oldCategory = asset.category;
      if (oldCategory != category) {
        changeAssetCategory(oldCategory, assetId, assetType, category);
      }
    } else {
      categoryMap[category]!.add(AssetUid(assetType, assetId));
      assets.typeMap[assetType]![assetId] =
          Asset(amount: amount, price: price, category: category);
    }
  }

  changeAssetCategory(Category oldCategory, AssetId assetId,
      AssetType assetType, Category newCategory) {
    _assetShouldExist(oldCategory, assetType, assetId, "change category");

    // remove the asset from old category and retrieve it
    categoryMap[oldCategory]!.remove(AssetUid(assetType, assetId));

    // add the asset to new category
    categoryMap.putIfAbsent(newCategory, () => {});
    categoryMap[newCategory]!.add(AssetUid(assetType, assetId));
  }

  bool checkIfCategoryExists(Category category) {
    return categoryMap.containsKey(category);
  }

  addNewCategory(Category category) {
    if (categoryMap.containsKey(category)) {
      throw 'Category $category already exists in the map!';
    }
    categoryMap[category] = {};
  }

  updateCategoryName(Category oldCategory, Category newCategory) {
    Set<AssetUid>? assetsToUpdate = categoryMap[oldCategory];

    if (assetsToUpdate != null) {
      categoryMap[newCategory] = assetsToUpdate;
      categoryMap.remove(oldCategory);
    }
  }

  pruneEmptyCategoriesOnSave() {
    categoryMap.removeWhere((key, value) => value.isEmpty);
  }

  updateAssetAmount(
      Category category, AssetType assetType, AssetId assetId, double amount) {
    _assetShouldExist(category, assetType, assetId, "update asset");

    assets.typeMap[assetType]![assetId]!.amount += amount;
  }

  _assetShouldExist(Category category, AssetType assetType, AssetId assetId,
      String operationName) {
    if (!categoryMap.containsKey(category)) {
      throw "Category ($category) does not exist! Operation: $operationName";
    }
    if (!categoryMap[category]!.contains(AssetUid(assetType, assetId))) {
      throw "Trying to find asset ($assetId)($assetType) in category ($category), but it does not exist! Operation: $operationName";
    }

    if (!assets.typeMap.containsKey(assetType)) {
      throw "Asset Type ($assetType) does not exist! Operation: $operationName";
    }
    if (!assets.typeMap[assetType]!.containsKey(assetId)) {
      throw "Trying to find asset ($assetId)($assetType) in typeMap, but it does not exist! Operation: $operationName";
    }
  }

  // necessary for checking the selected asset is unique or not
  // when user is selecting an asset to add, we prevent him from proceeding
  // if the selected asset is not unique
  bool checkIfAssetExists(AssetType assetType, AssetId assetId) {
    return categoryMap.values
        .any((value) => value.contains(AssetUid(assetType, assetId)));
  }

  Set<Category> get categorySet {
    return categoryMap.keys.toSet();
  }
}

/// type for storing snapshots as a Map
typedef SnapshotMap = LinkedHashMap<SnapshotDate, Assets>;

// for being more declarative :)
typedef SnapshotDate = String;

class Snapshots {
  SnapshotMap snapshotMap;

  Snapshots({required this.snapshotMap});

  // ignore: prefer_collection_literals
  Snapshots.empty() : snapshotMap = LinkedHashMap<SnapshotDate, Assets>();

  Iterable<SnapshotDate> getNonFinalizedSnapshotDates(
      DateTime? lastFinalizedDateUTC) {
    if (lastFinalizedDateUTC != null) {
      return snapshotMap.keys.where((dateString) =>
          parseDateWithHour(dateString)
              .difference(lastFinalizedDateUTC)
              .inHours >
          0);
    } else {
      // we don't have a finalized snapshot, return them all
      return snapshotMap.keys;
    }
  }

  factory Snapshots.fromMap(Map<String, dynamic> mapObject) {
    List<String> sortedKeys = mapObject.keys.toList(growable: false)..sort();

    LinkedHashMap<String, dynamic> sortedData = LinkedHashMap.fromIterable(
      sortedKeys,
      key: (k) => k,
      value: (v) => mapObject[v],
    );

    SnapshotMap snapshotMap = SnapshotMap.from(
      sortedData.map((date, assets) {
        if (assets is! Map) {
          throw 'incorrect type';
        }
        return MapEntry(
            date, Assets.fromMap(Map<String, dynamic>.from(assets)));
      }),
    );

    return Snapshots(snapshotMap: snapshotMap);
  }

  Map<String, dynamic> toMap() {
    return snapshotMap.map(
      (date, assets) => MapEntry(
        date,
        assets.toMap(),
      ),
    );
  }
}

/// interface for 3 report types (high-level, category-level, asset-level)
abstract class ReportBase {
  double endValue;
  double startValue;
  double deposit;
  double withdrawal;

  ReportBase({
    required this.endValue,
    required this.startValue,
    required this.deposit,
    required this.withdrawal,
  });

  double get profit => endValue - startValue + withdrawal - deposit;

  double get netDeposit => deposit - withdrawal;

  double get rateChange => profit / (deposit + startValue) * 100;
}

class Report extends ReportBase {
  Map<Category, CategoryReport> categories;

  Report({
    required super.endValue,
    required super.startValue,
    required super.deposit,
    required super.withdrawal,
    required this.categories,
  });

  Report.empty()
      : categories = {},
        super(endValue: 0, startValue: 0, deposit: 0, withdrawal: 0);
}

class CategoryReport extends ReportBase {
  Map<AssetUid, AssetReport> assets;

  CategoryReport({
    required super.endValue,
    required super.startValue,
    required super.deposit,
    required super.withdrawal,
    required this.assets,
  });
}

class AssetReport extends ReportBase {
  double amount;

  AssetReport({
    required this.amount,
    required super.endValue,
    required super.startValue,
    required super.deposit,
    required super.withdrawal,
  });
}

/// another class for `Asset`, that includes the `report` as well,
/// and thus, allows us to order them w.r.t their profit, etc.
class AssetItem {
  final AssetId assetId;
  final AssetReport report;
  final Category category;
  final AssetType assetType;

  AssetItem(this.assetId, this.report, this.category, this.assetType);
}

/// class for storing assets as a map where `AssetType` is the key
/// this will be useful for fetching the asset list from the server
/// (used for auto-completion when user adds a new asset)
class AssetTable {
  final Map<AssetType, dynamic> data;

  AssetTable._(this.data);

  factory AssetTable() {
    return AssetTable._({});
  }

  factory AssetTable.fromMap(Map<String, dynamic> mapObject) {
    Map<AssetType, dynamic> data = mapObject.map((type, assetTableEntries) {
      AssetType assetType = AssetTypeHelper.fromString(type);

      if (assetTableEntries is! Map) {
        throw 'One of the values is not a map';
      }
      Map<String, dynamic> innerMap = {};
      assetTableEntries.forEach((assetId, assetValue) {
        if (assetId is String && (assetValue is String || assetValue is Map)) {
          innerMap[assetId] = assetValue;
        } else {
          throw 'One of the keys/values in the nested map is not a string';
        }
      });

      return MapEntry(assetType, innerMap);
    });

    return AssetTable._(data);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> mapObject = data.map((key, value) {
      return MapEntry(key.name, value);
    });

    return mapObject;
  }

  dynamic getData(AssetType assetType, AssetId id) {
    return data[assetType][id];
  }
}

typedef Price = double;

class PriceTableEntries {
  // since PriceTableEntries belong to an AssetType, `AssetId` becomes unique
  final Map<AssetId, double> entries;

  PriceTableEntries._(this.entries);

  factory PriceTableEntries.fromMap(Map<String, num> mapObject) {
    Map<AssetId, double> entries =
        mapObject.map((assetId, price) => MapEntry(assetId, price.toDouble()));

    return PriceTableEntries._(entries);
  }

  Map<String, num> toMap() {
    return entries;
  }
}

/// hierarchical data structure for storing asset's prices
class PriceTable {
  final Map<AssetType, PriceTableEntries> data;

  PriceTable._(this.data);

  factory PriceTable() {
    return PriceTable._({});
  }

  factory PriceTable.fromMap(Map<String, dynamic> mapObject) {
    Map<AssetType, PriceTableEntries> data =
        mapObject.map((type, priceTableEntriesMap) {
      AssetType assetType = AssetTypeHelper.fromString(type);
      PriceTableEntries entries = PriceTableEntries.fromMap(
          Map<String, num>.from(priceTableEntriesMap));

      return MapEntry(assetType, entries);
    });

    return PriceTable._(data);
  }

  Map<String, Map<String, num>> toMap() {
    Map<String, Map<String, num>> mapObject =
        data.map((assetType, priceTableEntries) {
      String typeString = assetType.name;
      return MapEntry(typeString, priceTableEntries.toMap());
    });

    return mapObject;
  }
}

// for being more declarative :)
typedef PriceTableDate = String;

/// type for storing snapshots as a Map
typedef PriceTableMap = LinkedHashMap<PriceTableDate, PriceTable>;

class PriceTables {
  PriceTableMap priceTableMap;

  PriceTables({required this.priceTableMap});

  PriceTables.empty()
      // ignore: prefer_collection_literals
      : priceTableMap = LinkedHashMap<PriceTableDate, PriceTable>();

  factory PriceTables.fromMap(Map<String, dynamic> mapObject) {
    List<String> sortedKeys = mapObject.keys.toList(growable: false)..sort();

    LinkedHashMap<String, dynamic> sortedData = LinkedHashMap.fromIterable(
      sortedKeys,
      key: (k) => k,
      value: (v) => mapObject[v],
    );

    PriceTableMap priceTableMap = PriceTableMap.from(
      sortedData.map((date, priceTable) {
        if (priceTable is! Map) {
          throw 'incorrect type';
        }
        return MapEntry(
            date, PriceTable.fromMap(Map<String, dynamic>.from(priceTable)));
      }),
    );

    return PriceTables(priceTableMap: priceTableMap);
  }

  Map<String, dynamic> toMap() {
    return priceTableMap.map(
      (date, priceTable) => MapEntry(
        date,
        priceTable.toMap(),
      ),
    );
  }
}

class Transactions {
  Map<AssetUid, dynamic> transactions;

  Transactions({
    required this.transactions,
  });

  Transactions.empty() : transactions = {};

  addTransaction(AssetType assetType, AssetId assetId, double amount) {
    transactions[Tuple2(assetType, assetId)] ??= {
      'amount': 0.0,
      'timestamp': "",
      // we will fill the timestamp in last second, because:
      // assume user made a transaction (uncommitted), then waited in the EditAsset page for hours,
      // then made another uncommitted transaction. If an update happens within that wait time,
      // the uncommitted transaction will not make sense, it had to happen before the update, yet it didn't
      // the timestamps should represent the time it is sent to the server, not the creation in the client-side.
    };

    double previousAmount = transactions[Tuple2(assetType, assetId)]['amount']!;
    double newAmount = previousAmount + amount;

    // Remove the entry if the new amount is zero
    if (newAmount == 0) {
      transactions.remove(Tuple2(assetType, assetId));
    } else {
      transactions[Tuple2(assetType, assetId)]!['amount'] = newAmount;
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> resultMap = {};

    transactions.forEach((assetUid, data) {
      String timestamp = DateTime.now().toUtc().toString();

      resultMap[timestamp] = {
        'assetType': assetUid.item1.name,
        'assetId': assetUid.item2,
        'amount': data['amount'],
      };
    });

    return resultMap;
  }

  // we won't have a `fromMap` method, since we will never store the fetched transactions.
  // parsing the transactions will require traversing all of them,
  // and while we are traversing them, we can process them
  // instead of creating a variable out of them.
  // After processing them, we don't need them anymore
  // so, `fromMap` will not benefit us.
}

enum BaseCurrency {
  // ignore: constant_identifier_names
  USD,
  // ignore: constant_identifier_names
  TRY,
  // ignore: constant_identifier_names
  EUR,
  // ignore: constant_identifier_names
  BTC,
}
