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
  List<Assigned>? assigned;

  Result({this.assigned});

  factory Result.fromJson(Map<String, dynamic> json) {
    var list = json['assigned'] as List?;
    List<Assigned>? assignedList = list
        ?.map((e) => Assigned.fromJson(e as Map<String, dynamic>))
        .toList();
    return Result(assigned: assignedList);
  }
}

class Assigned {
  final int? id;
  final String? date;
  final List<FromTo>? fromTo;

  Assigned({this.id, this.date, this.fromTo});

  factory Assigned.fromJson(Map<String, dynamic> json) {
    var list = json['from_to'] as List?;
    List<FromTo>? fromToList = list
        ?.map((e) => FromTo.fromJson(e as Map<String, dynamic>))
        .toList();

    return Assigned(
      id: json['id'] as int?,
      date: json['date'] as String?,
      fromTo: fromToList,
    );
  }
}

class FromTo {
  final int? id; // Added this line
  final String? fromLocation;
  final String? toLocation;
  final String? extraPoint;

  FromTo({this.id, this.fromLocation, this.toLocation, this.extraPoint});

  factory FromTo.fromJson(Map<String, dynamic> json) {
    return FromTo(
      id: json['id'] as int?, // Parse 'id' if present
      fromLocation: json['from_location'] as String?,
      toLocation: json['to_location'] as String?,
      extraPoint: json['extra_point']?.toString(),
    );
  }
}
