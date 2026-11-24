import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';
import 'package:myportofolio_mobile/widgets/project_tile.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    const sectionStyle = TextStyle(
      color: AppColors.textMuted,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Proyek')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            // Gambar hanya ditampilkan jika URL-nya tidak kosong.
            if (project.projectImageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ProjectThumbnail(
                    project: project,
                    imageKey: const Key('project-image'),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            project.title,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        StarBadge(count: project.starCount),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in project.tagList)
                          Chip(label: Text(tag)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('DESKRIPSI', style: sectionStyle),
                    const SizedBox(height: 6),
                    Text(
                      project.description,
                      style: const TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    const Text('TAUTAN PROYEK', style: sectionStyle),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.link_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: SelectableText(
                            project.link.isEmpty
                                ? 'Tidak ada tautan.'
                                : project.link,
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
