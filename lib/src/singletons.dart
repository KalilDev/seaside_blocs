import 'package:firebase_abstraction/firebase.dart';
import 'package:key_value_store/key_value_store.dart';

/// This singletons will be stored to allow BloCs to be shared between web and
/// flutter.
FirebaseApp firebaseApp;
KeyValueStore keyValueStore;
bool isWeb;