import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/validators/project_validators.dart';

import 'helpers/fake_backend.dart';
import 'helpers/home_actions.dart';

const _dialogTitle = 'Buang perubahan?';

Finder _field(String label) => find.widgetWithText(TextFormField, label);

Future<void> _openForm(
  WidgetTester tester,
  FakeBackend backend, {
  String? token = 'valid-token',
}) async {
  await tester.pumpWidget(
    MyApp(apiClient: backend.apiClient, initialToken: token),
  );
  await tapHomeAction(tester, 'Tambah Proyek');
  await tester.pumpAndSettle();
}

Future<void> _pressBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.enterText(_field('Title'), '  Aplikasi Kasir  ');
  await tester.enterText(_field('Description'), 'Kasir untuk UMKM.');
  await tester.enterText(_field('Tech Stack'), 'Flutter, Django');
  await tester.enterText(_field('Project URL'), 'https://github.com/a/kasir');
}

Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  group('Simpan proyek ke API', () {
    testWidgets('Input kosong menampilkan error tanpa request', (tester) async {
      final backend = FakeBackend();
      await _openForm(tester, backend);

      await _tapSave(tester);

      expect(find.text('Judul proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Tech stack tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Tautan proyek tidak boleh kosong!'), findsOneWidget);
      expect(backend.requestsTo('/api/v1/projects/', method: 'POST'), isEmpty);
    });

    testWidgets('URL tidak valid ditolak sebelum dikirim', (tester) async {
      final backend = FakeBackend();
      await _openForm(tester, backend);
      await _fillValidForm(tester);
      await tester.enterText(_field('Project URL'), 'bukan-url');

      await _tapSave(tester);

      expect(find.textContaining('Masukkan URL valid'), findsOneWidget);
      expect(backend.requestsTo('/api/v1/projects/', method: 'POST'), isEmpty);
    });

    testWidgets('Input valid dikirim dengan token lalu dialog muncul', (
      tester,
    ) async {
      final backend = FakeBackend();
      await _openForm(tester, backend);
      await _fillValidForm(tester);

      await _tapSave(tester);

      final request = backend
          .requestsTo('/api/v1/projects/', method: 'POST')
          .single;
      expect(request.headers['Authorization'], 'Token valid-token');
      expect(jsonDecode(request.body), {
        'title': 'Aplikasi Kasir',
        'description': 'Kasir untuk UMKM.',
        'tags': 'Flutter, Django',
        'link': 'https://github.com/a/kasir',
        'project_image_url': '',
      });
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('ID: 1'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Aplikasi Kasir'), findsNothing);

      // Form sudah kosong, jadi keluar tanpa dialog konfirmasi.
      await _pressBack(tester);
      expect(find.text(_dialogTitle), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('Token kedaluwarsa (401) logout lalu minta login ulang', (
      tester,
    ) async {
      final backend = FakeBackend();
      await _openForm(tester, backend, token: 'token-lama');
      await _fillValidForm(tester);

      await _tapSave(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(backend.requestsTo('/api/v1/auth/logout/'), hasLength(1));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'owner',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        FakeBackend.password,
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(
        backend.requestsTo('/api/v1/projects/', method: 'POST'),
        hasLength(2),
      );
    });

    testWidgets('Error selain 401 tampil sebagai SnackBar', (tester) async {
      final backend = FakeBackend()..createErrorStatus = 400;
      await _openForm(tester, backend);
      await _fillValidForm(tester);

      await _tapSave(tester);

      expect(
        find.text('Data ditolak server: link: Enter a valid URL.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
      // Isian tetap ada supaya pengguna bisa memperbaikinya.
      expect(find.textContaining('Aplikasi Kasir'), findsOneWidget);
    });
  });

  group('Konfirmasi keluar formulir proyek', () {
    testWidgets('Form kosong bisa langsung ditinggalkan', (tester) async {
      await _openForm(tester, FakeBackend());
      await _pressBack(tester);

      expect(find.text(_dialogTitle), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('Tombol kembali meminta konfirmasi saat ada isian', (
      tester,
    ) async {
      await _openForm(tester, FakeBackend());
      await tester.enterText(_field('Title'), 'Draf Proyek');
      await tester.pump();

      await _pressBack(tester);
      expect(find.text(_dialogTitle), findsOneWidget);
      await tester.tap(find.text('Lanjut mengisi'));
      await tester.pumpAndSettle();
      expect(find.text('Draf Proyek'), findsOneWidget);

      await _pressBack(tester);
      await tester.tap(find.text('Buang'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('Opsi drawer meminta konfirmasi saat ada isian', (
      tester,
    ) async {
      await _openForm(tester, FakeBackend());
      await tester.enterText(_field('Title'), 'Draf Proyek');
      await tester.pump();
      tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text(_dialogTitle), findsOneWidget);
      await tester.tap(find.text('Buang'));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    });
  });

  group('ProjectValidators', () {
    test('mengikuti batas panjang model Django', () {
      expect(ProjectValidators.title('a' * 100), isNull);
      expect(ProjectValidators.title('a' * 101), isNotNull);
      expect(ProjectValidators.tags('a' * 201), isNotNull);
      expect(ProjectValidators.description('   '), isNotNull);
    });

    test('tautan wajib, gambar opsional', () {
      expect(ProjectValidators.link(''), isNotNull);
      expect(ProjectValidators.link('https://github.com/a/b'), isNull);
      expect(ProjectValidators.imageUrl(''), isNull);
      expect(ProjectValidators.imageUrl('ftp://example.com/a.png'), isNotNull);
    });
  });
}
