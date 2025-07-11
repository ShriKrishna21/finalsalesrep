import 'dart:convert';
import 'package:finalsalesrep/agent/agentscreen.dart';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/modelclasses/coustmermodel.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Coustmer extends StatefulWidget {
  const Coustmer({super.key});

  @override
  State<Coustmer> createState() => _CoustmerState();
}

class _CoustmerState extends State<Coustmer> {
  bool _isYes = false;
  bool _isAnotherToggle = false;
  bool _isofferTogle = false;
  bool _isemployed = false;
  int offerintresetedpeople = 0;
  int offernotintresetedpeople = 0;
  int offerintresetedpeoplecount = 0;
  int offernotintresetedpeoplecount = 0;
  int count = 0;
  int addcount = 0;
  String latitude = "";
  String longitude = "";
  String street = "";
  String place = "";
  String landmark = "";

  // String? locationAddress;
  // Employment Dropdown Variables
  String? _selectedJobType;
  String? _selectedGovDepartment;

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
  TextEditingController reason_for_not_taking_offer = TextEditingController();
  TextEditingController job_designation = TextEditingController();
  TextEditingController job_proffesion = TextEditingController();
  TextEditingController privateCompanyController = TextEditingController();
  TextEditingController privatedesignationController = TextEditingController();
  TextEditingController privateProffesionController = TextEditingController();

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Location Denied");
      await Geolocator.requestPermission();
      LocationPermission get = await Geolocator.requestPermission();
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      print("latitude=================>${currentPosition.latitude.toString()}");
      print(
          "longitude================>${currentPosition.longitude.toString()}");

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            currentPosition.latitude, currentPosition.longitude);
        Placemark placemark = placemarks[0];
        String? fetchedStreet = placemark.street ?? "";
        String? fetchedPlace = placemark.locality ?? "";
        String? fetchedLandmark = placemark.name ?? "";
        setState(() {
          latitude = currentPosition.latitude.toString();
          longitude = currentPosition.longitude.toString();
          street = fetchedStreet;
          place = fetchedPlace;
          landmark = fetchedLandmark;
          adddress.text = "$fetchedStreet,$fetchedPlace";
          city.text = placemark.locality ?? "";
          pincode.text = placemark.postalCode ?? "";
        });
        print("Street: $street");
        print("Place : $place");
        print("LandMark: $landmark");
      } catch (e) {
        print("Error fetching addresss======>:$e");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error fetching address: $e")));
      }

      print("latitude=${currentPosition.latitude.toString()}");
      latitude = currentPosition.latitude.toString();
      print("longitude=${currentPosition.longitude.toString()}");
      longitude = currentPosition.longitude.toString();

      setState(() {
        latitude = currentPosition.latitude.toString();
        longitude = currentPosition.longitude.toString();
      });
    }
  }

  String agents = '';
  List<String> jobTypes = ["government_job", "private_job"];
  List<String> govDepartments = [
    "central_job",
    "pSU",
    "state_job",
  ];
  String? _selectedproffesion;
  List<String> proffesion = ["farmer", "doctor", "teacher", "lawyer", "Artist"];
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
      // Set it in the controller too
    });
  }

  Future<void> uploaddata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? agentapi = prefs.getString('apikey');
    final String? agentlog = prefs.getString('agentlogin');
    final String? unit = prefs.getString('unit');
    print("Sending Latitude: $latitude, Longitude:$longitude");
    print("Street: $street, place: $place, Landmark: $landmark");

    print("Rrddddddddddddddddddddd$agentapi");

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
            "eenadu_newspaper": _isYes, // Send boolean directly
            "feedback_to_improve_eenadu_paper": feedback_to_improve.text,
            "read_newspaper": _isAnotherToggle, // Send boolean directly
            "current_newspaper": current_newspaper.text,
            "reason_for_not_taking_eenadu_newsPaper":
                reason_for_not_taking_eenadu.text,
            "reason_not_reading": reason_for_not_reading.text,
            "free_offer_15_days": _isofferTogle, // Send boolean directly
            "reason_not_taking_offer": reason_for_not_taking_offer.text,
            "employed": _isemployed, // Send boolean directly
            "job_type": _selectedJobType,
            "job_type_one": _selectedGovDepartment,
            "job_profession": job_proffesion.text,
            "job_designation": job_designation.text,
            "company_name": privateCompanyController.text,
            "profession": privateProffesionController.text,
            "job_designation_one": privatedesignationController.text,
            "latitude": latitude,
            "longitude": longitude,
            "street": street,
            "place": place,
            // "LandMark": landmark,
            "location_address": landmark,
          }
        }),
      );

      print(latitude);
      print(longitude);
      if (responsee.statusCode == 200) {
        print("wwwwwwwwwwwwwwwwwwwwwwwwwwwwww${responsee.statusCode}");
        final jsonResponse = jsonDecode(responsee.body) as Map<String, dynamic>;
        setState(() {
          data = coustmerform.fromJson(jsonResponse);
          print(
              "ttttttttttttttttttttttttttttttttttt${data?.toJson().toString()}");
        });

        if (data?.result?.code == "200") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data added successfully")),
          );

          // Load and update SharedPreferences values
          int houseVisited = prefs.getInt("house_visited") ?? 0;
          int targetLeft = prefs.getInt("target_left") ?? 0;
          int alreadySubscribed = prefs.getInt("already_Subscribed") ?? 0;
          int offerAccepted = prefs.getInt("offer_Accepted") ?? 0;
          int offerRejected = prefs.getInt("offer_Rejected") ?? 0;

          // Update values
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

          // Save updated values
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
      }
    } catch (error) {
      print("Error fetching data: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30,),
                textformfeild(
                    controller: agency,
                    label: localizations.agentName,
                    need: true),
                const SizedBox(height: 20),

                // Date & Time Fields
                Row(
                  children: [
                    Expanded(
                        child: date(
                            needed: true,
                            Dcontroller: datecontroller,
                            date: localizations.date,
                            inputType: TextInputType.datetime)),
                    const SizedBox(
                      width: 10,
                    ),
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
                const SizedBox(height: 10),

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
                    const SizedBox(
                      width: 10,
                    ),
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
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: textformfeild(
                            hunttext: localizations.pincodecannotbeempty,
                            maxvalue: 6,
                            controller: pincode,
                            // textForCounter: "",
                            label: localizations.pinCode,
                            keyboardType: TextInputType.number)),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),
                textformfeild(
                    controller: adddress, label: localizations.address),
                const SizedBox(
                  height: 10,
                ),
                textformfeild(
                  controller: TextEditingController(text: street),
                  label: localizations.streetNo,
                  hunttext: localizations.placecannotbeempty,
                  need: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                textformfeild(
                    controller: TextEditingController(text: landmark),
                    label: localizations.landmark,
                    hunttext: localizations.landmarkcannotbeempty,
                    need: true),

                // const SizedBox(height: 10),
                // textformfeild(controller: adddress, label: "Address"),
                const SizedBox(height: 10),
                textformfeild(
                    hunttext: localizations.mobilenumbercannotbeempty,
                    controller: mobile,
                    maxvalue: 10,
                    label: localizations.mobilenumber,
                    keyboardType: TextInputType.phone),

                const SizedBox(height: 15),
                Text(localizations.newsPaperDetails,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),

                // Eenadu Newspaper Toggle
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
                          // if (value) {
                          //   // _isAnotherToggle = false;
                          // }
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
                            color: _isAnotherToggle ? Colors.green : Colors.red,
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
                    textformfeild(
                        hunttext: localizations.currentnewspapercannotbeempty,
                        controller: current_newspaper,
                        label: localizations.currentnewpaper),
                  if (_isAnotherToggle)
                    textformfeild(
                        hunttext: localizations.reasonfornottakingcannotbeempty,
                        controller: reason_for_not_taking_eenadu,
                        label: localizations.reasonfornottakingeenadunewspaper),
                  if (!_isAnotherToggle)
                    textformfeild(
                        hunttext:
                            localizations.reasonfornotreadingcannotbeempty,
                        controller: reason_for_not_reading,
                        label: localizations.reasonfornotreadingnewspaper),
                  Row(
                    children: [
                      Expanded(
                        child: Text(localizations.daysOfferRejected15,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Text(_isofferTogle ? localizations.yes : localizations.no,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isofferTogle ? Colors.green : Colors.red,
                          )),
                      Switch(
                        inactiveThumbColor: Colors.white,
                        activeTrackColor: Colors.green,
                        inactiveTrackColor: Colors.red,
                        value: _isofferTogle,
                        onChanged: (value) {
                          setState(() {
                            _isofferTogle = value;
                          });
                        },
                      ),
                    ],
                  ),
                  if (!_isofferTogle)
                    textformfeild(
                        hunttext: localizations.fieldcannotbeempty,
                        controller: reason_for_not_taking_offer,
                        label: localizations.reasonfornottakingoffer),
                  const SizedBox(
                    height: 15,
                  ),
                ],
                const SizedBox(
                  height: 15,
                ),

                // Employment Status Toggle
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
                          _selectedproffesion = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),

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
                      });
                    },
                    decoration: InputDecoration(
                      labelText: localizations.jobtype,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                if (_selectedJobType == localizations.governmentjob) ...[
                  const SizedBox(
                    height: 20,
                  ),
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

                  // Show additional fields based on selection
                  if (_selectedGovDepartment == localizations.centraljob) ...[
                    const SizedBox(
                      height: 10,
                    ),
                    textformfeild(
                        hunttext: localizations.fieldcannotbeempty,
                        controller: job_designation,
                        label: localizations.jobdesignation),
                    const SizedBox(
                      height: 10,
                    ),
                    textformfeild(
                        hunttext: localizations.fieldcannotbeempty,
                        controller: job_proffesion,
                        label: localizations.jobdepartment),
                  ],

                  if (_selectedGovDepartment ==
                      localizations.psupublicsectorundertaking) ...[
                    const SizedBox(
                      height: 10,
                    ),
                    textformfeild(
                        hunttext: localizations.fieldcannotbeempty,
                        controller: job_designation,
                        label: localizations.jobdesignation),
                    const SizedBox(
                      height: 10,
                    ),
                    textformfeild(
                        hunttext: localizations.fieldcannotbeempty,
                        controller: job_proffesion,
                        label: localizations.jobdepartment),
                  ],

                  if (_selectedGovDepartment == localizations.statejob) ...[
                    const SizedBox(
                      height: 10,
                    ),
                    textformfeild(
                        hunttext: localizations.fieldcannotbeempty,
                        controller: job_designation,
                        label: localizations.jobdesignation),
                    const SizedBox(
                      height: 10,
                    ),
                    textformfeild(
                        hunttext: localizations.fieldcannotbeempty,
                        controller: job_proffesion,
                        label: localizations.jobdepartment),
                  ],
                ],

                // Private job details

                if (_selectedJobType == localizations.privatejob) ...[
                  const SizedBox(
                    height: 10,
                  ),
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
                  textformfeild(
                      hunttext: localizations.fieldcannotbeempty,
                      controller: privateProffesionController,
                      label: localizations.profession),
                ],

// If NOT employed, show Profession Dropdown
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
                const SizedBox(
                  height: 20,
                ),

                Center(
                  child: GestureDetector(
                    onTap: () async => {
                      if (_formKey.currentState?.validate() ?? false)
                        {
                          // datasaved(),
                          await getCurrentLocation(),
                          await uploaddata(),
                        }
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      height: MediaQuery.of(context).size.height / 18,
                      width: MediaQuery.of(context).size.height / 5,
                      child: Center(
                          child: Text(
                        localizations.submit,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.height / 45),
                      )),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

SizedBox date(
    {required TextEditingController Dcontroller,
    required String date,
    needed = false,
    required TextInputType inputType}) {
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

SizedBox address({
  required TextEditingController address,
  String? add,
  required TextInputType keyboardType,
  String? hhinnttextt,
}) {
  return SizedBox(
    height: 50,
    // width: 180,
    child: TextFormField(
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return hhinnttextt;
        }
        return null;
      },
      controller: address,
      // readOnly: true,
      decoration: InputDecoration(
          labelText: add,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.black)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.black, width: 4))),
    ),
  );
}

SizedBox textformfeild(
    {required TextEditingController controller,
    required String label,
    String? hunttext,
    String? textForCounter,
    int? maxvalue,
    need = false,
    keyboardType = TextInputType.text}) {
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
