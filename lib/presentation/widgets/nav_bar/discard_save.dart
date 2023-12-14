import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:how_much/controllers/report_controller.dart';
import 'package:how_much/controllers/user_assets_controller.dart';
import 'package:how_much/presentation/widgets/buttons/primary_secondary.dart';
import 'package:how_much/util/helper_funcs.dart';

class DiscardAndSave extends StatelessWidget {
  const DiscardAndSave({super.key});

  @override
  Widget build(BuildContext context) {
    UserAssetsController userAssetsController =
        Get.find<UserAssetsController>();

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Obx(() => SecondaryButton(
            cta: "Discard",
            enabled: userAssetsController.isThereAnyTransaction(),
            small: true,
            onTap: () async {
              bool discardConfirmed = await showDiscardDialog(context);
              if (discardConfirmed) {
                userAssetsController.discardChanges();
                Get.offAllNamed('/dashboard');
              }
            })),
        Obx(() => PrimaryButton(
            cta: "Done",
            enabled: userAssetsController.isThereAnyAsset(),
            small: true,
            onTap: () async {
              if (userAssetsController.isThereAnyTransaction()) {
                bool saveConfirmation =
                    await _showSaveDialog(context, userAssetsController);
                if (!saveConfirmation) {
                  // don't do anything if there are transactions and user does not confirm to proceed
                  return;
                }
              }
              // for every other scenario:
              loadingAnimation();
              await userAssetsController.saveAssets();
              Get.find<ReportController>().calculateAll();
              Get.offAllNamed('/dashboard');
            }))
      ]),
    );
  }
}

Future<bool> showDiscardDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Discard"),
      content: const Text(
          "This will discard any amount changes you have made (category changes are applied immediately). Are you sure you want to continue?"),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Discard"),
        ),
      ],
    ),
  ).then((value) =>
      value ??
      false); // If user taps outside the dialog to dismiss, return false
}

Future<bool> _showSaveDialog(
    BuildContext context, UserAssetsController userAssetsController) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Save"),
      content: const Text("Are you sure you want to save changes?"),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: userAssetsController.categoryAssetMap.isNotEmpty
              ? () => Navigator.of(context).pop(true)
              : null,
          child: const Text("Save"),
        ),
      ],
    ),
  ).then((value) =>
      value ??
      false); // If user taps outside the dialog to dismiss, return false
}
