import 'dart:convert';
import 'dart:io';
import 'package:finalsalesrep/agent/agentscreen.dart';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/modelclasses/coustmermodel.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Coustmer extends StatefulWidget {
  const Coustmer({super.key});

  @override
  State<Coustmer> createState() => _CoustmerState();
}

class _CoustmerState extends State<Coustmer> {
  File? faceImage;
  final ImagePicker _picker = ImagePicker();

  bool _isYes = false;
  bool _isAnotherToggle = false;
  bool _isofferTogle = false;
  bool _isemployed = false;
  bool _isLoading = false;
  int offerintresetedpeople = 0;
  int offernotintresetedpeople = 0;
  //int offerintresetedpeoplecount = 0;
  //int offernotintresetedpeoplecount = 0;
  int count = 0;
  int addcount = 0;
  String latitude = "";
  String longitude = "";
  String street = "";
  String place = "";
  String landmark = "";
  String? locationUrl = "";
  File? locationImage;
  String? _selectedJobType;
  String? _selectedGovDepartment;
  String? _selectedproffesion;
  String? _selectedNewspaper;
  String?
      _selectedPrivateProfession; // Added for private job profession dropdown
  final _formKey = GlobalKey<FormState>();

  TextEditingController agency = TextEditingController();
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
  TextEditingController feedback_to_improve = TextEditingController();
  TextEditingController reason_for_not_reading = TextEditingController();
  TextEditingController current_newspaper = TextEditingController();
  TextEditingController reason_for_not_taking_eenadu = TextEditingController();
  // TextEditingController reason_for_not_taking_offer = TextEditingController();
  TextEditingController job_designation = TextEditingController();
  TextEditingController job_proffesion = TextEditingController();
  TextEditingController privateCompanyController = TextEditingController();
  TextEditingController privatedesignationController = TextEditingController();
  TextEditingController privateProffesionController = TextEditingController();
  TextEditingController locationUrlController = TextEditingController();
  TextEditingController faceBase64Controller = TextEditingController();

  String agents = '';
  List<String> jobTypes = ["government_job", "private_job"];
  List<String> govDepartments = ["Central", "PSU", "State"];
  List<String> proffesion = ["farmer", "doctor", "teacher", "lawyer", "Artist"];
  List<String> newspapers = [
    "Eenadu",
    "Sakshi",
    "Andhra Jyothi",
    "Andhra Bhoomi",
    "Vaartha",
    "Namasthe Telangana",
    "Prajasakti",
    "Nava Telangana",
    "Andhra Prabha",
    "Suryaa",
    "Mana Telangana",
    "Janam Sakshi",
    "Visalaandhra",
    "Deccan Chronicle",
    "The Hans India",
    "Telangana Today",
    "The Siasat Daily",
    "Etemaad Daily"
  ];
  List<String> privateProfessions = [
    "IT & Software",
    "Healthcare & Medical",
    "Retail & Sales",
    "Manufacturing & Industrial",
    "Finance & Accounting",
    "Telecommunications",
    "Marketing & Advertising",
    "Hospitality & Tourism",
    "Creative & Design",
    "Education & Training",
    "Logistics & Supply Chain",
    "Startup Ecosystem"
  ]; // Added private professions list
  coustmerform? data;

  @override
  void initState() {
    super.initState();
    datecontroller.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    timecontroller.text = DateFormat('hh:mm a').format(DateTime.now());
    _loadSavedData();
    getCurrentLocation();
  }

  void _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      agents = prefs.getString('name') ?? '';
      agency.text = agents;
    });
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
      print("Location Denied");
      await Geolocator.requestPermission();
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            currentPosition.latitude, currentPosition.longitude);
        Placemark placemark = placemarks[0];
        String? fetchedStreet = placemark.street ?? "";
        String? fetchedPlace = placemark.locality ?? "";
        String? fetchedLandmark = placemark.name ?? "";
        String googleMapsUrl =
            "https://www.google.com/maps/search/?api=1&query=${currentPosition.latitude},${currentPosition.longitude}";
        setState(() {
          latitude = currentPosition.latitude.toString();
          longitude = currentPosition.longitude.toString();
          street = fetchedStreet;
          place = fetchedPlace;
          landmark = fetchedLandmark;
          locationUrl = googleMapsUrl;
          locationUrlController.text = googleMapsUrl;
          adddress.text = "$fetchedStreet, $fetchedPlace";
          city.text = placemark.locality ?? "";
          pincode.text = placemark.postalCode ?? "";
        });
        print("Generated Google Maps URL: $googleMapsUrl");
        print("Street: $street");
        print("Place: $place");
        print("LandMark: $landmark");
        print("Google Maps URL: $googleMapsUrl");
      } catch (e) {
        print("Error fetching address: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error fetching address: $e")));
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

  Future<void> faceBaseImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      setState(() {
        locationImage = File(image.path);
        faceBase64Controller.text = base64Image;
      });
    }
  }

  Future<void> uploaddata() async {
    setState(() {
      _isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? agentapi = prefs.getString('apikey');
    final String? agentlog = prefs.getString('agentlogin');
    final String? unit = prefs.getString('unit');

    try {
      final url = CommonApiClass.customerform;
      final responsee = await http.post(
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
            "date": datecontroller.text,
            "time": timecontroller.text,
            "family_head_name": familyhead.text,
            "father_name": fathersname.text,
            "mother_name": mothername.text,
            "spouse_name": spousename.text,
            "house_number": hno.text,
            "street_number": streetnumber.text,
            "city": city.text,
            "pin_code": pincode.text,
            "address": adddress.text,
            "mobile_number": mobile.text,
            "eenadu_newspaper": _isYes,
            "feedback_to_improve_eenadu_paper": feedback_to_improve.text,
            "read_newspaper": _isAnotherToggle,
            "current_newspaper": _selectedNewspaper ?? current_newspaper.text,
            "reason_for_not_taking_eenadu_newsPaper":
                reason_for_not_taking_eenadu.text,
            "reason_not_reading": reason_for_not_reading.text,
            "free_offer_15_days": _isofferTogle,
            "employed": _isemployed,
            "job_type": _selectedJobType,
            "job_type_one": _selectedGovDepartment,
            "job_profession": job_proffesion.text,
            "job_designation": job_designation.text,
            "company_name": privateCompanyController.text,
            "profession": _selectedPrivateProfession ??
                privateProffesionController
                    .text, // Updated to use dropdown value
            "job_designation_one": privatedesignationController.text,
            "latitude": latitude,
            "longitude": longitude,
            "street": street,
            "place": place,
            "location_address": landmark,
            "location_url": locationUrlController.text,
            "face_base64": faceBase64Controller.text,
          }
        }),
      );

      if (responsee.statusCode == 200) {
        final jsonResponse = jsonDecode(responsee.body) as Map<String, dynamic>;
        setState(() {
          data = coustmerform.fromJson(jsonResponse);
        });

        if (data?.result?.code == "200") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data added successfully")),
          );

          int houseVisited = prefs.getInt("house_visited") ?? 0;
          int targetLeft = prefs.getInt("target_left") ?? 0;
          int alreadySubscribed = prefs.getInt("already_subscribed") ?? 0;
          int offerAccepted = prefs.getInt("offer_accepted") ?? 0;
          int offerRejected = prefs.getInt("offer_rejected") ?? 0;

          houseVisited += 1;
          if (targetLeft > 0) {
            targetLeft -= 1;
          }
          if (_isYes) {
            alreadySubscribed += 1;
          } else if (_isofferTogle) {
            offerAccepted += 1;
          } else {
            offerRejected += 1;
          }

          await prefs.setInt("house_visited", houseVisited);
          await prefs.setInt("target_left", targetLeft);
          await prefs.setInt("already_subscribed", alreadySubscribed);
          await prefs.setInt("offer_accepted", offerAccepted);
          await prefs.setInt("offer_rejected", offerRejected);

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Agentscreen(),
              ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data Not added")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${responsee.statusCode}")),
        );
      }
    } catch (error) {
      print("Error fetching data: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void openGoogleMaps(String? latitude, String? longitude) {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    _launchUrl(url);
  }

  Future<void> _refreshForm() async {
    setState(() {
      _isYes = false;
      _isAnotherToggle = false;
      _isofferTogle = false;
      _isemployed = false;
      _selectedJobType = null;
      _selectedGovDepartment = null;
      _selectedproffesion = null;
      _selectedNewspaper = null;
      _selectedPrivateProfession = null; // Reset private profession dropdown
      agency.clear();
      familyhead.clear();
      fathersname.clear();
      mothername.clear();
      spousename.clear();
      hno.clear();
      streetnumber.clear();
      city.clear();
      pincode.clear();
      adddress.clear();
      mobile.clear();
      feedback_to_improve.clear();
      reason_for_not_reading.clear();
      current_newspaper.clear();
      reason_for_not_taking_eenadu.clear();
      job_designation.clear();
      job_proffesion.clear();
      privateCompanyController.clear();
      privatedesignationController.clear();
      privateProffesionController.clear();
      locationUrlController.clear();
      faceBase64Controller.clear();
      datecontroller.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      timecontroller.text = DateFormat('hh:mm a').format(DateTime.now());
      latitude = "";
      longitude = "";
      street = "";
      place = "";
      landmark = "";
      locationUrl = "";
    });

    _loadSavedData();
    await getCurrentLocation();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Form refreshed successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        title: Text(
          localizations.customerform,
          style: const TextStyle(
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
                      controller: agency, label: "Staff Name", need: true),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: date(
                              needed: true,
                              Dcontroller: datecontroller,
                              date: localizations.date,
                              inputType: TextInputType.datetime)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: date(
                              needed: true,
                              Dcontroller: timecontroller,
                              date: localizations.time,
                              inputType: TextInputType.datetime)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(localizations.familyDetails,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  textformfeild(
                      controller: familyhead,
                      label: localizations.name,
                      hunttext: localizations.familyheadname),
                  const SizedBox(height: 10),
                  textformfeild(
                      controller: fathersname,
                      label: localizations.fathersname,
                      hunttext: localizations.fathersnamecannotbeempty),
                  const SizedBox(height: 10),
                  textformfeild(
                      controller: mothername,
                      label: localizations.mothername,
                      hunttext: localizations.mothersnamecannotbeempty),
                  const SizedBox(height: 10),
                  textformfeild(
                      controller: spousename,
                      label: localizations.spousename,
                      hunttext: localizations.spousenamecannotbeempty),
                  const SizedBox(height: 15),
                  Text(localizations.addressDetails,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: textformfeild(
                              controller: hno,
                              label: localizations.houseNumber,
                              hunttext: localizations.housenumbercannotbeempty,
                              keyboardType: TextInputType.text)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: textformfeild(
                              controller: streetnumber,
                              hunttext: localizations.streetnumbercannotbeempty,
                              label: localizations.streetNo,
                              keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: textformfeild(
                              hunttext: localizations.citycannotbeempty,
                              controller: city,
                              label: localizations.city,
                              keyboardType: TextInputType.text)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: textformfeild(
                              hunttext: localizations.pincodecannotbeempty,
                              maxvalue: 6,
                              controller: pincode,
                              label: localizations.pinCode,
                              keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  textformfeild(
                      controller: adddress, label: localizations.address),
                  const SizedBox(height: 10),
                  textformfeild(
                    controller: TextEditingController(text: street),
                    label: localizations.streetNo,
                    hunttext: localizations.placecannotbeempty,
                    need: true,
                  ),
                  const SizedBox(height: 10),
                  textformfeild(
                      controller: TextEditingController(text: landmark),
                      label: localizations.landmark,
                      hunttext: localizations.landmarkcannotbeempty,
                      need: true),
                  const SizedBox(height: 10),
                  Text("landmark photo",
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                          : Center(child: Text("TapToSelectImage")),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
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
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: mobile,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: localizations.mobilenumber,
                      errorText: mobile.text.length < 10
                          ? localizations.mobilenumbercannotbeempty
                          : null,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(localizations.newsPaperDetails,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: Text(localizations.eenadunewspaper,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Text(_isYes ? localizations.yes : localizations.no,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isYes ? Colors.green : Colors.red,
                          )),
                      Switch(
                        inactiveThumbColor: Colors.white,
                        activeTrackColor: Colors.green,
                        inactiveTrackColor: Colors.red,
                        value: _isYes,
                        onChanged: (value) {
                          setState(() {
                            _isYes = value;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isYes)
                    textformfeild(
                        hunttext: localizations.feedbackcannotbeempty,
                        controller: feedback_to_improve,
                        label: localizations.feedbacktoimprovepaper),
                  if (!_isYes) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(localizations.readnewspaper,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        Text(
                            _isAnotherToggle
                                ? localizations.yes
                                : localizations.no,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  _isAnotherToggle ? Colors.green : Colors.red,
                            )),
                        Switch(
                          inactiveThumbColor: Colors.white,
                          activeTrackColor: Colors.green,
                          inactiveTrackColor: Colors.red,
                          value: _isAnotherToggle,
                          onChanged: (value) {
                            setState(() {
                              _isAnotherToggle = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_isAnotherToggle)
                      DropdownButtonFormField<String>(
                        value: _selectedNewspaper,
                        hint: Text(localizations.currentnewpaper),
                        isExpanded: true,
                        items: newspapers.map((String newspaper) {
                          return DropdownMenuItem<String>(
                            value: newspaper,
                            child: Text(newspaper),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedNewspaper = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return localizations.currentnewspapercannotbeempty;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: localizations.currentnewpaper,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    SizedBox(height: 10),
                    if (_isAnotherToggle)
                      textformfeild(
                          hunttext:
                              localizations.reasonfornottakingcannotbeempty,
                          controller: reason_for_not_taking_eenadu,
                          label:
                              localizations.reasonfornottakingeenadunewspaper),
                    if (!_isAnotherToggle)
                      textformfeild(
                          hunttext:
                              localizations.reasonfornotreadingcannotbeempty,
                          controller: reason_for_not_reading,
                          label: localizations.reasonfornotreadingnewspaper),
                  ],
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Text(localizations.employed,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Text(_isemployed ? localizations.yes : localizations.no,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isemployed ? Colors.green : Colors.red,
                          )),
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
                            _selectedPrivateProfession =
                                null; // Reset private profession
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (_isemployed)
                    DropdownButtonFormField<String>(
                      value: _selectedJobType,
                      hint: Text(localizations.jobtype),
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
                          _selectedPrivateProfession =
                              null; // Reset private profession
                        });
                      },
                      decoration: InputDecoration(
                        labelText: localizations.jobtype,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  if (_selectedJobType == "government_job") ...[
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedGovDepartment,
                      hint: Text(localizations.selectdepartment),
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
                      decoration: InputDecoration(
                        labelText: localizations.governmentjob,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    if (_selectedGovDepartment != null) ...[
                      const SizedBox(height: 10),
                      textformfeild(
                          hunttext: localizations.fieldcannotbeempty,
                          controller: job_designation,
                          label: localizations.jobdesignation),
                      const SizedBox(height: 10),
                      textformfeild(
                          hunttext: localizations.fieldcannotbeempty,
                          controller: job_proffesion,
                          label: localizations.jobdepartment),
                    ],
                  ],
                  if (_selectedJobType == "private_job") ...[
                    const SizedBox(height: 10),
                    textformfeild(
                        hunttext: localizations.fieldcannotbeempty,
                        controller: privateCompanyController,
                        label: localizations.companyname),
                    const SizedBox(height: 10),
                    textformfeild(
                        hunttext: localizations.fieldcannotbeempty,
                        controller: privatedesignationController,
                        label: localizations.designation),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedPrivateProfession,
                      hint: Text(localizations.profession),
                      isExpanded: true,
                      items: privateProfessions.map((String profession) {
                        return DropdownMenuItem<String>(
                          value: profession,
                          child: Text(profession),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPrivateProfession = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return localizations.fieldcannotbeempty;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: localizations.profession,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                  if (!_isemployed)
                    DropdownButtonFormField<String>(
                      value: _selectedproffesion,
                      hint: Text(localizations.profession),
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
                      decoration: InputDecoration(
                        labelText: localizations.profession,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
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
                              if (_formKey.currentState?.validate() ?? false) {
                                await getCurrentLocation();
                                await uploaddata();
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 5.0,
                                      spreadRadius: 1.0,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    )
                                  ]),
                              height: MediaQuery.of(context).size.height / 18,
                              width: MediaQuery.of(context).size.height / 5,
                              child: Center(
                                child: Text(
                                  localizations.submit,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.height /
                                              45),
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
            : Center(
                child: Text(AppLocalizations.of(context)!.taptoselectimage,
                    style: const TextStyle(color: Colors.black)),
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
              borderSide: const BorderSide(color: Colors.black)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.black, width: 4))),
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
  TextInputType keyboardType = TextInputType.text,
}) {
  return SizedBox(
    height: label == "mobile number" ? 85 : 70,
    width: double.infinity,
    child: TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return hunttext;
        }
        return null;
      },
      readOnly: need,
      keyboardType: keyboardType,
      controller: controller,
      maxLength: maxvalue,
      decoration: InputDecoration(
          counterText: textForCounter,
          labelText: label,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.black)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.black, width: 4))),
    ),
  );
}
