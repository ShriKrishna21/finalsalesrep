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
  bool _isLoading = false;

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

  // Utility method to safely convert any value to String
  String safeToString(dynamic value, {String defaultValue = ""}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is bool) return value ? "true" : "false";
    if (value is num) return value.toString();
    return value.toString();
  }

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final url = CommonApiClass.Loginscreen;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      print("🔄 Sending login request to: $url");

      final loginPayload = {
        'jsonrpc': "2.0",
        'method': "call",
        'params': {
          "db": "salesrep", // Replace with actual database name
          "login": usernameController.text,
          "password": passwordController.text,
        }
      };

      print("📦 Login payload: ${jsonEncode(loginPayload)}");

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginPayload),
      );

      // Ensure dialog is closed
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (response.statusCode != 200) {
        _showSnack('Server error: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print("🔄 Login response status: ${response.statusCode}");
      print("📄 Login response: ${response.body}");

      Map<String, dynamic> rawJson;
      try {
        rawJson = jsonDecode(response.body) as Map<String, dynamic>;
        print("✅ JSON parsing successful");
      } catch (jsonError) {
        print("❌ JSON parse error: $jsonError");
        _showSnack('Invalid response format');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        print("🔄 Creating LoginModel from JSON");
        _loginData = LoginModel.fromJson(rawJson);
        print("✅ LoginModel created successfully");
      } catch (modelError) {
        print("❌ Error creating model: $modelError");
        _showSnack('Error parsing response data');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final result = _loginData?.result;
      print("🔄 Result extracted: ${result != null ? 'success' : 'null'}");

      if (result == null) {
        _showSnack('Login failed: Invalid server response');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (result.code != "200") {
        _showSnack('Login failed: ${result.code}');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Only agents must have status 'active'
      if (result.role == 'agent' && result.status != 'active') {
        _showSnack(
            'Your agent account status is "${result.status}". Please contact admin.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print("🔄 Processing login success - Saving session data");

      try {
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null) {
          final sessionId =
              RegExp(r'session_id=([^;]+)').firstMatch(setCookie)?.group(1);
          if (sessionId != null) {
            await prefs.setString('session_id', sessionId);
            print("✅ Session ID saved: ${sessionId.substring(0, 5)}...");
          }
        }

        // Save session & user info - with detailed logging for each step
        print(
            "🔄 Saving api_key: ${result.apiKey != null ? 'present' : 'null'}");
        await prefs.setString('apikey', safeToString(result.apiKey));

        print("🔄 Saving name: ${result.name}");
        await prefs.setString('name', safeToString(result.name));

        print("🔄 Saving unit: ${result.unit}");
        await prefs.setString('unit', safeToString(result.unit));

        print("🔄 Saving role: ${result.role}");
        await prefs.setString('role', safeToString(result.role));

        print("🔄 Saving user_id: ${result.userId}");
        await prefs.setInt('id', result.userId ?? 0);

        print("🔄 Saving agentlogin: ${usernameController.text}");
        await prefs.setString('agentlogin', usernameController.text);

        // Handle target field with explicit type check for better diagnostics
        final targetValue = result.target;
        print(
            "🔄 Target value: $targetValue (type: ${targetValue?.runtimeType})");
        await prefs.setString(
            'target', safeToString(targetValue, defaultValue: "0"));

        print("🔄 Saving login state");
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', usernameController.text);
        await prefs.setString('password', passwordController.text);

        // Also store the agentname for agent screens
        if (result.name != null) {
          print("🔄 Saving agentname: ${result.name}");
          await prefs.setString('agentname', safeToString(result.name));
        }

        // Also set userRole for splash screen
        print("🔄 Saving userRole: ${result.role}");
        await prefs.setString('userRole', safeToString(result.role));

        print("✅ All session data saved successfully");
      } catch (storageError) {
        print("❌ Error saving session data: $storageError");
        _showSnack('Error saving login data');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Widget? screen;
      try {
        // First create the screen with proper error handling
        print("🔄 Creating screen for role: ${result.role}");
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
            setState(() {
              _isLoading = false;
            });
            return;
        }
        print("✅ Screen created successfully");

        if (!mounted) return;

        // Then navigate with proper error handling
        try {
          print("🔄 Navigating to screen for role: ${result.role}");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => screen!),
            (route) => false,
          );
          print("✅ Navigation successful");
        } catch (navError) {
          print("❌ Navigation error: $navError");
          String errorDetails = navError.toString();
          if (navError is Error && navError.stackTrace != null) {
            print("Stack trace: ${navError.stackTrace}");
          }
          _showSnack('Error during navigation: $errorDetails');
          setState(() {
            _isLoading = false;
          });
        }
      } catch (screenError) {
        print("❌ Screen creation error: $screenError");
        String errorDetails = screenError.toString();
        StackTrace? stackTrace =
            screenError is Error ? screenError.stackTrace : null;
        if (stackTrace != null) {
          print("Stack trace: $stackTrace");
        }
        _showSnack('Error creating screen: $errorDetails');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Login error: $e");
      String errorDetails = e.toString();
      StackTrace? stackTrace = e is Error ? e.stackTrace : null;
      if (stackTrace != null) {
        print("Stack trace: $stackTrace");
      }

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showSnack('Error: $errorDetails');
      setState(() {
        _isLoading = false;
      });
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
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate())
                                      loginUser();
                                  },
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text("LOGIN",
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