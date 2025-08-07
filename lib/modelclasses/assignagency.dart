class assignagencymodel {
  String? jsonrpc;
  Null? id;
  Result? result;

  assignagencymodel({this.jsonrpc, this.id, this.result});

  assignagencymodel.fromJson(Map<String, dynamic> json) {
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
  bool? success;
  Data? data;
  int? code;

  Result({this.success, this.data, this.code});

  Result.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['code'] = this.code;
    return data;
  }
}

class Data {
  int? id;
  bool? name;
  String? locationName;
  String? code;

  Data({this.id, this.name, this.locationName, this.code});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    locationName = json['location_name'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['location_name'] = this.locationName;
    data['code'] = this.code;
    return data;
  }
}