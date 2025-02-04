import 'package:firstapplication/services/auth/auth_provider.dart';
import 'package:firstapplication/services/auth/auth_user.dart';
import 'package:firstapplication/services/auth/auth_exception.dart';

// // we are doing this as in near future it is possible that we add more providers for your user login
// and signin like facebook or google so we need to make a logic so that we donot need to
// code the new providers logic that every page(like main page, register page, login page etc)
class AuthServices implements AuthProvider {
  final AuthProvider provider;

  AuthServices(this.provider);

  @override
  Future<AuthUser> createuser({
    required String email,
    required String password,
  }) {
    return provider.createuser(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => provider
      .currentUser; // this become a generic system which you can easily do

  @override
  Future<void> logOut() {
    return provider.logOut();
  }

  @override
  Future<AuthUser?> login({
    required String email,
    required String password,
  }) {
    return provider.login(email: email, password: password);
  }

  @override
  Future<void> sendemailverification() {
    return provider.sendemailverification();
  }
}
