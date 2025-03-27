import 'package:bloc/bloc.dart';
import 'package:firstapplication/services/auth/auth_provider.dart';
import 'package:firstapplication/services/auth/bloc/auth_events.dart';
import 'package:firstapplication/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvents, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    on<Sendemaillverificationevent>(((events, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    }));
    on<Register>((events, emit) async {
      final email = events.email;
      final password = events.password;
      try {
        await provider.createUser(
          email: email,
          password: password,
        );
        await provider.sendEmailVerification();
        emit(const Userneedverification());
      } on Exception catch (e) {
        emit(Authstateregistering(e));
      }
    });
    on<Autheventsinitialize>((events, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(
          const Loggedout(
            exceptions: null,
            isloading: false,
          ),
        );
      } else if (!user.isEmailVerified) {
        emit(const Userneedverification());
      } else {
        emit(Loggedin(user));
      }
    });
    on<Loggedinevent>((event, emit) async {
      emit(const Loggedout(exceptions: null, isloading: true));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );
        if (!user!.isEmailVerified) {
          emit(
            const Loggedout(
              exceptions: null,
              isloading: false,
            ),
          );
          emit(const Userneedverification());
        } else {
          emit(
            Loggedout(
              exceptions: null,
              isloading: true,
            ),
          );
          emit(Loggedin(user));
        }
      } on Exception catch (e) {
        final exceptions = e;
        emit(Loggedout(exceptions: exceptions, isloading: false));
      }
    });
    on<Loggedoutevent>((event, emit) async {
      try {
        await provider.logOut();
        emit(Loggedout(exceptions: null, isloading: false));
      } on Exception catch (e) {
        emit(Loggedout(exceptions: e, isloading: false));
      }
    });
  }
}
