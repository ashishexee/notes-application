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
    super.initState();
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
                        .pushNamedAndRemoveUntil(loginroute, (_) => false);
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
        future: _notesServices.getorcreateuser(email: useremail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesServices.allnotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allnotes = snapshot.data as List<DatabaseNote>;
                        devtools.log('Fetched ${allnotes.length} notes');
                        return ListView.builder(
                          itemCount: allnotes.length,
                          itemBuilder: (context, index) {
                            final note = allnotes[index];
                            return ListTile(
                              title: Text(
                                note.text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                // Navigate to edit note view
                                Navigator.of(context).pushNamed(
                                  newnoteroute,
                                  arguments: note,
                                );
                              },
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text('No Notes Yet'),
                        );
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

// Creating a dialog box for checking user confirmation
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
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Return false if cancel
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Return true if logout
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.blue)),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
