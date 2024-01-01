import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:how_much/controllers/helpers/currency.dart';
import 'package:how_much/presentation/widgets/cards/category_card_inner/category_graph.dart';
import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/util/parsing.dart';

class SmallCategoryCard extends StatelessWidget {
  final Widget icon;
  final String categoryName;
  final double totalAmount;
  final double profit;
  final double rateChange;
  final List<double> dataPoints;
  final List<Color> gradientColors;
  final Color lineColor;

  const SmallCategoryCard(
      {super.key,
      required this.icon,
      required this.categoryName,
      required this.totalAmount,
      required this.dataPoints,
      required this.rateChange,
      required this.profit,
      required this.gradientColors,
      required this.lineColor});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CurrencyController>();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      //color: howWhite,
      color: pinkish,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                icon,
                const Padding(padding: EdgeInsets.all(6)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(categoryName, style: smallCategoryHeaderTextStyle),
                    Text("${formatWithSign1Decimal(rateChange)}%",
                        style: smallCategoryChangeTextStyle(rateChange)),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => Text(
                        controller.displayCurrencyWithoutSign(totalAmount),
                        style: smallCategoryHeaderTextStyle)),
                    Obx(() => Text(
                        controller.displayCurrencyWithSign(profit,
                            displayPositiveSign: true),
                        style: smallCategoryChangeTextStyle(profit))),
                  ],
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.all(8)),
          Expanded(
            child: CategoryGraph(
              dataPoints: dataPoints,
              gradientColors: gradientColors,
              lineColor: lineColor,
            ),
          ),
        ],
      ),
    );
  }
}
