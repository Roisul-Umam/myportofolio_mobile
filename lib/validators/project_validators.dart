import 'package:myportofolio_mobile/validators/url_validator.dart';

/// Aturan validasi formulir proyek, mengikuti model Django `Project`.
///
/// Setiap method mengembalikan pesan kesalahan, atau `null` jika nilai valid.
abstract final class ProjectValidators {
  /// `title = CharField(max_length=100)`.
  static const int maxTitleLength = 100;

  /// `tags = CharField(max_length=200)`.
  static const int maxTagsLength = 200;

  static String? title(String? value) =>
      _requiredText(value, label: 'Judul proyek', maxLength: maxTitleLength);

  static String? description(String? value) =>
      _requiredText(value, label: 'Deskripsi proyek');

  static String? tags(String? value) =>
      _requiredText(value, label: 'Tech stack', maxLength: maxTagsLength);

  static String? link(String? value) => validateWebUrl(
    value,
    label: 'Tautan proyek',
    example: 'https://github.com/username/proyek',
    isRequired: true,
  );

  static String? imageUrl(String? value) =>
      validateWebUrl(value, example: 'https://example.com/gambar.png');

  static String? _requiredText(
    String? value, {
    required String label,
    int? maxLength,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '$label tidak boleh kosong!';
    }
    if (maxLength != null && text.length > maxLength) {
      return '$label maksimal $maxLength karakter!';
    }
    return null;
  }
}
