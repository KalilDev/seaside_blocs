import 'package:meta/meta.dart';

@immutable
abstract class AuthenticationManagerEvent {}

class ResponseEvent extends AuthenticationManagerEvent {
  ResponseEvent([this.userID, this.userName]);
  final String userID;
  final String userName;
}

class LoginFromEmailAuthEvent extends AuthenticationManagerEvent {
  LoginFromEmailAuthEvent({this.email, this.password})
      : assert(email != null && password != null);
  final String email;
  final String password;
}

class CreateUserAuthEvent extends AuthenticationManagerEvent {
  CreateUserAuthEvent(
      {this.email, this.password, this.firstName, this.lastName})
      : assert(email != null &&
            password != null &&
            firstName != null &&
            lastName != null);
  final String email;
  final String password;
  final String firstName;
  final String lastName;
}

class GoogleLoginAuthEvent extends AuthenticationManagerEvent {}

class LogoutAuthEvent extends AuthenticationManagerEvent {}

class ShowLoadingAuthEvent extends AuthenticationManagerEvent {}
