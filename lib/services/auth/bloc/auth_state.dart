import 'package:firstapplication/services/auth/auth_user.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';  

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized();
}

class Authstateregistering extends AuthState {
  final Exception? exceptions;
  const Authstateregistering(this.exceptions);
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

class Loggedout extends AuthState with EquatableMixin{
  final Exception? exceptions;
  final bool isloading;
  const Loggedout({
    required this.exceptions,
    required this.isloading,
  });
  
  @override
  List<Object?> get props =>[exceptions,isloading];  // same like verification state , this state does not need to carry anything
}
// now this particular state will produce like 3 states - no exceptions and isloading true , exceptions - yes and isloading - false and 3rd finally is exceptions  - yes and is loading false
// for this we will need a additional ppackage called equatable
