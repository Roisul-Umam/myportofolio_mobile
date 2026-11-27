import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

/// Ensures the user is authenticated, pushing [LoginScreen] when needed.
///
/// Mengembalikan `true` jika pengguna sudah atau berhasil login.
Future<bool> ensureLoggedIn(BuildContext context) async {
  if (context.read<AuthState>().isLoggedIn) return true;

  final loggedIn = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
  return loggedIn ?? false;
}

/// Menjalankan [request] dengan token sesi saat ini.
///
/// Jika server menolak token (401), sesi dihapus, pengguna diminta login
/// ulang, lalu [request] dicoba sekali lagi. Mengembalikan `null` jika
/// pengguna batal login. Error selain 401 diteruskan ke pemanggil.
Future<T?> runWithRelogin<T>(
  BuildContext context,
  Future<T> Function(String token) request,
) async {
  final auth = context.read<AuthState>();
  if (!await ensureLoggedIn(context)) return null;

  try {
    return await request(auth.token!);
  } on ApiException catch (error) {
    if (error.statusCode != 401) rethrow;

    await auth.logout();
    if (!context.mounted) return null;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Sesi login berakhir. Silakan login ulang.'),
        ),
      );
    if (!await ensureLoggedIn(context)) return null;

    return request(auth.token!);
  }
}
