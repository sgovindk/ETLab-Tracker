import 'package:flutter/foundation.dart';
import '../models/subject_attendance.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/feedback_service.dart';

enum SyncStatus { idle, syncing, success, error }

class AttendanceProvider extends ChangeNotifier {
  // State
  List<SubjectAttendance> _subjects = [];
  SyncStatus _status = SyncStatus.idle;
  String _error = '';
  DateTime? _lastSync;
  bool _isLoggedIn = false;

  List<SubjectAttendance> get subjects => _subjects;
  SyncStatus get status => _status;
  String get error => _error;
  DateTime? get lastSync => _lastSync;
  bool get isLoggedIn => _isLoggedIn;

  // Derived data
  double get overallPercentage {
    if (_subjects.isEmpty) return 0;
    final totalAttended = _subjects.fold<int>(0, (s, e) => s + e.hoursAttended);
    final totalHours = _subjects.fold<int>(0, (s, e) => s + e.totalHours);
    return totalHours > 0 ? totalAttended / totalHours * 100 : 0;
  }

  List<SubjectAttendance> get belowThreshold =>
      _subjects.where((s) => s.isBelowThreshold).toList();

  int get totalSubjects => _subjects.length;

  // Init (load cached)
  Future<void> init() async {
    _isLoggedIn = await StorageService.hasCredentials();
    _subjects = StorageService.getCachedAttendance();
    _lastSync = StorageService.getLastSync();
    notifyListeners();
  }

  // Login & fetch
  Future<bool> loginAndFetch(String username, String password) async {
    _status = SyncStatus.syncing;
    _error = '';
    notifyListeners();

    try {
      final api = ApiService();
      final data = await api.fetchAttendance(
        username: username,
        password: password,
      );

      _subjects = data;
      _lastSync = DateTime.now();
      _isLoggedIn = true;

      await StorageService.saveCredentials(username, password);
      await StorageService.cacheAttendance(data);

      _status = SyncStatus.success;
      FeedbackService.dataLoaded();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _status = SyncStatus.error;
      FeedbackService.error();
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection failed. Check your internet connection.';
      _status = SyncStatus.error;
      FeedbackService.error();
      notifyListeners();
      return false;
    }
  }

  // Refresh with stored credentials
  Future<bool> refresh() async {
    final user = await StorageService.getUsername();
    final pass = await StorageService.getPassword();
    if (user == null || pass == null) {
      _error = 'No stored credentials';
      _status = SyncStatus.error;
      notifyListeners();
      return false;
    }
    return loginAndFetch(user, pass);
  }

  // Logout
  Future<void> logout() async {
    await StorageService.clearAll();
    _subjects = [];
    _isLoggedIn = false;
    _lastSync = null;
    _status = SyncStatus.idle;
    notifyListeners();
  }

  // Find subject by code
  SubjectAttendance? findByCode(String code) {
    try {
      return _subjects.firstWhere(
        (s) => s.subjectCode.toLowerCase() == code.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
