import 'package:firstapplication/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  // for login a user
  Future<AuthUser?> logIn({
    required String email,
    required String password,
  });
  // for creating a user
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  // logging out a user
  Future<void> logOut();
  // for sending email verification
  Future<void> sendEmailVerification();
}

