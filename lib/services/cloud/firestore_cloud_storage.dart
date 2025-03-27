// this is basically the replacement of the what we used before like sqlite database that was stored locally
// now we are shifting to the cloud storage facility by cloud firestore
// this file will contain all out logic
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstapplication/services/cloud/cloud_note.dart';
import 'package:firstapplication/services/cloud/cloud_storage_constants.dart';
import 'package:firstapplication/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');
  // to update the note
  Future<void> updatenote({
    required deocumentid,
    required text,
  }) async {
    try {
      await notes.doc(deocumentid).update({textfieldname: text});
    } catch (e) {
      throw Couldnotupdatenoteexception();
    }
  }

  // to delete the note
  Future<void> deletenote({
    required documentid,
  }) async {
    try {
      await notes.doc(documentid).delete();
    } catch (e) {
      throw Couldnotdeletenoteexception();
    }
  }

//Method	When Data Updates?	Re-fetch Needed?	Usage
// .get()	       Only when called	              Yes (manually)	   One-time fetch
// .snapshots()	 Automatically on any change	  No (auto-updates)	 Real-time listening
// for continous watch to see all the changes need to use stream
  Stream<Iterable<CloudNote>> allnotes({required String owneruserid}) {
    final AllNotes = notes
        .where(owneruseridfieldname, isEqualTo: owneruserid)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    return AllNotes;
  }

  Future<CloudNote> createnewnote({required String owneruserid}) async {
    final document = await notes.add({
      owneruseridfieldname: owneruserid,
      textfieldname: '',
    });
    final fetchednote = await document.get();
    return CloudNote(
        documentid: fetchednote.id, owneruserid: owneruserid, text: ' ');
  }
// we have made our class a singelton design pattern this design pattern is made such that
// only one instance of firebasecloudstorage exist across the whole application lifecycle

// for example
// without singleton
// var instance1 = FirebaseCloudStorage();
// var instance2 = FirebaseCloudStorage();
// print(instance1 == instance2); // ❌ false (Different objects)

// with singleton
// var instance1 = FirebaseCloudStorage();
// var instance2 = FirebaseCloudStorage();
// print(instance1 == instance2); // ✅ true (Same object)
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
