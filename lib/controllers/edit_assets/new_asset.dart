import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:how_much/custom_types.dart';
import 'package:how_much/controllers/fetch/asset_table_controller.dart';
import 'package:how_much/controllers/helpers/currency.dart';
import 'package:how_much/controllers/user_assets_controller.dart';

class AddNewAssetController extends GetxController {
  final _selectedAssetId = "".obs;
  final _selectedAssetName = "".obs;
  final _selectedAssetSymbol =
      "".obs; // ID and symbol are the same, except for crypto assets
  final _selectedType = AssetType.crypto.obs;
  final _selectedCategory = "crypto".obs;
  final RxMap<String, dynamic> _assetsPerType = RxMap<String,
      dynamic>(); // required for auto-completion when entering new asset
  final amount = 0.0.obs;
  final _selectedAssetValue = "".obs;
  final price = 0.0.obs;

  final TextEditingController amountTextController = TextEditingController();
  final TextEditingController categoryTextController = TextEditingController();
  final AssetTableController assetTableController =
      Get.find<AssetTableController>();
  final UserAssetsController userAssetsController =
      Get.find<UserAssetsController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();

  AddNewAssetController() {
    // Listen for changes in the text fields and update them accordingly
    amountTextController.addListener(() {
      double? parsedAmount =
          double.tryParse(amountTextController.text.replaceAll(',', '.'));
      amount.value = parsedAmount ?? 0.0;
      updateSelectedAssetValue();
    });

    categoryTextController.addListener(() {
      _selectedCategory.value = categoryTextController.text;
    });

    // Listen for changes in selectedAssetId
    _selectedAssetId.listen((_) {
      updateSelectedAssetValue();
    });
  }

  @override
  void onInit() {
    super.onInit();
    categoryTextController.text = _selectedType.value.name;
    _assetsPerType.value =
        assetTableController.getAssetsPerType(AssetType.crypto);
  }

  String get selectedAssetName {
    return _selectedAssetName.value;
  }

  set selectedAssetName(String newValue) {
    _selectedAssetName.value = newValue;
  }

  String get selectedAssetId {
    return _selectedAssetId.value;
  }

  set selectedAssetId(String newValue) {
    _selectedAssetId.value = newValue;
  }

  String get selectedAssetSymbol {
    return _selectedAssetSymbol.value;
  }

  // Recalculate selected asset value
  void updateSelectedAssetValue() {
    if (_selectedAssetId.isNotEmpty && amount.value > 0) {
      double value = price * amount.value;
      _selectedAssetValue.value =
          currencyController.displayCurrencyWithoutSign(value);
    } else {
      _selectedAssetValue.value = "";
    }
  }

  String get selectedAssetValue => _selectedAssetValue.value;

  set selectedAssetSymbol(String newValue) {
    _selectedAssetSymbol.value = newValue;
  }

  AssetType get selectedType {
    return _selectedType.value;
  }

  set selectedType(AssetType newValue) {
    _selectedType.value = newValue;
    categoryTextController.text = newValue
        .name; // when text updates, _selectedCategory is also updated due to listener

    // new type selection should reset every other value
    _selectedAssetId.value = "";
    _selectedAssetName.value = "";
    _selectedAssetSymbol.value = "";
    amountTextController.text =
        ""; // when text updates, amount is also updated due to listener

    // update the assets list for this new assetType
    _assetsPerType.value = assetTableController.getAssetsPerType(newValue);
  }

  Category get selectedCategory {
    return _selectedCategory.value;
  }

  set selectedCategory(Category category) {
    _selectedCategory.value = category;
  }

  Iterable<MapEntry<String, dynamic>> get assetsPerType {
    return _assetsPerType.entries;
  }

  bool canProceed() {
    final selectedAssetIsNotEmpty = _selectedAssetId.value != "";
    final selectedCategoryIsNotEmpty = _selectedCategory.value != "";
    final amountIsPositive = amount > 0;

    final value = selectedAssetIsNotEmpty &&
        selectedCategoryIsNotEmpty &&
        amountIsPositive;

    return value;
  }

  void resetValues() {
    _selectedAssetName.value = "";
    _selectedAssetId.value = "";
    _selectedAssetSymbol.value = "";
    // don't reset selected category and type

    amount.value = 0.0;
    price.value = 0.0;
    amountTextController.text = "";
  }

  @override
  void dispose() {
    amountTextController.dispose();
    categoryTextController.dispose();
    super.dispose();
  }
}
