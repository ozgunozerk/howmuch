import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:get/get.dart';

import 'package:how_much/presentation/widgets/buttons/primary_secondary.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/util/helper_funcs.dart';
import 'package:how_much/util/intro_about.dart';

class Intro extends StatelessWidget {
  const Intro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              about(),
              const Padding(padding: EdgeInsets.all(24)),
              RichText(
                text: TextSpan(
                  text:
                      "By proceeding, you confirm that you have read and acknowledge our ",
                  style: disclaimerTextStyle,
                  children: [
                    TextSpan(
                      text: "disclaimer",
                      style: linkTextStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => bottomSheetModalInvoker(
                            context,
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: disclaimer(),
                            ),
                            0.70,
                            true),
                    ),
                    const TextSpan(
                      text: ".",
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                cta: "Wonderful! Let's proceed",
                enabled: true,
                onTap: () => Get.toNamed('/edit_assets'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
