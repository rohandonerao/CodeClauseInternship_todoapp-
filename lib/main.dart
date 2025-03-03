import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:todoapp/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase only if not already initialized
    if (Firebase.apps.isEmpty) {
      if (Platform.isAndroid) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyCvg67NB-EKyMRAFJQo_d1EI_UuoOEcSFs",
            appId: "1:750217717728:web:3b96341bfea4acc2d5ed85",
            messagingSenderId: "750217717728",
            projectId: "todoapp-23d4e",
            storageBucket: "todoapp-23d4e.firebasestorage.app",
          ),
        );
      } else {
        await Firebase.initializeApp();
      }

      // Activate Firebase App Check
      await FirebaseAppCheck.instance.activate();
    }
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  // Fetch saved theme mode
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  // Run the app with the appropriate theme
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.black,
          fill: 0,
          weight: 100,
          opticalSize: 48,
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
      ),
      dark: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        iconTheme: const IconThemeData(
            color: Colors.black, fill: 0, weight: 100, opticalSize: 48),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        theme: theme,
        darkTheme: darkTheme,
        home: VideoSplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
