import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldlogout = await showlogoutdialog(context);
                  if (shouldlogout == true) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login/', (_) => true);
                  }
                  break;
              }
              devtools.log(value.toString());
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
        backgroundColor: Colors.blue,
      ),
      body: const Text(
        'Hello World',
      ),
    );
  }
}

// creating a dialog box for checking for user confirmation
Future<bool> showlogoutdialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(false); // will return false if user chooses cancel
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(
                  true); // will return a future of true if user chooses log out
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
