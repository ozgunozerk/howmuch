import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:how_much/custom_types.dart';

class EditAssetController extends GetxController {
  final _selectedCategory = "crypto".obs;
  final amount = Rxn<double>();

  final TextEditingController amountTextController = TextEditingController();

  EditAssetController() {
    // Listen for changes in the text fields and update them accordingly
    amountTextController.addListener(() {
      amount.value =
          double.tryParse(amountTextController.text.replaceAll(',', '.'));
    });
  }

  Category get selectedCategory {
    return _selectedCategory.value;
  }

  set selectedCategory(Category category) {
    _selectedCategory.value = category;
  }

  void resetValues() {
    _selectedCategory.value = "crypto";

    amount.value = null;
    amountTextController.text = "";
  }

  @override
  void dispose() {
    amountTextController.dispose();
    super.dispose();
  }
}
