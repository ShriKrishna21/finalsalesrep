import 'dart:async';
import 'package:finalsalesrep/unit/circulationincharge/circulationinchargescreen.dart' show Circulationinchargescreen;
import 'package:finalsalesrep/unit/segmentincharge/segmentinchargescreen.dart' show Segmentinchargescreen;
import 'package:finalsalesrep/unit/unitmanager/unitmanagerscreen.dart' show Unitmanagerscreen;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finalsalesrep/agent/agentscreen.dart';

import 'package:finalsalesrep/login/loginscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    final String? role = prefs.getString("userRole"); // e.g., "agent", "circulation", "segment"

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (isLoggedIn) {
      switch (role) {
        case 'agent':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Agentscreen()));
          break;
        case 'circulation':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Circulationinchargescreen()));
          break;
        case 'segmentincharge':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Segmentinchargescreen()));
          break;
        case 'unitmanager':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Unitmanagerscreen()));
          break;
        default:
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Loginscreen()));
          break;
          
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Loginscreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("assets/images/loginbackground.jpg", fit: BoxFit.cover),
      ),
    );
  }
}
