import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';

/// Tag yang paling sering dipakai, dipakai sebagai chip filter.
List<String> popularTags(List<Project> projects, {int limit = 8}) {
  final counts = <String, int>{};
  for (final project in projects) {
    for (final tag in project.tagList) {
      counts[tag] = (counts[tag] ?? 0) + 1;
    }
  }
  final tags = counts.keys.toList()
    ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  return tags.take(limit).toList();
}

/// Gambar proyek, atau placeholder bergradasi jika URL kosong/gagal dimuat.
class ProjectThumbnail extends StatelessWidget {
  const ProjectThumbnail({
    required this.project,
    this.height,
    this.imageKey,
    super.key,
  });

  final Project project;
  final double? height;
  final Key? imageKey;

  Widget _placeholder() => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE8EEFF), Color(0xFFD4DEFF)],
      ),
    ),
    child: Center(
      child: Text(
        project.title.isEmpty ? '?' : project.title[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final child = project.projectImageUrl.isEmpty
        ? _placeholder()
        : Image.network(
            project.projectImageUrl,
            key: imageKey,
            fit: BoxFit.cover,
            // Di Flutter Web, gambar dari host tanpa header CORS
            // (mis. thumbnail Google Drive) ditampilkan lewat <img>.
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            errorBuilder: (context, error, stackTrace) => _placeholder(),
          );

    return SizedBox(height: height, width: double.infinity, child: child);
  }
}

/// Lencana jumlah bintang, diletakkan di pojok gambar seperti label harga.
class StarBadge extends StatelessWidget {
  const StarBadge({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu proyek untuk carousel di Home dan grid di daftar proyek.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    required this.project,
    required this.onTap,
    this.width,
    super.key,
  });

  final Project project;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final tags = project.tagList;

    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      ProjectThumbnail(project: project, height: 120),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: StarBadge(count: project.starCount),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tags.isEmpty ? 'Tanpa tag' : tags.take(2).join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
