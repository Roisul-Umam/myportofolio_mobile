import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';

/// Lembar akun: menampilkan status login dan tombol Login atau Logout.
Future<void> showAccountSheet(
  BuildContext context, {
  required String name,
  required String npm,
}) {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (sheetContext) {
      final auth = sheetContext.watch<AuthState>();

      Future<void> onPressed() async {
        Navigator.pop(sheetContext);
        if (auth.isLoggedIn) {
          await auth.logout();
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Kamu sudah logout.')));
        } else {
          navigator.push(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initialsOf(name),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  auth.isLoggedIn
                      ? 'NPM $npm · Login sebagai pemilik'
                      : 'NPM $npm · Belum login',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onPressed,
                icon: Icon(auth.isLoggedIn ? Icons.logout : Icons.login),
                label: Text(auth.isLoggedIn ? 'Keluar dari akun' : 'Masuk'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Mengambil maksimal dua huruf awal nama, mis. "Roisul Umam" -> "RU".
String initialsOf(String name) => name
    .split(' ')
    .where((part) => part.isNotEmpty)
    .take(2)
    .map((part) => part[0].toUpperCase())
    .join();
