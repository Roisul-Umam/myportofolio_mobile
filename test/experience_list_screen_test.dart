import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_detail_screen.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';

import 'helpers/fake_backend.dart';
import 'helpers/home_actions.dart';

Future<void> _openList(
  WidgetTester tester,
  FakeBackend backend, {
  String? token,
}) async {
  await tester.pumpWidget(
    MyApp(apiClient: backend.apiClient, initialToken: token),
  );
  await tapHomeAction(tester, 'Lihat Pengalaman');
  await tester.pumpAndSettle();
}

Future<void> _openDetail(WidgetTester tester, String title) async {
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

Future<void> _tapDelete(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Hapus pengalaman'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Hapus pengalaman'));
  await tester.pumpAndSettle();
}

Future<void> _confirmDelete(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(TextButton, 'Hapus'));
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
  group('Daftar pengalaman', () {
    testWidgets('Tampil tanpa login dari kartu aksi', (tester) async {
      final backend = FakeBackend(
        experiences: [
          sampleExperience(),
          sampleExperience(
            id: 'exp-2',
            title: 'Juara Hackathon',
            category: 'competition',
            endedAt: '2026-10-01T10:00:00Z',
          ),
        ],
      );

      await _openList(tester, backend);

      expect(find.byType(ExperienceListScreen), findsOneWidget);
      expect(find.text('Asisten Dosen PBP'), findsOneWidget);
      expect(find.text('Juara Hackathon'), findsOneWidget);
      expect(find.text('Sedang berlangsung'), findsOneWidget);
      expect(find.text('Selesai 01/10/2026'), findsOneWidget);
      final request = backend.requestsTo('/api/v1/experience/').single;
      expect(request.headers.containsKey('Authorization'), isFalse);
    });

    testWidgets('Bisa dibuka dari drawer', (tester) async {
      final backend = FakeBackend(experiences: [sampleExperience()]);
      await tester.pumpWidget(MyApp(apiClient: backend.apiClient));

      tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Experiences'));
      await tester.pumpAndSettle();

      expect(find.byType(ExperienceListScreen), findsOneWidget);
      expect(find.text('Asisten Dosen PBP'), findsOneWidget);
    });

    testWidgets('Filter kategori dan pencarian', (tester) async {
      final backend = FakeBackend(
        experiences: [
          sampleExperience(),
          sampleExperience(
            id: 'exp-2',
            title: 'Juara Hackathon',
            category: 'competition',
          ),
        ],
      );
      await _openList(tester, backend);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Competition'));
      await tester.pumpAndSettle();
      expect(find.text('Asisten Dosen PBP'), findsNothing);
      expect(find.text('Juara Hackathon'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Semua'));
      await tester.enterText(find.byType(TextField), 'asisten');
      await tester.pumpAndSettle();
      expect(find.text('Asisten Dosen PBP'), findsOneWidget);
      expect(find.text('Juara Hackathon'), findsNothing);
    });

    testWidgets('Daftar kosong menampilkan pesan dan bisa di-refresh', (
      tester,
    ) async {
      final backend = FakeBackend();
      await _openList(tester, backend);
      expect(find.text('Belum ada pengalaman.'), findsOneWidget);

      backend.experiences.add(sampleExperience());
      await tester.fling(
        find.text('Belum ada pengalaman.'),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('Asisten Dosen PBP'), findsOneWidget);
      expect(backend.requestsTo('/api/v1/experience/'), hasLength(2));
    });

    testWidgets('Error menampilkan pesan aman dan tombol Retry', (
      tester,
    ) async {
      final backend = FakeBackend(experiences: [sampleExperience()])
        ..experiencesErrorStatus = 500;

      await _openList(tester, backend);
      expect(find.textContaining('Server sedang bermasalah'), findsOneWidget);
      expect(find.textContaining('<html>'), findsNothing);

      backend.experiencesErrorStatus = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Asisten Dosen PBP'), findsOneWidget);
    });
  });

  group('Detail dan hapus pengalaman', () {
    testWidgets('Detail menampilkan seluruh field', (tester) async {
      final backend = FakeBackend(
        experiences: [
          sampleExperience(
            thumbnail: 'https://example.com/foto.png',
            endedAt: '2026-12-31T10:00:00Z',
          ),
        ],
      );
      await _openList(tester, backend);
      await _openDetail(tester, 'Asisten Dosen PBP');

      expect(find.byType(ExperienceDetailScreen), findsOneWidget);
      expect(find.byKey(const Key('experience-image')), findsOneWidget);
      expect(find.text('Part-Time'), findsOneWidget);
      expect(find.text('20/11/2026'), findsOneWidget);
      expect(find.text('31/12/2026'), findsOneWidget);
      expect(find.text('Selesai'), findsNWidgets(2));
      expect(find.text('3'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Membantu mahasiswa memahami Flutter.'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ExperienceDetailScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('Membantu mahasiswa memahami Flutter.'), findsOneWidget);
    });

    testWidgets('Hapus saat login menghapus entri dan memuat ulang daftar', (
      tester,
    ) async {
      final backend = FakeBackend(
        experiences: [
          sampleExperience(),
          sampleExperience(id: 'exp-2', title: 'Juara Hackathon'),
        ],
      );
      await _openList(tester, backend, token: 'valid-token');
      await _openDetail(tester, 'Asisten Dosen PBP');

      await _tapDelete(tester);
      expect(find.text('Hapus pengalaman?'), findsOneWidget);
      await _confirmDelete(tester);

      final request = backend
          .requestsTo('/api/v1/experience/exp-1/', method: 'DELETE')
          .single;
      expect(request.headers['Authorization'], 'Token valid-token');
      expect(find.byType(ExperienceListScreen), findsOneWidget);
      expect(find.text('Pengalaman dihapus.'), findsOneWidget);
      expect(find.text('Asisten Dosen PBP'), findsNothing);
      expect(find.text('Juara Hackathon'), findsOneWidget);
    });

    testWidgets('Batal di dialog konfirmasi tidak mengirim request', (
      tester,
    ) async {
      final backend = FakeBackend(experiences: [sampleExperience()]);
      await _openList(tester, backend, token: 'valid-token');
      await _openDetail(tester, 'Asisten Dosen PBP');

      await _tapDelete(tester);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(backend.requestsTo('/api/v1/experience/exp-1/'), isEmpty);
      expect(find.byType(ExperienceDetailScreen), findsOneWidget);
    });

    testWidgets('Hapus saat belum login membuka layar login dulu', (
      tester,
    ) async {
      final backend = FakeBackend(experiences: [sampleExperience()]);
      await _openList(tester, backend);
      await _openDetail(tester, 'Asisten Dosen PBP');

      await _tapDelete(tester);
      await _confirmDelete(tester);
      expect(find.byType(LoginScreen), findsOneWidget);

      await _login(tester);
      expect(backend.experiences, isEmpty);
      expect(find.byType(ExperienceListScreen), findsOneWidget);
    });

    testWidgets('Token kedaluwarsa (401) minta login ulang lalu menghapus', (
      tester,
    ) async {
      final backend = FakeBackend(experiences: [sampleExperience()]);
      await _openList(tester, backend, token: 'token-lama');
      await _openDetail(tester, 'Asisten Dosen PBP');

      await _tapDelete(tester);
      await _confirmDelete(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(backend.requestsTo('/api/v1/auth/logout/'), hasLength(1));

      await _login(tester);
      expect(backend.experiences, isEmpty);
      expect(
        backend.requestsTo('/api/v1/experience/exp-1/', method: 'DELETE'),
        hasLength(2),
      );
    });

    testWidgets('Akun tanpa izin (403) melihat SnackBar dan data tetap', (
      tester,
    ) async {
      final backend = FakeBackend(experiences: [sampleExperience()])
        ..deleteErrorStatus = 403;
      await _openList(tester, backend, token: 'valid-token');
      await _openDetail(tester, 'Asisten Dosen PBP');

      await _tapDelete(tester);
      await _confirmDelete(tester);

      expect(find.textContaining('tidak punya izin'), findsOneWidget);
      expect(find.byType(ExperienceDetailScreen), findsOneWidget);
      expect(backend.experiences, hasLength(1));
    });
  });
}
