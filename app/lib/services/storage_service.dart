import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject_attendance.dart';
import '../models/timetable_entry.dart';

/// Persists credentials securely and caches attendance / settings.
class StorageService {
  static late SharedPreferences _prefs;
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Keys
  static const _kUsername = 'etlab_username';
  static const _kPassword = 'etlab_password';
  static const _kAttendance = 'cached_attendance';
  static const _kTimetable = 'timetable';
  static const _kLastSync = 'last_sync';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Credentials (secure) ──────────────────────────────────────
  static Future<void> saveCredentials(String user, String pass) async {
    await _secure.write(key: _kUsername, value: user);
    await _secure.write(key: _kPassword, value: pass);
  }

  static Future<String?> getUsername() => _secure.read(key: _kUsername);
  static Future<String?> getPassword() => _secure.read(key: _kPassword);

  static Future<bool> hasCredentials() async {
    final u = await getUsername();
    return u != null && u.isNotEmpty;
  }

  static Future<void> clearCredentials() async {
    await _secure.delete(key: _kUsername);
    await _secure.delete(key: _kPassword);
  }

  // ── Cached attendance ─────────────────────────────────────────
  static Future<void> cacheAttendance(List<SubjectAttendance> data) async {
    final json = data.map((e) => e.toJson()).toList();
    await _prefs.setString(_kAttendance, jsonEncode(json));
    await _prefs.setString(_kLastSync, DateTime.now().toIso8601String());
  }

  static List<SubjectAttendance> getCachedAttendance() {
    final raw = _prefs.getString(_kAttendance);
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return list
        .map((e) => SubjectAttendance.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static DateTime? getLastSync() {
    final raw = _prefs.getString(_kLastSync);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  // ── Timetable ─────────────────────────────────────────────────
  static Future<void> saveTimetable(List<TimetableEntry> entries) async {
    final json = entries.map((e) => e.toJson()).toList();
    await _prefs.setString(_kTimetable, jsonEncode(json));
  }

  static List<TimetableEntry>? getSavedTimetable() {
    final raw = _prefs.getString(_kTimetable);
    if (raw == null) return null;
    final List list = jsonDecode(raw);
    return list
        .map((e) => TimetableEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Logout ────────────────────────────────────────────────────
  static Future<void> clearAll() async {
    await clearCredentials();
    await _prefs.clear();
  }
}
