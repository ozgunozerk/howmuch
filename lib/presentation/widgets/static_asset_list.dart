import 'package:flutter/material.dart';

import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/custom_types.dart';
import 'package:how_much/util/helper_funcs.dart';
import 'package:how_much/presentation/widgets/cards/static_asset_card.dart';

class StaticAssetList extends StatelessWidget {
  final List<AssetItem> assetList;

  const StaticAssetList({
    super.key,
    required this.assetList,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Make sure to match the borderRadius of your Material
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Shadow color
              spreadRadius: 2, // Spread radius
              blurRadius: 2, // Blur radius
              offset: const Offset(0, 1), // X,Y offsets of the shadow
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: _buildAssetItems(assetList, context),
          ),
        ),
      ),
    );
  }
}

List<Widget> _buildAssetItems(List<AssetItem> assetList, BuildContext context) {
  return List.generate(assetList.length, (assetIndex) {
    AssetItem entry = assetList[assetIndex];
    String assetId = entry.assetId;
    AssetType assetType = entry.assetType;
    AssetReport assetReport = entry.report;

    BorderRadius borderRadius =
        calculateBorderRadius(assetList.length, assetIndex);

    return Column(
      children: [
        StaticAssetCard(
            assetId: assetId,
            amount: assetReport.amount,
            value: assetReport.endValue,
            assetType: assetType,
            borderRadius: borderRadius,
            profit: assetReport.profit,
            rateChange: assetReport.rateChange),
        if (assetIndex !=
            assetList.length -
                1) // Add divider for each item except the last one
          const Divider(
            height: 1,
            thickness: 0.5,
            color: howLightGrey,
          ),
      ],
    );
  });
}
