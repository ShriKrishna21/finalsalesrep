class NofAgents {
  String? jsonrpc;
  dynamic id;
  Result? result;

  NofAgents({this.jsonrpc, this.id, this.result});

  factory NofAgents.fromJson(Map<String, dynamic> json) {
    return NofAgents(
      jsonrpc: json['jsonrpc'],
      id: json['id'],
      result: json['result'] != null ? Result.fromJson(json['result']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'id': id,
      'result': result?.toJson(),
    };
  }
}

class Result {
  int? status;
  List<User>? users;

  Result({this.status, this.users});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? ''),
      users: (json['users'] as List?)?.map((e) => User.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'users': users?.map((e) => e.toJson()).toList(),
    };
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? login;
  int? createUid;
  String? unitName;
  String? phone;
  String? state;
  String? panNumber;
  String? aadharNumber;
  String? role;
  String? status;

  User({
    this.id,
    this.name,
    this.email,
    this.login,
    this.createUid,
    this.unitName,
    this.phone,
    this.state,
    this.panNumber,
    this.aadharNumber,
    this.role,
    this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name'],
      email: json['email'],
      login: json['login'],
      createUid: json['create_uid'] is int
          ? json['create_uid']
          : int.tryParse(json['create_uid']?.toString() ?? ''),
      unitName: json['unit_name'],
      phone: json['phone'],
      state: json['state'],
      panNumber: json['pan_number'],
      aadharNumber: json['aadhar_number'],
      role: json['role'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'login': login,
      'create_uid': createUid,
      'unit_name': unitName,
      'phone': phone,
      'state': state,
      'pan_number': panNumber,
      'aadhar_number': aadharNumber,
      'role': role,
      'status': status,
    };
  }
}
