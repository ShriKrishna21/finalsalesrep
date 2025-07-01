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
import 'package:shared_preferences/shared_preferences.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  loginmodel? _loginData;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    if (isLoggedIn) {
      usernameController.text = prefs.getString("username") ?? "";
      passwordController.text = prefs.getString("password") ?? "";
      await loginUser();
    }
  }

  Future<void> loginUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        _loginData = loginmodel.fromJson(jsonResponse);

        if (_loginData!.result!.code == "200") {
          await prefs.setString('apikey', _loginData!.result!.apiKey ?? '');
          await prefs.setString('name', _loginData!.result!.name ?? '');
          await prefs.setString('unit', _loginData!.result!.unit ?? '');
          await prefs.setString('role', _loginData!.result!.role ?? '');
          await prefs.setInt('id', _loginData!.result!.userId ?? 0);
          await prefs.setString('agentlogin', usernameController.text);
          await prefs.setBool("isLoggedIn", true);
          await prefs.setString("username", usernameController.text);
          await prefs.setString("password", passwordController.text);

          Widget screen;
          switch (_loginData!.result!.role) {
            case "admin":
              screen = const Adminscreen();
              break;
            case "Office_staff":
              screen = OfficeStaffScreen();
              break;
            case "agent":
              screen = Agentscreen();
              break;
            case "unit_manager":
              screen = const Unitmanagerscreen();
              break;
            case "circulation_incharge":
              screen = Circulationinchargescreen();
              break;
            case "segment_incharge":
              screen = Segmentinchargescreen();
              break;
            case "region_head":
              screen = Reginoalheadscreen();
              break;
            case "circulation_head":
              screen = CirculationHead();
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Unknown user role")),
              );
              return;
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => screen),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Login failed: ${_loginData!.result!.code ?? 'Invalid credentials'}"),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/loginbackground.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Center(
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
                    Image.asset(
                      "assets/images/logo.jpg",
                      height: MediaQuery.of(context).size.height / 7,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: usernameController,
                      validator: (value) => value!.isEmpty ? "Username cannot be empty" : null,
                      decoration: InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      validator: (value) => value!.isEmpty ? "Password cannot be empty" : null,
                      decoration: InputDecoration(
                        labelText: "Password",
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await loginUser();
                        }
                      },
                      child: const Text("LOGIN", style: TextStyle(fontSize: 18)),
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
