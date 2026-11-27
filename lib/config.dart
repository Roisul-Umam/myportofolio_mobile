import 'package:flutter/foundation.dart';

/// Nilai dari `--dart-define=API_BASE_URL=...`; kosong jika tidak diisi.
const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

/// Base URL of the Django REST Framework backend.
///
/// Tanpa `--dart-define`, URL dipilih otomatis sesuai tempat aplikasi berjalan:
/// - emulator Android: `http://10.0.2.2:8000` (alamat laptop dari dalam emulator);
/// - web, desktop, dan simulator iOS: `http://localhost:8000`.
///
/// Untuk HP fisik atau server yang sudah di-deploy, timpa dengan
/// `--dart-define=API_BASE_URL=http://<alamat-server>:8000`.
String get apiBaseUrl => resolveApiBaseUrl(
  isWeb: kIsWeb,
  platform: defaultTargetPlatform,
  override: _apiBaseUrlOverride,
);

/// Logika pemilihan URL, dipisah supaya bisa diuji tanpa platform sungguhan.
@visibleForTesting
String resolveApiBaseUrl({
  required bool isWeb,
  required TargetPlatform platform,
  String override = '',
}) {
  if (override.isNotEmpty) return override;
  if (!isWeb && platform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000';
  }
  return 'http://localhost:8000';
}
