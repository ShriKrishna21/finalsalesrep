import 'dart:convert';
import 'dart:io';

import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/modelclasses/createagentmodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Createincharge extends StatefulWidget {
  const Createincharge({super.key});

  @override
  State<Createincharge> createState() => _createunitsState();
}

class _createunitsState extends State<Createincharge> {
  createUserModel? userdata;
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
    {'value': 'office_staff', 'label': 'Office Staff'},
    {'value': 'unit_manager', 'label': 'Unit Manager'},
    {'value': 'segment_incharge', 'label': 'Segment Incharge'},
    {'value': 'circulation_incharge', 'label': 'Circulation Incharge'},
    {'value': 'region_head', 'label': 'Regional Head'},
  ];

  // Images
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userlog = prefs.getString('apikey');

    try {
      final url = CommonApiClass.createregionalhead;

      final String aadhaarBase64 = aadhaarImage != null
          ? base64Encode(await aadhaarImage!.readAsBytes())
          : "";

      final String panBase64 = pancardImage != null
          ? base64Encode(await pancardImage!.readAsBytes())
          : "";

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {
            "token": userlog.toString(),
            "name": name.text,
            "email": mail.text,
            "password": password.text,
            "role": selectedRole,
            "aadhar_number": adhar.text,
            "pan_number": pan.text,
            "state": state.text,
            "status": "active",
            "phone": phone.text,
            "unit_name": unit.text,
            "aadhar_base64": aadhaarBase64,
            "Pan_base64": panBase64,
          }
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        userdata = createUserModel.fromJson(jsonResponse);

        if (userdata!.result?.success == "200") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User created successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User creation failed")),
          );
        }
      }
    } catch (error) {
      print("Error in creating user: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Center(
          child: Text(
            localizations.createincharge,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height / 34,
              fontWeight: FontWeight.bold,
            ),
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
                  hintText: localizations.name,
                  errorText: localizations.enteravalidname,
                ),
                usercredentials(
                  controller: unit,
                  hintText: localizations.unitName,
                  errorText: localizations.unitnamecantbeempty,
                ),
                usercredentials(
                  keyboardType: TextInputType.phone,
                  maxvalue: 10,
                  controller: phone,
                  hintText: localizations.phone,
                  errorText: localizations.enteravalidphonenumber,
                ),
                usercredentials(
                  controller: mail,
                  hintText: localizations.emailOrUserId,
                  errorText: localizations.enteravalidemail,
                  keyboardType: TextInputType.emailAddress,
                ),
                usercredentials(
                  controller: password,
                  hintText: localizations.password,
                  errorText: localizations.pleaseenteravalidpassword,
                  keyboardType: TextInputType.visiblePassword,
                ),
                usercredentials(
                  controller: state,
                  hintText: localizations.address,
                  errorText: localizations.addressCantBeEmpty,
                ),

                // ✅ Role dropdown
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
                        setState(() {
                          selectedRole = value;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: localizations.selectrole,
                      filled: true,
                      fillColor: Colors.blueGrey[200],
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 16.0),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                ),

                usercredentials(
                  controller: adhar,
                  hintText: localizations.aadhaarnumber,
                  errorText: localizations.invalidaadhaarnumber,
                  keyboardType: TextInputType.number,
                  maxvalue: 12,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.pleaseenteraadhaarnumber;
                    }
                    final aadhaarRegex = RegExp(r'^\d{12}$');
                    if (!aadhaarRegex.hasMatch(value)) {
                      return localizations.aadhaarmustbe12digits;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(localizations.uploadAadharPhoto,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        : Center(
                            child: Text(localizations.tapToSelectAadharImage),
                          ),
                  ),
                ),

                const SizedBox(height: 16),
                usercredentials(
                  controller: pan,
                  hintText: localizations.panNumber,
                  errorText: localizations.invalidpannumber,
                  maxvalue: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.enterpannumber;
                    }
                    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
                    if (!panRegex.hasMatch(value.toUpperCase())) {
                      return localizations.panmustbelikeABCDE1234F;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(localizations.uploadPanCardPhoto,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        : Center(
                            child: Text(localizations.tapToSelectPanCardImage),
                          ),
                  ),
                ),

                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      await createuser();
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height / 18,
                    width: MediaQuery.of(context).size.width / 2.5,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        localizations.createUser,
                        textAlign: TextAlign.center,
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

// 🔁 Reusable Input Field Widget
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
        maxLength: maxvalue,
        keyboardType: keyboardType ?? TextInputType.text,
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return errorText;
              }
              return null;
            },
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          filled: true,
          fillColor: Colors.blueGrey[200],
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
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
