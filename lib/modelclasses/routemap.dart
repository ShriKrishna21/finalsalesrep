class routemap {
  String? jsonrpc;
  Null? id;
  Result? result;

  routemap({this.jsonrpc, this.id, this.result});

  routemap.fromJson(Map<String, dynamic> json) {
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
    rootMap = json['root_map'] != null
        ? new RootMap.fromJson(json['root_map'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['status'] = this.status;
    data['agent_id'] = this.agentId;
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