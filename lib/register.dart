// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print, library_private_types_in_public_api, use_super_parameters, unused_local_variable, unused_import

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todoapp/HomeScreen.dart';
import 'package:todoapp/authscreen.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({Key? key}) : super(key: key);

  @override
  _MyRegisterState createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  static const String KEYLOGIN = 'login'; // Defined here

  String phoneNumber = '';
  String name = '';
  String email = '';
  String passw = '';
  TextEditingController emailController = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController cpassword = TextEditingController();
  bool isPasswordVisible = false;
  bool isPasswordVisible1 = false;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(); // Ensure Firebase is initialized.
  }

  // Google Sign-In logic
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If the user cancels the login
      if (googleUser == null) {
        return null; // The user canceled the login
      }

      // Get the authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message.toString());
      return null;
    }
  }

  // Modified createAccount method to use Google login
  void createAccount() async {
    String email = emailController.text.trim();
    String pass = password.text.trim();
    String cpass = cpassword.text.trim();
    if (email == "" || pass == "" || cpass == "") {
      _showErrorDialog("Please Enter Your Details");
    } else if (pass != cpass) {
      _showErrorDialog("Password Does Not Match");
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: pass);
        _showErrorDialog("User is created");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setBool(KEYLOGIN, true);
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message.toString());
      } catch (e) {
        print(e.toString());
      }
    }
  }

  void loginWithGoogle() async {
    UserCredential? userCredential = await signInWithGoogle();
    if (userCredential != null) {
      _showErrorDialog("Google Login Successful");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } else {
      _showErrorDialog("Google Login Failed");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => login()));
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 32),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return buildMobileLayout();
                } else {
                  return buildDesktopLayout();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMobileLayout() {
    return Column(
      children: [
        buildIllustration(),
        buildHeaderText(),
        buildSubHeaderText(),
        buildForm(),
      ],
    );
  }

  Widget buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 50),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildIllustration(),
                buildHeaderText(),
                buildSubHeaderText(),
                buildForm(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildIllustration() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        'assets/images/illustration-2.png',
      ),
    );
  }

  Widget buildHeaderText() {
    return Text(
      'Registration',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildSubHeaderText() {
    return Text(
      "Fill in the details below to create your account",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget buildForm() {
    return Container(
      width: 800,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Email',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: password,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Password',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !isPasswordVisible,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: cpassword,
              keyboardType: TextInputType.visiblePassword,
              obscureText: !isPasswordVisible1,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (value) {
                setState(() {
                  passw = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible1
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible1 = !isPasswordVisible1;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  createAccount();
                },
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
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
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  loginWithGoogle();
                },
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
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
                        height: 24.0, // Adjust image size
                        width: 28.0, // Adjust image size
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
      ),
    );
  }
}
