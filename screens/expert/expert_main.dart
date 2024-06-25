import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/data/foul_repository.dart';
import 'package:flutter_application_4/data/match_repository.dart';
import 'package:flutter_application_4/screens/admin/edit_match.dart';
import 'package:flutter_application_4/screens/edit_profile.dart';
import 'package:flutter_application_4/screens/expert/expert_preview.dart';
import 'package:flutter_application_4/screens/login_View.dart';
import 'package:flutter_application_4/screens/v.dart';

class FoulListWidget extends StatefulWidget {
  const FoulListWidget({super.key});
  static const routeName = '/Expert-homescreen';

  @override
  State<FoulListWidget> createState() => _FoulListWidgetState();
}

class _FoulListWidgetState extends State<FoulListWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Foul List',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.lightBlue,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome, Ahmed',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('fouls')
                    .where('decision', isEqualTo: '')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading');
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index];
                      return Card(
                        elevation: 3,
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          leading: Icon(Icons
                              .video_collection), // Icon before the match name
                          title: Text(
                            'Collection $index',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          // subtitle: Text(
                          //   'Date: ${data[index].date}',
                          //   style: TextStyle(fontSize: 14),
                          // ),
                          onTap: () async {
                            await getFoulFullData(data['uid']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VideoPreviewPage(
                                        uid: data["uid"],
                                        camera1: data["camera1"],
                                        camera2: data["camera2"],
                                        camera3: data["camera3"],
                                      )),
                            );
                          },
                        ),
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}











// class ItemListPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Match List', style: TextStyle(fontFamily: 'Roboto',color: Colors.white)),
//         backgroundColor: Colors.black,
//       ),
//       body: ListView.builder(
//         itemCount: matches.length,
//         itemBuilder: (context, index) {
//           return Card(
//             elevation: 3,
//             margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             child: ListTile(
//               contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               title: Text(
//                 matches[index].name,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text(
//                 'Date: ${matches[index].date}',
//                 style: TextStyle(fontSize: 14),
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => VideoPreviewPage(match: matches[index])),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

