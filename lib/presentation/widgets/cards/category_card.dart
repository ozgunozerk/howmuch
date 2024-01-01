import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:how_much/controllers/helpers/currency.dart';
import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/presentation/widgets/buttons/dropdown_menu_button.dart';
import 'package:how_much/presentation/widgets/cards/category_card_inner/category_graph.dart';
import 'package:how_much/presentation/widgets/triangle_painter.dart';
import 'package:how_much/util/parsing.dart';

class CategoryCard extends StatelessWidget {
  final double totalAmount;
  final double deposit;
  final double profit;
  final double rateChange;
  final List<double> dataPoints;
  final List<Color> gradientColors;
  final Color lineColor;
  final Color backgroundColor;

  const CategoryCard({
    super.key,
    required this.totalAmount,
    required this.dataPoints,
    required this.deposit,
    required this.rateChange,
    required this.profit,
    required this.gradientColors,
    required this.lineColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final currencyController = Get.find<CurrencyController>();

    return Card(
      margin: EdgeInsets.zero,
      color: backgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("Current Balance",
                        style: categoryHeaderTextStyle),
                    const Spacer(),
                    Obx(() => DropdownMenuButton(
                          text: currencyController.selectedCurrency.toString(),
                          valueList: currencyController.getBaseCurrencies(),
                          onSelect: (newValue) async {
                            currencyController.selectedCurrency = newValue;
                          },
                          textStyle: categoryHeaderTextStyle,
                        )),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() => totalAmountDisplay(currencyController)),
                const SizedBox(height: 32),
                Obx(() => depositWithdrawDisplay(currencyController)),
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

  Widget totalAmountDisplay(CurrencyController controller) {
    return Row(
      children: [
        SizedBox(
          width: 210,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              controller.displayCurrencyWithoutSign(totalAmount),
              style: categoryTotalAmountTextStyle,
              maxLines: 1, // Make sure it's a single line
            ),
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(
                24, 255, 255, 255), // a little transparency
            borderRadius: BorderRadius.circular(8),
          ),
          padding:
              const EdgeInsets.only(left: 14, right: 12, top: 8, bottom: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 10.0,
                height: 10.0,
                child: CustomPaint(
                  painter: TrianglePainter(
                      strokeColor: rateChange.isNegative ? red : green,
                      paintingStyle: PaintingStyle.fill,
                      direction: rateChange.isNegative
                          ? TriangleDirection.down
                          : TriangleDirection.up,
                      heightFactor: 0.8),
                ),
              ),
              const SizedBox(width: 6.0),
              Text(
                '${compactDouble(rateChange)}%',
                style: categoryRateChangeTextStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget depositWithdrawDisplay(CurrencyController controller) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.displayCurrencyWithoutSign(deposit),
                style: categoryProfitDepositAmountTextStyle),
            Text(
              deposit.isNegative ? "withdraw" : "deposit",
              style: categoryProfitDepositDescriptorTextStyle,
            )
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(controller.displayCurrencyWithSign(profit),
                style: categoryProfitDepositAmountTextStyle),
            const Text("profit",
                style: categoryProfitDepositDescriptorTextStyle)
          ],
        ),
      ],
    );
  }
}
