import 'package:get/get.dart';

import 'package:how_much/controllers/add/new_asset.dart';
import 'package:how_much/controllers/add/new_category.dart';

class EditAssetsBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AddNewAssetController(), permanent: true);
    Get.put(AddNewCategoryController(), permanent: true);
  }
}
