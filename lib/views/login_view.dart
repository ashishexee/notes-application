// import 'package:firebase_core/firebase_core.dart';
// import 'package:firstapplication/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firstapplication/constants/route.dart';
import 'package:firstapplication/firebase_options.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:firstapplication/utilities/show_error_dialog.dart'; // currently it is not used

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

var _obscure;

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
    _obscure = true;
  }

//ek baar jab init krr dete hai tou dispose krna bhi important hai
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Login Page',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _email,
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _password,
                        obscureText: _obscure,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscure = !_obscure;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          try {
                            // ignore: non_constant_identifier_names
                            final usercredentials = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: email,
                              password: password,
                            );
                            final user = FirebaseAuth.instance.currentUser;
                            if (user?.emailVerified ?? false) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  notesroute, (route) => false);
                            } else {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  emailverifyroute, (route) => false);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  'Oops you are not verified! please verify',
                                ),
                                backgroundColor: Colors.red,
                              ));
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Logged in as ${usercredentials.user?.email}',
                                ),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            devtools.log('error occured while trying to login');
                            devtools.log(e.code);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.message ?? 'Authentication failed',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } // we will do better handling when we will show the user that you have written a wrong code
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              registerroute,
                              (route) => false,
                            );
                          },
                          child: const Text('Not Registered? Register Here'))
                    ],
                  ),
                ),
              );
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
