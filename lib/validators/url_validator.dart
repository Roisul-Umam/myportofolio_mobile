/// Panjang bawaan Django untuk `URLField`.
const int webUrlMaxLength = 200;

/// Memvalidasi URL `http`/`https` yang punya domain.
///
/// Mengembalikan pesan kesalahan, atau `null` jika valid. URL kosong hanya
/// ditolak jika [isRequired] bernilai `true`.
String? validateWebUrl(
  String? value, {
  required String example,
  String label = 'URL',
  bool isRequired = false,
}) {
  final url = value?.trim() ?? '';
  if (url.isEmpty) {
    return isRequired ? '$label tidak boleh kosong!' : null;
  }
  if (url.length > webUrlMaxLength) {
    return 'URL maksimal $webUrlMaxLength karakter!';
  }

  final uri = url.contains(RegExp(r'\s')) ? null : Uri.tryParse(url);
  final hasWebScheme = uri?.scheme == 'http' || uri?.scheme == 'https';
  if (!hasWebScheme || !(uri?.host.contains('.') ?? false)) {
    return 'Masukkan URL valid, contoh: $example';
  }
  return null;
}
