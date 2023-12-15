import 'package:flutter/material.dart';

import 'package:ionicons/ionicons.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:how_much/controllers/auth.dart';
import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/util/helper_funcs.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Padding(padding: EdgeInsets.all(48)),
              const SizedBox(
                  width: 320,
                  height: 320,
                  child:
                      Image(image: AssetImage('assets/HM_LOGO-TYPE_02.png'))),
              const Spacer(),
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      bool loginSuccessful = await controller.googleLogin();
                      if (loginSuccessful) {
                        // Push a new page with only loading animation
                        loadingAnimation();
                        (await SharedPreferences.getInstance()).setBool(
                            'isLoggedIn', true); // Save the login status
                        await controller
                            .afterLogin(); // `afterLogin` will transition into a new page after it's completed
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: howBlack,
                        backgroundColor: howWhite,
                        minimumSize: const Size(double.infinity, 50)),
                    icon: const Icon(Ionicons.logo_google),
                    label: const Text("Sign up with Google"),
                  ),
                  const Padding(padding: EdgeInsets.all(16)),
                  ElevatedButton.icon(
                    onPressed: () async {
                      bool loginSuccessful = await controller.appleLogin();
                      if (loginSuccessful) {
                        // Push a new page with only loading animation
                        loadingAnimation();
                        (await SharedPreferences.getInstance()).setBool(
                            'isLoggedIn', true); // Save the login status
                        await controller
                            .afterLogin(); // `afterLogin` will transition into a new page after it's completed
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: howBlack,
                        backgroundColor: howWhite,
                        minimumSize: const Size(double.infinity, 50)),
                    icon: const Icon(Ionicons.logo_apple),
                    label: const Text("Sign up with Apple"),
                  ),
                  const Padding(padding: EdgeInsets.all(48)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
