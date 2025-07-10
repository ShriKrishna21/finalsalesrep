class routemap {
  String? jsonrpc;
  Null id;
  Result? result;

  routemap({this.jsonrpc, this.id, this.result});

  routemap.fromJson(Map<String, dynamic> json) {
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
  String? message;
  int? status;
  int? agentId;
  RootMap? rootMap;

  Result({this.success, this.message, this.status, this.agentId, this.rootMap});

  Result.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    status = json['status'];
    agentId = json['agent_id'];
    rootMap =
        json['root_map'] != null ? RootMap.fromJson(json['root_map']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['status'] = status;
    data['agent_id'] = agentId;
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
