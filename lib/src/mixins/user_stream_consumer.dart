import 'package:bloc/bloc.dart';
import 'package:firebase_abstraction/firebase.dart';
import 'dart:async';

typedef UserCallback = void Function(AuthUser);
mixin UserStreamConsumer<T, TO> on Bloc<T, TO> {
  StreamSubscription<AuthUser> _firebaseUserSubscription;

  Future<AuthUser> subscribeToStream(FirebaseApp app, UserCallback callback) {
    _firebaseUserSubscription = app.auth().userStream.listen(callback);
    return app.auth().currentUser;
  }

  @override
  Future<void> close() {
    _firebaseUserSubscription?.cancel();
    return super.close();
  }
}