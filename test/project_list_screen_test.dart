import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';

import 'helpers/fake_backend.dart';
import 'helpers/home_actions.dart';

Future<void> _openList(WidgetTester tester, FakeBackend backend) async {
  await tester.pumpWidget(MyApp(apiClient: backend.apiClient));
  await tapHomeAction(tester, 'Lihat Proyek');
  await tester.pump();
}

void main() {
  testWidgets('Menampilkan loading lalu daftar proyek tanpa login', (
    tester,
  ) async {
    final backend = FakeBackend(
      projects: [
        sampleProject(),
        sampleProject(id: 2, title: 'Aplikasi Mobile'),
      ],
    );

    await _openList(tester, backend);
    await tester.pump();
    expect(find.byType(ProjectListScreen), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Portfolio Web'), findsOneWidget);
    expect(find.text('Aplikasi Mobile'), findsOneWidget);
    expect(find.text('Django • Tailwind'), findsNWidgets(2));
    // Satu request dari carousel Home, satu dari halaman daftar.
    expect(backend.requestsTo('/api/v1/projects/'), hasLength(2));
  });

  testWidgets('Menekan proyek membuka detail dengan gambar', (tester) async {
    final backend = FakeBackend(
      projects: [sampleProject(imageUrl: 'https://example.com/gambar.png')],
    );

    await _openList(tester, backend);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Portfolio Web'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(find.byKey(const Key('project-image')), findsOneWidget);
    expect(find.text('Tailwind'), findsOneWidget);

    // Gambar 16:9 mendorong deskripsi ke bawah layar test.
    await tester.scrollUntilVisible(
      find.text('Website portofolio dengan Django.'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ProjectDetailScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Website portofolio dengan Django.'), findsOneWidget);
  });

  testWidgets('Detail tidak menampilkan gambar jika URL kosong', (
    tester,
  ) async {
    final backend = FakeBackend(projects: [sampleProject()]);

    await _openList(tester, backend);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Portfolio Web'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('project-image')), findsNothing);
  });

  testWidgets('Daftar kosong menampilkan pesan dan bisa di-refresh', (
    tester,
  ) async {
    final backend = FakeBackend();

    await _openList(tester, backend);
    await tester.pumpAndSettle();
    expect(find.text('No projects found.'), findsOneWidget);

    backend.projects.add(sampleProject());
    await tester.fling(
      find.text('No projects found.'),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(find.text('Portfolio Web'), findsOneWidget);
    // Home + daftar + refresh.
    expect(backend.requestsTo('/api/v1/projects/'), hasLength(3));
  });

  testWidgets('Error server menampilkan pesan aman dan tombol coba lagi', (
    tester,
  ) async {
    final backend = FakeBackend(projects: [sampleProject()])
      ..projectsErrorStatus = 500;

    await _openList(tester, backend);
    await tester.pumpAndSettle();
    expect(find.textContaining('Server sedang bermasalah'), findsOneWidget);
    expect(find.textContaining('Traceback'), findsNothing);

    backend.projectsErrorStatus = null;
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Portfolio Web'), findsOneWidget);
  });
}
