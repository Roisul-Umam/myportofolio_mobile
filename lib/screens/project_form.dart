import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/validators/project_validators.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/unsaved_changes_scope.dart';
import 'package:provider/provider.dart';

/// Formulir tambah proyek yang mengirim data ke `POST /api/v1/projects/`.
///
/// Field mengikuti `ProjectSerializer` Django: title, description, tags,
/// link, dan project_image_url.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _linkController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isSubmitting = false;

  List<TextEditingController> get _controllers => [
    _titleController,
    _descriptionController,
    _tagsController,
    _linkController,
    _imageUrlController,
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _hasUnsavedChanges =>
      _controllers.any((controller) => controller.text.trim().isNotEmpty);

  /// Mengembalikan `true` jika halaman boleh ditinggalkan.
  Future<bool> _confirmLeave() async =>
      !_hasUnsavedChanges || await confirmDiscardChanges(context);

  Project _buildProject() => Project(
    title: _titleController.text.trim(),
    description: _descriptionController.text.trim(),
    tags: _tagsController.text.trim(),
    link: _linkController.text.trim(),
    projectImageUrl: _imageUrlController.text.trim(),
  );

  void _resetForm() {
    _formKey.currentState!.reset();
    for (final controller in _controllers) {
      controller.clear();
    }
    setState(() {});
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await ensureLoggedIn(context) || !mounted) return;

    try {
      final created = await _createProjectWithRelogin();
      if (created == null || !mounted) return;
      await _showCreatedDialog(created);
      if (mounted) _resetForm();
    } on ApiException catch (error) {
      if (mounted) _showSnackBar(error.userMessage);
    } on http.ClientException catch (error) {
      if (mounted) _showSnackBar(describeApiError(error));
    }
  }

  /// Menampilkan spinner di tombol Save hanya selama request berjalan,
  /// bukan saat dialog atau layar login sedang terbuka.
  Future<T> _whileSubmitting<T>(Future<T> Function() request) async {
    setState(() => _isSubmitting = true);
    try {
      return await request();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Mengirim proyek. Jika token ditolak (401), sesi dihapus dan pengguna
  /// diminta login ulang, lalu pengiriman dicoba sekali lagi.
  Future<Project?> _createProjectWithRelogin() async {
    final apiClient = context.read<ApiClient>();
    final auth = context.read<AuthState>();
    Future<Project> send() => _whileSubmitting(
      () => apiClient.createProject(_buildProject(), token: auth.token!),
    );

    try {
      return await send();
    } on ApiException catch (error) {
      if (error.statusCode != 401) rethrow;

      await auth.logout();
      if (!mounted) return null;
      _showSnackBar('Sesi login berakhir. Silakan login ulang.');
      if (!await ensureLoggedIn(context) || !mounted) return null;

      return send();
    }
  }

  Future<void> _showCreatedDialog(Project project) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Proyek berhasil ditambahkan!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${project.id}'),
              Text('Judul: ${project.title}'),
              Text('Deskripsi: ${project.description}'),
              Text('Tech stack: ${project.tags}'),
              Text('Tautan: ${project.link}'),
              Text(
                'Gambar: ${project.projectImageUrl.isEmpty ? 'Tidak ada' : project.projectImageUrl}',
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

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(labelText: label, hintText: hint, errorMaxLines: 2);
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesScope(
      hasUnsavedChanges: _hasUnsavedChanges,
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Project Form')),
        drawer: LeftDrawer(onBeforeNavigate: _confirmLeave),
        body: SafeArea(
          child: Form(
            key: _formKey,
            // Memperbarui status "ada perubahan" setiap kali isian berubah.
            onChanged: () => setState(() {}),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              // Ruang bawah agar tombol Save bisa digulir ke atas SnackBar.
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration(
                      'Title',
                      hint: 'Contoh: Website Portofolio',
                    ),
                    validator: ProjectValidators.title,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: _decoration('Description'),
                    validator: ProjectValidators.description,
                  ),
                  TextFormField(
                    controller: _tagsController,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration(
                      'Tech Stack',
                      hint: 'Pisahkan dengan koma: Django, Flutter',
                    ),
                    validator: ProjectValidators.tags,
                  ),
                  TextFormField(
                    controller: _linkController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration(
                      'Project URL',
                      hint: 'https://github.com/username/proyek',
                    ),
                    validator: ProjectValidators.link,
                  ),
                  TextFormField(
                    controller: _imageUrlController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    decoration: _decoration(
                      'Project Image URL (Optional)',
                      hint: 'https://example.com/gambar.png',
                    ),
                    validator: ProjectValidators.imageUrl,
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
                    label: const Text('Save'),
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
