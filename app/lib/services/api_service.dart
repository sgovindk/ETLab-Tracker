import '../models/subject_attendance.dart';
import 'etlab_scraper.dart';

/// Wraps [ETLabScraper] with the same public interface
/// that the rest of the app expects.
///
/// No backend server needed – scraping runs on-device.
class ApiService {
  final ETLabScraper _scraper = ETLabScraper();

  /// Ignored – kept only so existing code that passes [baseUrl] still compiles.
  ApiService({String baseUrl = ''});

  // ── Fetch attendance (direct scrape) ──────────────────────────
  Future<List<SubjectAttendance>> fetchAttendance({
    required String username,
    required String password,
  }) async {
    try {
      return await _scraper.fetchAttendance(
        username: username,
        password: password,
      );
    } on ScrapeException catch (e) {
      throw ApiException(e.message);
    } catch (e) {
      throw ApiException('Scraping failed: $e');
    }
  }

  // ── Simple login test ─────────────────────────────────────────
  Future<bool> testLogin({
    required String username,
    required String password,
  }) async {
    try {
      await _scraper.fetchAttendance(
        username: username,
        password: password,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Health check (always true – no server needed) ─────────────
  Future<bool> healthCheck() async => true;
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
