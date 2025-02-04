import 'package:firebase_core/firebase_core.dart';
import 'package:firstapplication/services/auth/auth_exception.dart';
import 'package:firstapplication/services/auth/auth_user.dart';
import 'package:firstapplication/services/auth/auth_provider.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createuser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw usernotloggedinauthexception();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw weakpasswordauthexception();
      } else if (e.code == 'email-alreaady-in-use') {
        throw emailalreadyinuseauthexception();
      } else if (e.code == 'invalid-email') {
        throw invalidemailauthexception();
      } else {
        throw genericauthexception();
      }
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw usernotloggedinauthexception();
    }
  }

  @override
  Future<AuthUser?> login(
      {required String email, required String password}) async {
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw usernotloggedinauthexception();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw usernotfoundauthexpection();
      } else if (e.code == 'wrong-password') {
        throw wrongpasswordauthexception();
      } else {
        throw genericauthexception();
      }
    } catch (_) {
      // catch any exception
      throw genericauthexception();
    }
  }

  @override
  Future<void> sendemailverification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw usernotloggedinauthexception();
    }
  }
}
