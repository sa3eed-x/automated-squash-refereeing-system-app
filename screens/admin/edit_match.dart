// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, unused_import, avoid_print, no_leading_underscores_for_local_identifiers, empty_statements, unused_element

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/data/match_repository.dart';
import 'package:flutter_application_4/models/match_model.dart';
import 'package:flutter_application_4/widget/custom_button.dart';
import 'package:flutter_application_4/widget/custom_textfield.dart';

class EditMatchScreen extends StatefulWidget {
  const EditMatchScreen({
    super.key,
  });
  @override
  _EditMatchScreenState createState() => _EditMatchScreenState();
}

class _EditMatchScreenState extends State<EditMatchScreen> {
  final _player1Controller = TextEditingController();
  final _player2Controller = TextEditingController();
  final _courtNumberController = TextEditingController();
  final _dateTimeController = TextEditingController();
  final _refereeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    _player1Controller.text = match.player1!;
    _player2Controller.text = match.player2!;
    _courtNumberController.text = match.courtNumber!;
    _dateTimeController.text = match.dateTime!.toString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Match'),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 50),
                      buildCustomTextField(
                        hintText: 'Player 1 Name',
                        controller: _player1Controller,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Player 1 is required";
                          }
                          if (value.contains(RegExp(r'[0-9]'))) {
                            return "Player 1 name cannot contain numbers";
                          }
                          return null;
                        },
                        onPressed: () {},
                      ),
                      SizedBox(height: 20),
                      buildCustomTextField(
                        hintText: 'Player 2 Name',
                        readOnly: true,
                        controller: _player2Controller,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Player 2 is required";
                          }
                          if (value.contains(RegExp(r'[0-9]'))) {
                            return "Player 2 name cannot contain numbers";
                          }
                          return null;
                        },
                        onPressed: () {},
                      ),
                      SizedBox(height: 20),
                      buildCustomTextField(
                        hintText: 'Court Number',
                        controller: _courtNumberController,
                        keyboardType: TextInputType.name,
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
                        controller: _dateTimeController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Date and Time is required";
                          }
                          return null;
                        },
                        onPressed: () {},
                      ),
                      SizedBox(height: 40),
                      CustomButton(
                        labelText: 'edit match',
                        onPressed: () {
                          print('button pressed');
                          setState(() {
                            _isLoading = true;
                          });
                          updateMatch(
                            uid: match.uid!,
                            player1: _player1Controller.text,
                            player2: _player2Controller.text,
                            courtNumber: _courtNumberController.text.toString(),
                            dateTime: _dateTimeController.text,
                            referee: _refereeController.text,
                          );

                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(height: 40),
                      CustomButton(
                        labelText: 'Delete match',
                        onPressed: () {
                          print('button pressed');
                          setState(() {
                            _isLoading = true;
                          });
                          deleteMatch(
                            uid: match.uid!,
                          );

                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ));
  }

  Widget buildCustomTextField({
    required String hintText,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required Function() onPressed,
    bool readOnly = false,
    bool obscureText = false,
    String? Function(dynamic value)? validator,
  }) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.black,
          width: 1.0,
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
          validator: validator,
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

  Future<void> _selectDate() async {
    DateTime? _pickedDate = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        initialDate: DateTime.now());
    if (_pickedDate != null) {
      setState(
        () {
          _dateTimeController.text = _pickedDate.toString().split(' ')[0];
        },
      );
    }
    ;
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Function() onPressed;
  final bool readOnly;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.keyboardType,
    required this.onPressed,
    this.readOnly = false,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
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
        style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Colors.white), // Adjusted font size
      ),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(200, 50),
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(
            vertical: 15, horizontal: 30), // Adjusted padding
      ),
    );
  }
}
