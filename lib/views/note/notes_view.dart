import 'package:firstapplication/constants/route.dart';
import 'package:firstapplication/enums/menu_action.dart';
import 'package:firstapplication/services/auth/bloc/auth_bloc.dart';
import 'package:firstapplication/services/auth/bloc/auth_events.dart';
import 'package:firstapplication/services/auth_services.dart';
import 'package:firstapplication/services/cloud/cloud_note.dart';
import 'package:firstapplication/services/cloud/firestore_cloud_storage.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:flutter_bloc/flutter_bloc.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesServices;
  String get userid => AuthServices.firebase().currentUser!.id;

  @override
  void initState() {
    _notesServices = FirebaseCloudStorage();
    super.initState();
  }

  void _deletenote(context, CloudNote note) async {
    await showDialog(
      context: context,
      builder: (context) {
        final AnimationController controller = AnimationController(
          duration: const Duration(milliseconds: 500),
          vsync: Navigator.of(context),
        );
        final Animation<double> scaleAnimation = CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        );

        controller.forward();

        return ScaleTransition(
          scale: scaleAnimation,
          child: AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.delete, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Delete ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'Note',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 5, 96, 171),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Are you sure you want to delete this note?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  controller.reverse().then((_) {
                    Navigator.of(context).pop(false);
                  });
                },
                child: Row(
                  children: const [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 4),
                    Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _notesServices.deletenote(documentid: note.documentid);
                  controller.reverse().then((_) {
                    Navigator.of(context).pop(true);
                  });
                },
                child: Row(
                  children: const [
                    Icon(Icons.delete_forever, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      'Delete',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
                  Navigator.of(context).pushNamed(createorupdatenoteroute);
                },
                icon: const Icon(Icons.add, color: Colors.white)),
            PopupMenuButton<MenuAction>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldlogout = await showlogoutdialog(context);
                    if (shouldlogout == true) {
                      context.read<AuthBloc>().add(
                            Loggedoutevent(),
                          ); 
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
        body: StreamBuilder(
          stream: _notesServices.allnotes(owneruserid: userid),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allnotes = snapshot.data as Iterable<CloudNote>;
                  devtools.log('Fetched ${allnotes.length} notes');
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: allnotes.length,
                    itemBuilder: (context, index) {
                      final note = allnotes.elementAt(index);
                      return StatefulBuilder(
                        builder: (context, setState) {
                          bool isHovered = false;
                          return MouseRegion(
                            onEnter: (_) {
                              setState(() {
                                isHovered = true;
                              });
                            },
                            onExit: (_) {
                              setState(() {
                                isHovered = false;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              transform: isHovered
                                  ? (Matrix4.identity()..translate(0, -10, 0))
                                  : Matrix4.identity(),
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  title: Text(
                                    note.text,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      _deletenote(context, note);
                                      setState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  onTap: () async {
                                    final updatedNote =
                                        await Navigator.of(context).pushNamed(
                                      createorupdatenoteroute,
                                      arguments: note,
                                    );
                                    if (updatedNote != null) {
                                      setState(
                                          () {}); // Refresh the UI after returning from editing
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text(
                      'No Notes Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          },
        ));
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
