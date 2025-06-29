import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'RegisterPage.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isHidden = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;

      //     Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => SplashScreen()),
      // );
    }

    var url = "https://proesp32.000webhostapp.com/getUser.php";
    var response = await http.post(Uri.parse(url), body: {
      "username": _usernameController.text,
      "password": _passwordController.text,
    });
    var data = json.decode(response.body);
    if (data == "Success") {
      Fluttertoast.showToast(
        msg: "Login Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green, // Changed to green for success
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Username or Password Incorrect!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red, // Changed to red for error
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                  ),
                  Image.asset(
                    'assets/icon.png', // Update the path to your logo.png file
                    width:
                        150, // Set the width of the image as per your requirements
                    height:
                        150, // Set the height of the image as per your requirements
                  ),
                  Text(
                    'Trash Inspection', // Replace 'Your Text' with the text you want to display
                    textAlign: TextAlign.center, // Center the text
                    style: TextStyle(
                      fontSize: 25.0, // Set the desired font size
                      fontWeight: FontWeight.bold, // Apply bold font weight
                      color: const Color.fromARGB(
                          255, 0, 0, 0), // Set the desired text color
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(11.0),
                  ),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person), // Optional icon
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock), // Optional icon
                      suffixIcon: IconButton(
                        icon: Icon(_isHidden
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isHidden = !_isHidden;
                          });
                        },
                      ),
                    ),
                    obscureText: _isHidden,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
                  SizedBox(height: 16.0),
                  TextButton(
                    onPressed: _onRegisterButtonPressed,
                    child: Text('Don\'t have an account? Register now.'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onRegisterButtonPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterPage(),
      ),
    );
  }
}
