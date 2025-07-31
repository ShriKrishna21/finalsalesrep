class LoginModel {
  String? jsonrpc;
  dynamic id;
  Result? result;

  LoginModel({this.jsonrpc, this.id, this.result});

  LoginModel.fromJson(Map<String, dynamic> json) {
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
  String? status;
  int? userId;
  String? name;
  String? apiKey;
  String? roleLeGr;
  String? role;
  String? unit;
  String? expiration;
  String? code;
  dynamic state; // Can be bool or string
  String? aadharNumber;
  String? panNumber;
  String? phone;
  dynamic target;
  String? image1920; // <-- Added field

  Result({
    this.status,
    this.userId,
    this.name,
    this.apiKey,
    this.roleLeGr,
    this.role,
    this.unit,
    this.expiration,
    this.code,
    this.state,
    this.aadharNumber,
    this.panNumber,
    this.phone,
    this.target,
    this.image1920, // <-- Added to constructor
  });

  Result.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    userId = json['user_id'];
    name = json['name'];
    apiKey = json['api_key'];
    roleLeGr = json['role_Le_gr'];
    role = json['role'];
    unit = json['unit'];
    expiration = json['expiration'];
    code = json['code'];
    state = json['state'];
    aadharNumber = json['aadhar_number'];
    panNumber = json['pan_number'];
    phone = json['phone'];
    target = json['target'];
    image1920 = json['image_1920']; // <-- Parsing new field
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['user_id'] = userId;
    data['name'] = name;
    data['api_key'] = apiKey;
    data['role_Le_gr'] = roleLeGr;
    data['role'] = role;
    data['unit'] = unit;
    data['expiration'] = expiration;
    data['code'] = code;
    data['state'] = state;
    data['aadhar_number'] = aadharNumber;
    data['pan_number'] = panNumber;
    data['phone'] = phone;
    data['target'] = target;
    data['image_1920'] = image1920; // <-- Serializing new field
    return data;
  }
}
