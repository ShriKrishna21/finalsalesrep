import 'dart:convert';
import 'dart:io';
import 'package:finalsalesrep/agent/agentscreen.dart';
import 'package:finalsalesrep/common_api_class.dart';
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

// ==================== MODEL CLASSES ====================

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

class otp {
  String? jsonrpc;
  Null? id;
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

  // Controllers
  late TextEditingController agency;
  late TextEditingController promoter;
  late TextEditingController age;
  late TextEditingController datecontroller;
  late TextEditingController timecontroller;
  late TextEditingController familyhead;
  late TextEditingController fathersname;
  late TextEditingController mothername;
  late TextEditingController spousename;
  late TextEditingController hno;
  late TextEditingController streetnumber;
  late TextEditingController city;
  late TextEditingController pincode;
  late TextEditingController adddress;
  late TextEditingController mobile;
  late TextEditingController reason_for_not_taking_eenadu;
  late TextEditingController job_designation;
  late TextEditingController job_proffesion;
  late TextEditingController privateCompanyController;
  late TextEditingController privatedesignationController;
  late TextEditingController privateProffesionController;
  late TextEditingController locationUrlController;
  late TextEditingController faceBase64Controller;
  late TextEditingController otherNewspaperController;
  late TextEditingController startCirculationController;
  late TextEditingController streetController;
  late TextEditingController landmarkController;

  String agents = '';

  final List<String> jobTypes = ["government_job", "private_job"];
  final List<String> govDepartments = ["Central", "PSU", "State"];
  final List<String> privateJobProfessions = [
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
  final List<String> proffesion = [
    "farmer",
    "doctor",
    "teacher",
    "lawyer",
    "Artist"
  ];
  final List<String> previousNewspapers = [
    "Sakshi",
    "Andhra Jyothi",
    "Namasthe Telangana",
    "Deccan Chronicle",
    "Times Of India",
    "The Hindu",
    "Others"
  ];
  final List<String> customerTypes = ["New User", "Conversion"];

  coustmerform? data;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSavedData();
    getCurrentLocation();

    ConnectivityHelper().startListening((online) {
      setState(() => _isOnline = online);
      if (online) _syncPending();
    });
  }

  void _initializeControllers() {
    agency = TextEditingController();
    promoter = TextEditingController();
    age = TextEditingController();
    datecontroller = TextEditingController()
      ..text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    timecontroller = TextEditingController()
      ..text = DateFormat('hh:mm a').format(DateTime.now());
    familyhead = TextEditingController();
    fathersname = TextEditingController();
    mothername = TextEditingController();
    spousename = TextEditingController();
    hno = TextEditingController();
    streetnumber = TextEditingController();
    city = TextEditingController();
    pincode = TextEditingController();
    adddress = TextEditingController();
    mobile = TextEditingController();
    reason_for_not_taking_eenadu = TextEditingController();
    job_designation = TextEditingController();
    job_proffesion = TextEditingController();
    privateCompanyController = TextEditingController();
    privatedesignationController = TextEditingController();
    privateProffesionController = TextEditingController();
    locationUrlController = TextEditingController();
    faceBase64Controller = TextEditingController();
    otherNewspaperController = TextEditingController();
    startCirculationController = TextEditingController()
      ..text = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));
    streetController = TextEditingController();
    landmarkController = TextEditingController();
  }

  Future<void> _syncPending() async {
    final prefs = await SharedPreferences.getInstance();
    final agentapi = prefs.getString('apikey');
    if (agentapi != null) {
      await SyncManager().syncPendingForms(agentapi);
    }
  }

  Future<void> handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    Map<String, dynamic> formMap = {
      "agent_name": agents,
      "agent_login": await _getPref('agentlogin'),
      "unit_name": await _getPref('unit'),
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
    if (otpSent) _showOtpDialog();
  }

  Future<String?> _getPref(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  void dispose() {
    _otpController.dispose();
    agency.dispose();
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
    streetController.dispose();
    landmarkController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? agentapi = prefs.getString('apikey');
    setState(() {
      agents = prefs.getString('name') ?? '';
      promoter.text = agents;
    });

    if (_isOnline && agentapi != null) {
      try {
        final response = await http.post(
          Uri.parse(
              "https://salesrep.esanchaya.com/api/get_current_pin_location"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "params": {"token": agentapi}
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final agencyModel = assignagencymodel.fromJson(data);
          if (agencyModel.result?.success == true &&
              agencyModel.result?.data != null) {
            final agencyText =
                "${agencyModel.result!.data!.locationName ?? 'Unknown'} ";
            if (agency.text.isEmpty) {
              setState(() => agency.text = agencyText);
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching agency: $e");
      }
    } else {
      agency.text = '';
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
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      setState(() {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        locationUrl = googleMapsUrl;
        if (locationUrlController.text.isEmpty) {
          locationUrlController.text = googleMapsUrl;
        }
      });

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];

      setState(() {
        if (streetController.text.isEmpty)
          streetController.text = place.street ?? "";
        if (city.text.isEmpty) city.text = place.locality ?? "";
        if (landmarkController.text.isEmpty)
          landmarkController.text = place.name ?? "";
        if (pincode.text.isEmpty) pincode.text = place.postalCode ?? "";
        if (adddress.text.isEmpty) {
          adddress.text = [place.street, place.locality]
              .where((e) => e != null && e.isNotEmpty)
              .join(", ");
        }
      });
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<bool> _sendOtp() async {
    final prefs = await SharedPreferences.getInstance();
    final String? agentapi = prefs.getString('apikey');
    final String phone = mobile.text.trim();

    if (agentapi == null || phone.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid token or phone number')),
      );
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('https://salesrep.esanchaya.com/api/send_otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": agentapi, "phone": int.parse(phone)}
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully')),
        );
        return true;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    return false;
  }

  Future<bool> _verifyOtp(String otpCode) async {
    final prefs = await SharedPreferences.getInstance();
    final String? agentapi = prefs.getString('apikey');
    final String phone = mobile.text.trim();

    if (agentapi == null || phone.isEmpty || otpCode.isEmpty) return false;

    try {
      final response = await http.post(
        Uri.parse('https://salesrep.esanchaya.com/api/verify_otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": agentapi, "phone": phone, "otp": otpCode}
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final otpResponse = otp.fromJson(jsonResponse);
        if (otpResponse.result?.status == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(otpResponse.result?.message ?? 'OTP verified')),
          );
          return true;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    return false;
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Enter OTP'),
        content: TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
              labelText: 'OTP', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    if (_otpController.text.isNotEmpty) {
                      setState(() => _isLoading = true);
                      final verified = await _verifyOtp(_otpController.text);
                      setState(() => _isLoading = false);
                      Navigator.pop(context);
                      _otpController.clear();
                      if (verified) await _submitForm();
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
                    await _sendOtp();
                    setState(() => _isLoading = false);
                  },
            child: const Text('Resend'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final String? agentapi = prefs.getString('apikey');
    final String? agentlog = prefs.getString('agentlogin');
    final String? unit = prefs.getString('unit');

    try {
      final response = await http.post(
        Uri.parse('https://salesrep.esanchaya.com/api/customer_form'),
        headers: {'Content-Type': 'application/json'},
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
          }
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        data = coustmerform.fromJson(jsonResponse);

        if (data?.result?.code == "200") {
          final houseVisited = (prefs.getInt("house_visited") ?? 0) + 1;
          final targetLeft = (prefs.getInt("target_left") ?? 0) - 1;
          final offerAccepted =
              (prefs.getInt("offer_accepted") ?? 0) + (_isofferTogle ? 1 : 0);
          final offerRejected =
              (prefs.getInt("offer_rejected") ?? 0) + (_isofferTogle ? 0 : 1);

          await Future.wait([
            prefs.setInt("house_visited", houseVisited),
            prefs.setInt("target_left", targetLeft > 0 ? targetLeft : 0),
            prefs.setInt("offer_accepted", offerAccepted),
            prefs.setInt("offer_rejected", offerRejected),
          ]);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const Agentscreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data?.result?.message ?? 'Submission failed')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> uploaddata() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    setState(() => _isLoading = true);
    if (_isOnline) {
      final sent = await _sendOtp();
      if (sent) _showOtpDialog();
    } else {
      await handleSubmit();
    }
    setState(() => _isLoading = false);
  }

  void openGoogleMaps() {
    if (latitude.isNotEmpty && longitude.isNotEmpty) {
      final url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
      _launchUrl(url);
    }
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
      faceImage = null;
      faceBase64Controller.clear();
      // Clear all controllers
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
      otherNewspaperController.clear();
      streetController.clear();
      landmarkController.clear();
      datecontroller.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      timecontroller.text = DateFormat('hh:mm a').format(DateTime.now());
      startCirculationController.text = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(Duration(days: 1)));
      latitude = "";
      longitude = "";
    });
    await _loadSavedData();
    await getCurrentLocation();
  }

  Future<void> _selectStartCirculationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      startCirculationController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        title: const Text("Customer Form",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
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
                  const SizedBox(height: 20),

                  // Agency
                  textformfeild(
                      controller: agency,
                      label: "Agency",
                      need: true,
                      readOnly: _isOnline,
                      hunttext: "Agency required"),

                  const SizedBox(height: 10),
                  textformfeild(
                      controller: promoter,
                      label: "Promoter Name",
                      need: true,
                      hunttext: "Promoter required"),

                  // Date & Time
                  Row(
                    children: [
                      Expanded(
                          child:
                              date(Dcontroller: datecontroller, date: "Date")),
                      const SizedBox(width: 10),
                      Expanded(
                          child:
                              date(Dcontroller: timecontroller, date: "Time")),
                    ],
                  ),

                  const SizedBox(height: 15),
                  const Text("Family Details",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  textformfeild(
                      controller: familyhead,
                      label: "Name",
                      hunttext: "Required"),
                  textformfeild(
                      controller: age,
                      label: "Age",
                      keyboardType: TextInputType.number,
                      hunttext: "Required"),

                  const SizedBox(height: 15),
                  const Text("Address Details",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                          child: textformfeild(
                              controller: hno, label: "House Number")),
                      const SizedBox(width: 10),
                      Expanded(
                          child: textformfeild(
                              controller: streetnumber, label: "Street No")),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child:
                              textformfeild(controller: city, label: "City")),
                      const SizedBox(width: 10),
                      Expanded(
                          child: textformfeild(
                              controller: pincode,
                              label: "Pin Code",
                              maxvalue: 6,
                              keyboardType: TextInputType.number)),
                    ],
                  ),
                  textformfeild(controller: adddress, label: "Address"),
                  textformfeild(
                      controller: streetController,
                      label: "Street",
                      readOnly: _isOnline),
                  textformfeild(
                      controller: landmarkController,
                      label: "Landmark",
                      readOnly: _isOnline),

                  const Text("Landmark Photo",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  imagePickerBox(faceImage, pickFaceImage),

                  InkWell(
                      onTap: openGoogleMaps,
                      child: const Text('Open in Google Maps',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold))),

                  const SizedBox(height: 15),
                  const Text("Newspaper Details",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  DropdownButtonFormField<String>(
                    value: _selectedCustomerType,
                    hint: const Text("Customer Type"),
                    items: customerTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCustomerType = v),
                    validator: (v) => v == null ? "Required" : null,
                    decoration: const InputDecoration(
                        labelText: "Customer Type",
                        border: OutlineInputBorder()),
                  ),

                  if (_selectedCustomerType == "Conversion") ...[
                    DropdownButtonFormField<String>(
                      value: _selectedPreviousNewspaper,
                      hint: const Text("Current Newspaper"),
                      items: previousNewspapers
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedPreviousNewspaper = v),
                      validator: (v) {
                        if (v == null) return "Required";
                        if (v == "Others" &&
                            otherNewspaperController.text.isEmpty)
                          return "Enter newspaper";
                        return null;
                      },
                      decoration: const InputDecoration(
                          labelText: "Current Newspaper",
                          border: OutlineInputBorder()),
                    ),
                    if (_selectedPreviousNewspaper == "Others")
                      textformfeild(
                          controller: otherNewspaperController,
                          label: "Other Newspaper"),
                  ],

                  TextFormField(
                    controller: startCirculationController,
                    readOnly: true,
                    onTap: _selectStartCirculationDate,
                    decoration: const InputDecoration(
                      labelText: "Start Circulation",
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? "Required" : null,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Employed?",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Switch(
                          value: _isemployed,
                          onChanged: (v) => setState(() => _isemployed = v)),
                    ],
                  ),

                  if (_isemployed)
                    DropdownButtonFormField<String>(
                      value: _selectedJobType,
                      hint: const Text("Job Type"),
                      items: jobTypes
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedJobType = v),
                      decoration: const InputDecoration(
                          labelText: "Job Type", border: OutlineInputBorder()),
                    ),

                  if (_selectedJobType == "government_job") ...[
                    DropdownButtonFormField<String>(
                      value: _selectedGovDepartment,
                      hint: const Text("Department"),
                      items: govDepartments
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedGovDepartment = v),
                      decoration: const InputDecoration(
                          labelText: "Govt Dept", border: OutlineInputBorder()),
                    ),
                    textformfeild(
                        controller: job_designation, label: "Designation"),
                    textformfeild(
                        controller: job_proffesion, label: "Profession"),
                  ],

                  if (_selectedJobType == "private_job") ...[
                    textformfeild(
                        controller: privateCompanyController,
                        label: "Company Name"),
                    textformfeild(
                        controller: privatedesignationController,
                        label: "Designation"),
                    DropdownButtonFormField<String>(
                      value: _selectedPrivateProfession,
                      hint: const Text("Profession"),
                      items: privateJobProfessions
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedPrivateProfession = v),
                      decoration: const InputDecoration(
                          labelText: "Profession",
                          border: OutlineInputBorder()),
                    ),
                    if (_selectedPrivateProfession == "Other")
                      textformfeild(
                          controller: privateProffesionController,
                          label: "Other Profession"),
                  ],

                  if (!_isemployed)
                    DropdownButtonFormField<String>(
                      value: _selectedproffesion,
                      hint: const Text("Profession"),
                      items: proffesion
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedproffesion = v),
                      decoration: const InputDecoration(
                          labelText: "Profession",
                          border: OutlineInputBorder()),
                    ),

                  TextFormField(
                    controller: mobile,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: "Mobile Number",
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        v?.length != 10 ? "10 digits required" : null,
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: uploaddata,
                            child: const Text("Submit",
                                style: TextStyle(fontSize: 18)),
                          ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget imagePickerBox(File? image, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(image, fit: BoxFit.cover))
          : const Center(child: Text("Tap to select image")),
    ),
  );
}

SizedBox textformfeild({
  required TextEditingController controller,
  required String label,
  String? hunttext,
  int? maxvalue,
  bool need = false,
  bool readOnly = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return SizedBox(
    height: 70,
    child: TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLength: maxvalue,
      validator: need ? (v) => v?.isEmpty ?? true ? hunttext : null : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black)),
      ),
    ),
  );
}

SizedBox date({
  required TextEditingController Dcontroller,
  required String date,
}) {
  return SizedBox(
    width: 180,
    height: 50,
    child: TextFormField(
      controller: Dcontroller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: date,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );
}
