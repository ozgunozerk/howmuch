import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:how_much/controllers/edit_assets/new_asset.dart';
import 'package:how_much/controllers/fetch/price_tables_controller.dart';
import 'package:how_much/controllers/user_assets_controller.dart';
import 'package:how_much/custom_types.dart';
import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/presentation/widgets/buttons/dropdown_menu_button.dart';
import 'package:how_much/presentation/widgets/buttons/primary_secondary.dart';
import 'package:how_much/presentation/widgets/search/search_text_with_suggestions.dart';
import 'package:how_much/util/helper_funcs.dart';

class AddNewAsset extends StatelessWidget {
  const AddNewAsset({super.key});

  @override
  Widget build(BuildContext context) {
    final addNewAssetController = Get.find<AddNewAssetController>();
    final priceTableController = Get.find<PriceTablesController>();
    final userAssetsController = Get.find<UserAssetsController>();

    Widget assetTypeSelector() {
      return DropdownMenuButton(
        text: addNewAssetController.selectedType.name,
        textStyle: transactionInfoAssetTypeStyle,
        valueList: AssetType.values.map((e) => e.name).toList(),
        onSelect: (String? newValue) {
          addNewAssetController.selectedType =
              AssetTypeHelper.fromString(newValue!);
        },
      );
    }

    Widget assetSearchField() {
      return Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          border:
              Border.all(color: howDarkGrey, width: 0.5), // Adding border here
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0, right: 13, top: 8, bottom: 8),
              child: Icon(
                Ionicons.search,
                color: howDarkGrey,
                size: 18,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: SearchFieldWithSuggestions(
                  suggestionsCallback: (pattern) {
                    if (pattern.isEmpty) {
                      return [];
                    }
                    final assetType = addNewAssetController.selectedType;

                    List<String> assetFullNames =
                        addNewAssetController.assetsPerType.map((entry) {
                      if (assetType == AssetType.crypto) {
                        // Here, entry's value is a map
                        Map<String, String> innerMap = entry.value;
                        return '${innerMap['symbol']} - ${innerMap['name']}';
                      } else {
                        // Here, entry's value is a string
                        return '${entry.key} - ${entry.value}';
                      }
                    }).toList();

                    final returnList = assetFullNames.where((element) =>
                        element.toLowerCase().contains(pattern.toLowerCase()));

                    return returnList;
                  },
                  onSelectedCallback: (newValue) {
                    final assetType = addNewAssetController.selectedType;
                    final symbolAndName = newValue.split(' - ');

                    if (assetType == AssetType.crypto) {
                      // if crypto, we need to find the assets Id
                      final selectedEntry = addNewAssetController.assetsPerType
                          .firstWhere((entry) {
                        Map<String, String> innerMap = entry.value;
                        return innerMap['symbol'] == symbolAndName[0] &&
                            innerMap['name'] == symbolAndName[1];
                      });

                      addNewAssetController.selectedAssetId = selectedEntry.key;
                      addNewAssetController.selectedAssetSymbol =
                          selectedEntry.value['symbol'];
                      addNewAssetController.selectedAssetName =
                          selectedEntry.value['name'];
                    } else {
                      // if not crypto, we have everything we need
                      addNewAssetController.selectedAssetId = symbolAndName[0];
                      addNewAssetController.selectedAssetName =
                          symbolAndName[1];
                      // symbol is the same with id (except crypto)
                      addNewAssetController.selectedAssetSymbol =
                          symbolAndName[0];
                    }

                    addNewAssetController.price.value =
                        priceTableController.getPriceForAsset(
                            assetType, addNewAssetController.selectedAssetId)!;
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget enterAmount() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Obx(() => ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 24),
                child: IntrinsicWidth(
                  child: TextField(
                    controller: addNewAssetController.amountTextController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      hintText: addNewAssetController.amount.value != 0.0
                          ? "" // empty hintText if field is not empty
                          : "enter the amount",
                      hintStyle: transactionInfoHintStyle,
                      border: InputBorder.none,
                    ),
                    style: transactionInfoTextStyle,
                  ),
                ),
              )),
          const Padding(padding: EdgeInsets.only(left: 4)),
          Obx(() => Text(
                addNewAssetController.selectedAssetSymbol,
                style: transactionInfoCurrencySymbolStyle,
              )),
          const Spacer(), // Added Spacer widget
          Obx(() => Text(
                addNewAssetController.selectedAssetValue,
                style: transactionInfoCurrencySymbolStyle,
              )),
        ],
      );
    }

    Widget enterCategory() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          categoryInput(addNewAssetController.categoryTextController,
              userAssetsController, false)
        ],
      );
    }

    void showInfoDialog() {
      Get.dialog(
        Dialog(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            width: 320.0, // Adjust the width as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Submit New Asset",
                  style: heading2TextStyle,
                ),
                const SizedBox(height: 32.0),
                RichText(
                  text: TextSpan(
                    text:
                        "You can submit an issue for the missing asset. If it is supported by the API, I will add it ASAP. \n\nTo submit an issue, visit: ",
                    style: dialogInfoStyle,
                    children: [
                      TextSpan(
                        text: "HowMuch",
                        style: linkTextStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(
                                'https://github.com/ozgunozerk/howmuch/issues'));
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32.0),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget requestNewAsset() {
      return GestureDetector(
        onTap: () {
          showInfoDialog();
        },
        child: const Text("Couldn't find your asset?", style: linkTextStyle),
      );
    }

    Widget divider() {
      return Container(
        height: 0.5,
        decoration: BoxDecoration(
            color: howLightGrey, borderRadius: BorderRadius.circular(10.0)),
      );
    }

    return Center(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.center,
            child: Text(
              "Add New Asset",
              style: transactionInfoTitleStyle,
            ),
          ),
          const Padding(padding: EdgeInsets.all(4)),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.all(14)),
                  const Text("Asset Type", style: transactionInfoHeaderStyle),
                  const Padding(padding: EdgeInsets.all(2)),
                  Obx(() => assetTypeSelector()),

                  // 12 instead of 16, due to above Dropdown inner padding/margin
                  const Padding(padding: EdgeInsets.all(12)),
                  const Text("Search Asset", style: transactionInfoHeaderStyle),
                  const Padding(padding: EdgeInsets.all(2)),
                  assetSearchField(),

                  const Padding(padding: EdgeInsets.all(16)),
                  const Text("Amount", style: transactionInfoHeaderStyle),
                  const Padding(padding: EdgeInsets.all(2)),
                  enterAmount(),
                  divider(),

                  const Padding(padding: EdgeInsets.all(16)),
                  const Text("Category", style: transactionInfoHeaderStyle),
                  const Padding(padding: EdgeInsets.all(2)),
                  enterCategory(),
                  divider(),

                  const Padding(padding: EdgeInsets.all(16)),
                  requestNewAsset(),
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(32)),
          Obx(() => Align(
                alignment: Alignment.bottomCenter,
                child: PrimaryButton(
                    cta: "Done",
                    enabled: addNewAssetController.canProceed(),
                    onTap: () {
                      userAssetsController.addNewAsset(
                        addNewAssetController.selectedType,
                        addNewAssetController.selectedAssetId,
                        addNewAssetController.amount.value,
                        addNewAssetController.price.value,
                        addNewAssetController.selectedCategory,
                      );
                      addNewAssetController.resetValues();
                      Navigator.pop(context);
                    }),
              ))
        ],
      ),
    );
  }
}
