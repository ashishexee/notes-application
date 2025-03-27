// what is build context whenever you call a stateless or a stateful widget it is basically an
// implementation of a widgeet class , inside the widget class there is a function called create element
// this element store all the charsctertics of the widget like its parent its children
// its size render object etc now this element is basically the implementation of the builder context
import 'package:firebase_core/firebase_core.dart';
import 'package:firstapplication/constants/route.dart';
import 'package:firstapplication/firebase_options.dart';
import 'package:firstapplication/services/auth/bloc/auth_bloc.dart';
import 'package:firstapplication/services/auth/bloc/auth_events.dart';
import 'package:firstapplication/services/auth/bloc/auth_state.dart';
import 'package:firstapplication/services/auth/firebase_auth_provider.dart';
import 'package:firstapplication/views/note/create_update_note_view.dart';
import 'package:firstapplication/views/note/notes_view.dart';
import 'package:firstapplication/views/register_view.dart';
import 'package:firstapplication/views/login_view.dart';
import 'package:firstapplication/views/verify_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomePage(),
        routes: {
          loginroute: (context) => const LoginView(),
          registerroute: (context) => const RegisterView(),
          notesroute: (context) => const NotesView(),
          emailverifyroute: (context) => const VerifyEmailView(),
          createorupdatenoteroute: (context) => const CreateUpdateNoteView(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const Autheventsinitialize());

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Loggedout) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            loginroute,
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Loggedin) {
            return NotesView();
          } else if (state is Userneedverification) {
            return VerifyEmailView();
          } else if (state is Loggedout) {
            return LoginView();
          } else if (state is Authstateregistering) {
            return const RegisterView();
          } else {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Loading...'),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
