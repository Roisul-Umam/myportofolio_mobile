import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

/// Menggulir ke kartu aksi cepat di Home lalu mengetuknya.
///
/// Kartu aksi berada di bawah banner, jadi bisa di luar layar test dan
/// belum dibangun oleh ListView sebelum digulir.
Future<void> tapHomeAction(WidgetTester tester, String name) async {
  final finder = find.text(name);
  await tester.scrollUntilVisible(
    finder,
    120,
    scrollable: find
        .descendant(
          of: find.byType(MyHomePage),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
}
