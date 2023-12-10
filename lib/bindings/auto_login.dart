import 'package:get/get.dart';

import 'package:how_much/controllers/login.dart';

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    // login controller should be permanent, due to login/logout mechanisms
    Get.put(LoginController(), permanent: true);

    // from UX perspective, user is more ok to wait during login
    // we will take advantage of it, and do all our preparation in this window.
    // login controller initializes the below in the LoginController:
    /*
      Get.put(AssetTableController());
      Get.put(PriceTablesController());
      Get.put(SnapshotsController());
      Get.put(UserAssetsController());
      Get.put(ReportController());
      Get.put(DateController());
      Get.put(CurrencyController());
    */
  }
}
