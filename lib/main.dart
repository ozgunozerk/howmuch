import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:how_much/app_pages.dart';
import 'package:how_much/app_routes.dart';
import 'package:how_much/presentation/ui/colours.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // disables horizontal mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // this is required to enable the behavior:
    // when clicked out of scope, the dialogs/pop-ups/drawers will be closed
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: GetMaterialApp(
        title: "Demo",
        initialRoute: AppRoutes.autoLogin,
        getPages: AppPages.list,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Roboto",
          colorSchemeSeed: primary,
          useMaterial3: true,
        ),
      ),
    );
  }
}
