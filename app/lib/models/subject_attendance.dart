/// Model for a single subject's attendance data.
class SubjectAttendance {
  final String subjectCode;
  final String subjectName;
  final int hoursAttended;
  final int totalHours;
  final double percentage;

  const SubjectAttendance({
    required this.subjectCode,
    required this.subjectName,
    required this.hoursAttended,
    required this.totalHours,
    required this.percentage,
  });

  bool get isBelowThreshold => percentage < 75.0;
  bool get isCritical => percentage < 65.0;

  /// Classes needed to reach [target]%.
  /// Returns 0 if already above target.
  int classesNeeded(double target) {
    if (percentage >= target) return 0;
    if (target >= 100) return -1; // impossible
    // (hoursAttended + x) / (totalHours + x) >= target / 100
    // x >= (target * totalHours - 100 * hoursAttended) / (100 - target)
    final numerator = target * totalHours - 100 * hoursAttended;
    final denominator = 100 - target;
    if (denominator <= 0) return -1;
    final x = (numerator / denominator).ceil();
    return x < 0 ? 0 : x;
  }

  /// Projected percentage after attending [n] more classes.
  double projectedPercentage(int n) {
    if (totalHours + n == 0) return 0;
    return (hoursAttended + n) / (totalHours + n) * 100;
  }

  /// How many classes can be skipped while staying at/above [threshold]%.
  int bunkableClasses({double threshold = 75.0}) {
    int count = 0;
    while (true) {
      final projected = hoursAttended / (totalHours + count + 1) * 100;
      if (projected < threshold) break;
      count++;
    }
    return count;
  }

  factory SubjectAttendance.fromJson(Map<String, dynamic> json) {
    return SubjectAttendance(
      subjectCode: json['subject_code'] as String? ?? '',
      subjectName: json['subject_name'] as String? ?? '',
      hoursAttended: (json['hours_attended'] as num?)?.toInt() ?? 0,
      totalHours: (json['total_hours'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'subject_code': subjectCode,
        'subject_name': subjectName,
        'hours_attended': hoursAttended,
        'total_hours': totalHours,
        'percentage': percentage,
      };

  SubjectAttendance copyWith({
    String? subjectCode,
    String? subjectName,
    int? hoursAttended,
    int? totalHours,
    double? percentage,
  }) {
    return SubjectAttendance(
      subjectCode: subjectCode ?? this.subjectCode,
      subjectName: subjectName ?? this.subjectName,
      hoursAttended: hoursAttended ?? this.hoursAttended,
      totalHours: totalHours ?? this.totalHours,
      percentage: percentage ?? this.percentage,
    );
  }
}
