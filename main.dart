// ignore_for_file: p*96refer_const_constructors, duplicate_ignore, unused_import, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/screens/admin/edit_match.dart';
import 'package:flutter_application_4/screens/admin/edit_user.dart';
import 'package:flutter_application_4/data/match_repository.dart';
import 'package:flutter_application_4/screens/admin/add_match.dart';
import 'package:flutter_application_4/add_user.dart';
import 'package:flutter_application_4/screens/admin/admin_home_screen.dart';
import 'package:flutter_application_4/screens/admin/search_view_user.dart';
import 'package:flutter_application_4/screens/expert/expert_main.dart';
import 'package:flutter_application_4/screens/login_view.dart';
// import 'package:flutter_application_4/screens/referee_decision.dart';
import 'package:flutter_application_4/screens/admin/search_view_match.dart';
import 'package:flutter_application_4/screens/referee/match_requests.dart';
import 'package:flutter_application_4/screens/referee/referee_home_screen.dart';
import 'package:flutter_application_4/screens/referee/squash_game.dart';
import 'package:flutter_application_4/utils/cache_helper.dart';
import 'package:flutter/services.dart';
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyDAIJSqO_Ue-H4AUZ_vPvMHd1W3fjaSNfs',
          messagingSenderId: '836286435997',
          appId: '1:836286435997:android:185cb874235981cc767a74',
          projectId: 'grad-76af6'));


  runApp(
    MaterialApp(
      title: 'flutter_application_4',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        AdminHomeScreen.routeName: (context) => AdminHomeScreen(),
        '/add-user': (context) => AddUserScreen(),
        '/modify-user': (context) => SearchViewUser(),
        '/add-match': (context) => AddMatchScreen(),
        '/modify-match': (context) => SearchViewMatch(),
        '/Referee-page': (context) => RefereeHomeScreen(),
        '/Expert-homescreen': (context) => FoulListWidget(),
      },
    ),
  );
}
