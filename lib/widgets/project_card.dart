import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  Future<void> _handleTap(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    void showMessage(String message) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    switch (item.name) {
      case "Lihat Proyek":
        showMessage("Kamu telah menekan tombol ${item.name}!");
        navigator.push(
          MaterialPageRoute(builder: (context) => const ProjectListScreen()),
        );
      case "Tambah Proyek":
        showMessage("Kamu telah menekan tombol ${item.name}!");
        // Form proyek mengirim data dengan token, jadi wajib login dulu.
        if (await ensureLoggedIn(context)) {
          navigator.push(
            MaterialPageRoute(builder: (context) => const ProjectFormPage()),
          );
        }
      case "Tambah Pengalaman":
        showMessage("Kamu telah menekan tombol ${item.name}!");
        navigator.push(
          MaterialPageRoute(builder: (context) => const ExperienceFormPage()),
        );
      case "Logout":
        final auth = context.read<AuthState>();
        if (!auth.isLoggedIn) {
          showMessage("Kamu belum login.");
          return;
        }
        await auth.logout();
        showMessage("Kamu berhasil logout.");
      default:
        showMessage("Kamu telah menekan tombol ${item.name}!");
    }
  }

  /// Tombol aksi cepat: kotak ikon berwarna dengan label di bawahnya.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _handleTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(item.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
