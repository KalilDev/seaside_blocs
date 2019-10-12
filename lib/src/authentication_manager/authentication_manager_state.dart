import 'package:meta/meta.dart';

@immutable
abstract class AuthenticationManagerState {}

class LoadingAuthenticationManagerState extends AuthenticationManagerState {}

class AuthenticatedAuthenticationManagerState
    extends AuthenticationManagerState {
  AuthenticatedAuthenticationManagerState(this.userID, this.userName)
      : assert(userID != null);
  final String userID;
  final String userName;
}

class UnauthenticatedAuthenticationManagerState
    extends AuthenticationManagerState {}
