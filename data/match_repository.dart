// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter_application_4/models/match_model.dart";

Future<void> createMatchInDatabase(
    {required String player1,
    required String player2,
    required String courtNumber,
    required String dateTime,
    required List<String> referee,
    required bool visibility}) async {
  print('create match loading');
  final docRef = await FirebaseFirestore.instance.collection('matches').add({
    'player1': player1,
    'player2': player2,
    'courtNumber': courtNumber,
    'dateTime': dateTime,
    'referee': referee,
    'visibility': visibility
  });

  await FirebaseFirestore.instance
      .collection('matches')
      .doc(docRef.id)
      .update({'uid': docRef.id});
}

Future<void> updateMatch({
  required String uid,
  required String player1,
  required String player2,
  required String courtNumber,
  required String dateTime,
  required String referee,
}) async {
  CollectionReference matches =
      FirebaseFirestore.instance.collection('matches');
  await matches.doc(uid).update({
    'player1': player1,
    'player2': player2,
    'courtNumber': courtNumber,
    'dateTime': dateTime,
    'referee': referee,
  });
}

Match match = Match();

Future<void> getMatchFullData(String uid) async {
  await FirebaseFirestore.instance
      .collection('matches')
      .doc(uid)
      .get()
      .then((v) {
    match = Match.fromJson(v.data()!);
  });
}

Future<void> deleteMatch({
  required String uid,
}) async {
  CollectionReference matches =
      FirebaseFirestore.instance.collection('matches');
  await matches.doc(uid).delete();
}
