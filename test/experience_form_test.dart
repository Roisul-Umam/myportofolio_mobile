import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/validators/experience_validators.dart';

const _formTitle = 'Add Experience Form';

Finder _field(String label) => find.widgetWithText(TextFormField, label);

Future<void> _openFormFromCard(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.ensureVisible(find.text('Tambah Pengalaman'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Tambah Pengalaman'));
  await tester.pumpAndSettle();
}

Future<void> _openDrawer(WidgetTester tester) async {
  tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
  await tester.pumpAndSettle();
}

Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Simpan'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Simpan'));
  await tester.pumpAndSettle();
}

Future<void> _fillRequiredFields(WidgetTester tester) async {
  await tester.enterText(_field('Judul Pengalaman'), '  Asisten Dosen PBP  ');
  await tester.enterText(_field('Deskripsi'), 'Membantu mahasiswa.');
}

void main() {
  group('Navigasi formulir pengalaman', () {
    testWidgets('Kartu aksi membuka form dan bisa kembali', (tester) async {
      await _openFormFromCard(tester);
      expect(find.text(_formTitle), findsOneWidget);

      // Mensimulasikan tombol kembali bawaan perangkat.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text(_formTitle), findsNothing);
    });

    testWidgets('Drawer membuka form dan Home kembali ke halaman utama', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      await _openDrawer(tester);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Add Project'), findsOneWidget);
      await tester.tap(find.text('Add Experience'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsOneWidget);

      await _openDrawer(tester);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);
    });
  });

  group('Penyimpanan formulir', () {
    testWidgets('Input kosong menampilkan error tanpa dialog', (tester) async {
      await _openFormFromCard(tester);
      await _tapSave(tester);

      expect(find.text('Judul pengalaman tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('URL tidak valid menahan dialog', (tester) async {
      await _openFormFromCard(tester);
      await _fillRequiredFields(tester);
      await tester.enterText(_field('URL Thumbnail (opsional)'), 'bukan-url');
      await _tapSave(tester);

      expect(find.textContaining('Masukkan URL valid'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Input valid menampilkan ringkasan lalu kembali ke form', (
      tester,
    ) async {
      await _openFormFromCard(tester);
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

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Judul: Asisten Dosen PBP'), findsOneWidget);
      expect(find.text('Deskripsi: Membantu mahasiswa.'), findsOneWidget);
      expect(find.text('Kategori: Internship'), findsOneWidget);
      expect(find.textContaining('Mulai: '), findsOneWidget);
      expect(find.text('Selesai: Sedang berlangsung'), findsOneWidget);
      expect(
        find.text('Thumbnail: https://example.com/gambar.png'),
        findsOneWidget,
      );

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text(_formTitle), findsOneWidget);
      expect(find.text('Full-Time'), findsOneWidget);

      final urlField = tester.widget<TextFormField>(
        _field('URL Thumbnail (opsional)'),
      );
      expect(urlField.controller!.text, isEmpty);
    });
  });

  group('Konfirmasi keluar formulir', () {
    const dialogTitle = 'Buang perubahan?';

    Future<void> pressBack(WidgetTester tester) async {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }

    testWidgets('Form kosong bisa langsung ditinggalkan', (tester) async {
      await _openFormFromCard(tester);
      await pressBack(tester);

      expect(find.text(dialogTitle), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('Tombol kembali meminta konfirmasi saat ada isian', (
      tester,
    ) async {
      await _openFormFromCard(tester);
      await tester.enterText(_field('Judul Pengalaman'), 'Draf');
      await tester.pump();

      await pressBack(tester);
      expect(find.text(dialogTitle), findsOneWidget);
      await tester.tap(find.text('Lanjut mengisi'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(find.text('Draf'), findsOneWidget);

      await pressBack(tester);
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
      expect(find.text(dialogTitle), findsOneWidget);
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

    testWidgets('Setelah disimpan tidak ada konfirmasi', (tester) async {
      await _openFormFromCard(tester);
      await _fillRequiredFields(tester);
      await _tapSave(tester);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await pressBack(tester);
      expect(find.text(dialogTitle), findsNothing);
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

      await tester.pumpWidget(const MyApp());
      await _openDrawer(tester);
      await tester.tap(find.text('Add Experience'));
      await tester.pumpAndSettle();
      await tester.enterText(_field('Judul Pengalaman'), 'Draf');
      await tester.pump();

      await pressBack(tester);
      await tester.tap(find.text('Buang'));
      await tester.pumpAndSettle();

      expect(platformCalls, contains('SystemNavigator.pop'));
      expect(find.byType(ExperienceFormPage), findsOneWidget);
    });
  });

  testWidgets('Tanggal selesai dari date picker tampil di ringkasan', (
    tester,
  ) async {
    await _openFormFromCard(tester);
    await _fillRequiredFields(tester);

    await tester.ensureVisible(_field('Tanggal Selesai (opsional)'));
    await tester.pumpAndSettle();
    await tester.tap(_field('Tanggal Selesai (opsional)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await _tapSave(tester);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Selesai: '), findsOneWidget);
    expect(find.text('Selesai: Sedang berlangsung'), findsNothing);
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

    expect(find.byType(AlertDialog), findsOneWidget);
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
