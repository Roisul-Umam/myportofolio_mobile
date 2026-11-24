import 'package:myportofolio_mobile/validators/url_validator.dart';

/// Aturan validasi formulir pengalaman, mengikuti model Django `Experience`.
///
/// Dipisahkan dari widget supaya aturannya bisa diuji tanpa merender UI.
/// Setiap method mengembalikan pesan kesalahan, atau `null` jika nilai valid.
abstract final class ExperienceValidators {
  /// `title = CharField(max_length=255)`.
  static const int maxTitleLength = 255;

  /// Panjang bawaan Django untuk `URLField`.
  static const int maxUrlLength = webUrlMaxLength;

  static String? title(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Judul pengalaman tidak boleh kosong!';
    }
    if (text.length > maxTitleLength) {
      return 'Judul maksimal $maxTitleLength karakter!';
    }
    return null;
  }

  static String? description(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi tidak boleh kosong!';
    }
    return null;
  }

  /// `thumbnail` opsional, tetapi jika diisi harus http(s) dengan domain.
  static String? thumbnail(String? value) =>
      validateWebUrl(value, example: 'https://example.com/gambar.png');

  /// `ended_at` opsional; kosong berarti pengalaman masih berlangsung.
  ///
  /// `started_at` memakai `auto_now_add`, jadi tanggal mulai selalu hari
  /// data dibuat dan tanggal selesai tidak boleh lebih awal dari itu.
  static String? endedAt(DateTime? value, DateTime startedAt) {
    if (value == null) {
      return null;
    }
    if (_dateOnly(value).isBefore(_dateOnly(startedAt))) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai!';
    }
    return null;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
