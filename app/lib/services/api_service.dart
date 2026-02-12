import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subject_attendance.dart';

/// Communicates with the Python FastAPI backend.
class ApiService {
  final String baseUrl;
  ApiService({required this.baseUrl});

  // ── Fetch attendance (one-shot: login + scrape) ─────────────────
  Future<List<SubjectAttendance>> fetchAttendance({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/fetch');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data
          .map((e) => SubjectAttendance.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw ApiException('Invalid credentials');
    } else {
      final detail = _extractDetail(response.body);
      throw ApiException(detail);
    }
  }

  // ── Simple login test ───────────────────────────────────────────
  Future<bool> testLogin({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/login');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 60));
    return response.statusCode == 200;
  }

  // ── Health check ────────────────────────────────────────────────
  Future<bool> healthCheck() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  String _extractDetail(String body) {
    try {
      final json = jsonDecode(body);
      return json['detail'] ?? json['message'] ?? 'Unknown server error';
    } catch (_) {
      return 'Server returned an unexpected response';
    }
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
