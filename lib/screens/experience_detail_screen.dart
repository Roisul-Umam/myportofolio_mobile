import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';
import 'package:myportofolio_mobile/utils/date_format.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/experience_tile.dart';
import 'package:provider/provider.dart';

/// Detail satu pengalaman, dengan aksi hapus yang membutuhkan login.
///
/// Mengembalikan `true` lewat `Navigator.pop` jika entri berhasil dihapus,
/// supaya daftar memuat ulang datanya.
class ExperienceDetailScreen extends StatefulWidget {
  const ExperienceDetailScreen({required this.experience, super.key});

  final Experience experience;

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  bool _isDeleting = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus pengalaman?'),
        content: Text(
          '"${widget.experience.title}" akan dihapus dari server dan '
          'tidak bisa dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _delete() async {
    final id = widget.experience.id;
    if (id == null || !await _confirmDelete() || !mounted) return;

    final apiClient = context.read<ApiClient>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final deleted = await runWithRelogin(context, (token) async {
        setState(() => _isDeleting = true);
        try {
          await apiClient.deleteExperience(id, token: token);
          return true;
        } finally {
          if (mounted) setState(() => _isDeleting = false);
        }
      });
      if (deleted != true) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Pengalaman dihapus.')));
      navigator.pop(true);
    } on ApiException catch (error) {
      if (mounted) _showSnackBar(error.userMessage);
    } on http.ClientException catch (error) {
      if (mounted) _showSnackBar(describeApiError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final experience = widget.experience;
    final startedAt = experience.startedAt;
    final endedAt = experience.endedAt;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengalaman')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            if (experience.thumbnail.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: LayoutBuilder(
                    builder: (context, constraints) => ExperienceThumbnail(
                      experience: experience,
                      size: constraints.maxWidth,
                      imageKey: const Key('experience-image'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Chip(
                          avatar: Icon(
                            experienceCategoryIcon(experience.category),
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: Text(experience.categoryDisplay),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text('${experience.starCount}'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      experience.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.play_circle_outline,
                      label: 'Mulai',
                      value: startedAt == null ? '-' : formatDate(startedAt),
                    ),
                    _InfoRow(
                      icon: Icons.flag_outlined,
                      label: 'Selesai',
                      value: endedAt == null ? '-' : formatDate(endedAt),
                    ),
                    _InfoRow(
                      icon: Icons.timelapse,
                      label: 'Status',
                      value: experience.isOngoing
                          ? 'Sedang berlangsung'
                          : 'Selesai',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'DESKRIPSI',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      experience.description,
                      style: const TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isDeleting ? null : _delete,
              icon: _isDeleting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              label: const Text('Hapus pengalaman'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
