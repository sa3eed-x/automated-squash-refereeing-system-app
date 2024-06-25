import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/data/match_repository.dart';
import 'package:flutter_application_4/screens/referee/squash_game.dart';

class MatchList extends StatefulWidget {
  const MatchList({super.key});

  @override
  State<MatchList> createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  var searchName = "";

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
            .where('visibility', isEqualTo: true)
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
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index];
              return ListTile(
                onTap: () async {
                  await getMatchFullData(data['uid']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoDisplayer(
                        player1Name: data['player1'],
                        player2Name: data['player2'],
                      ),
                    ),
                  );
                },
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
              );
            },
          );
        },
      ),
    );
  }
}
