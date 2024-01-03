import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:how_much/controllers/helpers/currency.dart';
import 'package:how_much/custom_types.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/util/helper_funcs.dart';
import 'package:how_much/util/parsing.dart';
import 'package:how_much/util/symbol_to_icon.dart';

class EditableAssetCard extends StatelessWidget {
  final BorderRadiusGeometry borderRadius;
  final String assetId;
  final AssetType assetType;
  final double amount;
  final double value;

  const EditableAssetCard({
    super.key,
    required this.borderRadius,
    required this.assetId,
    required this.assetType,
    required this.amount,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CurrencyController>();
    return Container(
      height: 72,
      width: 370,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: assetIdToIcon(assetId, assetType),
            ),
            Text(
              assetType == AssetType.crypto
                  ? cryptoIdToSymbol(assetId).toUpperCase()
                  : assetId.toUpperCase(),
              style: assetTextStyle,
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatWithoutSign(amount),
                  style: assetTextStyle,
                ),
                Text(
                  controller.displayCurrencyWithoutSign(value),
                  style: changeTextStyle(value),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
