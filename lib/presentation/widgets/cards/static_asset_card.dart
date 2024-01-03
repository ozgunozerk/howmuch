import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:how_much/controllers/helpers/currency.dart';
import 'package:how_much/custom_types.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/util/helper_funcs.dart';
import 'package:how_much/util/parsing.dart';
import 'package:how_much/util/symbol_to_icon.dart';

class StaticAssetCard extends StatelessWidget {
  final AssetType assetType;
  final String assetId;
  final double amount;
  final double value;
  final double profit;
  final double rateChange;
  final BorderRadiusGeometry borderRadius;

  const StaticAssetCard({
    super.key,
    required this.assetId,
    required this.amount,
    required this.value,
    required this.profit,
    required this.assetType,
    required this.rateChange,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CurrencyController>();
    return Container(
      height: 72,
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
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 14),
                  child: assetIdToIcon(assetId, assetType),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      assetType == AssetType.crypto
                          ? cryptoIdToSymbol(assetId).toUpperCase()
                          : assetId.toUpperCase(),
                      style: assetTextStyle,
                    ),
                    Text(
                      formatWithoutSign(amount),
                      style: amountTextStyle,
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => Text(
                        controller.displayCurrencyWithoutSign(value),
                        style: assetTextStyle,
                      )),
                  Obx(() => Text(
                        "${controller.displayCurrencyWithSign(profit, displayPositiveSign: true)} (${formatWithSign2Decimal(rateChange, displayPositiveSign: true)}%)",
                        style: changeTextStyle(profit),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
