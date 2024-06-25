// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/screens/admin/edit_match.dart';
import 'package:flutter_application_4/data/match_repository.dart';

class SearchViewMatch extends StatefulWidget {
  const SearchViewMatch({super.key});

  @override
  State<SearchViewMatch> createState() => _SearchViewMatchState();
}

class _SearchViewMatchState extends State<SearchViewMatch> {
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
                  borderSide: BorderSide.none),
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
            .orderBy('dateTime')
            .startAt([searchName]).endAt([searchName + "\uf8ff"]).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
              return ListTile(
                onTap: () async {
                  await getMatchFullData(data['uid']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditMatchScreen(),
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
                title: Text(data['player1']+ " VS " +data['player2'],style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.black)),
                subtitle: Text(data['dateTime'],style: TextStyle(fontSize: 17, color: Colors.black)),
              );
            },
          );
        },
      ),
    );
  }
}
