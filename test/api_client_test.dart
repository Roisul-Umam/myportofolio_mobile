import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'helpers/fake_backend.dart';

void main() {
  group('Project model', () {
    test('fromJson memetakan snake_case dan mengisi default null', () {
      final project = Project.fromJson({
        ...sampleProject(),
        'link': null,
        'project_image_url': null,
      });

      expect(project.id, 1);
      expect(project.link, '');
      expect(project.projectImageUrl, '');
      expect(project.starCount, 2);
      expect(project.tagList, ['Django', 'Tailwind']);
    });

    test('toJson tidak mengirim field yang dibuat server', () {
      final json = Project.fromJson(sampleProject()).toJson();

      expect(json.keys, [
        'title',
        'description',
        'tags',
        'link',
        'project_image_url',
      ]);
    });
  });

  group('ApiClient', () {
    test('getProjects membaca daftar proyek publik', () async {
      final backend = FakeBackend(
        projects: [sampleProject(title: 'Aplikasi Kasir Ünïcode')],
      );

      final projects = await backend.apiClient.getProjects();

      expect(projects.single.title, 'Aplikasi Kasir Ünïcode');
      final request = backend.requests.single;
      expect(request.url.toString(), 'http://test.local/api/v1/projects/');
      expect(request.headers['Accept'], 'application/json');
      expect(request.headers.containsKey('Authorization'), isFalse);
    });

    test('createProject mengirim token dan body JSON', () async {
      final backend = FakeBackend();
      const project = Project(
        id: 99,
        title: 'Baru',
        description: 'Dari Flutter',
        tags: 'Flutter',
        link: 'https://example.com',
      );

      final created = await backend.apiClient.createProject(
        project,
        token: FakeBackend.issuedToken,
      );

      expect(created.id, 1);
      final request = backend.requests.single;
      expect(request.method, 'POST');
      expect(request.headers['Authorization'], 'Token valid-token');
      expect(request.headers['Content-Type'], contains('application/json'));
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body.containsKey('id'), isFalse);
      expect(body['title'], 'Baru');
    });

    test(
      'obtainToken mengembalikan token dan menolak password salah',
      () async {
        final backend = FakeBackend();

        expect(
          await backend.apiClient.obtainToken('owner', FakeBackend.password),
          FakeBackend.issuedToken,
        );
        await expectLater(
          backend.apiClient.obtainToken('owner', 'salah'),
          throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400),
          ),
        );
      },
    );

    test('logout mengirim header Authorization', () async {
      final backend = FakeBackend();

      await backend.apiClient.logout(token: FakeBackend.issuedToken);

      expect(
        backend.requests.single.headers['Authorization'],
        'Token valid-token',
      );
      expect(backend.validToken, isNull);
    });
  });

  group('ApiException.userMessage', () {
    test('menampilkan pesan validasi pertama dari DRF', () {
      const error = ApiException(400, '{"link": ["Enter a valid URL."]}');
      expect(
        error.userMessage,
        'Data ditolak server: link: Enter a valid URL.',
      );
    });

    test('tidak membocorkan halaman error HTML', () {
      const error = ApiException(500, '<html>Traceback rahasia</html>');
      expect(error.userMessage, isNot(contains('Traceback')));
    });

    test('memberi pesan khusus untuk 401 dan 403', () {
      expect(const ApiException(401, '').userMessage, contains('login ulang'));
      expect(const ApiException(403, '').userMessage, contains('izin'));
    });
  });
}
