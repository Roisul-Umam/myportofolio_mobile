import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_tile.dart';
import 'package:provider/provider.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({this.initialQuery, this.initialTag, super.key});

  /// Kata kunci awal dari kolom pencarian di Home.
  final String? initialQuery;

  /// Tag awal dari chip di Home.
  final String? initialTag;

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late Future<List<Project>> _projectsFuture;
  late final TextEditingController _searchController;
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    // Future dibuat sekali di initState, bukan di build(), supaya request
    // tidak dikirim ulang setiap kali widget di-rebuild.
    _projectsFuture = context.read<ApiClient>().getProjects();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _selectedTag = widget.initialTag;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final future = context.read<ApiClient>().getProjects();
    setState(() {
      _projectsFuture = future;
    });
    try {
      await future;
    } on Exception {
      // Error sudah ditampilkan oleh FutureBuilder.
    }
  }

  /// Penyaringan dilakukan di klien karena jumlah proyek portofolio kecil.
  List<Project> _filter(List<Project> projects) {
    final query = _searchController.text.trim().toLowerCase();
    return projects.where((project) {
      final matchesTag =
          _selectedTag == null || project.tagList.contains(_selectedTag);
      final matchesQuery =
          query.isEmpty ||
          project.title.toLowerCase().contains(query) ||
          project.tags.toLowerCase().contains(query) ||
          project.description.toLowerCase().contains(query);
      return matchesTag && matchesQuery;
    }).toList();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() => _selectedTag = null);
  }

  Future<void> _addProject() async {
    final navigator = Navigator.of(context);
    if (!await ensureLoggedIn(context)) return;
    await navigator.push(
      MaterialPageRoute(builder: (context) => const ProjectFormPage()),
    );
    if (mounted) _reload();
  }

  void _openDetail(Project project) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProjectDetailScreen(project: project),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.of(context).canPop();

    return Scaffold(
      drawer: const LeftDrawer(),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Project>>(
          future: _projectsFuture,
          builder: (context, snapshot) {
            final projects = snapshot.data ?? const <Project>[];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => _CircleButton(
                          icon: canGoBack ? Icons.arrow_back : Icons.menu,
                          tooltip: canGoBack ? 'Kembali' : 'Buka menu',
                          onPressed: canGoBack
                              ? () => Navigator.maybePop(context)
                              : () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Cari proyek...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Hapus pencarian',
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (projects.isNotEmpty) _buildTagFilter(projects),
                Expanded(child: _buildBody(snapshot)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _AddProjectBar(
        future: _projectsFuture,
        onPressed: _addProject,
      ),
    );
  }

  Widget _buildTagFilter(List<Project> projects) {
    final tags = popularTags(projects);
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final tag in [null, ...tags])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(tag ?? 'Semua'),
                selected: _selectedTag == tag,
                onSelected: (_) => setState(() => _selectedTag = tag),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(AsyncSnapshot<List<Project>> snapshot) {
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
                'Gagal memuat proyek. ${describeApiError(snapshot.error!)}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final allProjects = snapshot.data ?? const <Project>[];
    final projects = _filter(allProjects);
    if (projects.isEmpty) {
      // Tetap bisa ditarik ke bawah untuk refresh walau daftar kosong.
      return RefreshIndicator(
        onRefresh: _reload,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: allProjects.isEmpty
                    ? const Text('No projects found.')
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Tidak ada proyek yang cocok.'),
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Hapus filter'),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        // Lebar maksimal kartu 220: 2 kolom di ponsel, lebih banyak di tablet.
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisExtent: 206,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return ProjectCard(
            project: project,
            onTap: () => _openDetail(project),
          );
        },
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.outline)),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.text),
      ),
    );
  }
}

/// Bar ajakan di bawah layar, selalu terjangkau ibu jari saat menggulir.
class _AddProjectBar extends StatelessWidget {
  const _AddProjectBar({required this.future, required this.onPressed});

  final Future<List<Project>> future;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          elevation: 6,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Tambah proyek baru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FutureBuilder<List<Project>>(
                    future: future,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${snapshot.data!.length} proyek',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
