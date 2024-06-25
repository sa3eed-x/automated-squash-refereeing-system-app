import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/screens/admin/add_match.dart';
import 'package:flutter_application_4/screens/admin/add_user.dart';
import 'package:flutter_application_4/screens/edit_profile.dart';
import 'package:flutter_application_4/screens/login_View.dart';

class AdminHomeScreen extends StatelessWidget {
  static const routeName = '/Admin-page';

  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.settings),
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              } else if (value == 'editProfile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'editProfile',
                child: Text('Edit Profile'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgroundimage.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(20.0), // Set your desired margins here
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome back Admin!',
                  style: TextStyle(fontSize: 50, color: Colors.white),
                ),
                SizedBox(height: 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddUserScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              fixedSize: Size(200, 50),
                              backgroundColor:
                                  Colors.blue // Change the size here
                              ),
                          child: const Text(
                            'Add User',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 10), // Add space between buttons
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/modify-user');
                          },
                          style: ElevatedButton.styleFrom(
                              fixedSize: Size(200, 50), // Change the size here
                              backgroundColor:
                                  Colors.blue // Change the size here

                              ),
                          child: const Text(
                            'Modify User',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddMatchScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              fixedSize: Size(200, 50), // Change the size here
                              backgroundColor:
                                  Colors.blue // Change the size here

                              ),
                          child: const Text(
                            'Add Match',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 10), // Add space between buttons
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/modify-match');
                          },
                          style: ElevatedButton.styleFrom(
                              fixedSize: Size(200, 50), // Change the size here
                              backgroundColor:
                                  Colors.blue // Change the size here

                              ),
                          child: const Text(
                            'Modify Match',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
