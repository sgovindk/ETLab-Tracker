class TimetableEntry {
  final String day;       // Monday, Tuesday, …
  final String period;    // P1, P2, …
  final String time;      // "9:30–10:30"
  final String subjectCode;
  final String subjectName;
  final String teacher;
  final String type;      // Theory, Lab, Project, Free

  const TimetableEntry({
    required this.day,
    required this.period,
    required this.time,
    this.subjectCode = '',
    required this.subjectName,
    this.teacher = '',
    this.type = 'Theory',
  });

  bool get isFree => subjectName.toLowerCase().contains('free');

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      day: json['day'] as String? ?? '',
      period: json['period'] as String? ?? '',
      time: json['time'] as String? ?? '',
      subjectCode: json['subject_code'] as String? ?? '',
      subjectName: json['subject_name'] as String? ?? '',
      teacher: json['teacher'] as String? ?? '',
      type: json['type'] as String? ?? 'Theory',
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'period': period,
        'time': time,
        'subject_code': subjectCode,
        'subject_name': subjectName,
        'teacher': teacher,
        'type': type,
      };

  TimetableEntry copyWith({
    String? day,
    String? period,
    String? time,
    String? subjectCode,
    String? subjectName,
    String? teacher,
    String? type,
  }) {
    return TimetableEntry(
      day: day ?? this.day,
      period: period ?? this.period,
      time: time ?? this.time,
      subjectCode: subjectCode ?? this.subjectCode,
      subjectName: subjectName ?? this.subjectName,
      teacher: teacher ?? this.teacher,
      type: type ?? this.type,
    );
  }
}
