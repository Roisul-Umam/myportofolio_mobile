import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

import 'helpers/fake_backend.dart';
import 'helpers/home_actions.dart';

Future<void> _openDrawer(WidgetTester tester) async {
  tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
  await tester.pumpAndSettle();
}

Future<void> _login(WidgetTester tester, {String password = 'secret'}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Username'),
    'owner',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    password,
  );
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Kartu Tambah Proyek meminta login lalu membuka form', (
    tester,
  ) async {
    final backend = FakeBackend();
    await tester.pumpWidget(MyApp(apiClient: backend.apiClient));

    await tapHomeAction(tester, 'Tambah Proyek');
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);

    await _login(tester);

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(ProjectFormPage), findsOneWidget);
  });

  testWidgets('Batal login tidak membuka form', (tester) async {
    final backend = FakeBackend();
    await tester.pumpWidget(MyApp(apiClient: backend.apiClient));

    await tapHomeAction(tester, 'Tambah Proyek');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
  });

  testWidgets('Sudah login langsung membuka form', (tester) async {
    final backend = FakeBackend();
    await tester.pumpWidget(
      MyApp(apiClient: backend.apiClient, initialToken: 'valid-token'),
    );

    await tapHomeAction(tester, 'Tambah Proyek');
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(ProjectFormPage), findsOneWidget);
  });

  testWidgets('Validasi login dan password salah', (tester) async {
    final backend = FakeBackend();
    await tester.pumpWidget(MyApp(apiClient: backend.apiClient));
    await _openDrawer(tester);
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Username cannot be empty!'), findsOneWidget);
    expect(find.text('Password cannot be empty!'), findsOneWidget);
    expect(backend.requestsTo('/api/v1/auth/token/'), isEmpty);

    await _login(tester, password: 'salah');
    expect(
      find.text('Login gagal (400): Username atau password salah.'),
      findsOneWidget,
    );
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Drawer menukar opsi Login dan Logout', (tester) async {
    final backend = FakeBackend();
    await tester.pumpWidget(MyApp(apiClient: backend.apiClient));

    await _openDrawer(tester);
    expect(
      find.descendant(of: find.byType(Drawer), matching: find.text('Logout')),
      findsNothing,
    );
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await _login(tester);
    expect(find.text('Login berhasil.'), findsOneWidget);

    await _openDrawer(tester);
    expect(
      find.descendant(of: find.byType(Drawer), matching: find.text('Login')),
      findsNothing,
    );
    await tester.tap(
      find.descendant(of: find.byType(Drawer), matching: find.text('Logout')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kamu sudah logout.'), findsOneWidget);
    expect(backend.requestsTo('/api/v1/auth/logout/'), hasLength(1));
    await _openDrawer(tester);
    expect(
      find.descendant(of: find.byType(Drawer), matching: find.text('Login')),
      findsOneWidget,
    );
  });

  testWidgets('Opsi Add Project di drawer dilindungi login', (tester) async {
    final backend = FakeBackend();
    await tester.pumpWidget(MyApp(apiClient: backend.apiClient));

    await _openDrawer(tester);
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await _login(tester);
    expect(find.byType(ProjectFormPage), findsOneWidget);
  });

  testWidgets('Kartu Logout memanggil API saat sudah login', (tester) async {
    final backend = FakeBackend();
    await tester.pumpWidget(
      MyApp(apiClient: backend.apiClient, initialToken: 'valid-token'),
    );

    await tester.ensureVisible(find.text('Logout'));
    await tapHomeAction(tester, 'Logout');
    await tester.pumpAndSettle();

    expect(find.text('Kamu berhasil logout.'), findsOneWidget);
    expect(backend.validToken, isNull);

    await tapHomeAction(tester, 'Logout');
    await tester.pumpAndSettle();
    expect(find.text('Kamu belum login.'), findsOneWidget);
  });
}
