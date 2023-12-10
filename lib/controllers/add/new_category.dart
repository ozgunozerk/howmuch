import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:how_much/custom_types.dart';
import 'package:how_much/controllers/user_assets_controller.dart';

class AddNewCategoryController extends GetxController {
  final _selectedCategory = "".obs;

  final TextEditingController categoryTextController = TextEditingController();

  final UserAssetsController userAssetsController =
      Get.find<UserAssetsController>();

  AddNewCategoryController() {
    // Listen for changes in the text fields and update them accordingly

    categoryTextController.addListener(() {
      _selectedCategory.value = categoryTextController.text.trim();
    });
  }

  Category get selectedCategory {
    return _selectedCategory.value;
  }

  set selectedCategory(Category category) {
    _selectedCategory.value = category;
  }

  bool canProceed() {
    final selectedCategoryIsNotEmpty = _selectedCategory.value.trim() != "";
    final selectedCategoryIsUnique = !userAssetsController.categorySet
        .contains(_selectedCategory.value.toLowerCase());

    return selectedCategoryIsNotEmpty && selectedCategoryIsUnique;
  }

  @override
  void dispose() {
    categoryTextController.dispose();
    super.dispose();
  }
}
