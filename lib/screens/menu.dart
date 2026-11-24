import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';
import 'package:myportofolio_mobile/widgets/account_sheet.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:myportofolio_mobile/widgets/project_tile.dart';
import 'package:provider/provider.dart';

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  final String npm = '2506620210';
  final String name = 'Roisul Umam';
  final String className = 'PBP F';

  final List<ItemHomepage> items = [
    ItemHomepage("Lihat Proyek", Icons.folder_open, Colors.blue),
    ItemHomepage("Tambah Proyek", Icons.add, Colors.green),
    ItemHomepage("Tambah Pengalaman", Icons.work_outline, Colors.deepPurple),
    ItemHomepage("Logout", Icons.logout, Colors.red),
  ];

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Project>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = context.read<ApiClient>().getProjects();
  }

  Future<void> _reload() async {
    final future = context.read<ApiClient>().getProjects();
    setState(() => _projectsFuture = future);
    try {
      await future;
    } on Exception {
      // Error sudah ditampilkan oleh FutureBuilder.
    }
  }

  Future<void> _openProjects({String? query, String? tag}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProjectListScreen(initialQuery: query, initialTag: tag),
      ),
    );
    // Proyek baru mungkin ditambahkan dari halaman daftar.
    if (mounted) _reload();
  }

  void _openAccount() =>
      showAccountSheet(context, name: widget.name, npm: widget.npm);

  void _onBottomNavSelected(int index) {
    switch (index) {
      case 1:
        _openProjects();
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExperienceFormPage()),
        );
      case 3:
        _openAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LeftDrawer(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: _onBottomNavSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            label: 'Proyek',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            label: 'Pengalaman',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Akun',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _HomeHeader(name: widget.name, onAccountPressed: _openAccount),
              const SizedBox(height: 20),
              _SearchRow(
                onSubmitted: (query) => _openProjects(query: query),
                onFilterPressed: _openProjects,
              ),
              const SizedBox(height: 16),
              _TagChips(
                future: _projectsFuture,
                onSelected: (tag) => _openProjects(tag: tag),
              ),
              const SizedBox(height: 16),
              _IdentityBanner(
                npm: widget.npm,
                name: widget.name,
                className: widget.className,
                onExplore: _openProjects,
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Aksi Cepat'),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in widget.items)
                    Expanded(child: ItemCard(item)),
                ],
              ),
              const SizedBox(height: 24),
              _SectionTitle(
                'Proyek Unggulan',
                actionLabel: 'Lihat semua',
                onAction: _openProjects,
              ),
              const SizedBox(height: 12),
              _FeaturedProjects(future: _projectsFuture, onRetry: _reload),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header: avatar (membuka drawer), sapaan, dan tombol status akun.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.name, required this.onAccountPressed});

  final String name;
  final VoidCallback onAccountPressed;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Row(
      children: [
        Tooltip(
          message: 'Buka menu',
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initialsOf(name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu,
                      size: 14,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat datang kembali',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        _RoundIconButton(
          icon: Icons.person_outline,
          tooltip: isLoggedIn ? 'Akun (sudah login)' : 'Akun (belum login)',
          showBadge: isLoggedIn,
          onPressed: onAccountPressed,
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.showBadge = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.outline)),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Badge(
          isLabelVisible: showBadge,
          backgroundColor: Colors.green,
          smallSize: 9,
          child: Icon(icon, color: AppColors.text),
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.onSubmitted, required this.onFilterPressed});

  final ValueChanged<String> onSubmitted;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmitted,
            decoration: const InputDecoration(
              hintText: 'Cari proyek atau teknologi...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 54,
          height: 54,
          child: Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.outline),
            ),
            child: IconButton(
              tooltip: 'Filter proyek',
              onPressed: onFilterPressed,
              icon: const Icon(Icons.tune, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

/// Chip tag teknologi terpopuler; menekan chip membuka daftar terfilter.
class _TagChips extends StatelessWidget {
  const _TagChips({required this.future, required this.onSelected});

  final Future<List<Project>> future;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Project>>(
      future: future,
      builder: (context, snapshot) {
        final tags = popularTags(snapshot.data ?? const []);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 8,
            children: [
              ChoiceChip(
                selected: true,
                avatar: const Icon(
                  Icons.grid_view_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text('Semua'),
                onSelected: (_) => onSelected(null),
              ),
              for (final tag in tags)
                ChoiceChip(
                  selected: false,
                  label: Text(tag),
                  onSelected: (_) => onSelected(tag),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Banner utama berisi identitas pemilik dan satu ajakan utama.
class _IdentityBanner extends StatelessWidget {
  const _IdentityBanner({
    required this.npm,
    required this.name,
    required this.className,
    required this.onExplore,
  });

  final String npm;
  final String name;
  final String className;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Stack(
          children: [
            // Lingkaran dekoratif agar banner tidak terasa datar.
            Positioned(
              right: -40,
              top: -40,
              child: _Bubble(size: 140, opacity: 0.10),
            ),
            Positioned(
              right: 30,
              bottom: -50,
              child: _Bubble(size: 110, opacity: 0.08),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kenali proyek dan pengalamanku',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Portofolio mahasiswa Fasilkom UI',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: InfoCard(title: 'NPM', content: npm),
                      ),
                      Expanded(
                        child: InfoCard(title: 'Name', content: name),
                      ),
                      Expanded(
                        child: InfoCard(title: 'Class', content: className),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onExplore,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Jelajahi Proyek'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.text,
                      minimumSize: const Size(0, 44),
                      elevation: 0,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: opacity),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

/// Carousel horizontal proyek dengan bintang terbanyak.
class _FeaturedProjects extends StatelessWidget {
  const _FeaturedProjects({required this.future, required this.onRetry});

  final Future<List<Project>> future;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: FutureBuilder<List<Project>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Card(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        describeApiError(snapshot.error!),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: onRetry,
                        child: const Text('Muat ulang'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final projects = [...?snapshot.data]
            ..sort((a, b) => b.starCount.compareTo(a.starCount));
          if (projects.isEmpty) {
            return const Card(child: Center(child: Text('Belum ada proyek.')));
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: projects.length.clamp(0, 6),
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final project = projects[index];
              return ProjectCard(
                project: project,
                width: 168,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDetailScreen(project: project),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Kartu identitas kecil di dalam banner biru.
class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
