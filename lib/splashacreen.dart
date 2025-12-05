import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finalsalesrep/agent/agentscreen.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/regionalhead/reginoalheadscreen.dart';
import 'package:finalsalesrep/unit/circulationincharge/circulationinchargescreen.dart';
import 'package:finalsalesrep/unit/segmentincharge/segmentinchargescreen.dart';
import 'package:finalsalesrep/unit/unitmanager/unitmanagerscreen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<Widget> _getHomeScreen() async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    final String? role = prefs.getString("userRole");

    if (!isLoggedIn) return const Loginscreen();

    switch (role) {
      case 'agent':
        return const Agentscreen();
      case 'circulation':
        return const Circulationinchargescreen();
      case 'segmentincharge':
        return const Segmentinchargescreen();
      case 'unitmanager':
        return const Unitmanagerscreen();
      case 'region_head':
        return const Reginoalheadscreen();
      default:
        return const Loginscreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getHomeScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return const Loginscreen();
        }
      },
    );
  }
}