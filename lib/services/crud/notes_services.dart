//as we only need join from path package not all the functions
import 'dart:async';
import 'package:firstapplication/services/auth_services.dart';
import 'package:firstapplication/services/crud/crud_exceptions.dart';
import 'package:flutter/foundation.dart'; //for using immutable and overrides
import 'package:sqflite/sqflite.dart';
import "package:path_provider/path_provider.dart";
import "package:path/path.dart" show join;
import 'dart:developer' as developer;

class NotesServices {
  Database? _db;
  Database _getdatabaseorthrow() {
    final db = _db;
    if (db == null) {
      throw databaseisnotopened();
    } else {
      return db;
    }
  }

  late final StreamController<List<DatabaseNote>> _notestreamcontroller;

  // to make the noteservices skeleton(so that it can be accessed only once)
  // whenever someone is calling _notesservices it is not creating a new instance but returning the same instance again and again
  // making our code more optimized
  static final NotesServices _shared = NotesServices._sharedinstance();
  NotesServices._sharedinstance() {
    _notestreamcontroller =
        StreamController<List<DatabaseNote>>.broadcast(onListen: () {
      _notestreamcontroller.sink.add(_notes);
    });
  }

  factory NotesServices() => _shared;

// kisi bhi variable ya function ya class ke agai underscore dalne se _ ko ek
// private function bann jta hai
  List<DatabaseNote> _notes = [];
  Stream<List<DatabaseNote>> get allnotes => _notestreamcontroller
      .stream; // this will get all the notes from the previously created _notestreamcontroller
  Future<void> _cachenotes() async {
    final allnotes = await getallnotes();

    // Debug log to see if notes are being retrieved
    developer.log('Retrieved ${allnotes.length} notes from database');

    _notes = allnotes;
    _notestreamcontroller.add(_notes);
  }

  Future<void> ensuredbisopened() async {
    try {
      await open();
    } on databasealreadyopenedexception {
      //empty
    }
  }

  Future<DatabaseUser> getorcreateuser({required String email}) async {
    try {
      final user = await getuser(email: email);
      return user;
    } on couldnotfinduser {
      final createduser = await createuser(email: email);
      return createduser;
    } catch (e) {
      rethrow; //great to use this if you want to debug your application later
    }
  }

  Future<void> updatenote(
      {required DatabaseNote note, required String text}) async {
    await ensuredbisopened();
    final db = _getdatabaseorthrow();

    // Make sure note exists
    await getnote(id: note.id);

    // Update DB
    await db.update(
      notetable,
      {textcolumn: text, issyncedcolumn: 0},
      where: 'id = ?',
      whereArgs: [note.id],
    );

    // Update in-memory cache and stream
    final updatedNote = DatabaseNote(
      id: note.id,
      userid: note.userid,
      text: text,
      issyncedwithcloud: false,
    );

    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index >= 0) {
      _notes[index] = updatedNote;
      _notestreamcontroller.add(_notes);
      developer.log('Updated note with ID: ${note.id}, new text: $text');
    }
  }

  Future<DatabaseNote> getnote({required int id}) async {
    final db = _getdatabaseorthrow();
    final result = await db.query(
      notetable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) {
      throw couldnotfindnote();
    } else {
      final note = DatabaseNote.fromRow(result.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notestreamcontroller.add(_notes);
      developer.log('Fetched note with ID: $id');
      return note;
    }
  }

  Future<List<DatabaseNote>> getallnotes() async {
    await ensuredbisopened();
    final db = _getdatabaseorthrow();
    final currentUser = AuthServices.firebase().currentUser;
    final email = currentUser?.email ?? '';

    try {
      final owner = await getuser(email: email);
      final notes = await db.query(
        notetable,
        where: '$useridcolumn = ?',
        whereArgs: [owner.id],
      );

      // Debug log to see if user's notes are found
      developer.log(
          'Found ${notes.length} notes for user $email with ID ${owner.id}');

      return notes.map((noteRow) => DatabaseNote.fromRow(noteRow)).toList();
    } catch (e) {
      developer.log('Error getting notes: $e');
      return [];
    }
  }

// future int use kra kyuki ye hume return krega the number of rows affected
  Future<int> deleteallnotes() async {
    final db = _getdatabaseorthrow();
    final numberofdeletions = await db.delete(notetable);
    _notes = []; // reset the cached notes by making it a empty list
    _notestreamcontroller.add(_notes); // reseting the notesstreamcontroller too
    return numberofdeletions;
  }

  Future<DatabaseNote> createnote({required DatabaseUser owner}) async {
    await ensuredbisopened();
    final db = _getdatabaseorthrow();

    // Verify user exists
    final dbuser = await getuser(email: owner.email);
    if (dbuser.id != owner.id) {
      throw couldnotfinduser();
    }

    const text = "New Note"; // Use a meaningful default value

    // Insert note
    final noteId = await db.insert(notetable, {
      useridcolumn: owner.id,
      textcolumn: text,
      issyncedcolumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userid: owner.id,
      text: text,
      issyncedwithcloud: true,
    );

    _notes.add(note);
    _notestreamcontroller.add(_notes);

    // Debug log
    developer.log('Created note with ID: $noteId for user: ${owner.email}');

    return note;
  }

// idhar void isiliye use kra hai kyuki hum kuch return thodi karwa rahe hai buss delete he tou krr rahe hai
  Future<void> deletenote({required int id}) async {
    final db = _getdatabaseorthrow();
    final deletecount = await db.delete(
      notetable, // Correct table
      where: "id = ?",
      whereArgs: [id],
    );
    if (deletecount == 0) {
      throw couldnotdelete();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notestreamcontroller.add(_notes);
    }
  }

  Future<DatabaseUser> getuser({required String email}) async {
    await ensuredbisopened();
    final db = _getdatabaseorthrow();
    final results = await db.query(
      usertable,
      limit: 1,
      where: "email =?",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw couldnotfinduser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createuser({required String email}) async {
    await ensuredbisopened();
    final db = _getdatabaseorthrow();
    final results = await db.query(
      usertable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw useralreadyexists();
    } else {
      final userid = await db.insert(usertable, {
        emailcolumn: email.toLowerCase(),
      });
      return DatabaseUser(
        id: userid,
        email: email,
      );
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw databaseisnotopened();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw databasealreadyopenedexception();
    }
    try {
      final docpath = await getApplicationDocumentsDirectory();
      final dbpath = join(docpath.path, dbnotes);
      final db = await openDatabase(dbpath);
      _db = db;
      await db.execute(createusertable);
      await db.execute(createnotetable);
      await _cachenotes();
    } on MissingPlatformDirectoryException {
      throw unabletogetdocemntdirectory();
    }
  }

  Future<void> deleteuser({required String email}) async {
    await ensuredbisopened();
    final db = _getdatabaseorthrow();
    final deletecount = await db.delete(
      usertable,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (deletecount != 1) {
      throw couldnotdelete();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idcolumn] as int,
        email = map[emailcolumn] as String;
  // to show the user on the debug console
  @override
  String toString() {
    return "person, id = $id,email = $email";
  }

  // creating a eqauilty logic for comparing two users
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userid;
  final String text;
  final bool issyncedwithcloud;

  DatabaseNote({
    required this.id,
    required this.userid,
    required this.text,
    required this.issyncedwithcloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idcolumn] as int,
        userid = map[useridcolumn] as int,
        text = (map[textcolumn] ?? "") as String,
        issyncedwithcloud = (map[issyncedcolumn] as int) == 1;

  @override
  String toString() {
    return "note, id = $id, userid = $userid , issyncedwithcloud  = $issyncedwithcloud ";
  }

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbnotes = 'notes.db';
const notetable = 'note';
const usertable = 'user';
const idcolumn = 'id'; // instead of hard coding we are using this way
const emailcolumn = 'email';
const useridcolumn = 'user_id';
const textcolumn = 'text';
const issyncedcolumn = 'is_synced_with_server';
const createusertable = '''
CREATE TABLE IF NOT EXISTS "user"
 ( "id" INTEGER NOT NULL, "email" TEXT NOT NULL UNIQUE, PRIMARY KEY("id")
  ) ''';
const createnotetable = '''
CREATE TABLE IF NOT EXISTS "note" 
( 
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "user_id" INTEGER NOT NULL,
  "text" TEXT, 
  "is_synced_with_server" INTEGER DEFAULT 0,
  FOREIGN KEY("user_id") REFERENCES "user"("id")
)''';
