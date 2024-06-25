import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_4/data/user_repository.dart';
// import 'package:flutter_application_4/widget/custom_button.dart';
// import 'package:flutter_application_4/widget/custom_textfield.dart';

void main() {
  runApp(MaterialApp(home: AddUserScreen()));
}

class AddUserScreen extends StatefulWidget {
  static const routeName = '/add-user';

  const AddUserScreen({Key? key}) : super(key: key);

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  String gender = 'male';
  String role = 'referee';
  final _nameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgroundimage.jpg'),
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
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20), // Adjusted space
                    _buildCustomTextField(
                      hintText: 'Name',
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      onPressed: () {},
                    ),
                    SizedBox(height: 10),
                    _buildCustomTextField(
                      hintText: 'Date of Birth',
                      readOnly: true,
                      controller: _dateOfBirthController,
                      keyboardType: TextInputType.name,
                      onPressed: () async {
                        await _selectDate();
                      },
                    ),
                    SizedBox(height: 10),
                    _buildDropdownField(
                      items: ['male', 'female'],
                      value: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    _buildCustomTextField(
                      hintText: 'Phone number',
                      controller: _phoneController,
                      keyboardType: TextInputType.name,
                      onPressed: () {},
                    ),
                    SizedBox(height: 10),
                    _buildCustomTextField(
                      hintText: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onPressed: () {},
                    ),
                    SizedBox(height: 10),
                    _buildDropdownField(
                      items: ['admin', 'expert', 'referee'],
                      value: role,
                      onChanged: (value) {
                        setState(() {
                          role = value!;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    _buildCustomTextField(
                      hintText: 'Password',
                      controller: _passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      onPressed: () {},
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      labelText: 'Add User',
                      onPressed: () {
                        print('button pressed');
                        setState(() {
                          _isLoading = true;
                        });
                        registerUser(
                          name: _nameController.text,
                          dateOfBirth: _dateOfBirthController.text,
                          email: _emailController.text,
                          phoneNumber: _phoneController.text,
                          password: _passwordController.text,
                          gender: gender,
                          role: role,
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
          color: Colors.black,
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

  Widget _buildDropdownField({
    required List<String> items,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      height: 50, // Adjusted height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.black,
          width: 1.0, // Adjusted border width
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: DropdownButton<String>(
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
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
          _dateOfBirthController.text = _pickedDate.toString().split(' ')[0];
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
        style: TextStyle(fontSize: 16), // Adjusted font size
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
            vertical: 15, horizontal: 30), // Adjusted padding
      ),
    );
  }
}
