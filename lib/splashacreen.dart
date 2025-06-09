import 'dart:async';
import 'package:finalsalesrep/agent/agentscreen.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  // initState runs when the widget is first created
  //Initilize The App
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), _loginStatus);
  }

  // This function checks the login status from SharedPreferences
  // _loginStatus====> is Method
  Future<void> _loginStatus() async {
    final prefs = await SharedPreferences
        .getInstance(); // Get the SharedPreferences instance
    // Condition=========>isLoggedIn
    final bool isLoggedIn = prefs.getBool("isLoggedIn") ??
        false; // Read the "isLoggedIn" flag, default to false if not set Also Condition

    // If user is logged in, navigate to the dashboard
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Agentscreen()));
    } else {
      // If not logged in, go to login screen

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Loginscreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("assets/images/loginbackground.jpg"),
      ),
    );
  }
}
