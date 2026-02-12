import '../models/timetable_entry.dart';

/// Provides the default timetable and helper look-ups.
class TimetableService {
  TimetableService._();

  static const List<String> days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
  ];

  static const List<String> periods = ['P1', 'P2', 'P3', 'P4', 'P5', 'P6'];

  static const Map<String, String> periodTimes = {
    'P1': '9:30–10:30',
    'P2': '10:30–11:30',
    'P3': '11:30–12:30',
    'P4': '1:30–2:30',
    'P5': '2:30–3:30',
    'P6': '3:30–4:30',
  };

  /// Start hour in 24-hr format for each period.
  static const Map<String, double> periodStartHour = {
    'P1': 9.5,
    'P2': 10.5,
    'P3': 11.5,
    'P4': 13.5,
    'P5': 14.5,
    'P6': 15.5,
  };

  static const Map<String, double> periodEndHour = {
    'P1': 10.5,
    'P2': 11.5,
    'P3': 12.5,
    'P4': 14.5,
    'P5': 15.5,
    'P6': 16.5,
  };

  // ── Default timetable (user provided) ─────────────────────────
  static List<TimetableEntry> get defaultTimetable => [
    // ── Monday ──
    const TimetableEntry(day: 'Monday', period: 'P1', time: '9:30–10:30', subjectCode: 'AMT302', subjectName: 'Concepts in Natural Language Processing', teacher: 'Rejimoan R', type: 'Theory'),
    const TimetableEntry(day: 'Monday', period: 'P2', time: '10:30–11:30', subjectCode: 'CST306', subjectName: 'Algorithm Analysis and Design', teacher: 'Surekha I S', type: 'Theory'),
    const TimetableEntry(day: 'Monday', period: 'P3', time: '11:30–12:30', subjectCode: 'ANN', subjectName: 'Artificial Neural Networks Techniques', teacher: '', type: 'Theory'),
    const TimetableEntry(day: 'Monday', period: 'P4', time: '1:30–2:30', subjectCode: 'AIT304', subjectName: 'Robotics and Intelligent System', teacher: 'Syama R', type: 'Theory'),
    const TimetableEntry(day: 'Monday', period: 'P5', time: '2:30–3:30', subjectCode: 'PROJ', subjectName: 'Mini Project', teacher: '', type: 'Project'),
    const TimetableEntry(day: 'Monday', period: 'P6', time: '3:30–4:30', subjectCode: 'PROJ', subjectName: 'Mini Project', teacher: '', type: 'Project'),

    // ── Tuesday ──
    const TimetableEntry(day: 'Tuesday', period: 'P1', time: '9:30–10:30', subjectCode: 'HUT300', subjectName: 'Industrial Economics and Foreign Trade', teacher: 'Dr. Geethanjali M N', type: 'Theory'),
    const TimetableEntry(day: 'Tuesday', period: 'P2', time: '10:30–11:30', subjectCode: 'AMT302', subjectName: 'Concepts in Natural Language Processing', teacher: 'Rejimoan R', type: 'Theory'),
    const TimetableEntry(day: 'Tuesday', period: 'P3', time: '11:30–12:30', subjectCode: 'ANN', subjectName: 'Artificial Neural Networks Techniques', teacher: '', type: 'Theory'),
    const TimetableEntry(day: 'Tuesday', period: 'P4', time: '1:30–2:30', subjectCode: 'PROJ', subjectName: 'Mini Project', teacher: '', type: 'Project'),
    const TimetableEntry(day: 'Tuesday', period: 'P5', time: '2:30–3:30', subjectCode: 'PROJ', subjectName: 'Mini Project', teacher: '', type: 'Project'),
    const TimetableEntry(day: 'Tuesday', period: 'P6', time: '3:30–4:30', subjectCode: 'PROJ', subjectName: 'Mini Project', teacher: '', type: 'Project'),

    // ── Wednesday ──
    const TimetableEntry(day: 'Wednesday', period: 'P1', time: '9:30–10:30', subjectCode: 'AMT302', subjectName: 'Concepts in Natural Language Processing', teacher: 'Rejimoan R', type: 'Theory'),
    const TimetableEntry(day: 'Wednesday', period: 'P2', time: '10:30–11:30', subjectCode: 'AIT304', subjectName: 'Robotics and Intelligent System', teacher: 'Syama R', type: 'Theory'),
    const TimetableEntry(day: 'Wednesday', period: 'P3', time: '11:30–12:30', subjectCode: 'HUT300', subjectName: 'Industrial Economics and Foreign Trade', teacher: 'Dr. Geethanjali M N', type: 'Theory'),
    const TimetableEntry(day: 'Wednesday', period: 'P4', time: '1:30–2:30', subjectCode: 'CST306', subjectName: 'Algorithm Analysis and Design', teacher: 'Surekha I S', type: 'Theory'),
    const TimetableEntry(day: 'Wednesday', period: 'P5', time: '2:30–3:30', subjectCode: 'AMT302', subjectName: 'Concepts in Natural Language Processing', teacher: 'Rejimoan R', type: 'Theory'),
    const TimetableEntry(day: 'Wednesday', period: 'P6', time: '3:30–4:30', subjectCode: 'ANN', subjectName: 'Artificial Neural Networks Techniques', teacher: '', type: 'Theory'),

    // ── Thursday ──
    const TimetableEntry(day: 'Thursday', period: 'P1', time: '9:30–10:30', subjectCode: 'NLP_LAB', subjectName: 'Natural Language Processing Lab', teacher: '', type: 'Lab'),
    const TimetableEntry(day: 'Thursday', period: 'P2', time: '10:30–11:30', subjectCode: 'NLP_LAB', subjectName: 'Natural Language Processing Lab', teacher: '', type: 'Lab'),
    const TimetableEntry(day: 'Thursday', period: 'P3', time: '11:30–12:30', subjectCode: 'NLP_LAB', subjectName: 'Natural Language Processing Lab', teacher: '', type: 'Lab'),
    const TimetableEntry(day: 'Thursday', period: 'P4', time: '1:30–2:30', subjectCode: 'ANN', subjectName: 'Artificial Neural Networks Techniques', teacher: '', type: 'Theory'),
    const TimetableEntry(day: 'Thursday', period: 'P5', time: '2:30–3:30', subjectCode: 'AIT304', subjectName: 'Robotics and Intelligent System', teacher: 'Syama R', type: 'Theory'),
    const TimetableEntry(day: 'Thursday', period: 'P6', time: '3:30–4:30', subjectCode: 'CST306', subjectName: 'Algorithm Analysis and Design', teacher: 'Surekha I S', type: 'Theory'),

    // ── Friday ──
    const TimetableEntry(day: 'Friday', period: 'P1', time: '9:30–10:30', subjectCode: 'HUT300', subjectName: 'Industrial Economics and Foreign Trade', teacher: 'Dr. Geethanjali M N', type: 'Theory'),
    const TimetableEntry(day: 'Friday', period: 'P2', time: '10:30–11:30', subjectCode: 'AIT304', subjectName: 'Robotics and Intelligent System', teacher: 'Syama R', type: 'Theory'),
    const TimetableEntry(day: 'Friday', period: 'P3', time: '11:30–12:30', subjectCode: 'CST306', subjectName: 'Algorithm Analysis and Design', teacher: 'Surekha I S', type: 'Theory'),
    const TimetableEntry(day: 'Friday', period: 'P4', time: '1:30–2:30', subjectCode: 'CMT308', subjectName: 'Comprehensive Course Work', teacher: 'Surekha I S', type: 'Theory'),
    const TimetableEntry(day: 'Friday', period: 'P5', time: '2:30–3:30', subjectCode: 'FREE', subjectName: 'Free Period', teacher: '', type: 'Free'),
    const TimetableEntry(day: 'Friday', period: 'P6', time: '3:30–4:30', subjectCode: 'FREE', subjectName: 'Free Period', teacher: '', type: 'Free'),
  ];

  // ── Helpers ────────────────────────────────────────────────────

  /// Get today's day name.
  static String todayName() {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[DateTime.now().weekday - 1];
  }

  /// Get entries for a given day.
  static List<TimetableEntry> entriesForDay(List<TimetableEntry> all, String day) {
    return all.where((e) => e.day == day).toList()
      ..sort((a, b) => periods.indexOf(a.period).compareTo(periods.indexOf(b.period)));
  }

  /// Current fractional hour in 24h format (e.g., 14.75 = 2:45 PM).
  static double _nowHour() {
    final now = DateTime.now();
    return now.hour + now.minute / 60.0;
  }

  /// Find the next upcoming class from the timetable.
  /// Returns null on weekends or after all classes.
  static TimetableEntry? nextClass(List<TimetableEntry> all) {
    final today = todayName();
    if (!days.contains(today)) return null;

    final todayEntries = entriesForDay(all, today);
    final hour = _nowHour();

    for (final entry in todayEntries) {
      if (entry.isFree) continue;
      final end = periodEndHour[entry.period] ?? 0;
      if (hour < end) return entry;
    }
    return null; // all done for today
  }

  /// Find the currently ongoing class.
  static TimetableEntry? currentClass(List<TimetableEntry> all) {
    final today = todayName();
    if (!days.contains(today)) return null;

    final todayEntries = entriesForDay(all, today);
    final hour = _nowHour();

    for (final entry in todayEntries) {
      final start = periodStartHour[entry.period] ?? 0;
      final end = periodEndHour[entry.period] ?? 0;
      if (hour >= start && hour < end) return entry;
    }
    return null;
  }

  /// Minutes until a period starts.
  static int minutesUntil(String period) {
    final start = periodStartHour[period] ?? 0;
    final now = _nowHour();
    final diff = start - now;
    return (diff * 60).round();
  }
}
