import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../models/subject_attendance.dart';

class ETLabScraper {
  static const _baseUrl = 'https://sctce.etlab.in';
  static const _loginUrl = '$_baseUrl/user/login';

  /// Session cookies maintained across requests.
  final Map<String, String> _cookies = {};

  // Public API

  /// Login and fetch attendance in one shot.
  /// Returns list of [SubjectAttendance].
  /// Throws [ScrapeException] on failure.
  Future<List<SubjectAttendance>> fetchAttendance({
    required String username,
    required String password,
  }) async {
    try {
      _cookies.clear();

      // Step 1: GET login page (grab CSRF token + session cookie)
      await _getLoginPage();

      // Step 2: POST login credentials
      await _postLogin(username, password);

      // Step 3: Navigate to /student/attendance
      final attendancePage = await _getPage('$_baseUrl/student/attendance');

      // Step 4: Find the "viewattendancesubject" link
      final subjectUrl = _findAttendanceSubjectLink(attendancePage);
      if (subjectUrl == null) {
        throw ScrapeException(
          'Could not find attendance-by-subject link. '
          'ETLab may have changed its page structure.',
        );
      }

      // Step 5: GET the subject-wise attendance page
      final subjectPage = await _getPage(subjectUrl);

      // Step 6: Parse the pivoted attendance table
      final subjects = _parseAttendanceTable(subjectPage);
      if (subjects.isEmpty) {
        throw ScrapeException(
          'No attendance data found. The table format may have changed.',
        );
      }

      return subjects;
    } on http.ClientException catch (e) {
      _log('Network error: $e');
      throw ScrapeException(
        'Network error. Check your internet connection and try again.',
      );
    } on Exception catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  // Step 1: GET login page

  Future<void> _getLoginPage() async {
    _log('GET $_loginUrl');
    final response = await http.get(
      Uri.parse(_loginUrl),
      headers: _defaultHeaders(),
    ).timeout(const Duration(seconds: 30));

    _updateCookies(response);
    _log('Login page status: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw ScrapeException('Failed to load login page (${response.statusCode})');
    }
  }

  // Step 2: POST login

  Future<void> _postLogin(String username, String password) async {
    // Extract CSRF token from cookies (Yii framework uses CSRF)
    final csrfToken = _extractCsrf();

    final body = {
      'LoginForm[username]': username,
      'LoginForm[password]': password,
      if (csrfToken != null) 'YII_CSRF_TOKEN': csrfToken,
    };

    _log('POST $_loginUrl');
    final response = await http.post(
      Uri.parse(_loginUrl),
      headers: {
        ..._defaultHeaders(),
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': _cookieHeader(),
        'Referer': _loginUrl,
        'Origin': _baseUrl,
      },
      body: body,
    ).timeout(const Duration(seconds: 30));

    _updateCookies(response);
    _log('Login POST status: ${response.statusCode}');
    _log('Login redirect: ${response.headers['location']}');

    // Handle redirect chain (302 → dashboard)
    if (response.statusCode == 302 || response.statusCode == 301) {
      final location = response.headers['location'];
      if (location != null) {
        final redirectUrl =
            location.startsWith('http') ? location : '$_baseUrl$location';

        // If redirected back to login page → bad credentials
        if (redirectUrl.contains('/user/login') ||
            redirectUrl.contains('/login')) {
          throw ScrapeException('Invalid credentials');
        }

        // Follow the redirect
        await _getPage(redirectUrl);
        return;
      }
    }

    // If status 200 and still on login page → bad credentials
    if (response.statusCode == 200) {
      final body = response.body.toLowerCase();
      if (body.contains('loginform') ||
          body.contains('incorrect') ||
          body.contains('invalid')) {
        throw ScrapeException('Invalid credentials');
      }
    }

    if (response.statusCode != 200 &&
        response.statusCode != 302 &&
        response.statusCode != 301) {
      throw ScrapeException('Login failed (status ${response.statusCode})');
    }
  }

  // Step 3–5: Page navigation

  Future<String> _getPage(String url) async {
    _log('GET $url');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        ..._defaultHeaders(),
        'Cookie': _cookieHeader(),
        'Referer': '$_baseUrl/',
      },
    ).timeout(const Duration(seconds: 30));

    _updateCookies(response);
    _log('Page status: ${response.statusCode}, length: ${response.body.length}');

    // Follow redirects manually
    if (response.statusCode == 302 || response.statusCode == 301) {
      final location = response.headers['location'];
      if (location != null) {
        final redirectUrl =
            location.startsWith('http') ? location : '$_baseUrl$location';
        if (redirectUrl.contains('/user/login')) {
          throw ScrapeException('Session expired – redirected to login');
        }
        return _getPage(redirectUrl);
      }
    }

    if (response.statusCode != 200) {
      throw ScrapeException('Failed to load page (${response.statusCode})');
    }

    return response.body;
  }

  // Find viewattendancesubject link

  String? _findAttendanceSubjectLink(String html) {
    final doc = html_parser.parse(html);
    final links = doc.querySelectorAll('a[href]');

    for (final link in links) {
      final href = link.attributes['href'] ?? '';
      if (href.toLowerCase().contains('viewattendancesubject')) {
        _log('Found attendance subject link: $href');
        return href.startsWith('http') ? href : '$_baseUrl$href';
      }
    }

    // Fallback: look for viewattendance links
    for (final link in links) {
      final href = link.attributes['href'] ?? '';
      if (href.toLowerCase().contains('viewattendance') &&
          !href.toLowerCase().contains('/student/attendance')) {
        _log('Found fallback attendance link: $href');
        return href.startsWith('http') ? href : '$_baseUrl$href';
      }
    }

    return null;
  }

  // Parse pivoted attendance table

  List<SubjectAttendance> _parseAttendanceTable(String html) {
    final doc = html_parser.parse(html);
    final tables = doc.querySelectorAll('table');
    _log('Found ${tables.length} table(s)');

    for (int tableIdx = 0; tableIdx < tables.length; tableIdx++) {
      final table = tables[tableIdx];
      final rows = table.querySelectorAll('tr');
      _log('Table $tableIdx: ${rows.length} rows');

      if (rows.length < 2) continue;

      // Get header cells
      final headerRow = rows[0];
      final headerCells = headerRow.querySelectorAll('th');
      final headers = headerCells.isNotEmpty
          ? headerCells.map((c) => c.text.trim()).toList()
          : headerRow.querySelectorAll('td').map((c) => c.text.trim()).toList();

      _log('Headers: $headers');

      // Skip headers that are NOT subject codes
      const skipHeaders = {
        'uni reg no', 'reg no', 'roll no', 'name', 'total',
        'percentage', 'sl no', 'sl', '#', 'no', 'register no',
        'student name', 'roll', 'reg', 'register number',
      };

      // Find subject code columns (e.g., AMT302, AIT304, CST306)
      final subjectCodePattern = RegExp(r'^[A-Za-z]{2,5}\d{3,4}[A-Za-z]?$');
      final subjectColumns = <MapEntry<int, String>>[];

      for (int colIdx = 0; colIdx < headers.length; colIdx++) {
        final header = headers[colIdx].trim();
        if (header.isEmpty || skipHeaders.contains(header.toLowerCase())) {
          continue;
        }
        if (subjectCodePattern.hasMatch(header)) {
          subjectColumns.add(MapEntry(colIdx, header));
          _log('  Subject column $colIdx: $header');
        }
      }

      if (subjectColumns.isEmpty) continue;
      _log('Detected pivoted table with ${subjectColumns.length} subjects');

      // Parse data rows
      final results = <SubjectAttendance>[];
      for (int rowIdx = 1; rowIdx < rows.length; rowIdx++) {
        final cells = rows[rowIdx].querySelectorAll('td');
        final cellTexts = cells.map((c) => c.text.trim()).toList();

        for (final entry in subjectColumns) {
          final colIdx = entry.key;
          final subCode = entry.value;

          if (colIdx >= cellTexts.length) continue;
          final cellText = cellTexts[colIdx];
          final parsed = _parseAttendanceCell(cellText);

          if (parsed != null) {
            results.add(SubjectAttendance(
              subjectCode: subCode,
              subjectName: subCode,
              hoursAttended: parsed['attended']!.toInt(),
              totalHours: parsed['total']!.toInt(),
              percentage: parsed['percentage']!.toDouble(),
            ));
            _log('  $subCode: ${parsed['attended']}/${parsed['total']} (${parsed['percentage']}%)');
          }
        }
      }

      if (results.isNotEmpty) return results;
    }

    // Fallback: regex parse on raw HTML
    return _regexParsePage(html);
  }

  // Parse cell like "25/26 (96%)"

  Map<String, num>? _parseAttendanceCell(String cellText) {
    if (cellText.isEmpty || !cellText.contains('/')) return null;

    final regex = RegExp(r'(\d+)\s*/\s*(\d+)\s*(?:\(?\s*(\d+\.?\d*)\s*%?\s*\)?)?');
    final match = regex.firstMatch(cellText.trim());
    if (match == null) return null;

    final attended = int.parse(match.group(1)!);
    final total = int.parse(match.group(2)!);
    double percentage;

    if (match.group(3) != null) {
      percentage = double.parse(match.group(3)!);
    } else if (total > 0) {
      percentage = (attended / total * 100 * 100).roundToDouble() / 100;
    } else {
      percentage = 0.0;
    }

    if (total <= 0 || attended < 0) return null;

    return {'attended': attended, 'total': total, 'percentage': percentage};
  }

  // Regex fallback on raw HTML

  List<SubjectAttendance> _regexParsePage(String html) {
    final codePattern = RegExp(r'<t[hd][^>]*>\s*([A-Z]{2,5}\d{3,4}[A-Za-z]?)\s*</t[hd]>');
    final dataPattern = RegExp(r'<td[^>]*>\s*(\d+/\d+\s*\(\d+%?\))\s*</td>');

    final codes = codePattern.allMatches(html).map((m) => m.group(1)!).toList();
    final dataCells = dataPattern.allMatches(html).map((m) => m.group(1)!).toList();

    _log('Regex fallback: ${codes.length} codes, ${dataCells.length} data cells');

    // Filter out non-subject codes
    const skipPrefixes = ['SCT', 'KTU'];
    final subjectCodes = codes
        .where((c) => !skipPrefixes.any((p) => c.startsWith(p)))
        .toList();

    final results = <SubjectAttendance>[];
    for (int i = 0; i < subjectCodes.length && i < dataCells.length; i++) {
      final parsed = _parseAttendanceCell(dataCells[i]);
      if (parsed != null) {
        results.add(SubjectAttendance(
          subjectCode: subjectCodes[i],
          subjectName: subjectCodes[i],
          hoursAttended: parsed['attended']!.toInt(),
          totalHours: parsed['total']!.toInt(),
          percentage: parsed['percentage']!.toDouble(),
        ));
      }
    }

    return results;
  }

  // Cookie / header management

  Map<String, String> _defaultHeaders() => {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
            'AppleWebKit/537.36 (KHTML, like Gecko) '
            'Chrome/121.0.0.0 Safari/537.36',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Connection': 'keep-alive',
      };

  void _updateCookies(http.Response response) {
    final setCookie = response.headers['set-cookie'];
    if (setCookie == null) return;

    // Parse set-cookie header(s)
    // HTTP headers may combine multiple set-cookie values
    for (final part in setCookie.split(RegExp(r',(?=[^ ])'))) {
      final cookie = part.split(';').first.trim();
      final eqIdx = cookie.indexOf('=');
      if (eqIdx > 0) {
        final name = cookie.substring(0, eqIdx).trim();
        final value = cookie.substring(eqIdx + 1).trim();
        _cookies[name] = value;
      }
    }
    _log('Cookies: ${_cookies.keys.join(', ')}');
  }

  String _cookieHeader() {
    return _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  String? _extractCsrf() {
    // Yii stores CSRF token in a cookie
    return _cookies['YII_CSRF_TOKEN'] ?? _cookies['_csrf'];
  }

  void _log(String msg) {
    developer.log(msg, name: 'ETLabScraper');
  }
}

/// Exception thrown when scraping fails.
class ScrapeException implements Exception {
  final String message;
  const ScrapeException(this.message);

  @override
  String toString() => message;
}
