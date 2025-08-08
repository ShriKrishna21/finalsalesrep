class AllCustomerForms {
  String? jsonrpc;
  dynamic id;
  Result? result;

  AllCustomerForms({this.jsonrpc, this.id, this.result});

  AllCustomerForms.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'] as String?;
    id = json['id'];
    result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['jsonrpc'] = jsonrpc;
    data['id'] = id;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}

class Result {
  bool? success;
  List<Records>? records;
  int? count;
  String? code;

  Result({this.success, this.records, this.count, this.code});

  Result.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;
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
    data['success'] = success;
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
  String? unitName;
  String? date;
  String? familyHeadName;
  String? address;
  String? city;
  String? pinCode;
  String? mobileNumber;
  bool? eenaduNewspaper;
  bool? employed;
  String? faceBase64;
  String? locationUrl;
  String? latitude;
  String? longitude;
  String? forConsider;
  bool? shiftToEENADU;
  bool? wouldLikeToStayWithExistingNewsPapar;
  String? startCirculating;
  String? agency;
  String? age;
  String? customerType;

  Records({
    this.id,
    this.agentName,
    this.unitName,
    this.date,
    this.familyHeadName,
    this.address,
    this.city,
    this.pinCode,
    this.mobileNumber,
    this.eenaduNewspaper,
    this.employed,
    this.faceBase64,
    this.locationUrl,
    this.latitude,
    this.longitude,
    this.forConsider,
    this.shiftToEENADU,
    this.wouldLikeToStayWithExistingNewsPapar,
    this.startCirculating,
    this.agency,
    this.age,
    this.customerType,
  });

  Records.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    agentName = _asString(json['agent_name']);
    unitName = _asString(json['unit_name']);
    date = _asString(json['date']);
    familyHeadName = _asString(json['family_head_name']);
    address = _asString(json['address']);
    city = _asString(json['city']);
    pinCode = _asString(json['pin_code']);
    mobileNumber = _asString(json['mobile_number']);
    eenaduNewspaper = _parseBool(json['eenadu_newspaper']);
    employed = _parseBool(json['employed']);
    faceBase64 = _asString(json['face_base64']);
    locationUrl = _asString(json['location_url']);
    latitude = _asString(json['latitude']);
    longitude = _asString(json['longitude']);
    forConsider = _asString(json['for_consider']);
    shiftToEENADU = _parseBool(json['shift_to_eenadu']);
    wouldLikeToStayWithExistingNewsPapar =
        _parseBool(json['would_like_to_stay_with_existing_news_papar']);
    startCirculating = _asString(json['start_circulating']);
    agency = _asString(json['Agency']); // Capital 'A' to match API
    age = _asString(json['age']);
    customerType = _asString(json['customer_type']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['agent_name'] = agentName;
    data['unit_name'] = unitName;
    data['date'] = date;
    data['family_head_name'] = familyHeadName;
    data['address'] = address;
    data['city'] = city;
    data['pin_code'] = pinCode;
    data['mobile_number'] = mobileNumber;
    data['eenadu_newspaper'] = eenaduNewspaper;
    data['employed'] = employed;
    data['face_base64'] = faceBase64;
    data['location_url'] = locationUrl;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['for_consider'] = forConsider;
    data['shift_to_eenadu'] = shiftToEENADU;
    data['would_like_to_stay_with_existing_news_papar'] =
        wouldLikeToStayWithExistingNewsPapar;
    data['start_circulating'] = startCirculating;
    data['Agency'] = agency;
    data['age'] = age;
    data['customer_type'] = customerType;
    return data;
  }

  bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final s = value.toLowerCase();
      return s == 'true' || s == '1';
    }
    if (value is num) return value != 0;
    return null;
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    return value is String ? value : value.toString();
  }
}
