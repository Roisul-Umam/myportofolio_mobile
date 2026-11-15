import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';

void main() {
  testWidgets('Halaman utama menampilkan identitas dan tombol aksi',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text('2506620210'), findsOneWidget);
    expect(find.text('Roisul Umam'), findsOneWidget);
    expect(find.text('PBP F'), findsOneWidget);

    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  test('Setiap tombol aksi punya warna yang berbeda', () {
    final items = MyHomePage().items;
    final colors = items.map((item) => item.color).toSet();

    expect(items.length, greaterThanOrEqualTo(3));
    expect(colors.length, items.length);
  });

  testWidgets('Menekan tombol menampilkan SnackBar sesuai nama tombol',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    for (final name in ['Lihat Proyek', 'Tambah Proyek', 'Logout']) {
      await tester.tap(find.text(name));
      await tester.pump();
      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);
    }
  });
}