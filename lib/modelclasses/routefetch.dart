class routefetch {
  String? jsonrpc;
  Null? id;
  Result? result;

  routefetch({this.jsonrpc, this.id, this.result});

  routefetch.fromJson(Map<String, dynamic> json) {
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
  int? status;
  bool? success;
  RootMap? rootMap;

  Result({this.status, this.success, this.rootMap});

  Result.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    rootMap = json['root_map'] != null
        ? new RootMap.fromJson(json['root_map'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['success'] = this.success;
    if (this.rootMap != null) {
      data['root_map'] = this.rootMap!.toJson();
    }
    return data;
  }
}

class RootMap {
  int? id;
  String? name;

  RootMap({this.id, this.name});

  RootMap.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}