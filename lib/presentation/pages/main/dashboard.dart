import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import 'package:how_much/controllers/helpers/date.dart';
import 'package:how_much/controllers/helpers/nav_bar.dart';
import 'package:how_much/controllers/login.dart';
import 'package:how_much/controllers/report_controller.dart';
import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/presentation/widgets/buttons/interval_chip.dart';
import 'package:how_much/presentation/widgets/cards/category_card.dart';
import 'package:how_much/presentation/widgets/cards/small_category_card.dart';
import 'package:how_much/presentation/widgets/nav_bar/custom_fab.dart';
import 'package:how_much/presentation/widgets/nav_bar/navigation_bar.dart';
import 'package:how_much/presentation/widgets/static_asset_list.dart';
import 'package:how_much/util/symbol_to_icon.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final dateController = Get.find<DateController>();
  final loginController = Get.find<LoginController>();
  final reportController = Get.find<ReportController>();
  final navigationController = Get.find<NavigationController>();

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
                const Padding(padding: EdgeInsets.only(top: 24)),
                Row(
                  children: [
                    Text(
                        "👋 Welcome${loginController.displayName.split(" ")[0]}!",
                        style: welcomeTextStyle),
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
                          navigationController.selectedIndex.value = -1;
                          Get.toNamed('/notifications');
                        },
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(16)),
                Center(child: IntervalChipWidget(color: primary)),
                const Padding(padding: EdgeInsets.all(4)),
                Obx(
                  () => SizedBox(
                    height: 280,
                    child: CategoryCard(
                      totalAmount: reportController.totalSumOfAssets,
                      deposit: reportController.totalDeposits,
                      profit: reportController.totalAssetsProfit,
                      rateChange: reportController.totalAssetsRateChange,
                      dataPoints: reportController.dataPointsOfAllAssets,
                      gradientColors: bigCategoryGradient,
                      lineColor: howWhite,
                      backgroundColor: primary,
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(28)),
                const Text("Categories", style: heading2TextStyle),
                const Padding(padding: EdgeInsets.all(4)),
                SizedBox(
                  height: 160,
                  child: Obx(() => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            reportController.dataPointsPerCategory.length,
                        itemBuilder: (context, index) {
                          final category = reportController
                              .dataPointsPerCategory.keys
                              .elementAt(index);
                          final dataPoints =
                              reportController.dataPointsPerCategory[category]!;
                          final totalAmount =
                              reportController.sumPerCategory[category]!;
                          final profit =
                              reportController.profitPerCategory[category]!;
                          final rateChange =
                              reportController.rateChangePerCategory[category]!;

                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: InkWell(
                              onTap: () {
                                navigationController.selectedIndex.value = -1;
                                Get.toNamed('/category', arguments: {
                                  'logo': categoryIcon(category, howWhite),
                                  'category': category
                                });
                              },
                              child: SizedBox(
                                height: 150,
                                width: 260,
                                child: SmallCategoryCard(
                                  icon: categoryIcon(category, howBlack),
                                  categoryName: category.capitalize!,
                                  totalAmount: totalAmount,
                                  dataPoints: dataPoints,
                                  profit: profit,
                                  rateChange: rateChange,
                                  gradientColors: smallCategoryGradient,
                                  lineColor: orange,
                                ),
                              ),
                            ),
                          );
                        },
                      )),
                ),
                const Padding(padding: EdgeInsets.all(24)),
                Obx(
                  () {
                    if (reportController.topGainers.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Top Gainers", style: heading2TextStyle),
                          const SizedBox(height: 10),
                          StaticAssetList(
                              assetList: reportController.topGainers),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                const Padding(padding: EdgeInsets.all(24)),
                Obx(
                  () {
                    if (reportController.topLosers.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Top Losers", style: heading2TextStyle),
                          const SizedBox(height: 10),
                          StaticAssetList(
                              assetList: reportController.topLosers),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                const Padding(padding: EdgeInsets.all(24)),
                Obx(
                  () {
                    if (reportController.soldAssets.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Sold", style: heading2TextStyle),
                          const SizedBox(height: 10),
                          StaticAssetList(
                              assetList: reportController.soldAssets),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                const Padding(padding: EdgeInsets.only(bottom: 48))
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
