import 'dart:convert';
import 'dart:io';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finalsalesrep/common_api_class.dart';

class createstaff extends StatefulWidget {
  const createstaff({super.key});

  @override
  State<createstaff> createState() => _createstaffState();
}

class _createstaffState extends State<createstaff> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController name = TextEditingController();
  final TextEditingController unit = TextEditingController();
  final TextEditingController mail = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController adhar = TextEditingController();
  final TextEditingController pan = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController state = TextEditingController();

  // Role dropdown
  String selectedRole = 'agent';
  final List<Map<String, String>> roles = [
    {'value': 'agent', 'label': 'Agent'},
    {'value': 'Office_staff', 'label': 'Office Staff'},
  ];

  // Images
  File? aadhaarImage;
  File? pancardImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickAadhaarImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => aadhaarImage = File(image.path));
    }
  }

  Future<void> pickPancardImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => pancardImage = File(image.path));
    }
  }

  Future<void> createuser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userlog = prefs.getString('apikey');

    if (userlog == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("API key not found. Please login again.")),
      );
      return;
    }

    try {
      final url = CommonApiClass.createregionalhead;

      final String aadhaarBase64 = aadhaarImage != null
          ? base64Encode(await aadhaarImage!.readAsBytes())
          : "";

      final String panBase64 = pancardImage != null
          ? base64Encode(await pancardImage!.readAsBytes())
          : "";

      final body = {
        "params": {
          "token": userlog,
          "name": name.text.trim(),
          "email": mail.text.trim(),
          "password": password.text.trim(),
          "role": selectedRole,
          "aadhar_number": adhar.text.trim(),
          "pan_number": pan.text.trim(),
          "state": state.text.trim(),
          "status": "active",
          "phone": phone.text.trim(),
          "unit_name": unit.text.trim(),
          "aadhar_base64": aadhaarBase64,
          "Pan_base64": panBase64,
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final jsonResponse = jsonDecode(response.body);
      print("📡 Response: $jsonResponse");

      final result = jsonResponse['result'];
      final bool success = result['success'] == true;
      final String message = result['message'] ?? "Unknown response";

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ $message")),
        );
        Navigator.pop(context); // pop on success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: $message")),
        );
      }
    } catch (error) {
      print("❌ Error in creating user: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Something went wrong. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final Localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          Localizations.createUser,
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
                usercredentials(
                    controller: name,
                    hintText: Localizations.name,
                    errorText: Localizations.enteravalidname),
                usercredentials(
                    controller: unit,
                    hintText: Localizations.unitName,
                    errorText: Localizations.enteravalidunitname),
                usercredentials(
                    controller: phone,
                    hintText: Localizations.phone,
                    errorText: Localizations.enteravalidphonenumber,
                    keyboardType: TextInputType.phone,
                    maxvalue: 10),
                usercredentials(
                    controller: mail,
                    hintText: Localizations.emailOrUserId,
                    errorText: Localizations.enteravalidemail,
                    keyboardType: TextInputType.emailAddress),
                usercredentials(
                    controller: password,
                    hintText: Localizations.password,
                    errorText: Localizations.passwordrequired,
                    keyboardType: TextInputType.visiblePassword),
                usercredentials(
                    controller: state,
                    hintText: Localizations.address,
                    errorText: Localizations.addressrequired),

                // Role Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: roles
                        .map((role) => DropdownMenuItem<String>(
                              value: role['value'],
                              child: Text(role['label']!),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedRole = value);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: Localizations.selectrole,
                      filled: true,
                      fillColor: Colors.blueGrey[200],
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2)),
                    ),
                  ),
                ),

                usercredentials(
                  controller: adhar,
                  hintText: Localizations.aadharNumber,
                  errorText: Localizations.invalidaadhaarnumber,
                  keyboardType: TextInputType.number,
                  maxvalue: 12,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Localizations.aadhaarnumber;
                    }
                    if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                      return "Must be 12 digits";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),
                _uploadLabel(Localizations.uploadAadharPhoto),
                _imageSelector(aadhaarImage, pickAadhaarImage),

                const SizedBox(height: 16),
                usercredentials(
                  controller: pan,
                  hintText: Localizations.panNumber,
                  errorText: Localizations.invalidpannumber,
                  maxvalue: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter PAN number";
                    }
                    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$')
                        .hasMatch(value.toUpperCase())) {
                      return "Format: ABCDE1234F";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _uploadLabel(Localizations.uploadPanCardPhoto),
                _imageSelector(pancardImage, pickPancardImage),

                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      await createuser();
                    }
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height / 18,
                    width: MediaQuery.of(context).size.width / 2.5,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(
                        Localizations.createUser,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                10 + MediaQuery.of(context).size.height / 500),
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

  Widget _uploadLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _imageSelector(File? imageFile, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.grey[300], border: Border.all(color: Colors.black)),
        child: imageFile != null
            ? Image.file(imageFile, fit: BoxFit.cover)
            : Center(
                child: Text(AppLocalizations.of(context)!.taptoselectimage)),
      ),
    );
  }
}

// Reusable Input Field Widget
class usercredentials extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String errorText;
  final int? maxvalue;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const usercredentials({
    super.key,
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
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        maxLength: maxvalue,
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) return errorText;
              return null;
            },
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          filled: true,
          fillColor: Colors.blueGrey[200],
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2)),
        ),
      ),
    );
  }
}
