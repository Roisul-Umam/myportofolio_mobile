import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  /// Dipanggil sebelum pindah halaman; hasil `false` membatalkan navigasi.
  final Future<bool> Function()? onBeforeNavigate;

  const LeftDrawer({super.key, this.onBeforeNavigate});

  Future<void> _replacePage(
    BuildContext context,
    WidgetBuilder builder, {
    bool requiresLogin = false,
  }) async {
    final navigator = Navigator.of(context);
    final canLeave = await onBeforeNavigate?.call() ?? true;
    if (!canLeave || !context.mounted) return;
    if (requiresLogin && !await ensureLoggedIn(context)) return;
    navigator.pushReplacement(MaterialPageRoute(builder: builder));
  }

  Future<void> _login(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    navigator.pop(); // Tutup drawer dulu.

    final loggedIn = await navigator.push<bool>(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    if (loggedIn ?? false) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Login berhasil.')));
    }
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthState>();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(); // Tutup drawer dulu.

    await auth.logout();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Kamu sudah logout.')));
  }

  @override
  Widget build(BuildContext context) {
    // watch: drawer ikut berubah saat status login berubah.
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'My Portfolio',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Explore my projects!',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => _replacePage(context, (context) => MyHomePage()),
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('Projects'),
            onTap: () =>
                _replacePage(context, (context) => const ProjectListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            // Menambah proyek butuh token, jadi wajib login dulu.
            onTap: () => _replacePage(
              context,
              (context) => const ProjectFormPage(),
              requiresLogin: true,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.timeline),
            title: const Text('Experiences'),
            onTap: () => _replacePage(
              context,
              (context) => const ExperienceListScreen(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Add Experience'),
            // Menambah pengalaman butuh token, jadi wajib login dulu.
            onTap: () => _replacePage(
              context,
              (context) => const ExperienceFormPage(),
              requiresLogin: true,
            ),
          ),
          const Divider(),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () => _login(context),
            ),
        ],
      ),
    );
  }
}
