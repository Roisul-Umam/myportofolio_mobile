import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/utils/date_format.dart';
import 'package:myportofolio_mobile/validators/experience_validators.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/unsaved_changes_scope.dart';
import 'package:provider/provider.dart';

/// Pilihan kategori yang sama dengan `Experience.EXPERIENCE_CHOICES` di Django.
const Map<String, String> experienceCategories = {
  'internship': 'Internship',
  'research': 'Research',
  'volunteer': 'Volunteer',
  'part-time': 'Part-Time',
  'full-time': 'Full-Time',
  'freelance': 'Freelance',
  'competition': 'Competition',
};

/// Formulir tambah pengalaman yang mengirim `POST /api/v1/experience/`.
///
/// Pembukaan form dari kartu aksi, drawer, dan daftar dijaga dengan
/// [ensureLoggedIn]; pengiriman memakai token lewat [runWithRelogin].
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _endedAtController = TextEditingController();

  // started_at memakai auto_now_add, jadi nilainya selalu hari ini.
  final DateTime _startedAt = DateUtils.dateOnly(DateTime.now());

  String _category = Experience.defaultCategory;
  DateTime? _endedAt;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    _endedAtController.dispose();
    super.dispose();
  }

  Future<void> _pickEndedAt() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endedAt ?? _startedAt,
      firstDate: _startedAt,
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal selesai',
    );
    if (picked == null) return;

    setState(() {
      _endedAt = picked;
      _endedAtController.text = formatDate(picked);
    });
  }

  void _clearEndedAt() {
    setState(() {
      _endedAt = null;
      _endedAtController.clear();
    });
  }

  bool get _hasUnsavedChanges =>
      _titleController.text.trim().isNotEmpty ||
      _descriptionController.text.trim().isNotEmpty ||
      _thumbnailController.text.trim().isNotEmpty ||
      _category != Experience.defaultCategory ||
      _endedAt != null;

  /// Mengembalikan `true` jika halaman boleh ditinggalkan.
  Future<bool> _confirmLeave() async =>
      !_hasUnsavedChanges || await confirmDiscardChanges(context);

  void _resetForm() {
    _formKey.currentState!.reset();
    _titleController.clear();
    _descriptionController.clear();
    _thumbnailController.clear();
    _endedAtController.clear();
    setState(() {
      _category = Experience.defaultCategory;
      _endedAt = null;
    });
  }

  Experience _buildExperience() {
    final endedAt = _endedAt;
    return Experience(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      thumbnail: _thumbnailController.text.trim(),
      // Dikirim sebagai akhir hari, supaya memilih "hari ini" tidak dianggap
      // lebih awal dari started_at yang diisi server saat request diproses.
      endedAt: endedAt == null
          ? null
          : DateTime(endedAt.year, endedAt.month, endedAt.day, 23, 59, 59),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Menampilkan spinner di tombol Simpan hanya selama request berjalan.
  Future<T> _whileSubmitting<T>(Future<T> Function() request) async {
    setState(() => _isSubmitting = true);
    try {
      return await request();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final apiClient = context.read<ApiClient>();

    try {
      final created = await runWithRelogin(
        context,
        (token) => _whileSubmitting(
          () => apiClient.createExperience(_buildExperience(), token: token),
        ),
      );
      if (created == null || !mounted) return;
      await _showCreatedDialog(created);
      if (!mounted) return;
      _resetForm();
      _returnToList();
    } on ApiException catch (error) {
      if (mounted) _showSnackBar(error.userMessage);
    } on http.ClientException catch (error) {
      if (mounted) _showSnackBar(describeApiError(error));
    }
  }

  /// Kembali ke daftar (yang lalu memuat ulang data), atau membuka daftar
  /// jika form ini menjadi halaman pertama karena dibuka dari drawer.
  void _returnToList() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(true);
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const ExperienceListScreen()),
      );
    }
  }

  Future<void> _showCreatedDialog(Experience experience) {
    final startedAt = experience.startedAt;
    final endedAt = experience.endedAt;

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pengalaman berhasil disimpan!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Judul: ${experience.title}'),
              Text('Deskripsi: ${experience.description}'),
              Text('Kategori: ${experience.categoryDisplay}'),
              if (startedAt != null) Text('Mulai: ${formatDate(startedAt)}'),
              Text(
                'Selesai: ${endedAt == null ? 'Sedang berlangsung' : formatDate(endedAt)}',
              ),
              Text(
                'Thumbnail: ${experience.thumbnail.isEmpty ? 'Tidak ada' : experience.thumbnail}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(
    String label, {
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorMaxLines: 2,
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesScope(
      hasUnsavedChanges: _hasUnsavedChanges,
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Experience Form')),
        drawer: LeftDrawer(onBeforeNavigate: _confirmLeave),
        body: SafeArea(
          child: Form(
            key: _formKey,
            // Memperbarui canPop setiap kali isian berubah.
            onChanged: () => setState(() {}),
            // Scroll menjaga semua input dan tombol tetap terjangkau
            // di layar sempit atau saat papan ketik tampil.
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              // Ruang bawah agar tombol Simpan bisa digulir ke atas SnackBar
              // yang masih tampil setelah kartu aksi ditekan.
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16.0,
                children: [
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration(
                      'Judul Pengalaman',
                      hint: 'Contoh: Asisten Dosen PBP',
                    ),
                    validator: ExperienceValidators.title,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: _decoration(
                      'Deskripsi',
                      hint: 'Ceritakan peran dan kontribusimu',
                    ),
                    validator: ExperienceValidators.description,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    isExpanded: true,
                    decoration: _decoration('Kategori'),
                    items: experienceCategories.entries
                        .map(
                          (category) => DropdownMenuItem(
                            value: category.key,
                            child: Text(category.value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _category = value);
                    },
                  ),
                  TextFormField(
                    controller: _thumbnailController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    decoration: _decoration(
                      'URL Thumbnail (opsional)',
                      hint: 'https://example.com/gambar.png',
                    ),
                    validator: ExperienceValidators.thumbnail,
                  ),
                  TextFormField(
                    initialValue: formatDate(_startedAt),
                    enabled: false,
                    decoration: _decoration(
                      'Tanggal Mulai (otomatis)',
                      suffixIcon: const Icon(Icons.lock_clock),
                    ),
                  ),
                  TextFormField(
                    controller: _endedAtController,
                    readOnly: true,
                    onTap: _pickEndedAt,
                    decoration: _decoration(
                      'Tanggal Selesai (opsional)',
                      hint: 'Kosongkan jika masih berlangsung',
                      suffixIcon: _endedAt == null
                          ? const Icon(Icons.calendar_today)
                          : IconButton(
                              tooltip: 'Hapus tanggal selesai',
                              icon: const Icon(Icons.clear),
                              onPressed: _clearEndedAt,
                            ),
                    ),
                    validator: (_) =>
                        ExperienceValidators.endedAt(_endedAt, _startedAt),
                  ),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Simpan'),
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
