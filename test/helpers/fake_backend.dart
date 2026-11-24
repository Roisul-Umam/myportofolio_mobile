import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Backend Django palsu untuk test, dibangun dengan [MockClient].
///
/// Meniru endpoint `/api/v1/projects/`, `/api/v1/auth/token/`, dan
/// `/api/v1/auth/logout/` tanpa membutuhkan server sungguhan.
class FakeBackend {
  FakeBackend({List<Map<String, dynamic>>? projects})
    : projects = projects ?? [];

  static const password = 'secret';
  static const issuedToken = 'valid-token';

  final List<Map<String, dynamic>> projects;
  final List<http.Request> requests = [];

  /// Token yang masih berlaku di server. `null` berarti sudah dicabut.
  String? validToken = issuedToken;

  /// Jika diisi, `GET /projects/` gagal dengan status ini.
  int? projectsErrorStatus;

  /// Jika diisi, `POST /projects/` gagal dengan status ini.
  int? createErrorStatus;

  late final ApiClient apiClient = ApiClient(
    client: MockClient(_handle),
    baseUrl: 'http://test.local',
  );

  List<http.Request> requestsTo(String path, {String? method}) => requests
      .where(
        (request) =>
            request.url.path == path &&
            (method == null || request.method == method),
      )
      .toList();

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    final path = request.url.path;

    if (path == '/api/v1/projects/' && request.method == 'GET') {
      final status = projectsErrorStatus;
      if (status != null) {
        return http.Response('<html>Traceback rahasia</html>', status);
      }
      return _json(projects, 200);
    }

    if (path == '/api/v1/projects/' && request.method == 'POST') {
      if (!_isAuthorized(request)) {
        return _json({'detail': 'Invalid token.'}, 401);
      }
      final status = createErrorStatus;
      if (status != null) {
        return _json({
          'link': ['Enter a valid URL.'],
        }, status);
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final created = {...body, 'id': projects.length + 1, 'star_count': 0};
      projects.add(created);
      return _json(created, 201);
    }

    if (path == '/api/v1/auth/token/') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['password'] == password) {
        validToken = issuedToken;
        return _json({'token': issuedToken}, 200);
      }
      return _json({
        'non_field_errors': ['Unable to log in with provided credentials.'],
      }, 400);
    }

    if (path == '/api/v1/auth/logout/') {
      if (!_isAuthorized(request)) {
        return _json({'detail': 'Invalid token.'}, 401);
      }
      validToken = null;
      return http.Response('', 204);
    }

    return http.Response('Not found', 404);
  }

  bool _isAuthorized(http.Request request) =>
      validToken != null &&
      request.headers['Authorization'] == 'Token $validToken';

  http.Response _json(Object body, int status) => http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Map<String, dynamic> sampleProject({
  int id = 1,
  String title = 'Portfolio Web',
  String imageUrl = '',
}) => {
  'id': id,
  'title': title,
  'description': 'Website portofolio dengan Django.',
  'tags': 'Django, Tailwind',
  'link': 'https://github.com/example/portfolio',
  'project_image_url': imageUrl,
  'star_count': 2,
  'is_starred': false,
  'starred_by_names': '',
};
