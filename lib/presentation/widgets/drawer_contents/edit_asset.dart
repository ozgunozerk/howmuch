import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:how_much/controllers/user_assets_controller.dart';
import 'package:how_much/custom_types.dart';
import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/presentation/widgets/buttons/primary_secondary.dart';
import 'package:how_much/util/symbol_to_icon.dart';

class AssetEdit extends StatelessWidget {
  final AssetType assetType;
  final AssetId assetId;
  final Category category;
  final double currentAmount;

  const AssetEdit(
      {super.key,
      required this.assetType,
      required this.assetId,
      required this.category,
      required this.currentAmount});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();
    final UserAssetsController userAssetsController =
        Get.find<UserAssetsController>();

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
                  const Padding(padding: EdgeInsets.all(24)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.all(8)),
                      Text("Current Amount: ${currentAmount.toString()}",
                          style: transactionInfoTextStyle),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.all(16)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.all(8)),
                      const Text("New Amount",
                          style: transactionInfoHeaderStyle),
                      const Padding(padding: EdgeInsets.all(2)),
                      TextField(
                        controller: textEditingController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          hintText: "Enter the new amount",
                          hintStyle: transactionInfoHintStyle,
                          border: InputBorder.none,
                        ),
                        style: transactionInfoTextStyle,
                      ),
                    ],
                  ),
                  Container(
                    height: 0.5,
                    width: 280.0,
                    decoration: BoxDecoration(
                        color: howLightGrey,
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(16)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SecondaryButton(
                    cta: "Delete",
                    small: true,
                    enabled: true,
                    onTap: () async {
                      bool deleteConfirmation = await _showDeleteDialog(
                          context, userAssetsController);
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
                  const Spacer(),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: textEditingController,
                    builder: (BuildContext context, TextEditingValue value,
                        Widget? child) {
                      return PrimaryButton(
                        cta: "Done",
                        small: true,
                        onTap: () {
                          userAssetsController.updateAssetAmount(
                            category,
                            assetType,
                            assetId,
                            (double.tryParse(textEditingController.text
                                        .replaceAll(",", ".")) ??
                                    0.0) -
                                currentAmount,
                          );
                          Navigator.pop(context);
                        },
                        enabled: value.text.isNotEmpty,
                      );
                    },
                  ),
                ],
              ),
            ),
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
