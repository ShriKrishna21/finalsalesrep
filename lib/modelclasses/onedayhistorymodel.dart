class OneDayHistory {
  String? jsonrpc;
  dynamic id;
  Result? result;

  OneDayHistory({this.jsonrpc, this.id, this.result});

  factory OneDayHistory.fromJson(Map<String, dynamic> json) {
    return OneDayHistory(
      jsonrpc: json['jsonrpc'],
      id: json['id'],
      result: json['result'] != null ? Result.fromJson(json['result']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'id': id,
      'result': result?.toJson(),
    };
  }
}

class Result {
  List<Record>? records;
  int? count;
  String? code;

  Result({this.records, this.count, this.code});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      records:
          (json['records'] as List?)?.map((e) => Record.fromJson(e)).toList(),
      count: json['count'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'records': records?.map((e) => e.toJson()).toList(),
      'count': count,
      'code': code,
    };
  }
}

class Record {
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
  dynamic jobType;
  dynamic jobTypeOne;
  String? jobProfession;
  String? jobDesignation;
  String? companyName;
  String? profession;
  dynamic jobWorkingState;
  dynamic jobWorkingLocation;
  String? jobDesignationOne;
  String? latitude;
  String? longitude;
  dynamic locationAddress;

  Record({
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
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'],
      agentName: _parseString(json['agent_name']),
      agentLogin: _parseString(json['agent_login']),
      unitName: _parseString(json['unit_name']),
      date: _parseString(json['date']),
      time: _parseString(json['time']),
      familyHeadName: _parseString(json['family_head_name']),
      fatherName: _parseString(json['father_name']),
      motherName: _parseString(json['mother_name']),
      spouseName: _parseString(json['spouse_name']),
      houseNumber: _parseString(json['house_number']),
      streetNumber: _parseString(json['street_number']),
      city: _parseString(json['city']),
      pinCode: _parseString(json['pin_code']),
      address: _parseString(json['address']),
      mobileNumber: _parseString(json['mobile_number']),
      eenaduNewspaper: _parseBool(json['eenadu_newspaper']),
      feedbackToImproveEenaduPaper:
          _parseString(json['feedback_to_improve_eenadu_paper']),
      readNewspaper: _parseBool(json['read_newspaper']),
      currentNewspaper: _parseString(json['current_newspaper']),
      reasonForNotTakingEenaduNewsPaper:
          _parseString(json['reason_for_not_taking_eenadu_newsPaper']),
      reasonNotReading: _parseString(json['reason_not_reading']),
      freeOffer15Days: _parseBool(json['free_offer_15_days']),
      reasonNotTakingOffer: _parseString(json['reason_not_taking_offer']),
      employed: _parseBool(json['employed']),
      jobType: json['job_type'],
      jobTypeOne: json['job_type_one'],
      jobProfession: _parseString(json['job_profession']),
      jobDesignation: _parseString(json['job_designation']),
      companyName: _parseString(json['company_name']),
      profession: _parseString(json['profession']),
      jobWorkingState: json['job_working_state'],
      jobWorkingLocation: json['job_working_location'],
      jobDesignationOne: _parseString(json['job_designation_one']),
      latitude: _parseString(json['latitude']),
      longitude: _parseString(json['longitude']),
      locationAddress: _parseString(json['location_address']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agent_name': agentName,
      'agent_login': agentLogin,
      'unit_name': unitName,
      'date': date,
      'time': time,
      'family_head_name': familyHeadName,
      'father_name': fatherName,
      'mother_name': motherName,
      'spouse_name': spouseName,
      'house_number': houseNumber,
      'street_number': streetNumber,
      'city': city,
      'pin_code': pinCode,
      'address': address,
      'mobile_number': mobileNumber,
      'eenadu_newspaper': eenaduNewspaper,
      'feedback_to_improve_eenadu_paper': feedbackToImproveEenaduPaper,
      'read_newspaper': readNewspaper,
      'current_newspaper': currentNewspaper,
      'reason_for_not_taking_eenadu_newsPaper':
          reasonForNotTakingEenaduNewsPaper,
      'reason_not_reading': reasonNotReading,
      'free_offer_15_days': freeOffer15Days,
      'reason_not_taking_offer': reasonNotTakingOffer,
      'employed': employed,
      'job_type': jobType,
      'job_type_one': jobTypeOne,
      'job_profession': jobProfession,
      'job_designation': jobDesignation,
      'company_name': companyName,
      'profession': profession,
      'job_working_state': jobWorkingState,
      'job_working_location': jobWorkingLocation,
      'job_designation_one': jobDesignationOne,
      'latitude': latitude,
      'longitude': longitude,
      'location_address': locationAddress,
    };
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return null;
  }

  static String? _parseString(dynamic value) {
    return value is String ? value : null;
  }
}
