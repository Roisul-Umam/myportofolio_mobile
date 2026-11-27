import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Exception thrown when an API request returns a non-2xx status code.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;

  /// Body mentah dari server. Jangan ditampilkan langsung ke pengguna karena
  /// bisa berisi halaman error HTML saat `DEBUG=True` di Django.
  final String message;

  /// Pesan yang aman dan mudah dipahami untuk ditampilkan di UI.
  String get userMessage {
    switch (statusCode) {
      case 400:
        final detail = _firstValidationError();
        return detail == null
            ? 'Data ditolak server. Periksa kembali isianmu.'
            : 'Data ditolak server: $detail';
      case 401:
        return 'Sesi login berakhir. Silakan login ulang.';
      case 403:
        return 'Akun ini tidak punya izin untuk melakukan aksi ini.';
      case 404:
        return 'Data tidak ditemukan di server.';
    }
    if (statusCode >= 500) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    }
    return 'Permintaan gagal (kode $statusCode).';
  }

  /// Mengambil pesan validasi pertama dari body JSON DRF, misalnya
  /// `{"link": ["Enter a valid URL."]}` menjadi `link: Enter a valid URL.`.
  String? _firstValidationError() {
    try {
      final decoded = jsonDecode(message);
      if (decoded is! Map<String, dynamic> || decoded.isEmpty) return null;
      final entry = decoded.entries.first;
      final value = entry.value;
      final text = value is List && value.isNotEmpty ? value.first : value;
      return entry.key == 'non_field_errors' || entry.key == 'detail'
          ? '$text'
          : '${entry.key}: $text';
    } on FormatException {
      return null;
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Mengubah error dari pemanggilan API menjadi pesan untuk pengguna.
String describeApiError(Object error) {
  if (error is ApiException) return error.userMessage;
  if (error is http.ClientException) {
    return 'Tidak dapat terhubung ke server di $apiBaseUrl. '
        'Pastikan server Django sedang berjalan.';
  }
  return 'Terjadi kesalahan yang tidak terduga.';
}

/// HTTP client for the MyPortfolio Django REST Framework backend.
///
/// Header ditulis sebagai string biasa, bukan `HttpHeaders` dari `dart:io`,
/// supaya tetap bisa di-build untuk Flutter Web.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = baseUrl ?? apiBaseUrl;

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<Project>> getProjects() async {
    final response = await _client.get(
      _uri('/api/v1/projects/'),
      headers: const {'Accept': 'application/json'},
    );
    _ensureSuccess(response);

    final decoded = _decode(response) as List<dynamic>;
    return decoded
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/projects/'),
      headers: _authJsonHeaders(token),
      body: jsonEncode(project.toJson()),
    );
    _ensureSuccess(response);

    return Project.fromJson(_decode(response) as Map<String, dynamic>);
  }

  /// Daftar pengalaman bersifat publik, jadi tidak mengirim token.
  Future<List<Experience>> getExperiences() async {
    final response = await _client.get(
      _uri('/api/v1/experience/'),
      headers: const {'Accept': 'application/json'},
    );
    _ensureSuccess(response);

    final decoded = _decode(response) as List<dynamic>;
    return decoded
        .map((item) => Experience.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Experience> createExperience(
    Experience experience, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/experience/'),
      headers: _authJsonHeaders(token),
      body: jsonEncode(experience.toJson()),
    );
    _ensureSuccess(response);

    return Experience.fromJson(_decode(response) as Map<String, dynamic>);
  }

  /// Menghapus pengalaman; server menjawab 204 No Content jika berhasil.
  Future<void> deleteExperience(String id, {required String token}) async {
    final response = await _client.delete(
      _uri('/api/v1/experience/$id/'),
      headers: {'Accept': 'application/json', 'Authorization': 'Token $token'},
    );
    _ensureSuccess(response);
  }

  Map<String, String> _authJsonHeaders(String token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Token $token',
  };

  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);

    final decoded = _decode(response) as Map<String, dynamic>;
    return decoded['token'] as String;
  }

  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: {'Accept': 'application/json', 'Authorization': 'Token $token'},
    );
    _ensureSuccess(response);
  }

  /// Dekode sebagai UTF-8 supaya karakter non-ASCII tidak rusak.
  dynamic _decode(http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes));

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(response.statusCode, response.body);
  }
}
