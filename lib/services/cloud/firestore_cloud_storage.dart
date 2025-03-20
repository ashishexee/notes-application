// this is basically the replacement of the what we used before like sqlite database that was stored locally
// now we are shifting to the cloud storage facility by cloud firestore
// this file will contain all out logic
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstapplication/services/cloud/cloud_note.dart';
import 'package:firstapplication/services/cloud/cloud_storage_constants.dart';
import 'package:firstapplication/services/cloud/cloud_storage_exceptions.dart';
import 'package:firstapplication/services/crud/crud_exceptions.dart';

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
      throw couldnotupdatenote();
    }
  }
 // to delete the note
  Future<void> deletenote({
    required documentid,
  }) async {
    try {
      await notes.doc(documentid).delete();
    } catch (e) {
      throw couldnotdelete();
    }
  }

//Method	When Data Updates?	Re-fetch Needed?	Usage
// .get()	       Only when called	              Yes (manually)	   One-time fetch
// .snapshots()	 Automatically on any change	  No (auto-updates)	 Real-time listening
// for continous watch to see all the changes need to use stream
  Stream<Iterable<CloudNote>> allnotes({required String owneruserid}) {
    return notes.snapshots().map((event) =>
        event.docs.map((doc) => CloudNote.fromSnapshot(doc)).where((note) {
          return note.owneruserid == owneruserid;
        }));
  }

//for one time below :
  Future<Iterable<CloudNote>> getnote({required String owneruserid}) async {
    // this is basically like a one time thing
    try {
      return await notes
          .where(
            // how(which) data you want to retrieve from the firebase firestore database
            owneruseridfieldname,
            isEqualTo: owneruserid,
          )
          .get() // this will extract and fetch the results from the firebase database(one time) need to manually run again to fetch the desired notes
          .then((value) => value.docs.map((doc) {
                // doc => list of document snapshots
                return CloudNote(
                    documentid: doc.id,
                    owneruserid: doc.data()[owneruseridfieldname] as String,
                    text: doc.data()[textfieldname]);
              }));
    } catch (e) {
      throw CouldNotgetallnotesexception();
    }
  }

  void createnewnote({required String owneruserid}) async {
    await notes.add({
      owneruseridfieldname: owneruserid,
      textfieldname: '',
    });
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
