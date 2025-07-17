import 'dart:convert';
import 'package:finalsalesrep/admin/adminscreen.dart';
import 'package:finalsalesrep/agent/agentscreen.dart';
import 'package:finalsalesrep/circulationhead/circulationhead.dart';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/modelclasses/loginmodel.dart';
import 'package:finalsalesrep/regionalhead/reginoalheadscreen.dart';
import 'package:finalsalesrep/unit/circulationincharge/circulationinchargescreen.dart';
import 'package:finalsalesrep/unit/officestaff.dart/officestaffscreen.dart';
import 'package:finalsalesrep/unit/segmentincharge/segmentinchargescreen.dart';
import 'package:finalsalesrep/unit/unitmanager/unitmanagerscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ... [all your existing imports]

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});
  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  LoginModel? _loginData;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isLoggedIn") ?? false) {
      usernameController.text = prefs.getString("username") ?? "";
      passwordController.text = prefs.getString("password") ?? "";
      await loginUser();
    }
  }

  Future<void> loginUser() async {
    final prefs = await SharedPreferences.getInstance();
    final url = CommonApiClass.Loginscreen;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': "2.0",
          'method': "call",
          'params': {
            "db": "your_db_name",
            "login": usernameController.text,
            "password": passwordController.text,
          }
        }),
      );

      Navigator.pop(context);

      if (response.statusCode != 200) {
        _showSnack('Server error: ${response.statusCode}');
        return;
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      _loginData = LoginModel.fromJson(jsonResponse);
      final result = _loginData?.result;

      if (result == null) {
        _showSnack('Login failed: Invalid server response');
        return;
      }

      if (result.code != "200") {
        _showSnack('Login failed: ${result.code}');
        return;
      }

      // Only agents must have status 'active'
      if (result.role == 'agent' && result.status != 'active') {
        _showSnack(
            'Your agent account status is "${result.status}". Please contact admin.');
        return;
      }

      final setCookie = response.headers['set-cookie'];
      if (setCookie != null) {
        final sessionId =
            RegExp(r'session_id=([^;]+)').firstMatch(setCookie)?.group(1);
        if (sessionId != null) {
          await prefs.setString('session_id', sessionId);
        }
      }

      // Save session & user info
      await prefs.setString('apikey', result.apiKey ?? '');
      await prefs.setString('name', result.name ?? '');
      await prefs.setString('unit', result.unit ?? '');
      await prefs.setString('role', result.role ?? '');
      await prefs.setInt('id', result.userId ?? 0);
      await prefs.setString('agentlogin', usernameController.text);
      await prefs.setString('target', (result.target ?? false).toString());
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', usernameController.text);
      await prefs.setString('password', passwordController.text);

      Widget screen;
      switch (result.role) {
        case "admin":
          screen = const Adminscreen();
          break;
        case "Office_staff":
          screen = const OfficeStaffScreen();
          break;
        case "agent":
          screen = const Agentscreen();
          break;
        case "unit_manager":
          screen = const Unitmanagerscreen();
          break;
        case "circulation_incharge":
          screen = const Circulationinchargescreen();
          break;
        case "segment_incharge":
          screen = const Segmentinchargescreen();
          break;
        case "region_head":
          screen = const Reginoalheadscreen();
          break;
        case "circulation_head":
          screen = const CirculationHead();
          break;
        default:
          _showSnack('Unknown user role: ${result.role}');
          return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => screen),
        (route) => false,
      );
    } catch (e) {
      Navigator.pop(context);
      _showSnack('Error: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/loginbackground.jpg",
                fit: BoxFit.cover),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Login form (centered)
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset("assets/images/logo.jpg",
                              height: MediaQuery.of(context).size.height / 7),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: usernameController,
                            validator: (v) =>
                                v!.isEmpty ? "Username cannot be empty" : null,
                            decoration: InputDecoration(
                              labelText: "Username",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            validator: (v) =>
                                v!.isEmpty ? "Password cannot be empty" : null,
                            decoration: InputDecoration(
                              labelText: "Password",
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(() =>
                                    _isPasswordVisible = !_isPasswordVisible),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              fixedSize: const Size(250, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate())
                                loginUser();
                            },
                            child: const Text("LOGIN",
                                style: TextStyle(fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
