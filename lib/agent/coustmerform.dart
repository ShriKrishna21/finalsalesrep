import 'dart:convert';
import 'dart:io';
import 'package:finalsalesrep/agent/agentscreen.dart';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/locallllllllllll_db.dart' show DBHelper;
import 'package:finalsalesrep/modelclasses/assignagency.dart';
import 'package:finalsalesrep/modelclasses/agencymodel.dart';
import 'package:finalsalesrep/offline/connecticityhelper.dart';
import 'package:finalsalesrep/offline/localdb.dart';
import 'package:finalsalesrep/offline/syncmanager.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// Placeholder customerform class
class coustmerform {
  Result? result;
  coustmerform({this.result});
  coustmerform.fromJson(Map<String, dynamic> json) {
    result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}

class Result {
  String? code;
  String? message;
  Result({this.code, this.message});
  Result.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    return data;
  }
}

// OTP model class
class otp {
  String? jsonrpc;
  Null id;
  OtpResult? result;
  otp({this.jsonrpc, this.id, this.result});
  otp.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'];
    id = json['id'];
    result = json['result'] != null ? OtpResult.fromJson(json['result']) : null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['jsonrpc'] = jsonrpc;
    data['id'] = id;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}

class OtpResult {
  String? status;
  String? message;
  OtpResult({this.status, this.message});
  OtpResult.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Coustmer extends StatefulWidget {
  const Coustmer({super.key});
  @override
  State<Coustmer> createState() => _CoustmerState();
}

class _CoustmerState extends State<Coustmer> {
  File? faceImage;
  final ImagePicker _picker = ImagePicker();
  bool _isOnline = false;
  bool _isofferTogle = false;
  bool _isemployed = false;
  bool _isLoading = false;
  int offerintresetedpeople = 0;
  int offernotintresetedpeople = 0;
  int count = 0;
  int addcount = 0;
  String latitude = "";
  String longitude = "";
  String? locationUrl = "";
  File? locationImage;
  String? _selectedJobType;
  String? _selectedGovDepartment;
  String? _selectedproffesion;
  String? _selectedPrivateProfession;
  String? _selectedCustomerType;
  String? _selectedPreviousNewspaper;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  TextEditingController agency = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController promoter = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController datecontroller = TextEditingController();
  TextEditingController timecontroller = TextEditingController();
  TextEditingController familyhead = TextEditingController();
  TextEditingController fathersname = TextEditingController();
  TextEditingController mothername = TextEditingController();
  TextEditingController spousename = TextEditingController();
  TextEditingController hno = TextEditingController();
  TextEditingController streetnumber = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController adddress = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController reason_for_not_taking_eenadu = TextEditingController();
  TextEditingController job_designation = TextEditingController();
  TextEditingController job_proffesion = TextEditingController();
  TextEditingController privateCompanyController = TextEditingController();
  TextEditingController privatedesignationController = TextEditingController();
  TextEditingController privateProffesionController = TextEditingController();
  TextEditingController locationUrlController = TextEditingController();
  TextEditingController faceBase64Controller = TextEditingController();
  TextEditingController otherNewspaperController = TextEditingController();
  TextEditingController startCirculationController = TextEditingController();
  // NEW: Quantity Controller and Variable
  TextEditingController quantityController = TextEditingController(text: "1");
  int quantity = 1;
  String agents = '';
  List<String> jobTypes = ["government_job", "private_job"];
  List<String> govDepartments = ["Central", "PSU", "State"];
  List<String> privateJobProfessions = [
    "Software Engineer",
    "Accountant",
    "Marketing Manager",
    "Sales Executive",
    "Graphic Designer",
    "HR Manager",
    "Project Manager",
    "Data Analyst",
    "Consultant",
    "Engineer",
    "Other"
  ];
  List<String> proffesion = ["farmer", "doctor", "teacher", "lawyer", "Artist"];
  List<String> previousNewspapers = [
    "Sakshi",
    "Andhra Jyothi",
    "Namasthe Telangana",
    "Deccan Chronicle",
    "Times Of India",
    "The Hindu",
    "Others"
  ];
  List<String> customerTypes = ["New User", "Conversion"];
  coustmerform? data;
  @override
  void initState() {
    super.initState();
    datecontroller.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    timecontroller.text = DateFormat('hh:mm a').format(DateTime.now());
    startCirculationController.text = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().add(const Duration(days: 1)));
    quantityController.text = "1";
    quantity = 1;
    _loadSavedData();
    getCurrentLocation();
    ConnectivityHelper().startListening((online) {
      setState(() {
        _isOnline = online;
      });
      _loadSavedData(); // Reload agency data on connectivity change
      if (online) {
        _syncPending();
      }
    });
  }

  Future<void> _syncPending() async {
    final prefs = await SharedPreferences.getInstance();
    final agentapi = prefs.getString('apikey');
    if (agentapi != null) {
      await SyncManager().syncPendingForms(agentapi);
    }
  }

  Future<void> handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    Map<String, dynamic> formMap = {
      "agent_name": agents,
      "agent_login": await SharedPreferences.getInstance()
          .then((p) => p.getString('agentlogin')),
      "unit_name": await SharedPreferences.getInstance()
          .then((p) => p.getString('unit')),
      "Agency": agency.text,
      "promoter": promoter.text,
      "date": datecontroller.text,
      "time": timecontroller.text,
      "family_head_name": familyhead.text,
      "father_name": fathersname.text,
      "mother_name": mothername.text,
      "spouse_name": spousename.text,
      "age": age.text,
      "house_number": hno.text,
      "street_number": streetnumber.text,
      "city": city.text,
      "pin_code": pincode.text,
      "address": adddress.text,
      "mobile_number": mobile.text,
      "reason_for_not_taking_eenadu_newsPaper":
          reason_for_not_taking_eenadu.text,
      "customer_type": _selectedCustomerType,
      "current_newspaper": _selectedCustomerType == "Conversion"
          ? (_selectedPreviousNewspaper ?? otherNewspaperController.text)
          : null,
      "free_offer_15_days": _isofferTogle,
      "employed": _isemployed,
      "job_type": _selectedJobType,
      "job_type_one": _selectedGovDepartment,
      "job_profession": job_proffesion.text,
      "job_designation": job_designation.text,
      "company_name": privateCompanyController.text,
      "profession": _selectedPrivateProfession == "Other"
          ? privateProffesionController.text
          : _selectedPrivateProfession ?? "",
      "job_designation_one": privatedesignationController.text,
      "latitude": latitude,
      "longitude": longitude,
      "street": streetController.text,
      "place": city.text,
      "location_address": landmarkController.text,
      "location_url": locationUrlController.text,
      "face_base64": faceBase64Controller.text,
      "Start_Circulating": startCirculationController.text,
      "quantity": quantity, // NEW: Quantity saved locally
    };
    if (!_isOnline) {
      await LocalDb().insertForm(formMap);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet: Form saved locally')),
      );
      await _refreshForm();
      return;
    }
    bool otpSent = await _sendOtp();
    if (!otpSent) return;
    _showOtpDialog();
  }

  @override
  void dispose() {
    _otpController.dispose();
    agency.dispose();
    streetController.dispose();
    landmarkController.dispose();
    promoter.dispose();
    age.dispose();
    datecontroller.dispose();
    timecontroller.dispose();
    familyhead.dispose();
    fathersname.dispose();
    mothername.dispose();
    spousename.dispose();
    hno.dispose();
    streetnumber.dispose();
    city.dispose();
    pincode.dispose();
    adddress.dispose();
    mobile.dispose();
    reason_for_not_taking_eenadu.dispose();
    job_designation.dispose();
    job_proffesion.dispose();
    privateCompanyController.dispose();
    privatedesignationController.dispose();
    privateProffesionController.dispose();
    locationUrlController.dispose();
    faceBase64Controller.dispose();
    otherNewspaperController.dispose();
    startCirculationController.dispose();
    quantityController.dispose(); // NEW
    super.dispose();
  }

  // ... [All other methods like pickFaceImage, getCurrentLocation, etc. remain unchanged] ...
  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? agentapi = prefs.getString('apikey');
    setState(() {
      agents = prefs.getString('name') ?? '';
      promoter.text = agents;
    });
    if (_isOnline) {
      try {
        final response = await http.post(
          Uri.parse(
              "https://salesrep.esanchaya.com/api/get_current_pin_location"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "params": {
              "token": agentapi,
            }
          }),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final agencyModel = assignagencymodel.fromJson(data);
          if (agencyModel.result?.success == true &&
              agencyModel.result?.data != null) {
            final agencyData = agencyModel.result!.data!;
            final agencyText = "${agencyData.locationName ?? 'Unknown'} ";
            setState(() {
              if (agency.text.isEmpty) {
                agency.text = agencyText;
              }
            });
          }
        }
      } catch (e) {
        debugPrint("Error fetching agency: $e");
      }
    } else {
      // Offline: Load from local SQLite DB
      final assigned = await DBHelper.instance.getAssignedAgency();
      if (assigned != null) {
        final agencyText = "${assigned['location_name'] ?? 'Unknown'}";
        setState(() {
          agency.text = agencyText;
        });
      } else {
        setState(() {
          agency.text = '';
        });
      }
    }
  }

  Future<void> pickFaceImage() async {
    final XFile? img = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() {
        faceImage = File(img.path);
        faceBase64Controller.text = base64Encode(bytes);
      });
    }
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
      return;
    }
    if (!_isOnline) return;
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=${currentPosition.latitude},${currentPosition.longitude}";
      setState(() {
        latitude = currentPosition.latitude.toString();
        longitude = currentPosition.longitude.toString();
        locationUrl = googleMapsUrl;
        if (locationUrlController.text.isEmpty) {
          locationUrlController.text = googleMapsUrl;
        }
      });
      List<Placemark> placemarks = await placemarkFromCoordinates(
          currentPosition.latitude, currentPosition.longitude);
      Placemark placemark = placemarks[0];
      setState(() {
        if (streetController.text.isEmpty)
          streetController.text = placemark.street ?? "";
        if (city.text.isEmpty) city.text = placemark.locality ?? "";
        if (landmarkController.text.isEmpty)
          landmarkController.text = placemark.name ?? "";
        if (adddress.text.isEmpty) {
          final s = placemark.street ?? "";
          final l = placemark.locality ?? "";
          adddress.text = [s, l].where((e) => e.isNotEmpty).join(", ");
        }
        if (pincode.text.isEmpty) pincode.text = placemark.postalCode ?? "";
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching address: $e")),
        );
      }
    }
  }

  Future<void> _launchUrl(Uri url) async {
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Launch error: $e');
    }
  }

  Future<bool> _sendOtp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? agentapi = prefs.getString('apikey');
    final String phone = mobile.text.trim();
    if (agentapi == null || phone.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid token or phone number')),
      );
      return false;
    }
    final requestBody = {
      "params": {
        "token": agentapi,
        "phone": int.tryParse(phone) ?? 0,
      }
    };
    try {
      final response = await http.post(
        Uri.parse('https://salesrep.esanchaya.com/api/send_otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: ${response.statusCode}')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending OTP: $e')),
      );
      return false;
    }
  }

  Future<bool> _verifyOtp(String otpCode) async {
    final prefs = await SharedPreferences.getInstance();
    final String? agentapi = prefs.getString('apikey');
    final String phone = mobile.text.trim();
    if (agentapi == null || phone.isEmpty || otpCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid token, phone, or OTP')),
      );
      return false;
    }
    final requestBody = {
      "params": {
        "token": agentapi,
        "phone": phone,
        "otp": otpCode,
      }
    };
    try {
      final response = await http.post(
        Uri.parse('https://salesrep.esanchaya.com/api/verify_otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final otpResponse = otp.fromJson(jsonResponse);
        if (otpResponse.result?.status == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(otpResponse.result?.message ??
                    'OTP verified successfully')),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(otpResponse.result?.message ?? 'Invalid OTP')),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to verify OTP: ${response.statusCode}')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying OTP: $e')),
      );
      return false;
    }
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'OTP',
              border: OutlineInputBorder(),
            ),
            maxLength: 6,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _otpController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_otpController.text.isNotEmpty) {
                        setState(() => _isLoading = true);
                        final isVerified =
                            await _verifyOtp(_otpController.text);
                        setState(() => _isLoading = false);
                        Navigator.of(context).pop();
                        _otpController.clear();
                        if (isVerified) {
                          await _submitForm();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter OTP')),
                        );
                      }
                    },
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Verify'),
            ),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      final success = await _sendOtp();
                      setState(() => _isLoading = false);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('OTP resent successfully')),
                        );
                      }
                    },
              child: const Text('Resend OTP'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? agentapi = prefs.getString('apikey');
    final String? agentlog = prefs.getString('agentlogin');
    final String? unit = prefs.getString('unit');
    try {
      const url = 'https://salesrep.esanchaya.com/api/customer_form';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "params": {
            "token": agentapi,
            "agent_name": agents,
            "agent_login": agentlog,
            "unit_name": unit,
            "Agency": agency.text,
            "promoter": promoter.text,
            "date": datecontroller.text,
            "time": timecontroller.text,
            "family_head_name": familyhead.text,
            "father_name": fathersname.text,
            "mother_name": mothername.text,
            "spouse_name": spousename.text,
            "age": age.text,
            "house_number": hno.text,
            "street_number": streetnumber.text,
            "city": city.text,
            "pin_code": pincode.text,
            "address": adddress.text,
            "mobile_number": mobile.text,
            "reason_for_not_taking_eenadu_newsPaper":
                reason_for_not_taking_eenadu.text,
            "customer_type": _selectedCustomerType,
            "current_newspaper": _selectedCustomerType == "Conversion"
                ? (_selectedPreviousNewspaper ?? otherNewspaperController.text)
                : null,
            "free_offer_15_days": _isofferTogle,
            "employed": _isemployed,
            "job_type": _selectedJobType,
            "job_type_one": _selectedGovDepartment,
            "job_profession": job_proffesion.text,
            "job_designation": job_designation.text,
            "company_name": privateCompanyController.text,
            "profession": _selectedPrivateProfession == "Other"
                ? privateProffesionController.text
                : _selectedPrivateProfession ?? "",
            "job_designation_one": privatedesignationController.text,
            "latitude": latitude,
            "longitude": longitude,
            "street": streetController.text,
            "place": city.text,
            "location_address": landmarkController.text,
            "location_url": locationUrlController.text,
            "face_base64": faceBase64Controller.text,
            "Start_Circulating": startCirculationController.text,
            "quantity": quantity, // NEW: Sent to server
          }
        }),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          data = coustmerform.fromJson(jsonResponse);
        });
        if (data?.result?.code == "200") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Form submitted successfully")),
          );
          int houseVisited = prefs.getInt("house_visited") ?? 0;
          int targetLeft = prefs.getInt("target_left") ?? 0;
          int offerAccepted = prefs.getInt("offer_accepted") ?? 0;
          int offerRejected = prefs.getInt("offer_rejected") ?? 0;
          houseVisited += 1;
          if (targetLeft > 0) targetLeft -= 1;
          if (_isofferTogle) {
            offerAccepted += 1;
          } else {
            offerRejected += 1;
          }
          await prefs.setInt("house_visited", houseVisited);
          await prefs.setInt("target_left", targetLeft);
          await prefs.setInt("offer_accepted", offerAccepted);
          await prefs.setInt("offer_rejected", offerRejected);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Agentscreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Failed to submit form: ${data?.result?.message ?? 'Unknown error'}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> uploaddata() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      if (_isOnline) {
        final success = await _sendOtp();
        setState(() {
          _isLoading = false;
        });
        if (success) {
          _showOtpDialog();
        }
      } else {
        await handleSubmit();
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  void openGoogleMaps(String? latitude, String? longitude) {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    _launchUrl(url);
  }

  Future<void> _refreshForm() async {
    setState(() {
      _isofferTogle = false;
      _isemployed = false;
      _selectedJobType = null;
      _selectedGovDepartment = null;
      _selectedproffesion = null;
      _selectedPrivateProfession = null;
      _selectedCustomerType = null;
      _selectedPreviousNewspaper = null;
      agency.clear();
      promoter.clear();
      age.clear();
      fathersname.clear();
      mothername.clear();
      spousename.clear();
      familyhead.clear();
      hno.clear();
      streetnumber.clear();
      city.clear();
      pincode.clear();
      adddress.clear();
      mobile.clear();
      reason_for_not_taking_eenadu.clear();
      job_designation.clear();
      job_proffesion.clear();
      privateCompanyController.clear();
      privatedesignationController.clear();
      privateProffesionController.clear();
      locationUrlController.clear();
      faceBase64Controller.clear();
      otherNewspaperController.clear();
      startCirculationController.clear();
      streetController.clear();
      landmarkController.clear();
      datecontroller.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      timecontroller.text = DateFormat('hh:mm a').format(DateTime.now());
      startCirculationController.text = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));
      latitude = "";
      longitude = "";
      locationUrl = "";
      quantity = 1;
      quantityController.text = "1";
    });
    await _loadSavedData();
    await getCurrentLocation();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Form refreshed successfully")),
    );
  }

  Future<void> _selectStartCirculationDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        startCirculationController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        title: const Text(
          "Customer Form",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshForm,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  textformfeild(
                    controller: agency,
                    label: "Agency",
                    need: true,
                    readOnly: _isOnline,
                    hunttext: "Agency cannot be empty",
                  ),
                  const SizedBox(height: 10),
                  textformfeild(
                    controller: promoter,
                    label: "Promoter Name",
                    need: true,
                    hunttext: "Promoter cannot be empty",
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: date(
                          needed: true,
                          Dcontroller: datecontroller,
                          date: "Date",
                          inputType: TextInputType.datetime,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: date(
                          needed: true,
                          Dcontroller: timecontroller,
                          date: "Time",
                          inputType: TextInputType.datetime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Family Details",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  textformfeild(
                    controller: familyhead,
                    label: "Name",
                    hunttext: "Family head name cannot be empty",
                  ),
                  const SizedBox(height: 5),
                  textformfeild(
                    controller: age,
                    label: "Age",
                    hunttext: "Age cannot be empty",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Address Details",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: textformfeild(
                          controller: hno,
                          label: "House Number",
                          hunttext: "House number cannot be empty",
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: textformfeild(
                          controller: streetnumber,
                          hunttext: "Street number cannot be empty",
                          label: "Street No",
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: textformfeild(
                          hunttext: "City cannot be empty",
                          controller: city,
                          label: "City",
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: textformfeild(
                          hunttext: "Pin code cannot be empty",
                          maxvalue: 6,
                          controller: pincode,
                          label: "Pin Code",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  textformfeild(
                    controller: adddress,
                    label: "Address",
                  ),
                  const SizedBox(height: 10),
                  textformfeild(
                    controller: streetController,
                    label: "Street",
                    hunttext: "Street cannot be empty",
                    need: true,
                    readOnly: _isOnline,
                  ),
                  const SizedBox(height: 10),
                  textformfeild(
                    controller: landmarkController,
                    label: "Landmark",
                    hunttext: "Landmark cannot be empty",
                    need: true,
                    readOnly: _isOnline,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Landmark Photo",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: pickFaceImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: faceImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(faceImage!, fit: BoxFit.cover),
                            )
                          : const Center(child: Text("Tap to select image")),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      openGoogleMaps(latitude, longitude);
                    },
                    child: const Text(
                      'Open Location in Google Maps',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // NEWSPAPER DETAILS WITH QUANTITY
                  const Text(
                    "Newspaper Details",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // QUANTITY ROW (RIGHT CORNER)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Quantity",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                  quantityController.text = quantity.toString();
                                });
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          SizedBox(
                            width: 50,
                            child: TextFormField(
                              controller: quantityController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                quantity++;
                                quantityController.text = quantity.toString();
                              });
                            },
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedCustomerType,
                    hint: const Text("Customer Type"),
                    isExpanded: true,
                    items: customerTypes.map((String customerType) {
                      return DropdownMenuItem<String>(
                        value: customerType,
                        child: Text(customerType),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCustomerType = newValue;
                        if (newValue != "Conversion") {
                          _selectedPreviousNewspaper = null;
                          otherNewspaperController.clear();
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Please select customer type";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Customer Type",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  if (_selectedCustomerType == "Conversion") ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedPreviousNewspaper,
                      hint: const Text("Current Newspaper"),
                      isExpanded: true,
                      items: previousNewspapers.map((String newspaper) {
                        return DropdownMenuItem<String>(
                          value: newspaper,
                          child: Text(newspaper),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPreviousNewspaper = newValue;
                          if (newValue != "Others") {
                            otherNewspaperController.clear();
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Please select a newspaper";
                        }
                        if (value == "Others" &&
                            otherNewspaperController.text.isEmpty) {
                          return "Please enter other newspaper name";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: "Current Newspaper",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    if (_selectedPreviousNewspaper == "Others") ...[
                      const SizedBox(height: 10),
                      textformfeild(
                        hunttext: "Please enter other newspaper name",
                        controller: otherNewspaperController,
                        label: "Other Newspaper",
                        need: false,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: TextFormField(
                      controller: startCirculationController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Start Circulation",
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 4),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: _selectStartCirculationDate,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Start circulation date cannot be empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  // ... [Rest of the form (Employed?, Job details, Mobile, Submit button) remains exactly the same] ...
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Employed?",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        _isemployed ? "Yes" : "No",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isemployed ? Colors.green : Colors.red,
                        ),
                      ),
                      Switch(
                        inactiveThumbColor: Colors.white,
                        activeTrackColor: Colors.green,
                        inactiveTrackColor: Colors.red,
                        value: _isemployed,
                        onChanged: (value) {
                          setState(() {
                            _isemployed = value;
                            _selectedJobType = null;
                            _selectedGovDepartment = null;
                            privateCompanyController.clear();
                            privateProffesionController.clear();
                            _selectedPrivateProfession = null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (_isemployed)
                    DropdownButtonFormField<String>(
                      value: _selectedJobType,
                      hint: const Text("Job Type"),
                      isExpanded: true,
                      items: jobTypes.map((String job) {
                        return DropdownMenuItem<String>(
                          value: job,
                          child: Text(job),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedJobType = newValue;
                          _selectedGovDepartment = null;
                          privateCompanyController.clear();
                          privateProffesionController.clear();
                          _selectedPrivateProfession = null;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Job Type",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                  if (_selectedJobType == "government_job") ...[
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedGovDepartment,
                      hint: const Text("Select Department"),
                      isExpanded: true,
                      items: govDepartments.map((String dept) {
                        return DropdownMenuItem<String>(
                          value: dept,
                          child: Text(dept),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGovDepartment = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Government Job",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    if (_selectedGovDepartment != null) ...[
                      const SizedBox(height: 10),
                      textformfeild(
                        hunttext: "Field cannot be empty",
                        controller: job_designation,
                        label: "Job Designation",
                      ),
                      const SizedBox(height: 10),
                      textformfeild(
                        hunttext: "Field cannot be empty",
                        controller: job_proffesion,
                        label: "Job Department",
                      ),
                    ],
                  ],
                  if (_selectedJobType == "private_job") ...[
                    const SizedBox(height: 10),
                    textformfeild(
                      hunttext: "Field cannot be empty",
                      controller: privateCompanyController,
                      label: "Company Name",
                    ),
                    const SizedBox(height: 10),
                    textformfeild(
                      hunttext: "Field cannot be empty",
                      controller: privatedesignationController,
                      label: "Designation",
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedPrivateProfession,
                      hint: const Text("Profession"),
                      isExpanded: true,
                      items: privateJobProfessions.map((String profession) {
                        return DropdownMenuItem<String>(
                          value: profession,
                          child: Text(profession),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPrivateProfession = newValue;
                          if (newValue != "Other") {
                            privateProffesionController.clear();
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Please select a profession";
                        }
                        if (value == "Other" &&
                            privateProffesionController.text.isEmpty) {
                          return "Please enter other profession";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: "Profession",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    if (_selectedPrivateProfession == "Other") ...[
                      const SizedBox(height: 10),
                      textformfeild(
                        hunttext: "Please enter other profession",
                        controller: privateProffesionController,
                        label: "Other Profession",
                        need: false,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ],
                  if (!_isemployed)
                    DropdownButtonFormField<String>(
                      value: _selectedproffesion,
                      hint: const Text("Profession"),
                      isExpanded: true,
                      items: proffesion.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedproffesion = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Profession",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: mobile,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      labelText: "Mobile Number",
                      errorText: null,
                    ),
                    validator: (value) {
                      if (value == null || value.length < 10) {
                        return "Mobile number must be 10 digits";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          )
                        : GestureDetector(
                            onTap: () async {
                              await uploaddata();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(50)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 5.0,
                                    spreadRadius: 1.0,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              height: MediaQuery.of(context).size.height / 18,
                              width: MediaQuery.of(context).size.height / 5,
                              child: Center(
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.height / 45,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget imagePickerBox(File? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.black),
        ),
        child: image != null
            ? Image.file(image, fit: BoxFit.cover)
            : const Center(
                child: Text(
                  "Tap to select image",
                  style: TextStyle(color: Colors.black),
                ),
              ),
      ),
    );
  }
}

SizedBox date({
  required TextEditingController Dcontroller,
  required String date,
  bool needed = false,
  required TextInputType inputType,
}) {
  return SizedBox(
    height: 50,
    width: 180,
    child: TextFormField(
      keyboardType: inputType,
      controller: Dcontroller,
      readOnly: needed,
      decoration: InputDecoration(
        labelText: date,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black, width: 4),
        ),
      ),
    ),
  );
}

SizedBox textformfeild({
  required TextEditingController controller,
  required String label,
  String? hunttext,
  String? textForCounter,
  int? maxvalue,
  bool need = false,
  bool readOnly = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return SizedBox(
    height: label == "Mobile Number" ? 85 : 70,
    width: double.infinity,
    child: TextFormField(
      validator: need
          ? (value) {
              if (value == null || value.isEmpty) {
                return hunttext;
              }
              return null;
            }
          : null,
      readOnly: readOnly,
      keyboardType: keyboardType,
      controller: controller,
      maxLength: maxvalue,
      decoration: InputDecoration(
        counterText: textForCounter,
        labelText: label,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black, width: 4),
        ),
      ),
    ),
  );
}
