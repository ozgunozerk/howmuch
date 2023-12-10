import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import 'package:how_much/presentation/ui/colours.dart';

class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: howWhite,
      shape: const CircleBorder(),
      child: const Icon(
        Ionicons.pencil,
        color: howBlack,
      ),
      onPressed: () {
        Get.toNamed('edit_assets');
      },
    );
  }
}
