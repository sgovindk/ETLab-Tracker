import 'package:flutter/foundation.dart';
import '../models/timetable_entry.dart';
import '../services/storage_service.dart';
import '../services/timetable_service.dart';

/// Manages timetable state with persistence.
class TimetableProvider extends ChangeNotifier {
  List<TimetableEntry> _entries = [];

  List<TimetableEntry> get entries => _entries;

  // ── Init ───────────────────────────────────────────────────────
  void init() {
    final saved = StorageService.getSavedTimetable();
    _entries = saved ?? TimetableService.defaultTimetable;
    notifyListeners();
  }

  // ── Day queries ────────────────────────────────────────────────
  List<TimetableEntry> forDay(String day) =>
      TimetableService.entriesForDay(_entries, day);

  List<TimetableEntry> get todayEntries =>
      forDay(TimetableService.todayName());

  TimetableEntry? get nextClass =>
      TimetableService.nextClass(_entries);

  TimetableEntry? get currentClass =>
      TimetableService.currentClass(_entries);

  // ── Edit a single entry ────────────────────────────────────────
  Future<void> updateEntry(
    String day,
    String period, {
    String? subjectCode,
    String? subjectName,
    String? teacher,
    String? type,
  }) async {
    final idx = _entries.indexWhere(
      (e) => e.day == day && e.period == period,
    );
    if (idx == -1) return;

    _entries[idx] = _entries[idx].copyWith(
      subjectCode: subjectCode,
      subjectName: subjectName,
      teacher: teacher,
      type: type,
    );
    await StorageService.saveTimetable(_entries);
    notifyListeners();
  }

  // ── Replace full entry ─────────────────────────────────────────
  Future<void> replaceEntry(String day, String period, TimetableEntry newEntry) async {
    final idx = _entries.indexWhere(
      (e) => e.day == day && e.period == period,
    );
    if (idx == -1) return;
    _entries[idx] = newEntry;
    await StorageService.saveTimetable(_entries);
    notifyListeners();
  }

  // ── Reset to default ──────────────────────────────────────────
  Future<void> resetToDefault() async {
    _entries = TimetableService.defaultTimetable;
    await StorageService.saveTimetable(_entries);
    notifyListeners();
  }
}
