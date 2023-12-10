import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import 'package:how_much/custom_types.dart';
import 'package:how_much/controllers/helpers/date.dart';
import 'package:how_much/controllers/report_controller.dart';
import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/presentation/widgets/buttons/interval_chip.dart';
import 'package:how_much/presentation/widgets/cards/category_card.dart';
import 'package:how_much/presentation/widgets/nav_bar/custom_fab.dart';
import 'package:how_much/presentation/widgets/nav_bar/navigation_bar.dart';
import 'package:how_much/presentation/widgets/static_asset_list.dart';

class CategoryPage extends StatelessWidget {
  late final Widget logo;
  late final Category category;

  CategoryPage({super.key}) {
    final args = Get.arguments;
    logo = args['logo'];
    category = args['category'];
  }

  final dateController = Get.find<DateController>();
  final reportController = Get.find<ReportController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    BackButton(onPressed: () => Get.back()),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: howDarkGrey,
                      child: logo,
                    ),
                    const Padding(padding: EdgeInsets.all(4)),
                    Text(category.capitalize!, style: heading2TextStyle),
                    const Spacer(),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      child: IconButton(
                        icon: const Icon(
                          Ionicons.notifications_outline,
                          color: primary,
                          size: 20,
                        ),
                        onPressed: () {
                          // add your logic for notifications
                        },
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(12)),
                Center(child: IntervalChipWidget(color: categoryChip)),
                const Padding(padding: EdgeInsets.all(4)),
                Obx(
                  () => SizedBox(
                    height: 280,
                    child: CategoryCard(
                      totalAmount:
                          reportController.categoryTotalSumOfAssets(category),
                      deposit: reportController.categoryTotalDeposits(category),
                      profit:
                          reportController.categoryTotalAssetsProfit(category),
                      rateChange: reportController
                          .categoryTotalAssetsRateChange(category),
                      dataPoints:
                          reportController.dataPointsPerCategory[category]!,
                      gradientColors: bigCategoryGradient,
                      lineColor: howWhite,
                      backgroundColor: categoryCardColor,
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(20)),
                const Text("Assets", style: heading2TextStyle),
                StaticAssetList(
                    assetList: reportController.categoryAssets(category)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: const CustomFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavigationBar(),
    );
  }
}
