import 'package:finalsalesrep/splashacreen.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

// await Firebase.initializeApp(
//   options:DefaultFirebaseOptions.currentPlatform);



  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  const MyApp({super.key,});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  SplashScreen(),
      //  isLoggedIn ? const AgentDashBoardScreen() :
    );
  }
}
