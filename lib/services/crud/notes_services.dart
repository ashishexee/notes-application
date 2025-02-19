//as we only need join from path package not all the functions
import 'package:firstapplication/services/crud/crud_exceptions.dart';
import 'package:flutter/foundation.dart'; //for using immutable and overrides
import 'package:sqflite/sqflite.dart';
import "package:path_provider/path_provider.dart";
import "package:path/path.dart" show join;

class NotesServices {
  Database? _db;
  Database _getdatabaseorthrow() {
    final db = _db;
    if (db == null)
      throw databaseisnotopened();
    else
      return db;
  }

  Future<DatabaseNote> updatenote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getdatabaseorthrow();
    await getnote(id: note.id);
    final updatecount = await db.update(notetable, {
      textcolumn: text,
      issyncedcolumn: 0,
    });
    if (updatecount == 0) {
      throw couldnotupdatenote();
    } else {
      return await getnote(id: note.id);
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
      return DatabaseNote.fromRow(result.first);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getdatabaseorthrow();
    final result = await db.query(notetable);
    return result.map((row) => DatabaseNote.fromRow(row)).toList();
  }

// future int use kra kyuki ye hume return krega the number of rows affected
  Future<int> deleteallnotes() async {
    final db = _getdatabaseorthrow();
    return await db.delete(notetable);
  }

  Future<DatabaseNote> createnote({required DatabaseUser owner}) async {
    final db = _getdatabaseorthrow();
    final dbuser = await getuser(email: owner.email);
    if (dbuser != owner) {
      throw couldnotfinduser();
    }
    const text = "";
    final noteid = await db.insert(notetable, {
      useridcolumn: owner.id,
      textcolumn: text,
      issyncedcolumn: 1,
    });
    final note = DatabaseNote(
        id: noteid,
        userid: owner.id.toString(),
        text: text,
        issyncedwithcloud: true);
    return note;
  }

// idhar void isiliye use kra hai kyuki hum kuch return thodi karwa rahe hai buss delete he tou krr rahe hai
  Future<void> deletenote({required int id}) async {
    final db = _getdatabaseorthrow();
    final deletecount = await db.delete(
      usertable,
      where: "id = ?",
      whereArgs: [id],
    );
    if (deletecount == 0) {
      throw couldnotdelete();
    }
  }

  Future<DatabaseUser> getuser({required String email}) async {
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
      // we have put out code inside a try block because getapplicationdocumentdirectory can
      // throw an error so we need to deal with it
      final docpath =
          await getApplicationDocumentsDirectory(); // jo humne getapplicationdocmentsdirectory ki directory location copy kri vo hai ye
      final dbpath = join(docpath.path,
          dbnotes); // now humne dbnotes ka naam that is "notes.db" ko jo abhi directory find kri hai uske path join krr diya jo ki humne path_provider wali library se import kri thi
      final db = await openDatabase(dbpath); // abb humne vo database khol liya
      _db = db;
      //now we are creating a user table
      await db.execute(createusertable);
      //creating notestable
      await db.execute(createnotetable);
    } on MissingPlatformDirectoryException {
      // this is the exception that getapplicationdocdir throws
      throw unabletogetdocemntdirectory();
    }
  }

  Future<void> deleteuser({required String email}) async {
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
    return "person, ID = $id,Email = $email";
  }

  // creating a eqauilty logic for comparing two users
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final String userid;
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
        userid = map[useridcolumn] as String,
        text = map[textcolumn] as String,
        issyncedwithcloud = (map[issyncedcolumn] as int) == 1 ? true : false;

  @override
  String toString() {
    //we are not adding text here because text can be so long
    // and it can get in your way to parsing information from the debug console
    return "note Id = $id, userid = $userid , issyncedwithcloud  = $issyncedwithcloud ";
  }

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbnotes = 'notes.db';
const notetable = 'note';
const usertable = 'user';
const idcolumn = "id"; // instead of hard coding we are using this way
const emailcolumn = "email";
const useridcolumn = "user_id";
const textcolumn = "text";
const issyncedcolumn = "is_synced_with_server";
const createusertable = '''
CREATE TABLE IF NOT EXISTS"user"
 ( "id" INTEGER NOT NULL, "email" TEXT NOT NULL UNIQUE, PRIMARY KEY("id")
  ) ''';
const createnotetable = '''
      CREATE TABLE IF NOT EXISTS "note" 
      ( "id" INTEGER NOT NULL,
       "user_id" INTEGER NOT NULL,
        "text" TEXT, 
        "is_synced_with_server" INTEGER DEFAULT 0,
         PRIMARY KEY("id","user_id"), 
         FOREIGN KEY("user_id") REFERENCES "user"("id") )''';