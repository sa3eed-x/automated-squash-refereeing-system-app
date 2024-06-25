import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_4/data/user_repository.dart';
// import 'package:flutter_application_4/widget/custom_button.dart';
// import 'package:flutter_application_4/widget/custom_textfield.dart';

// void main() {
//   runApp(MaterialApp(home: AddUserScreen()));
// }

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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgroundimage.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: FutureBuilder(
            future:
                _isLoading ? Future.delayed(const Duration(seconds: 1)) : null,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20), // Adjusted space
                      buildCustomTextField(
                        hintText: 'Name',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        onPressed: () {},
                      ),
                      const SizedBox(height: 10),
                      buildCustomTextField(
                        hintText: 'Date of Birth',
                        readOnly: true,
                        controller: _dateOfBirthController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Date of Birth is required";
                          }
                          return null;
                        },
                        onPressed: () async {
                          await _selectDate();
                        },
                      ),
                      const SizedBox(height: 10),
                      buildDropdownField(
                        items: ['male', 'female'],
                        value: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      buildCustomTextField(
                        hintText: 'Phone number',
                        controller: _phoneController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Phone number is required";
                          }
                          if (value.length != 11) {
                            return "Phone number must be 11 digits";
                          }
                          return null;
                        },
                        onPressed: () {},
                      ),
                      const SizedBox(height: 10),
                      buildCustomTextField(
                        hintText: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required";
                          }
                          if (!value.contains('@gmail.com')) {
                            return "Invalid email format";
                          }
                          return null;
                        },
                        onPressed: () {},
                      ),
                      const SizedBox(height: 10),
                      buildDropdownField(
                        items: ['admin', 'expert', 'referee'],
                        value: role,
                        onChanged: (value) {
                          setState(() {
                            role = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      buildCustomTextField(
                        hintText: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }
                          return null;
                        },
                        onPressed: () {},
                      ),
                      const SizedBox(height: 40),
                      CustomButton(
                        labelText: 'Add User',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
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
                          }
                        },
                      ),
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

  Widget buildDropdownField({
    required List<String> items,
    required String value,
    required ValueChanged<String?> onChanged,
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
        child: DropdownButton<String>(
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          value: value,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
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
        firstDate: DateTime.now().subtract(Duration(days: 100 * 365)),
        lastDate: DateTime.now().subtract(Duration(days: 18 * 365)),
        initialDate: DateTime.now().subtract(Duration(days: 18 * 365)));
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

  const CustomButton(
      {super.key, required this.labelText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        labelText,
        style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Colors.white), // Adjusted font size
      ),
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(200, 50),
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(
            vertical: 15, horizontal: 30), // Adjusted padding
      ),
    );
  }
}
