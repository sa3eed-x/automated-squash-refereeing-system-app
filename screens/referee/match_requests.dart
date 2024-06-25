import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class MatchRequests extends StatefulWidget {
  const MatchRequests({super.key});

  @override
  State<MatchRequests> createState() => _MatchRequestsState();
}

class _MatchRequestsState extends State<MatchRequests> {
  var searchName = "";

  @override
  void initState() {
    super.initState();
    initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: SizedBox(
          height: 40,
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchName = value;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              filled: true,
              fillColor: const Color.fromARGB(255, 246, 242, 242),
              hintText: 'Search',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('matches')
            .where('referee',
                arrayContains: FirebaseAuth.instance.currentUser!.uid)
            .where('visibility', isEqualTo: false)
            .orderBy('dateTime')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');

            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading');
          }
          if (snapshot.data!.docs.isNotEmpty) {
            sendNotification(snapshot.data!.docs.last.data());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index];
              return ListTile(
                leading: const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.stadium,
                    color: Colors.white,
                  ),
                ),
                title: Text(data['player1'] + ' VS ' + data['player2'],
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
                subtitle: Text(
                  'Court Number:' +
                      data['courtNumber'] +
                      '    ' +
                      'Date: ' +
                      data['dateTime'],
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Accept match logic here
                        await FirebaseFirestore.instance
                            .collection('matches')
                            .doc(data.id)
                            .update({
                          'visibility': true,
                          'referee': [FirebaseAuth.instance.currentUser!.uid],
                        });
                        sendNotification(data);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Accept'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        // Reject match logic here
                        await FirebaseFirestore.instance
                            .collection('matches')
                            .doc(data.id)
                            .update({
                          'referee': FieldValue.arrayRemove(
                              [FirebaseAuth.instance.currentUser!.uid]),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Future<void> sendNotification(var data) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'match_request_channel',
      title: 'New Match Request',
      body:
          'You have a new match request from ${data['player1']} vs ${data['player2']} ${data['dateTime']}',
      bigPicture: 'https://example.com/match_request_image.jpg',
      notificationLayout: NotificationLayout.BigPicture,
    ),
  );
}

Future<void> initNotifications() async {
  await AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    null,
    [
      NotificationChannel(
        channelKey: 'match_request_channel',
        channelName: 'Match Request Channel',
        channelDescription: 'Channel for match requests',
        defaultColor: Colors.blue,
        importance: NotificationImportance.Max,
      ),
    ],
  );
}
