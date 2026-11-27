import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/validators/experience_validators.dart';

import 'helpers/fake_backend.dart';
import 'helpers/home_actions.dart';

const _formTitle = 'Add Experience Form';
const _dialogTitle = 'Buang perubahan?';

Finder _field(String label) => find.widgetWithText(TextFormField, label);

Future<void> _openFormFromCard(
  WidgetTester tester, {
  FakeBackend? backend,
  String? token = 'valid-token',
}) async {
  await tester.pumpWidget(
    MyApp(apiClient: (backend ?? FakeBackend()).apiClient, initialToken: token),
  );
  await tapHomeAction(tester, 'Tambah Pengalaman');
  await tester.pumpAndSettle();
}

Future<void> _openDrawer(WidgetTester tester) async {
  tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
  await tester.pumpAndSettle();
}

Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Simpan'));
  await tester.pumpAndSettle();
  // Gulir sampai mentok supaya tombol naik di atas SnackBar mengambang.
  await tester.drag(find.byType(Form), const Offset(0, -400));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Simpan'));
  await tester.pumpAndSettle();
}

Future<void> _fillRequiredFields(WidgetTester tester) async {
  await tester.enterText(_field('Judul Pengalaman'), '  Asisten Dosen PBP  ');
  await tester.enterText(_field('Deskripsi'), 'Membantu mahasiswa.');
}

Future<void> _pressBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

Future<void> _login(WidgetTester tester) async {
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
}

void main() {
  group('Akses formulir pengalaman', () {
    testWidgets('Kartu aksi meminta login sebelum membuka form', (
      tester,
    ) async {
      await _openFormFromCard(tester, token: null);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);

      await _login(tester);
      expect(find.text(_formTitle), findsOneWidget);
    });

    testWidgets('Kartu aksi membuka form dan tombol kembali menutupnya', (
      tester,
    ) async {
      await _openFormFromCard(tester);
      expect(find.text(_formTitle), findsOneWidget);

      await _pressBack(tester);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('Drawer Add Experience dijaga login', (tester) async {
      await tester.pumpWidget(MyApp(apiClient: FakeBackend().apiClient));

      await _openDrawer(tester);
      await tester.tap(find.text('Add Experience'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);

      await _login(tester);
      expect(find.byType(ExperienceFormPage), findsOneWidget);

      await _openDrawer(tester);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    });
  });

  group('Kirim pengalaman ke API', () {
    testWidgets('Input kosong menampilkan error tanpa request', (tester) async {
      final backend = FakeBackend();
      await _openFormFromCard(tester, backend: backend);
      await _tapSave(tester);

      expect(find.text('Judul pengalaman tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
      expect(
        backend.requestsTo('/api/v1/experience/', method: 'POST'),
        isEmpty,
      );
    });

    testWidgets('URL tidak valid ditolak sebelum dikirim', (tester) async {
      final backend = FakeBackend();
      await _openFormFromCard(tester, backend: backend);
      await _fillRequiredFields(tester);
      await tester.enterText(_field('URL Thumbnail (opsional)'), 'bukan-url');
      await _tapSave(tester);

      expect(find.textContaining('Masukkan URL valid'), findsOneWidget);
      expect(
        backend.requestsTo('/api/v1/experience/', method: 'POST'),
        isEmpty,
      );
    });

    testWidgets('Input valid dikirim dengan token lalu kembali', (
      tester,
    ) async {
      final backend = FakeBackend();
      await _openFormFromCard(tester, backend: backend);
      await _fillRequiredFields(tester);

      await tester.ensureVisible(find.text('Full-Time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Full-Time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Internship').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        _field('URL Thumbnail (opsional)'),
        'https://example.com/gambar.png',
      );
      await _tapSave(tester);

      final request = backend
          .requestsTo('/api/v1/experience/', method: 'POST')
          .single;
      expect(request.headers['Authorization'], 'Token valid-token');
      expect(jsonDecode(request.body), {
        'title': 'Asisten Dosen PBP',
        'description': 'Membantu mahasiswa.',
        'category': 'internship',
        'thumbnail': 'https://example.com/gambar.png',
        'ended_at': null,
      });

      expect(find.text('Pengalaman berhasil disimpan!'), findsOneWidget);
      expect(find.text('Kategori: Internship'), findsOneWidget);
      expect(find.text('Selesai: Sedang berlangsung'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('Tanggal selesai dikirim sebagai akhir hari (UTC)', (
      tester,
    ) async {
      final backend = FakeBackend();
      await _openFormFromCard(tester, backend: backend);
      await _fillRequiredFields(tester);

      await tester.ensureVisible(_field('Tanggal Selesai (opsional)'));
      await tester.pumpAndSettle();
      await tester.tap(_field('Tanggal Selesai (opsional)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await _tapSave(tester);

      final body = jsonDecode(
        backend.requestsTo('/api/v1/experience/', method: 'POST').single.body,
      ) as Map<String, dynamic>;
      final now = DateTime.now();
      final expected = DateTime(now.year, now.month, now.day, 23, 59, 59);
      expect(DateTime.parse(body['ended_at'] as String), expected.toUtc());
      expect(find.text('Selesai: Sedang berlangsung'), findsNothing);
    });

    testWidgets('Dari daftar, entri baru langsung muncul setelah disimpan', (
      tester,
    ) async {
      final backend = FakeBackend(experiences: [sampleExperience()]);
      await tester.pumpWidget(
        MyApp(apiClient: backend.apiClient, initialToken: 'valid-token'),
      );
      await tapHomeAction(tester, 'Lihat Pengalaman');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tambah pengalaman baru'));
      await tester.pumpAndSettle();
      await tester.enterText(_field('Judul Pengalaman'), 'Juara Hackathon');
      await tester.enterText(_field('Deskripsi'), 'Juara 1 tingkat nasional.');
      await _tapSave(tester);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(ExperienceListScreen), findsOneWidget);
      expect(find.text('Juara Hackathon'), findsOneWidget);
      expect(find.text('Asisten Dosen PBP'), findsOneWidget);
    });

    testWidgets('Token kedaluwarsa (401) logout lalu minta login ulang', (
      tester,
    ) async {
      final backend = FakeBackend();
      await _openFormFromCard(tester, backend: backend, token: 'token-lama');
      await _fillRequiredFields(tester);
      await _tapSave(tester);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(backend.requestsTo('/api/v1/auth/logout/'), hasLength(1));

      await _login(tester);
      expect(find.text('Pengalaman berhasil disimpan!'), findsOneWidget);
      expect(
        backend.requestsTo('/api/v1/experience/', method: 'POST'),
        hasLength(2),
      );
    });
  });

  group('Konfirmasi keluar formulir', () {
    testWidgets('Form kosong bisa langsung ditinggalkan', (tester) async {
      await _openFormFromCard(tester);
      await _pressBack(tester);

      expect(find.text(_dialogTitle), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('Tombol kembali meminta konfirmasi saat ada isian', (
      tester,
    ) async {
      await _openFormFromCard(tester);
      await tester.enterText(_field('Judul Pengalaman'), 'Draf');
      await tester.pump();

      await _pressBack(tester);
      expect(find.text(_dialogTitle), findsOneWidget);
      await tester.tap(find.text('Lanjut mengisi'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(find.text('Draf'), findsOneWidget);

      await _pressBack(tester);
      await tester.tap(find.text('Buang'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('Opsi drawer meminta konfirmasi saat ada isian', (
      tester,
    ) async {
      await _openFormFromCard(tester);
      await tester.enterText(_field('Judul Pengalaman'), 'Draf');
      await tester.pump();
      await _openDrawer(tester);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text(_dialogTitle), findsOneWidget);
      await tester.tap(find.text('Lanjut mengisi'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buang'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('Form sebagai route terakhir keluar aplikasi setelah dibuang', (
      tester,
    ) async {
      final platformCalls = <String>[];
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        platformCalls.add(call.method);
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await tester.pumpWidget(
        MyApp(apiClient: FakeBackend().apiClient, initialToken: 'valid-token'),
      );
      await _openDrawer(tester);
      await tester.tap(find.text('Add Experience'));
      await tester.pumpAndSettle();
      await tester.enterText(_field('Judul Pengalaman'), 'Draf');
      await tester.pump();

      await _pressBack(tester);
      await tester.tap(find.text('Buang'));
      await tester.pumpAndSettle();

      expect(platformCalls, contains('SystemNavigator.pop'));
      expect(find.byType(ExperienceFormPage), findsOneWidget);
    });
  });

  testWidgets('Alur form berjalan tanpa overflow di layar ponsel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _openFormFromCard(tester);
    await _fillRequiredFields(tester);
    await _tapSave(tester);

    expect(find.text('Pengalaman berhasil disimpan!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('ExperienceValidators', () {
    test('kategori sama dengan pilihan model Django', () {
      expect(experienceCategories.keys, [
        'internship',
        'research',
        'volunteer',
        'part-time',
        'full-time',
        'freelance',
        'competition',
      ]);
    });

    test('menolak teks kosong, spasi, dan judul terlalu panjang', () {
      expect(ExperienceValidators.title(''), isNotNull);
      expect(ExperienceValidators.title('    '), isNotNull);
      expect(ExperienceValidators.title('a' * 256), isNotNull);
      expect(ExperienceValidators.title('a' * 255), isNull);
      expect(ExperienceValidators.description('   '), isNotNull);
      expect(ExperienceValidators.description('Isi'), isNull);
    });

    test('memeriksa urutan tanggal', () {
      final startedAt = DateTime(2026, 11, 21, 15);

      expect(ExperienceValidators.endedAt(null, startedAt), isNull);
      expect(
        ExperienceValidators.endedAt(DateTime(2026, 11, 20), startedAt),
        isNotNull,
      );
      expect(
        ExperienceValidators.endedAt(DateTime(2026, 11, 21), startedAt),
        isNull,
      );
      expect(
        ExperienceValidators.endedAt(DateTime(2026, 12, 1), startedAt),
        isNull,
      );
    });

    test('memeriksa format URL thumbnail', () {
      for (final url in [
        'bukan-url',
        'ftp://example.com',
        'https://',
        'https://contoh',
        'https://exa mple.com',
        'https://example.com/${'a' * 200}',
      ]) {
        expect(ExperienceValidators.thumbnail(url), isNotNull, reason: url);
      }

      expect(ExperienceValidators.thumbnail(''), isNull);
      expect(
        ExperienceValidators.thumbnail('https://example.com/a.png?b=1'),
        isNull,
      );
    });
  });
}
