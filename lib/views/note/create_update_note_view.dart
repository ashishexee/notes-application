import 'package:firstapplication/services/auth_services.dart';
import 'package:firstapplication/services/crud/notes_services.dart';
import 'package:firstapplication/utilities/generics/get_argument.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNote? _note;
  late final NotesServices _notesservices;
  late final TextEditingController _textcontroller;

  @override
  void initState() {
    _notesservices = NotesServices();
    _textcontroller = TextEditingController();
    super.initState();
  }
 
  @override // to edit the note
  void didChangeDependencies() {
    super.didChangeDependencies();
    final existingNote = context.getArgument<DatabaseNote>();
    if (existingNote != null) {
      _note = existingNote;
      _textcontroller.text = existingNote.text; // Pre-fill text field
    } else {
      createNewNote();
    }
    _setupTextControllerListener();
  }

  void _setupTextControllerListener() {
    _textcontroller.removeListener(_textControllerListener);
    _textcontroller.addListener(_textControllerListener);
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) return;
    final text = _textcontroller.text;
    await _notesservices.updatenote(note: note, text: text);
    devtools.log('Updated note with ID: ${note.id}, new text: $text');
  }

  Future<void> createNewNote() async {
    final currentUser = AuthServices.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesservices.getuser(email: email);
    final newNote = await _notesservices.createnote(owner: owner);
    setState(() {
      _note = newNote;
    });
    devtools.log('Created new note with ID: ${newNote.id}');
  }

  void _deleteNoteIfEmpty() {
    if (_textcontroller.text.isEmpty && _note != null) {
      _notesservices.deletenote(id: _note!.id);
      devtools.log('Deleted empty note with ID: ${_note!.id}');
    }
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _textcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Edit Note',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textcontroller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Start Typing Your Notes Here',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
