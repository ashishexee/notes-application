import 'package:firstapplication/services/auth_services.dart';
import 'package:firstapplication/services/crud/notes_services.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

// ignore: camel_case_types
class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

// ignore: camel_case_types
class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  late final NotesServices _notesservices;
  late final TextEditingController _textcontoller;

  @override
  void initState() {
    _notesservices = NotesServices();
    _textcontoller = TextEditingController();
    super.initState();
    createnewnote().then((note) {
      setState(() {
        _note = note;
      });
      _setuptextcontrollerlistner();
      devtools.log('Created new note with ID: ${note.id}');
    });
  }

  void _textcontrollerlistner() async {
    final note = _note;
    if (note == null) return;
    final text = _textcontoller.text;
    await _notesservices.updatenote(
      note: note,
      text: text,
    );
    devtools.log('Updated note with ID: ${note.id}, new text: $text');
  }

  void _setuptextcontrollerlistner() {
    _textcontoller.removeListener(_textcontrollerlistner);
    _textcontoller.addListener(_textcontrollerlistner);
  }

  Future<DatabaseNote> createnewnote() async {
    final existingnote = _note;
    if (existingnote != null) {
      return existingnote;
    }
    final currentuser = AuthServices.firebase().currentUser!;
    final email = currentuser.email!;
    final owner = await _notesservices.getuser(email: email);
    return await _notesservices.createnote(owner: owner);
  }

  void _deletenoteiftextifempty() async {
    final note = _note;
    if (_textcontoller.text.isEmpty && _note != null) {
      _notesservices.deletenote(id: note!.id);
      devtools.log('Deleted empty note with ID: ${note.id}');
    }
  }

  void _savenoteiftextnotempty() async {
    final note = _note;
    final text = _textcontoller.text;
    if (note != null && text.isNotEmpty) {
      await _notesservices.updatenote(
        note: note,
        text: text,
      );
      devtools.log('Saved note with ID: ${note.id}, text: $text');
    }
  }

  @override
  void dispose() {
    _deletenoteiftextifempty();
    _savenoteiftextnotempty();
    _textcontoller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'New Note',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textcontoller,
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