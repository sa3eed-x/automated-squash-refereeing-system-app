import 'package:flutter/material.dart';
import 'package:flutter_application_4/data/user_repository.dart';
 
void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primaryColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}

void showError(String message) {
  print('Error: $message');
}

// void loginUser({
//   required BuildContext context,
//   required String email,
//   required String password,
// }) async {
//   try {
//     // Simulating a login process for demonstration purposes
//     await Future.delayed(Duration(seconds: 2));
//     // Navigate to home screen after successful login
//     Navigator.pushReplacementNamed(context, '/home');
//   } catch (e) {
//     showError('An error occurred: $e');
//   }
// }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgroundimage.jpg"), // Add your background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 50),
                      Text(
                        'Semi-automated Squash refereeing system',
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          // fontStyle: FontStyle.italic,
                          color: Colors.white70,
                          // shadows: [
                          //   Shadow(
                          //     color: Colors.white,
                          //     offset: Offset(1, 1),
                          //     blurRadius: 3,
                          //   ),
                          // ],
                        ),
                      ),
                      SizedBox(height: 50),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _emailController,
                          style: TextStyle(fontSize: 25, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(fontSize: 25, color: Colors.black), // Added,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.blue, width: 2.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _passwordController,
                          style: TextStyle(fontSize: 25, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(fontSize: 25, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.blue, width: 2.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                          ),
                          obscureText: true,
                          keyboardType: TextInputType.visiblePassword,
                        ),
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                          });
                          loginUser(
                            email: _emailController.text,
                            password: _passwordController.text,
                            context: context,
                          );
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
        fixedSize: Size(200, 55),
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(
            vertical: 15, horizontal: 30), // Adjusted padding
      ),
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold,color:Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}