import 'package:bloc/bloc.dart';
import 'package:firstapplication/services/auth/auth_provider.dart';
import 'package:firstapplication/services/auth/bloc/auth_events.dart';
import 'package:firstapplication/services/auth/bloc/auth_state.dart';
// this will create the actual authentication logic of our application
/// combining both the AuthState and AuthEvents
class AuthBloc extends Bloc<AuthEvents, AuthState> {
  AuthBloc(AuthProvider provider) : super(const Authstateloading()) {
    //  the authbloc always need a initial state (basically an initilizer)
    // we need this piece of code because bloc always need a initilized state
    // we need to first check if  the user is already logged in and we he is logged in
    // then we will emit(const LoggedInState);
    on<Autheventsinitialize>((events, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const Loggedout());
      } else if (!user.isEmailVerified) {
        emit(const Userneedverification());
      } else {
        emit(Loggedin(user));
      }
    });
    // log in
    on<Loggedinevent>((event, emit) async {
      emit(
          Authstateloading()); // this is basically to tell the bloc that we are doing something that might take some time
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );
        if (user != null) {
          emit(Loggedin(user));
        } else {
          emit(const Loggedout());
        }
      } on Exception catch (e) {
        final exceptions = e;
        emit(Logginfailure(exceptions));
      }
    });

    // handle logout
    on<Loggedoutevent>((event, emit) async {
      try {
        emit(const Authstateloading());
        await provider.logOut();
        emit(const Loggedout());
      } on Exception catch (e) {
        emit(Loggedoutfailure(e));
      }
    });
  }
}
