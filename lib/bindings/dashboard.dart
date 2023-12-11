import 'package:get/get.dart';

import 'package:how_much/controllers/helpers/nav_bar.dart';

class DashboardBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NavigationController(), permanent: true);
  }
}
