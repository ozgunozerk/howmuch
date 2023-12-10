import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:how_much/controllers/fetch/asset_table_controller.dart';
import 'package:how_much/controllers/user_assets_controller.dart';
import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/presentation/widgets/dialogs/inner_bottom.dart';
import 'package:how_much/util/parsing.dart';

void bottomSheetModalInvoker(BuildContext context, Widget content,
    double heightFactor, bool cancellable) {
  showModalBottomSheet(
    context: context,
    enableDrag: false,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor:
            heightFactor, // Adjust this value to change the height percentage
        child:
            InnerBottomDialogModal(cancellable: cancellable, content: content),
      );
    },
  );
}

String cryptoIdToSymbol(String assetId) {
  final AssetTableController assetTableController =
      Get.find<AssetTableController>();
  return assetTableController.getCryptoAssetSymbol(assetId);
}

BorderRadius calculateBorderRadius(int length, int index) {
  if (length == 1) {
    return BorderRadius.circular(12);
  } else if (index == 0) {
    return const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    );
  } else if (index == length - 1) {
    return const BorderRadius.only(
      bottomLeft: Radius.circular(12),
      bottomRight: Radius.circular(12),
    );
  }
  return BorderRadius.zero;
}

Widget categoryInput(TextEditingController textEditingController,
    UserAssetsController userAssetsController, bool validate) {
  return ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 24),
    child: IntrinsicWidth(
      child: Form(
        child: TextFormField(
          enableSuggestions: false,
          controller: textEditingController,
          autocorrect: false,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            isDense: true,
            hintText: textEditingController.text != ""
                ? "" // empty hintText if field is not empty
                : "enter the category",
            hintStyle: transactionInfoHintStyle,
            border: InputBorder.none,
          ),
          style: transactionInfoTextStyle,
          autovalidateMode: validate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          validator: validate
              ? (value) {
                  if (value == null || value.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      userAssetsController.categoryNameValid = false;
                    });
                    return "Category name can't be empty";
                  }
                  if (userAssetsController.categorySet
                      .contains(value.toLowerCase())) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      userAssetsController.categoryNameValid = false;
                    });
                    return "Category already exists";
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    userAssetsController.categoryNameValid = true;
                  });
                  return null; // Return null if the input is valid
                }
              : null,
        ),
      ),
    ),
  );
}

loadingAnimation() {
  Get.to(
    () => Scaffold(
      body: Center(
        child: LoadingAnimationWidget.threeArchedCircle(
          color: primary,
          size: 200,
        ),
      ),
    ),
  );
}

void showErrorDialog(String errorText) {
  Get.dialog(
    AlertDialog(
      title: const Text("Error"),
      content: Text(errorText),
      actions: <Widget>[
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

String getPreviousUpdateTime(DateTime timestamp) {
  // round the hour part to it's nearest 6th multiple (00, 06, 12, 18)
  // server is doing updates on these hours
  // and create the new date string, to find the respective snapshot
  int roundedDownHour = (timestamp.hour ~/ 6) * 6;
  String previousUpdateTime = formatDateWithHour(DateTime(
      timestamp.year, timestamp.month, timestamp.day, roundedDownHour));

  return previousUpdateTime;
}

String getNextUpdateTime() {
  final DateTime now = DateTime.now();
  final DateTime nowUTC = now.subtract(now.timeZoneOffset);

  int roundedDownHour = (nowUTC.hour ~/ 6) * 6;
  DateTime roundedDownDate =
      DateTime(nowUTC.year, nowUTC.month, nowUTC.day, roundedDownHour);
  DateTime roundedUpDate = roundedDownDate.add(const Duration(hours: 6));
  String nextSnapshotDateString = formatDateWithHour(roundedUpDate);

  return nextSnapshotDateString;
}
