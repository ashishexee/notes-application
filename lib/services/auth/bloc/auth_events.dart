import 'package:flutter/widgets.dart';

@immutable
abstract class AuthEvents {
  const AuthEvents();
}

class Autheventsinitialize extends AuthEvents {
  const Autheventsinitialize();
}

class Loggedinevent extends AuthEvents {
  final String email;
  final String password;
  const Loggedinevent(this.email, this.password);
}

class Loggedoutevent extends AuthEvents {
  const Loggedoutevent();  // we donot need any parameter to logged out the user from the application
}
