class Historymodel {
  String? jsonrpc;
  Object? id;
  Result? result;

  Historymodel({this.jsonrpc, this.id, this.result});

  Historymodel.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'] as String?;
    id = json['id'];
    result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['jsonrpc'] = jsonrpc;
    data['id'] = id;
    if (result != null) data['result'] = result!.toJson();
    return data;
  }
}

class Result {
  List<Records>? records;
  int? count;
  String? code;

  Result({this.records, this.count, this.code});

  Result.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      records = (json['records'] as List)
          .map((e) => Records.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    count = json['count'] as int?;
    code = json['code'] as String?;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (records != null) {
      data['records'] = records!.map((r) => r.toJson()).toList();
    }
    data['count'] = count;
    data['code'] = code;
    return data;
  }
}

class Records {
  int? id;
  String? agentName;
  String? agentLogin;
  String? unitName;
  String? date;
  String? time;
  String? familyHeadName;
  String? fatherName;
  String? motherName;
  String? spouseName;
  String? houseNumber;
  String? streetNumber;
  String? city;
  String? pinCode;
  String? address;
  String? mobileNumber;
  bool? eenaduNewspaper;
  String? feedbackToImproveEenaduPaper;
  bool? readNewspaper;
  String? currentNewspaper;
  String? reasonForNotTakingEenaduNewsPaper;
  String? reasonNotReading;
  bool? freeOffer15Days;
  String? reasonNotTakingOffer;
  bool? employed;
  String? jobType;
  String? jobTypeOne;
  String? jobProfession;
  String? jobDesignation;
  String? companyName;
  String? profession;
  bool? jobWorkingState;
  bool? jobWorkingLocation;
  String? jobDesignationOne;
  String? latitude;
  String? longitude;
  String? locationAddress;
  String? locationUrl;
  String? faceBase64;

  Records({
    this.id,
    this.agentName,
    this.agentLogin,
    this.unitName,
    this.date,
    this.time,
    this.familyHeadName,
    this.fatherName,
    this.motherName,
    this.spouseName,
    this.houseNumber,
    this.streetNumber,
    this.city,
    this.pinCode,
    this.address,
    this.mobileNumber,
    this.eenaduNewspaper,
    this.feedbackToImproveEenaduPaper,
    this.readNewspaper,
    this.currentNewspaper,
    this.reasonForNotTakingEenaduNewsPaper,
    this.reasonNotReading,
    this.freeOffer15Days,
    this.reasonNotTakingOffer,
    this.employed,
    this.jobType,
    this.jobTypeOne,
    this.jobProfession,
    this.jobDesignation,
    this.companyName,
    this.profession,
    this.jobWorkingState,
    this.jobWorkingLocation,
    this.jobDesignationOne,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.locationUrl,
    this.faceBase64,
  });

  Records.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    agentName = _asString(json['agent_name']);
    agentLogin = _asString(json['agent_login']);
    unitName = _asString(json['unit_name']);
    date = _asString(json['date']);
    time = _asString(json['time']);
    familyHeadName = _asString(json['family_head_name']);
    fatherName = _asString(json['father_name']);
    motherName = _asString(json['mother_name']);
    spouseName = _asString(json['spouse_name']);
    houseNumber = _asString(json['house_number']);
    streetNumber = _asString(json['street_number']);
    city = _asString(json['city']);
    pinCode = _asString(json['pin_code']);
    address = _asString(json['address']);
    mobileNumber = _asString(json['mobile_number']);
    eenaduNewspaper = _parseBool(json['eenadu_newspaper']);
    feedbackToImproveEenaduPaper = _asString(json['feedback_to_improve_eenadu_paper']);
    readNewspaper = _parseBool(json['read_newspaper']);
    currentNewspaper = _asString(json['current_newspaper']);
    reasonForNotTakingEenaduNewsPaper = _asString(json['reason_for_not_taking_eenadu_newsPaper']);
    reasonNotReading = _asString(json['reason_not_reading']);
    freeOffer15Days = _parseBool(json['free_offer_15_days']);
    reasonNotTakingOffer = _asString(json['reason_not_taking_offer']);
    employed = _parseBool(json['employed']);
    jobType = json['job_type']?.toString();
    jobTypeOne = json['job_type_one']?.toString();
    jobProfession = _asString(json['job_profession']);
    jobDesignation = _asString(json['job_designation']);
    companyName = _asString(json['company_name']);
    profession = _asString(json['profession']);
    jobWorkingState = _parseBool(json['job_working_state']);
    jobWorkingLocation = _parseBool(json['job_working_location']);
    jobDesignationOne = _asString(json['job_designation_one']);
    latitude = _asString(json['latitude']);
    longitude = _asString(json['longitude']);
    locationAddress = _asString(json['location_address']);
    locationUrl = _asString(json['location_url']);
    faceBase64 = _asString(json['face_base64']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['agent_name'] = agentName;
    data['agent_login'] = agentLogin;
    data['unit_name'] = unitName;
    data['date'] = date;
    data['time'] = time;
    data['family_head_name'] = familyHeadName;
    data['father_name'] = fatherName;
    data['mother_name'] = motherName;
    data['spouse_name'] = spouseName;
    data['house_number'] = houseNumber;
    data['street_number'] = streetNumber;
    data['city'] = city;
    data['pin_code'] = pinCode;
    data['address'] = address;
    data['mobile_number'] = mobileNumber;
    data['eenadu_newspaper'] = eenaduNewspaper;
    data['feedback_to_improve_eenadu_paper'] = feedbackToImproveEenaduPaper;
    data['read_newspaper'] = readNewspaper;
    data['current_newspaper'] = currentNewspaper;
    data['reason_for_not_taking_eenadu_newsPaper'] = reasonForNotTakingEenaduNewsPaper;
    data['reason_not_reading'] = reasonNotReading;
    data['free_offer_15_days'] = freeOffer15Days;
    data['reason_not_taking_offer'] = reasonNotTakingOffer;
    data['employed'] = employed;
    data['job_type'] = jobType;
    data['job_type_one'] = jobTypeOne;
    data['job_profession'] = jobProfession;
    data['job_designation'] = jobDesignation;
    data['company_name'] = companyName;
    data['profession'] = profession;
    data['job_working_state'] = jobWorkingState;
    data['job_working_location'] = jobWorkingLocation;
    data['job_designation_one'] = jobDesignationOne;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['location_address'] = locationAddress;
    data['location_url'] = locationUrl;
    data['face_base64'] = faceBase64;
    return data;
  }

  bool? _parseBool(Object? v) {
    if (v is bool) return v;
    if (v is String) {
      final s = v.toLowerCase();
      return s == 'true' || s == '1';
    }
    if (v is num) return v != 0;
    return null;
  }

  String? _asString(Object? v) {
    if (v == null) return null;
    return v is String ? v : v.toString();
  }
}
