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
      final loginPayload = {
        'jsonrpc': "2.0",
        'method': "call",
        'params': {
          "db": "salesrep",
          "login": usernameController.text,
          "password": passwordController.text,
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginPayload),
      );

      if (Navigator.canPop(context)) Navigator.pop(context);

      if (response.statusCode != 200) {
        _showSnack('Server error: ${response.statusCode}');
        setState(() => _isLoading = false);
        return;
      }

      Map<String, dynamic> rawJson;
      try {
        rawJson = jsonDecode(response.body);
      } catch (e) {
        _showSnack('Invalid response format');
        setState(() => _isLoading = false);
        return;
      }

      try {
        _loginData = LoginModel.fromJson(rawJson);
      } catch (e) {
        _showSnack('Error parsing response data');
        setState(() => _isLoading = false);
        return;
      }

      final result = _loginData?.result;
      if (result == null) {
        _showSnack('Login failed: Invalid server response');
        setState(() => _isLoading = false);
        return;
      }

      if (result.code != "200") {
        _showSnack('Login failed: ${result.code}');
        setState(() => _isLoading = false);
        return;
      }

      if (result.role == 'agent' && result.status != 'active') {
        _showSnack(
            'Your agent account status is "${result.status}". Please contact admin.');
        setState(() => _isLoading = false);
        return;
      }

      try {
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null) {
          final sessionId =
              RegExp(r'session_id=([^;]+)').firstMatch(setCookie)?.group(1);
          if (sessionId != null) {
            await prefs.setString('session_id', sessionId);
          }
        }

        await prefs.setString('apikey', safeToString(result.apiKey));
        await prefs.setString('name', safeToString(result.name));
        await prefs.setString('unit', safeToString(result.unit));
        await prefs.setString('role', safeToString(result.role));
        await prefs.setInt('id', result.userId ?? 0);
        await prefs.setString('agentlogin', usernameController.text);
        await prefs.setString(
            'target', safeToString(result.target, defaultValue: "0"));
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', usernameController.text);
        await prefs.setString('password', passwordController.text);
        if (result.name != null) {
          await prefs.setString('agentname', safeToString(result.name));
        }
        await prefs.setString('userRole', safeToString(result.role));

        // 🔄 Save the image_1920 field
        await prefs.setString(
            'profile_image_base64', safeToString(result.image1920));
      } catch (e) {
        _showSnack('Error saving login data');
        setState(() => _isLoading = false);
        return;
      }

      Widget? screen;
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
          setState(() => _isLoading = false);
          return;
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => screen!),
        (route) => false,
      );
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      _showSnack('Error: ${e.toString()}');
      setState(() => _isLoading = false);
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
                          Image.asset("assets/images/esanchaya_survey.png",
                              height: MediaQuery.of(context).size.height / 4),
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
