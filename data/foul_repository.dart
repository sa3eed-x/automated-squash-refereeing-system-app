// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, unused_import, unnecessary_string_interpolations
import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/fouls_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_4/screens/referee/referee_recall.dart';
// import 'package:flutter_application_4/screens/squash_game.dart';
import 'package:flutter_application_4/utils/cache_helper.dart';


Future<void> createFoulsCollectionInDatabase({
  required String camera1,
  required String camera2,
  required String camera3,
  String? decision,
}) async {
  print('create foul collection loading');
  final docRef = await FirebaseFirestore.instance.collection('fouls').add({
    'camera1': camera1,
    'camera2': camera2,
    'camera3': camera3,
    'decision': decision,
  });
  await FirebaseFirestore.instance
      .collection('fouls')
      .doc(docRef.id)
      .update({'uid': docRef.id}).then((value) => print('create foul done'));
}

Future<void> updateFoul({
  required String uid,
  required String decision,

}) async {
  CollectionReference fouls =
      FirebaseFirestore.instance.collection('fouls');
  await fouls.doc(uid).update({
    'decision': decision,
  });
}

Map<String, String> foulsNames = {};

Future<void> getAllFoulsNames() async {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  try {
    QuerySnapshot querySnapshot = await users.get();

    for (var doc in querySnapshot.docs) {
      String uid = doc.id;
      String email = doc['email'];

      foulsNames[uid] = email;
      print(foulsNames);
    }
  } catch (e) {
    print('Error fetching users: $e');
  }
}

Foul foul = Foul();

Future<void> getFoulFullData(String uid) async {
  await FirebaseFirestore.instance
      .collection('fouls')
      .doc(uid)
      .get()
      .then((v) {
    foul = Foul.fromJson(v.data()!);
  });
}



