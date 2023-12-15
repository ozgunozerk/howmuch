import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:how_much/controllers/auth.dart';
import 'package:how_much/controllers/helpers/nav_bar.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/presentation/widgets/blinking_status.dart';
import 'package:how_much/presentation/widgets/nav_bar/navigation_bar.dart';

class NotificationsPage extends GetView<LoginController> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.find<NavigationController>();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            navigationController.onItemTapped(0);
          },
        ),
        title: const Text("Notifications"),
      ),
      extendBody: true,
      body: const SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 48.0),
        child: Column(
          children: [
            Padding(padding: EdgeInsets.all(8)),
            Center(child: BlinkingStatus()),
            Spacer(),
            Text("You have no notifications at the moment. Enjoy the peace!",
                style: welcomeTextStyle),
            Spacer(),
            // Center(child: BlinkingStatus()),
            // Padding(padding: EdgeInsets.all(12)),
          ],
        ),
      )),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }
}
