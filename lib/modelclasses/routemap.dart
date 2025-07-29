class RouteMap {
  final String? jsonrpc;
  final dynamic id;
  final Result? result;

  RouteMap({this.jsonrpc, this.id, this.result});

  factory RouteMap.fromJson(Map<String, dynamic> json) {
    return RouteMap(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] != null
          ? Result.fromJson(json['result'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Result {
  final bool? success;
  final int? status;
  final int? userId;
   List<Assigned>? assigned;
  final List<Assigned>? working;
  final List<Assigned>? done;

  Result({
    this.success,
    this.status,
    this.userId,
    this.assigned,
    this.working,
    this.done,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      success: json['success'] as bool?,
      status: json['status'] as int?,
      userId: json['user_id'] as int?,
      assigned: (json['assigned'] as List?)
          ?.map((e) => Assigned.fromJson(e as Map<String, dynamic>))
          .toList(),
      working: (json['working'] as List?)
          ?.map((e) => Assigned.fromJson(e as Map<String, dynamic>))
          .toList(),
      done: (json['done'] as List?)
          ?.map((e) => Assigned.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Assigned {
  final int? id;
  final String? name;
  final String? date;
  final String? stage;
  final List<FromTo>? fromTo;

  Assigned({this.id, this.name, this.date, this.stage, this.fromTo});

  factory Assigned.fromJson(Map<String, dynamic> json) {
    return Assigned(
      id: json['id'] as int?,
      name: json['name'] as String?,
      date: json['date'] as String?,
      stage: json['stage'] as String?,
      fromTo: (json['from_to'] as List?)
          ?.map((e) => FromTo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FromTo {
  final int? id;
  final String? fromLocation;
  final String? toLocation;
  final List<ExtraPoint>? extraPoints;

  FromTo({this.id, this.fromLocation, this.toLocation, this.extraPoints});

  factory FromTo.fromJson(Map<String, dynamic> json) {
    return FromTo(
      id: json['id'] as int?,
      fromLocation: json['from_location'] as String?,
      toLocation: json['to_location'] as String?,
      extraPoints: (json['extra_points'] as List?)
          ?.map((e) => ExtraPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExtraPoint {
  final int? id;
  final String? name;

  ExtraPoint({this.id, this.name});

  factory ExtraPoint.fromJson(Map<String, dynamic> json) {
    return ExtraPoint(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }
}
