class loginmodel {
  String? jsonrpc;
  Null id;
  Result? result;

  loginmodel({this.jsonrpc, this.id, this.result});

  loginmodel.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'];
    id = json['id'];
    result =
        json['result'] != null ? new Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jsonrpc'] = this.jsonrpc;
    data['id'] = this.id;
    if (this.result != null) {
      data['result'] = this.result!.toJson();
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

  Result(
      {this.status,
      this.userId,
      this.name,
      this.apiKey,
      this.roleLeGr,
      this.role,
      this.unit,
      this.expiration,
      this.code});

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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['api_key'] = this.apiKey;
    data['role_Le_gr'] = this.roleLeGr;
    data['role'] = this.role;
    data['unit'] = this.unit;
    data['expiration'] = this.expiration;
    data['code'] = this.code;
    return data;
  }
}