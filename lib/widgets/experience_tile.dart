import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';
import 'package:myportofolio_mobile/utils/date_format.dart';

/// Ikon per kategori supaya daftar mudah dipindai tanpa membaca label.
IconData experienceCategoryIcon(String category) => switch (category) {
  'internship' => Icons.badge_outlined,
  'research' => Icons.science_outlined,
  'volunteer' => Icons.volunteer_activism_outlined,
  'part-time' => Icons.schedule_outlined,
  'freelance' => Icons.laptop_mac_outlined,
  'competition' => Icons.emoji_events_outlined,
  _ => Icons.work_outline,
};

/// Teks status: "Sedang berlangsung" atau tanggal selesai.
String experienceStatus(Experience experience) {
  final endedAt = experience.endedAt;
  if (experience.isOngoing || endedAt == null) return 'Sedang berlangsung';
  return 'Selesai ${formatDate(endedAt)}';
}

/// Thumbnail pengalaman, atau ikon kategori jika URL kosong/gagal dimuat.
class ExperienceThumbnail extends StatelessWidget {
  const ExperienceThumbnail({
    required this.experience,
    this.size = 64,
    this.imageKey,
    super.key,
  });

  final Experience experience;
  final double size;
  final Key? imageKey;

  Widget _placeholder() => ColoredBox(
    color: const Color(0xFFE8EEFF),
    child: Center(
      child: Icon(
        experienceCategoryIcon(experience.category),
        color: AppColors.primary,
        size: size * 0.45,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: experience.thumbnail.isEmpty
          ? _placeholder()
          : Image.network(
              experience.thumbnail,
              key: imageKey,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
              errorBuilder: (context, error, stackTrace) => _placeholder(),
            ),
    );
  }
}

/// Kartu baris untuk daftar pengalaman.
class ExperienceCard extends StatelessWidget {
  const ExperienceCard({
    required this.experience,
    required this.onTap,
    super.key,
  });

  final Experience experience;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ongoing = experience.isOngoing;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: ExperienceThumbnail(experience: experience),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience.categoryDisplay,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      experience.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          ongoing ? Icons.circle : Icons.check_circle,
                          size: 10,
                          color: ongoing ? Colors.green : AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            experienceStatus(experience),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
