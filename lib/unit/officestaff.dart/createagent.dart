import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/modelclasses/createagentmodel.dart';

class CreateAgent extends StatefulWidget {
  const CreateAgent({super.key});

  @override
  State<CreateAgent> createState() => _CreateAgentState();
}

class _CreateAgentState extends State<CreateAgent> {
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

  @override
  void initState() {
    super.initState();
    _loadUnitFromPrefs();
  }

  Future<void> _loadUnitFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String unitName = prefs.getString('unit') ?? '';
    setState(() {
      unit.text = unitName;
    });
  }

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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userlog = prefs.getString('apikey');
    final String? unitName = prefs.getString('unit');

    try {
      final url = CommonApiClass.CreateAgent;
      final String aadhaarBase64 = aadhaarImage != null ? base64Encode(await aadhaarImage!.readAsBytes()) : "";
      final String panBase64 = pancardImage != null ? base64Encode(await pancardImage!.readAsBytes()) : "";

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
            "unit_name": unitName,
            "aadhar_base64": aadhaarBase64,
            "Pan_base64": panBase64,
          }
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        userdata = createUserModel.fromJson(jsonResponse);

        if (userdata!.result?.success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User created successfully")),
          );
          Navigator.pop(context);
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
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Agent"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                usercredentials(controller: name, hintText: "Name", errorText: "Enter a valid name"),
                usercredentials(controller: unit, hintText: "Unit Name", errorText: "Unit not found", readOnly: true),
                usercredentials(controller: phone, hintText: "Phone", errorText: "Enter valid phone", keyboardType: TextInputType.phone, maxvalue: 10),
                usercredentials(controller: mail, hintText: "Email", errorText: "Enter valid email", keyboardType: TextInputType.emailAddress),
                usercredentials(controller: password, hintText: "Password", errorText: "Enter valid password", keyboardType: TextInputType.visiblePassword),
                usercredentials(controller: state, hintText: "Address", errorText: "Address can't be empty"),
                usercredentials(
                  controller: adhar,
                  hintText: "Aadhaar Number",
                  errorText: "Invalid Aadhaar",
                  keyboardType: TextInputType.number,
                  maxvalue: 12,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter Aadhaar number";
                    return RegExp(r'^\d{12}\$').hasMatch(value) ? null : "Aadhaar must be 12 digits";
                  },
                ),
                const SizedBox(height: 10),
                uploadImageLabel("Upload Aadhaar Photo"),
                imagePickerBox(aadhaarImage, pickAadhaarImage),
                const SizedBox(height: 16),
                usercredentials(
                  controller: pan,
                  hintText: "PAN Number",
                  errorText: "Invalid PAN Number",
                  maxvalue: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter PAN number";
                    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]\$').hasMatch(value.toUpperCase()) ? null : "PAN must be like ABCDE1234F";
                  },
                ),
                uploadImageLabel("Upload PAN Card Photo"),
                imagePickerBox(pancardImage, pickPancardImage),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await createuser();
                    }
                  },
                  child: const Text("Create User", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget uploadImageLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget imagePickerBox(File? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.grey[300], border: Border.all(color: Colors.black)),
        child: image != null ? Image.file(image, fit: BoxFit.cover) : const Center(child: Text("Tap to select image")),
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
  final bool readOnly;

  const usercredentials({
    required this.controller,
    required this.hintText,
    required this.errorText,
    this.maxvalue,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLength: maxvalue,
        keyboardType: keyboardType ?? TextInputType.text,
        readOnly: readOnly,
        validator: validator ?? (value) => (value == null || value.isEmpty) ? errorText : null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          filled: true,
          fillColor: Colors.blueGrey[200],
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
        ),
      ),
    );
  }
}
