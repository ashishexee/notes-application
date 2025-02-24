import 'package:firstapplication/constants/route.dart';
import 'package:firstapplication/enums/menu_action.dart';
import 'package:firstapplication/services/auth_services.dart';
import 'package:firstapplication/services/crud/notes_services.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesServices _notesServices;
  String get useremail => AuthServices.firebase().currentUser!.email!;
  @override
  void initState() {
    _notesServices = NotesServices();
    _notesServices.open(); // this will open the database
    super.initState();
  }

  @override
  void dispose() {
    _notesServices.close(); // this will close the database
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Your Notes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
          Navigator.of(context).pushNamed(newnoteroute);
              },
              icon: const Icon(Icons.add, color: Colors.white)),
          PopupMenuButton<MenuAction>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              switch (value) {
          case MenuAction.logout:
            final shouldlogout = await showlogoutdialog(context);
            if (shouldlogout == true) {
              await AuthServices.firebase().logOut();
              Navigator.of(context)
            .pushNamedAndRemoveUntil(loginroute, (_) => true);
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
      body: FutureBuilder(
        // its like a promise in javascript
        future: _notesServices.getorcreateuser(email: useremail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                  stream: _notesServices.allnotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Text(
                            "waiting for getting all notes.....dumbass");
                      default:
                        return const CircularProgressIndicator();
                    }
                  });
            default:
              return CircularProgressIndicator();
          }
        },
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
