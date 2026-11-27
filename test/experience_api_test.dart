import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'helpers/fake_backend.dart';

void main() {
  group('Experience model', () {
    test('fromJson membaca field server dan mengisi default null', () {
      final experience = Experience.fromJson(sampleExperience());

      expect(experience.id, 'exp-1');
      expect(experience.categoryDisplay, 'Part-Time');
      expect(experience.thumbnail, '');
      expect(experience.startedAt, DateTime.utc(2026, 11, 20, 3));
      expect(experience.endedAt, isNull);
      expect(experience.isOngoing, isTrue);
      expect(experience.starCount, 3);
    });

    test('toJson hanya mengirim field yang boleh ditulis', () {
      final json = Experience(
        id: 'tidak-dikirim',
        title: 'Magang',
        description: 'Data pipeline',
        category: 'internship',
        endedAt: DateTime.utc(2026, 12, 31, 16, 59, 59),
      ).toJson();

      expect(json, {
        'title': 'Magang',
        'description': 'Data pipeline',
        'category': 'internship',
        'thumbnail': '',
        'ended_at': '2026-12-31T16:59:59.000Z',
      });
    });

    test('kategori default sama dengan model Django', () {
      const experience = Experience(title: 'a', description: 'b');
      expect(experience.category, 'full-time');
    });
  });

  group('ApiClient Experience', () {
    test('getExperiences publik tanpa header Authorization', () async {
      final backend = FakeBackend(experiences: [sampleExperience()]);

      final experiences = await backend.apiClient.getExperiences();

      expect(experiences.single.title, 'Asisten Dosen PBP');
      final request = backend.requests.single;
      expect(request.url.path, '/api/v1/experience/');
      expect(request.headers.containsKey('Authorization'), isFalse);
    });

    test('createExperience mengirim token dan body JSON', () async {
      final backend = FakeBackend();

      final created = await backend.apiClient.createExperience(
        const Experience(
          title: 'Magang',
          description: 'Data',
          category: 'research',
        ),
        token: FakeBackend.issuedToken,
      );

      expect(created.id, 'exp-1');
      expect(created.categoryDisplay, 'Research');
      final request = backend.requests.single;
      expect(request.method, 'POST');
      expect(request.headers['Authorization'], 'Token valid-token');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body.containsKey('id'), isFalse);
      expect(body.containsKey('started_at'), isFalse);
    });

    test('deleteExperience memanggil URL detail dengan token', () async {
      final backend = FakeBackend(experiences: [sampleExperience()]);

      await backend.apiClient.deleteExperience(
        'exp-1',
        token: FakeBackend.issuedToken,
      );

      final request = backend.requests.single;
      expect(request.method, 'DELETE');
      expect(request.url.path, '/api/v1/experience/exp-1/');
      expect(request.headers['Authorization'], 'Token valid-token');
      expect(backend.experiences, isEmpty);
    });

    test('status non-2xx dilempar sebagai ApiException', () async {
      final backend = FakeBackend(experiences: [sampleExperience()])
        ..deleteErrorStatus = 403;

      await expectLater(
        backend.apiClient.deleteExperience(
          'exp-1',
          token: FakeBackend.issuedToken,
        ),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403),
        ),
      );
      await expectLater(
        backend.apiClient.createExperience(
          const Experience(title: 'a', description: 'b'),
          token: 'token-salah',
        ),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });
  });
}
