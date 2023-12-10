import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import 'package:how_much/controllers/login.dart';
import 'package:how_much/controllers/helpers/nav_bar.dart';
import 'package:how_much/presentation/widgets/nav_bar/navigation_bar.dart';

class SettingsPage extends GetView<LoginController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.find<NavigationController>();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            navigationController.selectedIndex.value = 0;
            Get.toNamed('/dashboard');
          },
        ),
        title: const Text("Settings"),
      ),
      extendBody: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView.separated(
            itemCount: 3,
            separatorBuilder: (BuildContext context, int index) =>
                const Padding(padding: EdgeInsets.all(10.0)), // added padding
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Ionicons.information_circle_outline),
                  title: const Text("About"),
                  onTap: () => Get.toNamed('about'),
                );
              } else if (index == 1) {
                return ListTile(
                  leading: const Icon(Ionicons.help_circle_outline),
                  title: const Text("FAQ"),
                  onTap: () => Get.toNamed('faq'),
                );
              } else {
                return ListTile(
                  leading: const Icon(Ionicons.log_out_outline),
                  title: const Text("Log Out"),
                  onTap: () => _showLogoutDialog(context),
                );
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text(
              "Are you sure you want to log out? (your data will be preserved)"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
                onPressed: () async {
                  await controller.logout();
                  Get.offAllNamed('/login');
                },
                child: const Text("Log out")),
          ],
        );
      },
    );
  }
}
