import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:how_much/controllers/edit_assets/edit_asset.dart';

import 'package:how_much/controllers/user_assets_controller.dart';
import 'package:how_much/custom_types.dart';
import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/presentation/widgets/buttons/dropdown_menu_button.dart';
import 'package:how_much/presentation/widgets/buttons/primary_secondary.dart';
import 'package:how_much/util/symbol_to_icon.dart';

class AssetEdit extends StatelessWidget {
  final AssetType assetType;
  final AssetId assetId;
  final Category category;
  final double currentAmount;

  const AssetEdit({
    super.key,
    required this.assetType,
    required this.assetId,
    required this.category,
    required this.currentAmount,
  });

  @override
  Widget build(BuildContext context) {
    final UserAssetsController userAssetsController =
        Get.find<UserAssetsController>();
    final EditAssetController editAssetController =
        Get.find<EditAssetController>();
    editAssetController.selectedCategory = category;

    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              assetIdToIcon(assetId, assetType),
              const Padding(padding: EdgeInsets.all(4)),
              Text(
                assetId,
                style: transactionInfoTitleStyle,
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.all(32)),
                  Text("Current Amount: ${currentAmount.toString()}",
                      style: transactionInfoTextStyle),
                  const Padding(padding: EdgeInsets.all(24)),
                  const Text("New Amount", style: transactionInfoHeaderStyle),
                  const Padding(padding: EdgeInsets.all(2)),
                  TextField(
                    controller: editAssetController.amountTextController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      hintText: "Enter the new amount",
                      hintStyle: transactionInfoHintStyle,
                      border: InputBorder.none,
                    ),
                    style: transactionInfoTextStyle,
                  ),
                  Container(
                    height: 0.5,
                    width: 280.0,
                    decoration: BoxDecoration(
                        color: howLightGrey,
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  const Padding(padding: EdgeInsets.all(32)),
                  Row(
                    children: [
                      const Text(
                        "Category: ",
                        style: transactionInfoSecondaryTextStyle,
                      ),
                      Obx(() => DropdownMenuButton(
                            valueList:
                                userAssetsController.categorySet.toList(),
                            onSelect: (newCategory) {
                              editAssetController.selectedCategory =
                                  newCategory;
                            },
                            text: editAssetController.selectedCategory,
                            textStyle: transactionInfoSecondaryTextStyle,
                          )),
                    ],
                  )
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(32)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SecondaryButton(
                cta: "Delete",
                small: true,
                enabled: true,
                onTap: () async {
                  bool deleteConfirmation =
                      await _showDeleteDialog(context, userAssetsController);
                  if (deleteConfirmation) {
                    userAssetsController.deleteAsset(
                      category,
                      assetType,
                      assetId,
                    );
                    Get.back();
                  }
                },
              ),
              const Padding(padding: EdgeInsets.all(12)),
              PrimaryButton(
                cta: "Done",
                small: true,
                onTap: () {
                  {
                    double newAmount = editAssetController.amount.value;
                    if (newAmount != 0) {
                      userAssetsController.updateAssetAmount(category,
                          assetType, assetId, newAmount - currentAmount);
                    }
                    String newCategory = editAssetController.selectedCategory;
                    if (category != newCategory) {
                      userAssetsController.changeAssetCategory(
                          assetId, assetType, category, newCategory);
                    }
                    editAssetController.resetValues();
                  }
                  Navigator.pop(context);
                },
                enabled: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<bool> _showDeleteDialog(
    BuildContext context, UserAssetsController userAssetsController) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Deletion"),
      content: const Text("Are you sure you want to delete this asset?"),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Delete"),
        ),
      ],
    ),
  ).then((value) =>
      value ??
      false); // If user taps outside the dialog to dismiss, return false
}
