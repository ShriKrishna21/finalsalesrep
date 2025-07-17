class Historymodel {
  String? jsonrpc;
  Null id;
  Result? result;

  Historymodel({this.jsonrpc, this.id, this.result});

  Historymodel.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'];
    id = json['id'];
    result = json['result'] != null ? Result.fromJson(json['result']) : null;
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

class Result {
  List<Records>? records;
  int? count;
  String? code;

  Result({this.records, this.count, this.code});

  Result.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      records = <Records>[];
      json['records'].forEach((v) {
        records!.add(Records.fromJson(v));
      });
    }
    count = json['count'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (records != null) {
      data['records'] = records!.map((v) => v.toJson()).toList();
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
  bool? jobType;
  bool? jobTypeOne;
  String? jobProfession;
  String? jobDesignation;
  String? companyName;
  String? profession;
  bool? jobWorkingState;
  bool? jobWorkingLocation;
  String? jobDesignationOne;
  String? latitude;
  String? longitude;
  bool? locationAddress;
  String? locationUrl;

  Records(
      {this.id,
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
      this.locationUrl});

  Records.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    agentName = _safeString(json['agent_name']);
    agentLogin = _safeString(json['agent_login']);
    unitName = _safeString(json['unit_name']);
    date = _safeString(json['date']);
    time = _safeString(json['time']);
    familyHeadName = _safeString(json['family_head_name']);
    fatherName = _safeString(json['father_name']);
    motherName = _safeString(json['mother_name']);
    spouseName = _safeString(json['spouse_name']);
    houseNumber = _safeString(json['house_number']);
    streetNumber = _safeString(json['street_number']);
    city = _safeString(json['city']);
    pinCode = _safeString(json['pin_code']);
    address = _safeString(json['address']);
    mobileNumber = _safeString(json['mobile_number']);
    eenaduNewspaper = _parseBool(json['eenadu_newspaper']);
    feedbackToImproveEenaduPaper =
        _safeString(json['feedback_to_improve_eenadu_paper']);
    readNewspaper = _parseBool(json['read_newspaper']);
    currentNewspaper = _safeString(json['current_newspaper']);
    reasonForNotTakingEenaduNewsPaper =
        _safeString(json['reason_for_not_taking_eenadu_newsPaper']);
    reasonNotReading = _safeString(json['reason_not_reading']);
    freeOffer15Days = _parseBool(json['free_offer_15_days']);
    reasonNotTakingOffer = _safeString(json['reason_not_taking_offer']);
    employed = _parseBool(json['employed']);
    jobType = _parseBool(json['job_type']);
    jobTypeOne = _parseBool(json['job_type_one']);
    jobProfession = _safeString(json['job_profession']);
    jobDesignation = _safeString(json['job_designation']);
    companyName = _safeString(json['company_name']);
    profession = _safeString(json['profession']);
    jobWorkingState = _parseBool(json['job_working_state']);
    jobWorkingLocation = _parseBool(json['job_working_location']);
    jobDesignationOne = _safeString(json['job_designation_one']);
    latitude = _safeString(json['latitude']);
    longitude = _safeString(json['longitude']);
    locationAddress = _parseBool(json['location_address']);
    locationUrl = _safeString(json['location_url']) ?? "N/A"; // ✅ fixed
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    data['reason_for_not_taking_eenadu_newsPaper'] =
        reasonForNotTakingEenaduNewsPaper;
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
    return data;
  }

  /// 🔧 Converts "true"/"false" strings or actual bool to bool?
  bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return null;
  }

  /// 🔧 Safely converts to String? (avoids assigning bool or int to String)
  String? _safeString(dynamic value) {
    return value is String ? value : null;
  }
}
