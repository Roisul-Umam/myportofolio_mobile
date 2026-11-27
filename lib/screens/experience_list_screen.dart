import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_detail_screen.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/experience_tile.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Daftar pengalaman publik dari `GET /api/v1/experience/`.
class ExperienceListScreen extends StatefulWidget {
  const ExperienceListScreen({super.key});

  @override
  State<ExperienceListScreen> createState() => _ExperienceListScreenState();
}

class _ExperienceListScreenState extends State<ExperienceListScreen> {
  late Future<List<Experience>> _experiencesFuture;
  final _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Future dibuat sekali di initState, bukan di build(), supaya request
    // tidak dikirim ulang setiap kali widget di-rebuild.
    _experiencesFuture = context.read<ApiClient>().getExperiences();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final future = context.read<ApiClient>().getExperiences();
    setState(() {
      _experiencesFuture = future;
    });
    try {
      await future;
    } on Exception {
      // Error sudah ditampilkan oleh FutureBuilder.
    }
  }

  List<Experience> _filter(List<Experience> experiences) {
    final query = _searchController.text.trim().toLowerCase();
    return experiences.where((experience) {
      final matchesCategory =
          _selectedCategory == null || experience.category == _selectedCategory;
      final matchesQuery =
          query.isEmpty ||
          experience.title.toLowerCase().contains(query) ||
          experience.description.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> _addExperience() async {
    final navigator = Navigator.of(context);
    if (!await ensureLoggedIn(context)) return;
    final created = await navigator.push<bool>(
      MaterialPageRoute(builder: (context) => const ExperienceFormPage()),
    );
    if ((created ?? false) && mounted) _reload();
  }

  Future<void> _openDetail(Experience experience) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ExperienceDetailScreen(experience: experience),
      ),
    );
    if ((deleted ?? false) && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.of(context).canPop();

    return Scaffold(
      drawer: const LeftDrawer(),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Experience>>(
          future: _experiencesFuture,
          builder: (context, snapshot) {
            final experiences = snapshot.data ?? const <Experience>[];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => Material(
                          color: AppColors.surface,
                          shape: const CircleBorder(
                            side: BorderSide(color: AppColors.outline),
                          ),
                          child: IconButton(
                            tooltip: canGoBack ? 'Kembali' : 'Buka menu',
                            icon: Icon(
                              canGoBack ? Icons.arrow_back : Icons.menu,
                              color: AppColors.text,
                            ),
                            onPressed: canGoBack
                                ? () => Navigator.maybePop(context)
                                : () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Cari pengalaman...',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (experiences.isNotEmpty) _buildCategoryFilter(experiences),
                Expanded(child: _buildBody(snapshot)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: FilledButton.icon(
            onPressed: _addExperience,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Tambah pengalaman baru'),
          ),
        ),
      ),
    );
  }

  /// Chip hanya untuk kategori yang benar-benar dipakai.
  Widget _buildCategoryFilter(List<Experience> experiences) {
    final categories = <String, String>{
      for (final experience in experiences)
        experience.category: experience.categoryDisplay,
    };
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final entry in [null, ...categories.entries])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(entry?.value ?? 'Semua'),
                selected: _selectedCategory == entry?.key,
                onSelected: (_) =>
                    setState(() => _selectedCategory = entry?.key),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(AsyncSnapshot<List<Experience>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                'Gagal memuat pengalaman. ${describeApiError(snapshot.error!)}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final all = snapshot.data ?? const <Experience>[];
    final experiences = _filter(all);
    if (experiences.isEmpty) {
      // Tetap bisa ditarik ke bawah untuk refresh walau daftar kosong.
      return RefreshIndicator(
        onRefresh: _reload,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Text(
                  all.isEmpty
                      ? 'Belum ada pengalaman.'
                      : 'Tidak ada pengalaman yang cocok.',
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: experiences.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final experience = experiences[index];
          return ExperienceCard(
            experience: experience,
            onTap: () => _openDetail(experience),
          );
        },
      ),
    );
  }
}
