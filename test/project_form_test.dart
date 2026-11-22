import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

const _dialogTitle = 'Buang perubahan?';

Finder get _nameField => find.byType(TextFormField).at(0);
Finder get _descriptionField => find.byType(TextFormField).at(1);

Future<void> _openFormFromCard(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.tap(find.text('Tambah Proyek'));
  await tester.pumpAndSettle();
}

Future<void> _openDrawer(WidgetTester tester) async {
  tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
  await tester.pumpAndSettle();
}

Future<void> _pressBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

void main() {
  group('Konfirmasi keluar formulir proyek', () {
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
      await tester.enterText(_nameField, 'Draf Proyek');
      await tester.pump();

      await _pressBack(tester);
      expect(find.text(_dialogTitle), findsOneWidget);
      await tester.tap(find.text('Lanjut mengisi'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsOneWidget);
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
      await _openFormFromCard(tester);
      await tester.enterText(_nameField, 'Draf Proyek');
      await tester.pump();
      await _openDrawer(tester);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text(_dialogTitle), findsOneWidget);
      await tester.tap(find.text('Lanjut mengisi'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buang'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('Mengganti kategori saja juga meminta konfirmasi', (
      tester,
    ) async {
      await _openFormFromCard(tester);
      await tester.tap(find.text('Web Development'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Data Science').last);
      await tester.pumpAndSettle();

      await _pressBack(tester);
      expect(find.text(_dialogTitle), findsOneWidget);
    });

    testWidgets('Setelah disimpan form kosong dan tidak ada konfirmasi', (
      tester,
    ) async {
      await _openFormFromCard(tester);
      await tester.enterText(_nameField, 'Proyek Baru');
      await tester.enterText(_descriptionField, 'Deskripsi proyek.');
      await tester.tap(find.text('Web Development'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Data Science').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Kategori: Data Science'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Proyek Baru'), findsNothing);
      expect(find.text('Web Development'), findsOneWidget);

      await _pressBack(tester);
      expect(find.text(_dialogTitle), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });
  });
}
