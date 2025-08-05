
class SelfieSession {
  final String? startTime;
  final String? endTime;
  final String? startSelfie;
  final String? endSelfie;

  SelfieSession({
    this.startTime,
    this.endTime,
    this.startSelfie,
    this.endSelfie,
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
    final result = json['result'];
    // Handle String-to-bool conversion for 'success'
    final successValue = result['success'];
    bool parsedSuccess;
    if (successValue is bool) {
      parsedSuccess = successValue;
    } else if (successValue is String) {
      parsedSuccess = successValue.toLowerCase() == 'true';
    } else {
      parsedSuccess = false; // Fallback for unexpected types
    }

    // Extract all start_time, end_time, start_selfie, and end_selfie from the selfies array
    final List<SelfieSession> sessions = [];
    final selfies = result['selfies'] as List<dynamic>?;
    if (selfies != null && selfies.isNotEmpty) {
      sessions.addAll(selfies.map((selfie) {
        final startTime = selfie['start_time']?.toString();
        final endTime = selfie['end_time'] is String && selfie['end_time'] != 'false'
            ? selfie['end_time'].toString()
            : null;
        final startSelfie = selfie['start_selfie']?.toString();
        final endSelfie = selfie['end_selfie']?.toString();
        return SelfieSession(
          startTime: startTime,
          endTime: endTime,
          startSelfie: startSelfie,
          endSelfie: endSelfie,
        );
      }).toList());
      // Sort sessions by start_time in descending order (latest first)
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
