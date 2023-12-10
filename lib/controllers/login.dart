import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:how_much/controllers/fetch/asset_table_controller.dart';
import 'package:how_much/controllers/fetch/price_tables_controller.dart';
import 'package:how_much/controllers/report_controller.dart';
import 'package:how_much/controllers/snapshots_controller.dart';
import 'package:how_much/controllers/user_assets_controller.dart';
import 'package:how_much/controllers/helpers/currency.dart';
import 'package:how_much/controllers/helpers/date.dart';

class LoginController extends GetxController {
  final googleSignIn = GoogleSignIn();
  User? _firebaseUser;
  GoogleSignInAccount? _googleUser;

  User get firebaseUser => _firebaseUser!;

  GoogleSignInAccount get googleUser => _googleUser!;

  LoginController() {
    // if (kDebugMode) {
    //   FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    // }
  }

  @override
  void onInit() async {
    super.onInit();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedInBefore = prefs.getBool('isLoggedIn') ?? false;

    // even if the app is deleted, firebase instance remains,
    // and automatically logs in the user on the first install of the app,
    // to prevent this, we are utilizing SharedPreferences (local)
    if (isLoggedInBefore) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user == null) {
          // will be triggered on `logout`
          Get.offAllNamed('/login');
        } else {
          // will be triggered on `login`
          _firebaseUser = user;
          await afterLogin();
        }
      });
    } else {
      // if we don't recognize the user for this app (local storage is empty),
      // then they should manually login, regardless of whether firebase recognizes them
      Get.offAllNamed('/login');
    }
  }

  Future<bool> googleLogin() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return false;
    _googleUser = googleUser;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    _firebaseUser =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;
    update();
    return true;
  }

  Future<void> afterLogin() async {
    // initialize these controllers after successful login immediately

    // we need this for being able to map asset symbols to names
    Get.put(AssetTableController());

    // this is for snapshot controller to be able to fetch prices
    PriceTablesController priceTablesController =
        Get.put(PriceTablesController());
    if (priceTablesController.loading.value) {
      // Wait until priceTableController.loading becomes false
      await priceTablesController.loading.stream
          .firstWhere((isLoading) => !isLoading);
    }

    // snapshots are needed for creating the report, and for the userAssets
    // this is also setting the `newUser` observable
    SnapshotsController snapshotsController = Get.put(SnapshotsController());
    if (snapshotsController.loading.value) {
      // Wait until snapshotsController.loading becomes false
      await snapshotsController.loading.stream
          .firstWhere((isLoading) => !isLoading);
    }

    // this controls what will be displayed in the dashboard, along with the report
    UserAssetsController userAssetsController = Get.put(UserAssetsController());
    if (userAssetsController.loading.value) {
      // Wait until userAssetsController.loading becomes false
      await userAssetsController.loading.stream
          .firstWhere((isLoading) => !isLoading);
    }

    // date controller will set the dates for Report Controller
    Get.put(DateController());

    // we need report controller for both edit assets screen and for dashboard
    ReportController reportController = Get.put(ReportController());
    if (reportController.loading.value) {
      // Wait until reportController.loading becomes false
      await reportController.loading.stream
          .firstWhere((isLoading) => !isLoading);
    }

    // this lets us display the total amount in other currencies
    Get.put(CurrencyController());

    if (snapshotsController.newUser) {
      Get.toNamed('/intro');
    } else {
      Get.toNamed('/dashboard');
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await googleSignIn.signOut();
    FirebaseAuth.instance.signOut();
  }

  String get displayName => _firebaseUser!.displayName!;
}
