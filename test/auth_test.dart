import 'package:firstapplication/services/auth/auth_provider.dart';
import 'package:firstapplication/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('should not be initialized to begin with', () {
      expect(provider.isinitialized, false);
    });
    test('cannot log out if not initialized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<notinitializeexceptions>()),
      );

      test('should be able to initilised', () async {
        await provider.initialize();
        expect(provider.isinitialized, true);
      });

      test('user should be null after initialized', () {
        expect(provider.currentUser, null);
      });

      test(
        'should be able to initialize in less than 2 seconds',
        () async {
          await provider.initialize();
          expect(provider.isinitialized, true);
        },
        timeout: const Timeout(Duration(
            seconds:
                2)), //if initialization takes more than 2 seconds then this test will fail
      );
    });
  
  });
}

// exception to give user if the mockauthservices are used without
// initializing the firebase
class notinitializeexceptions implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user; // to get the current user
  var _isinitialize = false;
  bool get isinitialized {
    return _isinitialize;
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isinitialized) throw notinitializeexceptions();
    await Future.delayed(const Duration(seconds: 1));
    return await logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 2));
    _isinitialize = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    if (!isinitialized) throw notinitializeexceptions();
    throw UnimplementedError();
  }

  @override
  Future<void> logOut() {
    throw UnimplementedError();
  }

  @override
  Future<void> sendEmailVerification() {
    throw UnimplementedError();
  }
}
