import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/services/api_client.dart';

/// Holds the in-memory authentication token for the current session.
///
/// Token hanya disimpan di memori, jadi hilang saat aplikasi ditutup.
class AuthState extends ChangeNotifier {
  AuthState(this._apiClient, {String? initialToken}) : _token = initialToken;

  final ApiClient _apiClient;
  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  Future<void> login(String username, String password) async {
    _token = await _apiClient.obtainToken(username, password);
    notifyListeners();
  }

  Future<void> logout() async {
    final current = _token;
    if (current == null) return;

    try {
      await _apiClient.logout(token: current);
    } on ApiException {
      // Token mungkin sudah dicabut di server; sesi lokal tetap dihapus.
    } on http.ClientException {
      // Server tidak terjangkau; sesi lokal tetap dihapus.
    } finally {
      _token = null;
      notifyListeners();
    }
  }
}
