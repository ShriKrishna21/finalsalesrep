class routefetch {
  String? jsonrpc;
  Null id;
  Result? result;

  routefetch({this.jsonrpc, this.id, this.result});

  routefetch.fromJson(Map<String, dynamic> json) {
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
  int? status;
  bool? success;
  RootMap? rootMap;

  Result({this.status, this.success, this.rootMap});

  Result.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    rootMap =
        json['root_map'] != null ? RootMap.fromJson(json['root_map']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['success'] = success;
    if (rootMap != null) {
      data['root_map'] = rootMap!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
