// ignore_for_file: unused_local_variable, prefer_const_constructors, use_build_context_synchronously, unused_import, library_private_types_in_public_api, use_key_in_widget_constructors, constant_identifier_names

import 'dart:async'; // Added to use Timer
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/HomeScreen.dart';
import 'package:todoapp/authscreen.dart';
import 'package:video_player/video_player.dart';

class VideoSplashScreen extends StatefulWidget {
  @override
  _VideoSplashScreenState createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  late VideoPlayerController _controller;
  static const String KEYLOGIN = 'login';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/splash.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();

        // Delay navigation until video finishes
        Future.delayed(Duration(seconds: _controller.value.duration.inSeconds),
            () {
          whereToGo(context); // Call whereToGo after the video finishes
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Set fixed width and height, but with scaling for screen sizes
    final double videoWidth = screenWidth * 0.9; // 80% of the screen width
    final double videoHeight = videoWidth * 1; // Maintain aspect ratio (4:3)

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: videoWidth, // Responsive width
                      height: videoHeight, // Responsive height
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                ],
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void whereToGo(BuildContext context) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var isLoggedIn = sharedPreferences.getBool(KEYLOGIN);

    // Timer to simulate a delay (like in the second file)
    Timer(Duration(seconds: 2), () {
      if (isLoggedIn != null) {
        if (isLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => login()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => login()),
        );
      }
    });
  }
}
