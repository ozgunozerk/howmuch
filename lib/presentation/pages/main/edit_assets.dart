import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import 'package:how_much/controllers/user_assets_controller.dart';
import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/presentation/widgets/drawer_contents/add_asset_or_category.dart';
import 'package:how_much/presentation/widgets/editable_asset_list.dart';
import 'package:how_much/presentation/widgets/nav_bar/discard_save.dart';
import 'package:how_much/util/helper_funcs.dart';

class EditAssetsPage extends GetView<UserAssetsController> {
  const EditAssetsPage({super.key});

  _onBackPressed(BuildContext context) async {
    bool discardApproved = await showDiscardDialog(context);
    if (discardApproved) {
      controller.discardChanges();
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => _onBackPressed(context)),
        title: const Text("Editing Assets"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
                onPressed: () {
                  bottomSheetModalInvoker(
                      context, const AddAssetOrCategory(), 0.90, true);
                },
                icon: const Icon(
                  Ionicons.add_circle,
                  color: lightOrange,
                  size: 36,
                )),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
          child: Center(
            child: Column(
              children: [
                Obx(
                  () {
                    final categoryAssetMap = controller.categoryAssetMap;

                    if (categoryAssetMap.isNotEmpty) {
                      return Expanded(
                        child: EditableAssetList(
                          categoryAssetMap: categoryAssetMap,
                        ),
                      );
                    } else {
                      return _welcome();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const DiscardAndSave(),
    );
  }
}

Widget _welcome() {
  return Expanded(
    child: Column(
      children: [
        const Padding(padding: EdgeInsets.all(40)),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: transactionInfoSecondaryTextStyle,
              children: <TextSpan>[
                const TextSpan(text: "Welcome to "),
                TextSpan(
                  text: "HowMuch",
                  style: transactionInfoSecondaryTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: "!\n\nStart by adding your first asset."),
              ],
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.all(12)),
      ],
    ),
  );
}
