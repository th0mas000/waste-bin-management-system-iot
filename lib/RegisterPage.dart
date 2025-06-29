import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:test2/LoginPage.dart';


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  Future register() async{
  var username = _usernameController.text.trim();
  var password = _passwordController.text.trim();
  var confirmPassword = _confirmPasswordController.text.trim();
  if (username.isEmpty || password.isEmpty) {
    Fluttertoast.showToast(
      msg: "Please fill in all fields",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    return; // Exit the function if any field is empty
  }
    if (password != confirmPassword) {
    Fluttertoast.showToast(
      msg: "Passwords do not match",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    return; // Exit the function if passwords don't match
  }


    var url = "https://proesp32.000webhostapp.com/addUser.php";
    var response = await http.post(Uri.parse(url), body: {
      "username" : _usernameController.text,
      "password" : _passwordController.text,
    });
    

    
    var data = json.decode(response.body);
    if(data == "Successfully"){
      Fluttertoast.showToast(
          msg: "Registration Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }else{
      Fluttertoast.showToast(
          msg: "This User Already Exit!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.greenAccent,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
      
          : SingleChildScrollView(
        child: Padding(
          
          padding: const EdgeInsets.all(16.0),
          child: Column(
            
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                  'สมัครสมาชิก',  // Replace 'Your Text' with the text you want to display
                  textAlign: TextAlign.center,  // Center the text
                  style: TextStyle(
                    fontSize: 25.0,  // Set the desired font size
                    fontWeight: FontWeight.bold,  // Apply bold font weight
                    color: const Color.fromARGB(255, 0, 0, 0),  // Set the desired text color
                  ),
                ),
              SizedBox(height: 16.0),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                    inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')), // Deny spaces
      ],
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ConstrainedBox(
  constraints: BoxConstraints.tightFor(width: 50, height: 50), // Adjust the width and height as needed
  child: ElevatedButton(
    onPressed: () {
      register();
      _onloginButtonPressed();
    },
    child: Text('Register'),
  ),
)

            ],
            
          ),
          
        ),
      ),
    );
  }

    void _onloginButtonPressed() {
      Fluttertoast.showToast(
    msg: "Register Success",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16.0,
  );
    Navigator.of(context).pop(
      MaterialPageRoute(
        builder: (_) =>LoginPage(),
      ),
    );
  }


void _onRegisterButtonPressed() async {
  final username = _usernameController.text.trim();
  final password = _passwordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();
  

  if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please fill in all fields.'),
      ),
    );
    return;
  }

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Passwords do not match.'),
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    await register(); // Assuming register handles the HTTP request

    Navigator.of(context).pushReplacementNamed('/login');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registration successful.'),
      ),
    );
  } catch (error) {
    print('Error registering: $error');
    Fluttertoast.showToast(
      msg: "An error occurred during registration",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

}
