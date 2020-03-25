import 'package:meta/meta.dart';

@immutable
abstract class AuthenticationManagerState {
  @override
  bool operator ==(other) {
    return this.runtimeType == other.runtimeType;
  }
  @override
  int get hashCode => this.runtimeType.hashCode;
}

class LoadingAuthenticationManagerState extends AuthenticationManagerState {}

class AuthenticatedAuthenticationManagerState
    extends AuthenticationManagerState {
  AuthenticatedAuthenticationManagerState(this.userID, this.userName)
      : assert(userID != null);
  final String userID;
  final String userName;

  @override
  bool operator ==(other) {
    return other is AuthenticatedAuthenticationManagerState && other.userID == this.userID && other.userName == this.userName;
  }
  @override
  int get hashCode => this.runtimeType.hashCode+this.userID.hashCode+this.userName.hashCode;
}

class UnauthenticatedAuthenticationManagerState
    extends AuthenticationManagerState {}
