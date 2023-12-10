import 'package:flutter/material.dart';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import 'package:how_much/controllers/helpers/nav_bar.dart';
import 'package:how_much/presentation/ui/colours.dart';

class CustomNavigationBar extends StatelessWidget {
  final navigationController = Get.find<NavigationController>();

  CustomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = navigationController.selectedIndex.value;

      return AnimatedBottomNavigationBar(
        borderColor: howLightGrey,
        borderWidth: 0.5,
        icons: <IconData>[
          selectedIndex == 0 ? Ionicons.grid : Ionicons.grid_outline,
          selectedIndex == 1 ? Ionicons.settings : Ionicons.settings_outline,
        ],
        activeIndex: selectedIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        onTap: (index) {
          navigationController.onItemTapped(index);
        },
      );
    });
  }
}
