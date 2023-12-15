import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:how_much/controllers/edit_assets/new_category.dart';
import 'package:how_much/controllers/user_assets_controller.dart';
import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/presentation/widgets/buttons/primary_secondary.dart';
import 'package:how_much/util/helper_funcs.dart';

class AddNewCategory extends StatelessWidget {
  const AddNewCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final addNewCategoryController = Get.find<AddNewCategoryController>();
    final userAssetsController = Get.find<UserAssetsController>();

    return Center(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.center,
            child: Text(
              "Add New Category",
              style: transactionInfoTitleStyle,
            ),
          ),
          const Padding(padding: EdgeInsets.all(4)),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.all(10)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.all(8)),
                      const Text("Category", style: transactionInfoHeaderStyle),
                      const Padding(padding: EdgeInsets.all(2)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          categoryInput(
                              addNewCategoryController.categoryTextController,
                              userAssetsController,
                              true)
                        ],
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
          const Padding(padding: EdgeInsets.all(32)),
          Obx(() => Align(
                alignment: Alignment.bottomCenter,
                child: PrimaryButton(
                    cta: "Done",
                    enabled: addNewCategoryController.canProceed(),
                    onTap: () {
                      userAssetsController.addCategory(
                          addNewCategoryController.selectedCategory);
                      Navigator.pop(context);
                    }),
              ))
        ],
      ),
    );
  }
}
