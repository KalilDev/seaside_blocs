import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_abstraction/firebase.dart';
import 'package:seaside_blocs/src/singletons.dart';

import './bloc.dart';

class AuthenticationManagerBloc
    extends Bloc<AuthenticationManagerEvent, AuthenticationManagerState> {
  AuthenticationManagerBloc([FirebaseApp app])
      : this.app = app ?? firebaseApp;
  final FirebaseApp app;
  AuthInstance _auth() => app.auth();

  _loadUser() async {
    try {
      final AuthUser user = await _auth().currentUser;
      add(ResponseEvent(user?.uid, user?.displayName));
    } catch (e) {
      add(ResponseEvent());
    }
  }

  _googleLogin() async {
    add(ShowLoadingAuthEvent());
    try {
      final AuthUser user = await _auth().signInWithGoogleAccount();
      add(ResponseEvent(user.uid, user.displayName));
    } catch (e) {
      add(ResponseEvent());
    }
  }

  _createUser(
      {String firstName,
      String lastName,
      String email,
      String password}) async {
    add(ShowLoadingAuthEvent());
    try {
      final AuthUser user = await _auth()
          .createUserWithEmailAndPassword(email: email, password: password);

      final AuthUserProfile info = AuthUserProfile()
        ..displayName = '$firstName $lastName';
      user.updateProfile(info);
      add(ResponseEvent(user.uid, user.displayName));
    } catch (e) {
      add(ResponseEvent());
    }
  }

  _loginUser({String email, String password}) async {
    add(ShowLoadingAuthEvent());
    try {
      final AuthUser user = await _auth()
          .signInWithEmailAndPassword(email: email, password: password);
      add(ResponseEvent(user.uid, user.displayName));
    } catch (e) {
      add(ResponseEvent());
    }
  }

  _logout() async {
    add(ShowLoadingAuthEvent());
    await _auth().signOut();
    add(ResponseEvent());
  }

  @override
  AuthenticationManagerState get initialState {
    _loadUser();
    return LoadingAuthenticationManagerState();
  }

  @override
  Stream<AuthenticationManagerState> mapEventToState(
    AuthenticationManagerEvent event,
  ) async* {
    if (event is ShowLoadingAuthEvent) {
      yield LoadingAuthenticationManagerState();
    }
    if (event is ResponseEvent) {
      if (event.userID == null) {
        yield UnauthenticatedAuthenticationManagerState();
      } else {
        yield AuthenticatedAuthenticationManagerState(
            event.userID, event.userName);
      }
    }
    if (event is LoginFromEmailAuthEvent) {
      _loginUser(email: event.email, password: event.password);
    }
    if (event is CreateUserAuthEvent) {
      _createUser(
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          password: event.password);
    }
    if (event is LogoutAuthEvent) {
      _logout();
    }
    if (event is GoogleLoginAuthEvent) {
      _googleLogin();
    }
  }
}
