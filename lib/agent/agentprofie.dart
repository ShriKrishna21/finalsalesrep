import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/modelclasses/userlogoutmodel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class agentProfile extends StatefulWidget {
  const agentProfile({super.key});

  @override
  State<agentProfile> createState() => _AgentProfileState();
}

class _AgentProfileState extends State<agentProfile> {
  String? agentname;
  String? unitname;
  String? jobrole;
  String? userid;
  userlogout? logoutt;
  Uint8List? _imageBytes;
  File? _selectedImage;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _selectedImage = File(pickedFile.path);
    });

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('apikey');
    final int? userId = prefs.getInt('id');

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token or User ID is missing")),
      );
      return;
    }

    final bytes = await pickedFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    print("Token: $token");
    print("User ID: $userId");
    print("Image size: ${base64Image.length}");

    final url = 'https://salesrep.esanchaya.com/api/upload_user_image';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {
            "token": token,
            "user_id": userId,
            "image": base64Image,
          }
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print("Upload Response: $responseBody");

        final result = responseBody["result"];
        final message = result?["message"] ?? "Unknown error";
        final code = result?["code"];

        if (code == "200" ||
            message.toString().toLowerCase().contains("uploaded")) {
          await prefs.setString('profile_image_base64', base64Image);
          setState(() {
            _imageBytes = base64Decode(base64Image);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Profile image uploaded successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload image: $message")),
          );
        }
      } else {
        print("Upload HTTP error: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error uploading image")),
        );
      }
    } catch (error) {
      print("Error uploading image: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred while uploading the image")),
      );
    }
  }

  Future<void> agentLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? apiKey = prefs.getString('apikey');
    print("API Key: $apiKey");

    try {
      // Note: Verify that CommonApiClass.agentProfile is the correct logout endpoint
      final url = CommonApiClass
          .agentProfile; // Replace with correct logout endpoint if needed
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": apiKey.toString()}
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        logoutt = userlogout.fromJson(jsonResponse);
      }

      if (logoutt != null && logoutt!.result!.code == "200") {
        await prefs.clear();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Loginscreen()),
          (Route<dynamic> route) => false,
        );
        print("Logout Success");
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Log out failed")),
        );
      }
    } catch (error) {
      print("Error: $error");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred during logout")),
      );
    }
  }

  Future<bool> stopWork() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        imageQuality: 80,
      );

      if (photo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo required")),
        );
        return false;
      }

      final bytes = await photo.readAsBytes();
      final photoBase64 = base64Encode(bytes);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('apikey');

      if (token == null || token.isEmpty) {
        print("❌ Missing or empty API key");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Missing or invalid API key")),
        );
        return false;
      }

      print("📡 Hitting API: https://salesrep.esanchaya.com/api/end_work");

      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/api/end_work"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {
            "token": token,
            "selfie": photoBase64,
          }
        }),
      );

      print("🔁 Status Code: ${response.statusCode}");
      print("✅ Response: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)['result'];
        if (result != null && result['success'] == true) {
          await prefs.setBool('isWorking', false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Work stopped")),
          );
          return true;
        } else {
          final errorMessage = result?['message'] ?? 'Unknown error';
          print("❌ Failed to stop work: $errorMessage");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to stop work: $errorMessage")),
          );
          return false;
        }
      } else {
        print("❌ Failed to stop work: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to stop work: ${response.statusCode}")),
        );
        return false;
      }
    } catch (e) {
      print("❌ Error stopping work: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error stopping work: $e")),
      );
      return false;
    }
  }

  Future<void> handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? isWorking = prefs.getBool('isWorking');

    if (isWorking == true) {
      final bool? confirmStop = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("stopworkrequired"),
            content: Text("needtostopworkbeforelogout"),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.cancel,
                    style: const TextStyle(color: Colors.black)),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.stopwork,
                    style: const TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirmStop == true) {
        final bool stopped = await stopWork();
        if (stopped) {
          agentLogout();
        }
      }
    } else {
      agentLogout();
    }
  }

  @override
  void initState() {
    super.initState();
    loadSavedData(); // Rename the method
  }

  Future<void> loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      agentname = prefs.getString('name');
      userid = prefs.getInt('id')?.toString();
      jobrole = prefs.getString('role');
      unitname = prefs.getString('unit');

      String? base64Image = prefs.getString('profile_image_base64');
      if (base64Image != null) {
        if (base64Image.startsWith('data:image')) {
          base64Image = base64Image.split(',').last;
        }
        try {
          _imageBytes = base64Decode(base64Image);
        } catch (e) {
          print("Error decoding base64 image: $e");
          _imageBytes = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          localizations.myProfile,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadSavedData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.black12,
                    backgroundImage:
                        _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                    child: _imageBytes == null
                        ? const Icon(Icons.person,
                            size: 60, color: Colors.black54)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 150,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileItem(
                      title: localizations.name, value: agentname ?? "-"),
                  ProfileItem(
                      title: localizations.userid, value: userid ?? "-"),
                  ProfileItem(
                      title: localizations.jobRole, value: "staff"),
                  ProfileItem(
                      title: localizations.unitName, value: unitname ?? "-"),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(localizations.confirmlogout,
                              style: const TextStyle(color: Colors.black)),
                          content: Text(localizations.areyousureyouwanttologout,
                              style: const TextStyle(color: Colors.black)),
                          actions: [
                            TextButton(
                              child: Text(localizations.cancel,
                                  style: const TextStyle(color: Colors.black)),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: Text(localizations.logout,
                                  style: const TextStyle(color: Colors.red)),
                              onPressed: () {
                                Navigator.of(context).pop();
                                handleLogout();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(localizations.logout,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  const ProfileItem({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontSize: 16, color: Colors.black))),
          const Text(":", style: TextStyle(fontSize: 16, color: Colors.black)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
