import 'package:cloud_functions/cloud_functions.dart';

class FirebaseService {
  final FirebaseFunctions _functions;

  FirebaseService()
      : _functions = FirebaseFunctions.instanceFor(region: "europe-west1") {
    // if (kDebugMode) {
    //   _functions.useFunctionsEmulator('localhost', 5001);
    // }
  }

  FirebaseFunctions get functions => _functions;
}
