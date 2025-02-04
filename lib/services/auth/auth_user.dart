import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final bool isemailverified;
  const AuthUser(this.isemailverified);

  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}


