import 'package:firstapplication/services/auth/auth_user.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class Authstateloading extends AuthState {
  const Authstateloading();
}

class Loggedin extends AuthState {
  final AuthUser
      user; // this first thing you want then the user has reached the loggedin state is the current user right?
  const Loggedin(this.user);
}

class Logginfailure extends AuthState {
  final Exception exceptions;
  const Logginfailure(this.exceptions);
}

class Userneedverification extends AuthState {
  const Userneedverification(); // does not need to carrry anything
}

class Loggedout extends AuthState {
  const Loggedout(); // same like verification state , this state does not need to carry anything
}

class Loggedoutfailure extends AuthState {
  final Exception exceptions;
  const Loggedoutfailure(this.exceptions);
}
