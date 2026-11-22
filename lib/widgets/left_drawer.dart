import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

class LeftDrawer extends StatelessWidget {
  /// Dipanggil sebelum pindah halaman; hasil `false` membatalkan navigasi.
  final Future<bool> Function()? onBeforeNavigate;

  const LeftDrawer({super.key, this.onBeforeNavigate});

  Future<void> _replacePage(BuildContext context, WidgetBuilder builder) async {
    final navigator = Navigator.of(context);
    final canLeave = await onBeforeNavigate?.call() ?? true;
    if (canLeave) {
      navigator.pushReplacement(MaterialPageRoute(builder: builder));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo,
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
            // Navigasi ke halaman utama portofolio
            onTap: () => _replacePage(context, (context) => MyHomePage()),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            // Navigasi ke halaman tambah proyek
            onTap: () =>
                _replacePage(context, (context) => const ProjectFormPage()),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Add Experience'),
            // Navigasi ke halaman tambah pengalaman
            onTap: () =>
                _replacePage(context, (context) => const ExperienceFormPage()),
          ),
        ],
      ),
    );
  }
}