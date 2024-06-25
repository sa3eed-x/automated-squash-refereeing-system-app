import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseInitializer extends StatefulWidget {
  @override
  _FirebaseInitializerState createState() => _FirebaseInitializerState();
}

class _FirebaseInitializerState extends State<FirebaseInitializer> {
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  // Function to initialize Firebase
  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'YOUR_API_KEY',
          messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
          appId: 'YOUR_APP_ID',
          projectId: 'YOUR_PROJECT_ID',
        ),
      );
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      print("Error initializing Firebase: $e");
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error initializing Firebase.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (!_initialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Text(
          'Firebase initialized successfully!',
          style: TextStyle(color: Colors.green),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FirebaseInitializer(),
  ));
}
