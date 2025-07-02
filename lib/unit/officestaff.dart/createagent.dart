import 'dart:convert';
import 'dart:io';

import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/modelclasses/createagentmodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class createagent extends StatefulWidget {
  const createagent({super.key});

  @override
  State<createagent> createState() => _createagentState();
}

class _createagentState extends State<createagent> {
  createUserModel? userdata;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController name = TextEditingController();
  final TextEditingController unit = TextEditingController();
  final TextEditingController mail = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController adhar = TextEditingController();
  final TextEditingController pan = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController state = TextEditingController();

  File? aadhaarImage;
  File? pancardImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickAadhaarImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        aadhaarImage = File(image.path);
      });
    }
  }

  Future<void> pickPancardImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        pancardImage = File(image.path);
      });
    }
  }

  Future<void> createuser() async {
    print("🚀 createuser() called");

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userlog = prefs.getString('apikey');

    try {
      final url = CommonApiClass.CreateAgent;

      final String aadhaarBase64 = aadhaarImage != null
          ? base64Encode(await aadhaarImage!.readAsBytes())
          : "";

      final String panBase64 = pancardImage != null
          ? base64Encode(await pancardImage!.readAsBytes())
          : "";

      print("📤 Token: $userlog");

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {
            "token": userlog.toString(),
            "name": name.text,
            "email": mail.text,
            "password": password.text,
            "role": 'agent',
            "aadhar_number": adhar.text,
            "pan_number": pan.text,
            "state": state.text,
            "status": "un_activ",
            "phone": phone.text,
            "unit_name": unit.text,
            "aadhar_base64": aadhaarBase64,
            "Pan_base64": panBase64,
          }
        }),
      );

      print("📡 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        userdata = createUserModel.fromJson(jsonResponse);
        print("✅ Response Code: ${userdata!.result?.success}");

        if (userdata!.result?.success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User created successfully")),
          );
          Navigator.pop(context); // Navigate back to previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User creation failed")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (error, stackTrace) {
      print("❌ Error: $error");
      print("📛 StackTrace: $stackTrace");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          "Create Agent",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height / 34,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                usercredentials(
                  controller: name,
                  hintText: "Name",
                  errorText: "Please enter a valid name",
                ),
                usercredentials(
                  controller: unit,
                  hintText: "Unit Name",
                  errorText: "Please enter a valid unit name",
                ),
                usercredentials(
                  keyboardType: TextInputType.phone,
                  maxvalue: 10,
                  controller: phone,
                  hintText: "Phone",
                  errorText: "Please enter a valid phone number",
                ),
                usercredentials(
                  controller: mail,
                  hintText: "Email/User ID",
                  errorText: "Please enter a valid email",
                  keyboardType: TextInputType.emailAddress,
                ),
                usercredentials(
                  controller: password,
                  hintText: "Password",
                  errorText: "Please enter a valid password",
                  keyboardType: TextInputType.visiblePassword,
                ),
                usercredentials(
                  controller: state,
                  hintText: "Address",
                  errorText: "Address cannot be empty",
                ),
                usercredentials(
                  controller: adhar,
                  hintText: "Aadhaar Number",
                  errorText: "Invalid Aadhaar Number",
                  keyboardType: TextInputType.number,
                  maxvalue: 12,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Aadhaar number";
                    }
                    final aadhaarRegex = RegExp(r'^\d{12}$');
                    if (!aadhaarRegex.hasMatch(value)) {
                      return "Aadhaar must be exactly 12 digits";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Upload Aadhaar Photo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: pickAadhaarImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.black),
                    ),
                    child: aadhaarImage != null
                        ? Image.file(aadhaarImage!, fit: BoxFit.cover)
                        : const Center(child: Text("Tap to select Aadhaar image")),
                  ),
                ),
                const SizedBox(height: 16),
                usercredentials(
                  controller: pan,
                  hintText: "PAN Number",
                  errorText: "Invalid PAN Number",
                  maxvalue: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter PAN number";
                    }
                    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
                    if (!panRegex.hasMatch(value.toUpperCase())) {
                      return "PAN format: ABCDE1234F";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Upload PAN Card Photo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: pickPancardImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.black),
                    ),
                    child: pancardImage != null
                        ? Image.file(pancardImage!, fit: BoxFit.cover)
                        : const Center(child: Text("Tap to select PAN card image")),
                  ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      print("✅ Form is valid");
                      await createuser();
                    } else {
                      print("❌ Form is invalid");
                    }
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height / 18,
                    width: MediaQuery.of(context).size.width / 2.5,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        "Create User",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class usercredentials extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String errorText;
  final int? maxvalue;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const usercredentials({
    required this.controller,
    required this.hintText,
    required this.errorText,
    this.maxvalue,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        maxLength: maxvalue,
        keyboardType: keyboardType ?? TextInputType.text,
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return errorText;
          }
          return null;
        },
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          filled: true,
          fillColor: Colors.blueGrey[200],
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
        ),
      ),
    );
  }
}
