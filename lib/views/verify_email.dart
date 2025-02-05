import 'package:firstapplication/constants/route.dart';
import 'package:firstapplication/services/auth_services.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Verify Email',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text("We've send you a confirmation. Check your inbox"),
              const Text(
                "Did not recieve? Resend",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                 await AuthServices.firebase().sendEmailVerification();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Re-Send Email',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await AuthServices.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerroute,
                    (route) => false,
                  );
                },
                child: const Text('Restart'),
              )
            ],
          ),
        ),
      ),
    );
  }

}
