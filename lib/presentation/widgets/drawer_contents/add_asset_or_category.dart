import 'package:flutter/material.dart';

import 'package:how_much/presentation/widgets/buttons/primary_secondary.dart';
import 'package:how_much/presentation/widgets/drawer_contents/add_new_asset.dart';
import 'package:how_much/presentation/widgets/drawer_contents/add_new_category.dart';
import 'package:how_much/util/helper_funcs.dart';

class AddAssetOrCategory extends StatelessWidget {
  const AddAssetOrCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: PrimaryButton(
                cta: "Add New Asset",
                enabled: true,
                onTap: () {
                  Navigator.pop(context);
                  bottomSheetModalInvoker(
                      context, const AddNewAsset(), 0.90, true);
                }),
          ),
          const Padding(padding: EdgeInsets.all(32)),
          Align(
            alignment: Alignment.bottomCenter,
            child: PrimaryButton(
                cta: "Add New Category",
                enabled: true,
                onTap: () {
                  Navigator.pop(context);
                  bottomSheetModalInvoker(
                      context, const AddNewCategory(), 0.90, true);
                }),
          )
        ],
      ),
    );
  }
}
