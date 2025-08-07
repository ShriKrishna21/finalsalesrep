class AgencyModel {
  String? jsonrpc;
  dynamic id;
  AgencyResult? result;

  AgencyModel({this.jsonrpc, this.id, this.result});

  AgencyModel.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'];
    id = json['id'];
    result = json['result'] != null
        ? AgencyResult.fromJson(json['result'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['jsonrpc'] = jsonrpc;
    data['id'] = id;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}

class AgencyResult {
  bool? success;
  List<AgencyData>? data;
  int? code;

  AgencyResult({this.success, this.data, this.code});

  AgencyResult.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    if (json['data'] != null) {
      data = <AgencyData>[];
      json['data'].forEach((v) {
        data!.add(AgencyData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AgencyData {
  int? id;
  String? name;
  String? code;
  String? locationName;

  AgencyData({this.id, this.name, this.code, this.locationName});

  AgencyData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
    code = json['code']?.toString();
    locationName = json['location_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['location_name'] = locationName;
    return data;
  }
}
