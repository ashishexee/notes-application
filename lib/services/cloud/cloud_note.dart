import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstapplication/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/cupertino.dart';

@immutable
class CloudNote {
  final String documentid;
  final String owneruserid;
  final String text;
  const CloudNote({
    required this.documentid,
    required this.owneruserid,
    required this.text,
  });
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentid = snapshot.id,
        owneruserid = snapshot.data()[owneruseridfieldname],
        text = snapshot.data()[textfieldname] as String;
}