import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

import 'helpers/fake_backend.dart';
import 'helpers/home_actions.dart';

void main() {
  testWidgets('Halaman utama menampilkan identitas dan tombol aksi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: FakeBackend().apiClient));

    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text('2506620210'), findsOneWidget);
    // Nama tampil di header sapaan dan di kartu identitas.
    expect(
      find.descendant(
        of: find.byType(InfoCard),
        matching: find.text('Roisul Umam'),
      ),
      findsOneWidget,
    );
    expect(find.text('PBP F'), findsOneWidget);

    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Tambah Pengalaman'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  test('Setiap tombol aksi punya warna yang berbeda', () {
    final items = MyHomePage().items;
    final colors = items.map((item) => item.color).toSet();

    expect(items.length, greaterThanOrEqualTo(3));
    expect(colors.length, items.length);
  });

  testWidgets('Menekan tombol menampilkan SnackBar sesuai nama tombol', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: FakeBackend().apiClient));

    // Tiga tombol ini membuka halaman lain (Tambah Proyek membuka Login
    // karena belum login), jadi kembali ke home sebelum tombol berikutnya.
    for (final name in ['Lihat Proyek', 'Tambah Proyek', 'Tambah Pengalaman']) {
      await tester.ensureVisible(find.text(name));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    }

    await tester.ensureVisible(find.text('Logout'));
    await tester.pumpAndSettle();
    await tapHomeAction(tester, 'Logout');
    await tester.pumpAndSettle();
    expect(find.text('Kamu belum login.'), findsOneWidget);
  });

  testWidgets('Tombol Tambah Proyek membuka halaman form saat sudah login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(apiClient: FakeBackend().apiClient, initialToken: 'valid-token'),
    );

    await tapHomeAction(tester, 'Tambah Proyek');
    await tester.pumpAndSettle();

    expect(find.text('Add Project Form'), findsOneWidget);
  });
}
