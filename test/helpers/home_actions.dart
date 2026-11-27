import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

/// Menggulir ke kartu aksi cepat di Home lalu mengetuknya.
///
/// Kartu aksi berada di bawah banner dan barisnya bisa digulir ke samping,
/// jadi kartu bisa di luar layar test sebelum digulir.
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
  // Menggulir baris aksi ke samping jika kartunya terpotong.
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}
