import 'package:get/get.dart';

import 'package:how_much/app_routes.dart';
import 'package:how_much/bindings/dashboard.dart';
import 'package:how_much/bindings/edit_assets.dart';
import 'package:how_much/bindings/auto_login.dart';
import 'package:how_much/presentation/pages/main/category.dart';
import 'package:how_much/presentation/pages/main/dashboard.dart';
import 'package:how_much/presentation/pages/main/edit_assets.dart';
import 'package:how_much/presentation/pages/main/notifications.dart';
import 'package:how_much/presentation/pages/main/settings.dart';
import 'package:how_much/presentation/pages/onboarding/intro.dart';
import 'package:how_much/presentation/pages/onboarding/loading.dart';
import 'package:how_much/presentation/pages/onboarding/login.dart';
import 'package:how_much/presentation/pages/sub_settings/about.dart';
import 'package:how_much/presentation/pages/sub_settings/faq.dart';

class AppPages {
  static var list = [
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardPage(),
      binding: DashboardBindings(),
    ),
    GetPage(
      name: AppRoutes.autoLogin,
      page: () =>
          const LoadingPage(), // when auto-login happens, we show a loading page
      binding: LoginBindings(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.intro,
      page: () => const Intro(),
    ),
    GetPage(
      name: AppRoutes.editAssets,
      page: () => const EditAssetsPage(),
      binding: EditAssetsBindings(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
    ),
    GetPage(
      name: AppRoutes.category,
      page: () => CategoryPage(), // don't know what to do here
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsPage(), // don't know what to do here
    ),
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutPage(),
    ),
    GetPage(
      name: AppRoutes.faq,
      page: () => const FAQPage(),
    )
  ];
}
