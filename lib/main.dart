import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firstapplication/firebase_options.dart';
import 'package:firstapplication/views/notes_view.dart';
import 'package:firstapplication/views/register_view.dart';
import 'package:firstapplication/views/login_view.dart';
import 'package:firstapplication/views/verify_email.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
// agar sirf dart:developer import krte tou sari cheeje jo uss library mai hai
// vo bhi sath aa jati prr agar apko sirf kuch specific part he chaiye apne code mai tou you can do

//hot reload se jo bhi changes apne void main() ke andar kare honge vo affect nhi honge
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
        '/notes/':(context)=> const NotesView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                if (user.emailVerified) {
                  return const NotesView();
                } else {
                  devtools.log('hey not verified you are');
                  return const VerifyEmailView();
                }
              } else {
                return LoginView();
              }
              return const Text('Done');
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}