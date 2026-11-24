import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

import 'helpers/fake_backend.dart';

void main() {
  test('login menyimpan token dan memberi tahu listener', () async {
    final backend = FakeBackend();
    final auth = AuthState(backend.apiClient);
    var notified = 0;
    auth.addListener(() => notified++);

    await auth.login('owner', FakeBackend.password);

    expect(auth.isLoggedIn, isTrue);
    expect(auth.token, FakeBackend.issuedToken);
    expect(notified, 1);
  });

  test('logout menghapus token walau server menolak token lama', () async {
    final backend = FakeBackend()..validToken = null;
    final auth = AuthState(backend.apiClient, initialToken: 'token-lama');
    var notified = 0;
    auth.addListener(() => notified++);

    await auth.logout();

    expect(auth.isLoggedIn, isFalse);
    expect(notified, 1);
    expect(backend.requestsTo('/api/v1/auth/logout/'), hasLength(1));
  });

  test('logout tidak memanggil server jika belum login', () async {
    final backend = FakeBackend();
    final auth = AuthState(backend.apiClient);

    await auth.logout();

    expect(backend.requests, isEmpty);
  });
}
