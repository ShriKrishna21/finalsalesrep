class SelfieSession {
  final String? startTime;
  final String? endTime;
  final String? startSelfie;
  final String? endSelfie;

  // Start work location
  final String? startLatitude;
  final String? startLongitude;
  final String? startLocationUrl;

  // End work location
  final String? endLatitude;
  final String? endLongitude;
  final String? endLocationUrl;

  SelfieSession({
    this.startTime,
    this.endTime,
    this.startSelfie,
    this.endSelfie,
    this.startLatitude,
    this.startLongitude,
    this.startLocationUrl,
    this.endLatitude,
    this.endLongitude,
    this.endLocationUrl,
  });
}

class SelfieTimesResponse {
  final bool success;
  final List<SelfieSession> sessions;

  SelfieTimesResponse({
    required this.success,
    required this.sessions,
  });

  factory SelfieTimesResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? {};

    final successValue = result['success'];

    bool parsedSuccess;
    if (successValue is bool) {
      parsedSuccess = successValue;
    } else if (successValue is String) {
      parsedSuccess = successValue.toLowerCase() == 'true';
    } else {
      parsedSuccess = false;
    }

    final List<SelfieSession> sessions = [];
    final selfies = result['selfies'] as List<dynamic>?;

    if (selfies != null && selfies.isNotEmpty) {
      sessions.addAll(selfies.map((selfie) {
        String? parseValue(dynamic value) {
          if (value == null ||
              value == false ||
              value == 'false' ||
              value == '') {
            return null;
          }
          return value.toString();
        }

        return SelfieSession(
          startTime: parseValue(selfie['start_time']),
          endTime: parseValue(selfie['end_time']),
          startSelfie: parseValue(selfie['start_selfie']),
          endSelfie: parseValue(selfie['end_selfie']),

          // Start location
          startLatitude: parseValue(selfie['start_latitude']),
          startLongitude: parseValue(selfie['start_longitude']),
          startLocationUrl: parseValue(selfie['start_location_url']),

          // End location
          endLatitude: parseValue(selfie['end_latitude']),
          endLongitude: parseValue(selfie['end_longitude']),
          endLocationUrl: parseValue(selfie['end_location_url']),
        );
      }).toList());

      sessions.sort((a, b) {
        final aTime = DateTime.tryParse(a.startTime ?? '') ?? DateTime(0);
        final bTime = DateTime.tryParse(b.startTime ?? '') ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
    }

    return SelfieTimesResponse(
      success: parsedSuccess,
      sessions: sessions,
    );
  }
}
