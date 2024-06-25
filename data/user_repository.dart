// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, unused_import, unnecessary_string_interpolations
import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/user_model.dart ';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_4/screens/admin/add_match.dart';
import 'package:flutter_application_4/screens/admin/add_user.dart';
import 'package:flutter_application_4/screens/admin/admin_home_screen.dart';
import 'package:flutter_application_4/screens/expert/expert_main.dart';
import 'package:flutter_application_4/screens/referee/referee_home_screen.dart';
import 'package:flutter_application_4/screens/referee/squash_game.dart';
// import 'package:flutter_application_4/screens/squash_game.dart';
import 'package:flutter_application_4/utils/cache_helper.dart';

void registerUser({
  required String name,
  required String dateOfBirth,
  required String email,
  required String password,
  required String phoneNumber,
  required String role,
  required String gender,
}) async {
  try {
    print('authentication loading');
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      print('Authentication done');
      CacheHelper.putData(key: 'uid', value: value.user!.uid);

      await _createUserInDatabase(
        email: value.user!.email!,
        name: name,
        gender: gender,
        dateOfBirth: dateOfBirth,
        role: role,
        phoneNumber: phoneNumber,
        uid: value.user!.uid,
      );
    });
  } on FirebaseAuthException catch (e) {
    print(e.message);
  }
}

Future<void> _createUserInDatabase({
  required String uid,
  required String name,
  required String dateOfBirth,
  required String email,
  required String phoneNumber,
  required String role,
  required String gender,
}) async {
  print('create user loading');
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'full Name': name,
    'email': email,
    'phoneNumber': phoneNumber,
    'date of Birth': dateOfBirth,
    'uid': uid,
    'role': role,
    'gender': gender,
  }).then((value) {
    print('create user done');
  }).catchError((error) {
    print('create user in database: ' + error);
  });
}

Map<String, String> usersNames = {};

Future<void> getAllUsersNames() async {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  try {
    QuerySnapshot querySnapshot = await users.get();

    for (var doc in querySnapshot.docs) {
      String uid = doc.id;
      String email = doc['email'];

      usersNames[uid] = email;
      print(usersNames);
    }
  } catch (e) {
    print('Error fetching users: $e');
  }
}

UserModel user = UserModel();

Future<void> getUserFullData(String uid) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc('$uid')
      .get()
      .then((v) {
    user = UserModel.fromJson(v.data()!);
  });
}

Future<void> updateUser({
  required String uid,
  required String name,
  required String dateOfBirth,
  required String phoneNumber,
  required String role,
}) async {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  await users.doc(uid).update({
    'full Name': name,
    'date of Birth': dateOfBirth,
    'phoneNumber': phoneNumber,
    'role': role,
  });
}

Future<void> deleteUser({
  required String uid,
}) async {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  await users.doc(uid).delete();
}

void loginUser(
    {required BuildContext context,
    required String email,
    required String password}) async {
  try {
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    final uid = userCredential.user!.uid;

    // Cache the user ID
    CacheHelper.putData(key: 'uid', value: uid);

    // Get the user role from Firestore
    final firestore = FirebaseFirestore.instance;
    final userDoc = await firestore.collection('users').doc(uid).get();
    final userRole = userDoc.get('role');

    // Navigate to the corresponding screen based on the role
    switch (userRole) {
      case 'admin':
        // Navigate to admin screen
        Navigator.pushReplacementNamed(context, AdminHomeScreen.routeName);
        break;
      case 'referee':
        // Navigate to user screen
        Navigator.pushReplacementNamed(context, RefereeHomeScreen.routeName);
        break;
      case 'expert':
        // Navigate to referee screen
        Navigator.pushReplacementNamed(context, FoulListWidget.routeName);
        break;
      default:
        // Handle unknown role or error
        showError('Unknown role or error');
    }
  } on FirebaseAuthException catch (e) {
    // Handle Firebase authentication error
    showError('Error logging in: ${e.message}');
  } catch (e) {
    // Handle general error
    showError('An error occurred: $e');
  }
}

void showError(String message) {
  // Show an error message to the user or log it for debugging purposes
  print('Error: $message');
  // You can also use a package like `fluttertoast` to show a toast message
  // Fluttertoast.showToast(msg: message);
}
