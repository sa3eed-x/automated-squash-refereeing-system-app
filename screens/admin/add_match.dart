// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, unused_import, avoid_print, no_leading_underscores_for_local_identifiers, empty_statements, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_4/data/match_repository.dart';
import 'package:flutter_application_4/data/user_repository.dart';
import 'package:flutter_application_4/models/match_model.dart';
import 'package:flutter_application_4/models/user_model.dart';
import 'package:flutter_application_4/screens/admin/add_user.dart';
import 'package:flutter_application_4/widget/custom_button.dart';
import 'package:flutter_application_4/widget/custom_textfield.dart';

class AddMatchScreen extends StatefulWidget {
  static const routeName = '/add-match';

  const AddMatchScreen({super.key});

  @override
  _AddMatchScreenState createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends State<AddMatchScreen> {
  final _player1Controller = TextEditingController();
  final _player2Controller = TextEditingController();
  final _courtNumberController = TextEditingController();
  final _dateTimeController = TextEditingController();
  final _refereeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _selectedReferee;
  List<String> _selectedReferees = [];
  List<String> refereeIDs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Match'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgroundimage.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: FutureBuilder(
            future: _isLoading ? Future.delayed(Duration(seconds: 1)) : null,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 50),
                      buildCustomTextField(
                        hintText: 'Player 1',
                        controller: _player1Controller,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter player 1';
                          }
                          return null;
                        },
                        onPressed: () {},
                      ),
                      SizedBox(height: 20),
                      buildCustomTextField(
                        hintText: 'Player 2',
                        controller: _player2Controller,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter player 2';
                          }
                          return null;
                        },
                        onPressed: () {},
                      ),
                      SizedBox(height: 20),
                      buildCustomTextField(
                        hintText: 'Court number',
                        controller: _courtNumberController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Court number is required";
                          }
                          if (int.parse(value) > 33 || int.parse(value) < 1) {
                            return "Court number must be between 1 and 33";
                          }
                          return null;
                        },
                        onPressed: () {},
                      ),
                      SizedBox(height: 20),
                      buildCustomTextField(
                        hintText: 'Date and Time',
                        readOnly: true,
                        controller: _dateTimeController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Date and Time is required";
                          }
                          return null;
                        },
                        onPressed: () async {
                          await _selectDate();
                        },
                      ),
                      Visibility(
                        visible: showReferee,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .where('role', isEqualTo: 'referee')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Something went wrong');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Loading');
                            }

                            List<CheckboxListTile> refereesList = snapshot
                                .data!.docs
                                .where((doc) {
                                  bool isRefereeAvailable = true;
                                  for (var id in refereeIDs) {
                                    if (doc.id == id) {
                                      isRefereeAvailable = false;
                                      break;
                                    }
                                  }
                                  return isRefereeAvailable;
                                })
                                .map((doc) => CheckboxListTile(
                                      title: Text(doc['full Name'],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 21)),
                                      value: _selectedReferees.contains(doc.id),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value!) {
                                            _selectedReferees.add(doc.id);
                                          } else {
                                            _selectedReferees.remove(doc.id);
                                          }
                                        });
                                      },
                                    ))
                                .toList();

                            return Column(
                              children: [
                                SizedBox(height: 30),
                                ...refereesList,
                                SizedBox(height: 30),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 40),
                      CustomButton(
                        labelText: 'Add Match',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            createMatchInDatabase(
                              player1: _player1Controller.text,
                              player2: _player2Controller.text,
                              courtNumber: _courtNumberController.text,
                              dateTime: _dateTimeController.text,
                              referee: _selectedReferees,
                              visibility:
                                  _selectedReferees.length > 1 ? false : true,
                            );

                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.pop(context);
                          }
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required String hintText,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required Function() onPressed,
    bool readOnly = false,
    bool obscureText = false,
  }) {
    return Container(
      width: double.infinity,
      height: 50, // Adjusted height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.white,
          width: 1.0, // Adjusted border width
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: CustomTextField(
          hintText: hintText,
          controller: controller,
          keyboardType: keyboardType,
          onPressed: onPressed,
          readOnly: readOnly,
          obscureText: obscureText,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    _courtNumberController.dispose();
    _dateTimeController.dispose();
    _refereeController.dispose();

    super.dispose();
  }

  bool showReferee = false;

  Future<void> _selectDate() async {
    DateTime? _pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now()
          .add(const Duration(days: 365)), // Add one year to the current date
      initialDate: DateTime.now(),
    );
    if (_pickedDate != null) {
      refereeIDs = [];
      setState(() {
        _dateTimeController.text = _pickedDate.toString().split(' ')[0];
      });
      await FirebaseFirestore.instance
          .collection('matches')
          .where('dateTime', isEqualTo: _dateTimeController.text)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          for (var referee in doc.get('referee')) {
            refereeIDs.add(referee);
          }
        }
        print(refereeIDs);
      }).then((value) {
        setState(
          () {
            showReferee = true;
          },
        );
      });
    }
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Function() onPressed;
  final bool readOnly;
  final bool obscureText;

  const CustomTextField({
    required this.hintText,
    required this.controller,
    required this.keyboardType,
    required this.onPressed,
    this.readOnly = false,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(
          fontSize: 21, fontWeight: FontWeight.w500, color: Colors.black),
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
      ),
      onTap: onPressed,
    );
  }
}

class CustomButton extends StatelessWidget {
  final String labelText;
  final Function() onPressed;

  const CustomButton({required this.labelText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        labelText,
        style:
            TextStyle(fontSize: 16, color: Colors.white), // Adjusted font size
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(
            vertical: 15, horizontal: 30), // Adjusted padding
      ),
    );
  }
}
