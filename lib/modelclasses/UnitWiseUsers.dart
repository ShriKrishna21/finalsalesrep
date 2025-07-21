class unitwiseusers {
  final Result? result;

  unitwiseusers({this.result});

  factory unitwiseusers.fromJson(Map<String, dynamic> json) {
    return unitwiseusers(
      result: json['result'] != null ? Result.fromJson(json['result']) : null,
    );
  }
}

class Result {
  final List<Users>? users;

  Result({this.users});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      users: (json['users'] as List<dynamic>?)
          ?.map((e) => Users.fromJson(e))
          .toList(),
    );
  }
}

class Users {
  final String? unitName;
  final String? name;

  Users({this.unitName, this.name});

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      unitName: json['unit_name'],
      name: json['name'],
    );
  }
}
