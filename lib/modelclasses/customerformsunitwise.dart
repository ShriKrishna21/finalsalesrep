class AllCustomerForms {
  String? jsonrpc;
  dynamic id;
  Result? result;

  AllCustomerForms({this.jsonrpc, this.id, this.result});

  AllCustomerForms.fromJson(Map<String, dynamic> json) {
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
  bool? success;
  List<Records>? records;
  int? count;
  String? code;

  Result({this.success, this.records, this.count, this.code});

  Result.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;
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
  bool? eenaduNewspaper; // <-- should be bool?
  bool? employed; // <-- should be bool?
  String? faceBase64;

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
  });

  Records.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    agentName = json['agent_name'];
    unitName = json['unit_name'];
    date = json['date'];
    familyHeadName = json['family_head_name'];
    address = json['address'];
    city = json['city'];
    pinCode = json['pin_code'];
    mobileNumber = json['mobile_number'];
    eenaduNewspaper = json['eenadu_newspaper'];
    employed = json['employed'];
    faceBase64 = json['face_base64'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    return data;
  }
}

bool? _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  if (value is num) return value == 1;
  return null;
}
