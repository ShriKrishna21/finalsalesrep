// lib/unit/officestaff.dart/createagent.dart
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/modelclasses/createagentmodel.dart';
import 'package:finalsalesrep/offline/dbhelper.dart'; // Make sure path is correct
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CreateAgent extends StatefulWidget {
  const CreateAgent({super.key});

  @override
  State<CreateAgent> createState() => _CreateAgentState();
}

class _CreateAgentState extends State<CreateAgent> {
  final _formKey = GlobalKey<FormState>();
  createUserModel? userdata;

  final name = TextEditingController();
  final unit = TextEditingController();
  final mail = TextEditingController();
  final password = TextEditingController();
  final adhar = TextEditingController();
  final pan = TextEditingController();
  final phone = TextEditingController();
  final state = TextEditingController();

  File? aadhaarImage;
  File? pancardImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUnit();
  }

  Future<void> _loadUnit() async {
    final prefs = await SharedPreferences.getInstance();
    unit.text = prefs.getString('unit') ?? '';
  }

  Future<void> _pickImage(bool isAadhaar) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isAadhaar) aadhaarImage = File(picked.path);
        else pancardImage = File(picked.path);
      });
    }
  }

  // FIXED: Correct way to check internet
  Future<bool> _isOnline() async {
    final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    return results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn);
  }

  Future<void> _saveOffline() async {
    final aadhaar64 = aadhaarImage != null
        ? base64Encode(await aadhaarImage!.readAsBytes())
        : "";
    final pan64 = pancardImage != null
        ? base64Encode(await pancardImage!.readAsBytes())
        : "";

    try {
      await DBHelper().insertAgent({
        'name': name.text,
        'unit': unit.text,
        'email': mail.text,
        'password': password.text,
        'aadhar_number': adhar.text,
        'pan_number': pan.text,
        'state': state.text,
        'phone': phone.text,
        'aadhar_base64': aadhaar64,
        'pan_base64': pan64,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Saved offline. Will sync when online"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save offline: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final bool online = await _isOnline();

    if (!online) {
      await _saveOffline();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final unitName = prefs.getString('unit');

    final aadhaar64 = aadhaarImage != null
        ? base64Encode(await aadhaarImage!.readAsBytes())
        : "";
    final pan64 = pancardImage != null
        ? base64Encode(await pancardImage!.readAsBytes())
        : "";

    try {
      final response = await http.post(
        Uri.parse(CommonApiClass.CreateAgent),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {
            "token": token,
            "name": name.text,
            "email": mail.text,
            "password": password.text,
            "role": "agent",
            "aadhar_number": adhar.text,
            "pan_number": pan.text,
            "state": state.text,
            "status": "un_activ",
            "phone": phone.text,
            "unit_name": unitName,
            "aadhar_base64": aadhaar64,
            "Pan_base64": pan64,
          }
        }),
      ).timeout(Duration(seconds: 20));

      final json = jsonDecode(response.body);
      userdata = createUserModel.fromJson(json);

      if (userdata?.result?.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Staff created successfully!")),
        );
        Navigator.pop(context);
      } else {
        await _saveOffline(); // fallback
      }
    } catch (e) {
      await _saveOffline();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Staff"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _field(name, loc.name, loc.enteravalidname),
                _field(unit, loc.unit1, "", readOnly: true),
                _field(phone, loc.phone, loc.entervalidphone, keyboard: TextInputType.phone, max: 10),
                _field(mail, "UserId", loc.entervalidemail, keyboard: TextInputType.emailAddress),
                _field(password, loc.password, loc.entervalidpassword),
                _field(state, loc.address, loc.addressCantBeEmpty),
                _field(
                  adhar,
                  loc.aadhar,
                  loc.invalidAadhaar,
                  keyboard: TextInputType.number,
                  max: 12,
                  validator: (v) => v?.length == 12 ? null : loc.aadhaarmustbe12digits,
                ),

                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 55),
                  ),
                  child: Text(loc.createUser, style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint,
    String err, {
    TextInputType? keyboard,
    int? max,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: ctrl,
        readOnly: readOnly,
        keyboardType: keyboard,
        maxLength: max,
        validator: validator ?? (v) => v!.isEmpty ? err : null,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
        ),
      ),
    );
  }
}