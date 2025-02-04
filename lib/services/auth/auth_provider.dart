import 'package:firstapplication/services/auth/auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;
  // for login a user
  Future<AuthUser?> login({
    required String email,
    required String password,
  });
  // for creating a user
  Future<AuthUser> createuser({
    required String email,
    required String password,
  });
  // logging out a user
  Future<void> logOut();
  // for sending email verification
  Future<void> sendemailverification();
}
