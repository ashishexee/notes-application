import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firstapplication/constants/route.dart';
import 'package:firstapplication/firebase_options.dart';
import 'package:firstapplication/views/verify_email.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

// my name is ashish singh and i am flutter developer
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

var _obscureText;

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _obscureText = true;
    super.initState();
  }

// ek baar jab init krr dete hai tou dispose krna bhi important hai
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
        title: const Text(
          'Register Page',
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
            //snapshot is like a async function ,, future hai firebase auth ka tou jab tak vo active nhi hoga tou hum default case mai return krr denge text as 'loading ...' warna tou hum usse column return krr denga
            case ConnectionState.done:
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      controller: _email,
                      decoration: InputDecoration(
                        hintText: 'Enter Your Email',
                        border: OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 20),
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        bool obscureText = true;
                        return Column(
                          children: [
                            TextField(
                              obscureText: _obscureText,
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: _password,
                              decoration: InputDecoration(
                                hintText: 'Enter your Password',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                filled: true,
                                fillColor: Colors.grey[200],
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        try {
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: email, password: password);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Succesfully registered',
                              ),
                              backgroundColor: Colors.blue,
                            ),
                          );
                          final user = FirebaseAuth.instance.currentUser;
                          await user?.sendEmailVerification();
                          // // we didnot use pushNamedAndRemoveUntil because we still want to have register view on
                          // the back of the email verify view so that if in case the user enters a wrong email
                          // he/she can easily go back using the back button present at the top of appbar
                          Navigator.of(context).pushNamed(emailverifyroute);
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'An error occured ${e.code}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        backgroundColor: Colors.blue,
                      ),
                      child: Text('Register'),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            loginroute,
                            (route) => false,
                          );
                        },
                        child: const Text(
                            'Already Registered? Click here to login'))
                  ],
                ),
              ));
            default:
              return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
