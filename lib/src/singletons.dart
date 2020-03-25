import 'package:firebase_abstraction/firebase.dart';

/// This singletons will be stored to allow BloCs to be shared between web and
/// flutter.
FirebaseApp firebaseApp;

// Js has only one number type
final bool isWeb = identical(0.0, 0);
