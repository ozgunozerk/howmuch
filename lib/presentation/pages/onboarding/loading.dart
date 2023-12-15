import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:how_much/controllers/auth.dart';
import 'package:how_much/presentation/ui/colours.dart';

class LoadingPage extends GetView<LoginController> {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // this is just a loading screen to show a loading animation while
      // waiting for performing tasks before dashboard
      // this can act as a SPLASH screen as well
      // login controller controls where to go next:
      // if user is recognized -> dashboard page
      // if user is not recognized -> login page
      body: Center(
        child: LoadingAnimationWidget.threeArchedCircle(
          color: primary,
          size: 200,
        ),
      ),
    );
  }
}
