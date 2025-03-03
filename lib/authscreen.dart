// ignore_for_file: prefer_const_constructors, unused_import, camel_case_types, use_build_context_synchronously

import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todoapp/HomeScreen.dart';
import 'package:todoapp/forgot.dart';
import 'package:todoapp/register.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _MyLoginState();
}

class _MyLoginState extends State<login> {
  static const String KEYLOGIN = 'login';

  bool _isPasswordVisible = false;
  String emai = '';
  String pass = '';
  TextEditingController mailController = TextEditingController();
  TextEditingController passw = TextEditingController();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      showAlertDialog("Error", e.message ?? "An error occurred.");
      return null;
    }
  }

  void loginAccount() async {
    String emai = mailController.text.trim();
    String pas = passw.text.trim();

    if (emai == "" || pas == "") {
      showAlertDialog("Error", "Please enter your details.");
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: emai, password: pas);

        if (userCredential.user != null) {
          Navigator.pushReplacement(
              context, CupertinoPageRoute(builder: (context) => HomeScreen()));

          final SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setBool(KEYLOGIN, true);
        }
      } on FirebaseAuthException catch (ex) {
        showAlertDialog("Error", ex.message ?? "An error occurred.");
      }
    }
  }

  void showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void loginWithGoogleButton() async {
    UserCredential? userCredential = await signInWithGoogle();
    if (userCredential != null) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => HomeScreen()),
      );
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setBool(KEYLOGIN, true);
    } else {
      showAlertDialog("Error", "Google login failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 850) {
                return buildMobileLayout(constraints.maxWidth);
              } else {
                return buildDesktopLayout(constraints.maxWidth);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildMobileLayout(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 24, horizontal: width * 0.1), // Adjusted padding
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 18),
            Container(
              width: width * 0.5, // Adjusted for responsiveness
              height: width * 0.5, // Adjusted for responsiveness
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/illustration-3.png',
              ),
            ),
            SizedBox(height: 24),
            buildForm(width),
          ],
        ),
      ),
    );
  }

  Widget buildDesktopLayout(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Column(
        children: [
          Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: width * 0.25, // Adjusted for responsiveness
                  height: width * 0.25, // Adjusted for responsiveness
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/illustration-3.png',
                  ),
                ),
              ),
              SizedBox(width: 50),
              Expanded(child: buildForm(width)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildForm(double width) {
    return Container(
      width: width < 850 ? double.infinity : 400, // Adjusted for responsiveness
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Login',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Enter your credentials to log in",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: mailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: passw,
            obscureText: !_isPasswordVisible,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyRegister()),
                  );
                },
                child: Text(
                  "SignUp",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPasswordPage()),
                  );
                },
                child: Text(
                  "Forgot password",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                loginAccount();
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.purple),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(14.0),
                child: Text('Login', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loginWithGoogleButton,
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/google.png',
                      height: 24.0,
                      width: 24.0,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Login with Google',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
