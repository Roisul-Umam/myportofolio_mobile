import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/config.dart';

void main() {
  test('emulator Android memakai 10.0.2.2', () {
    expect(
      resolveApiBaseUrl(isWeb: false, platform: TargetPlatform.android),
      'http://10.0.2.2:8000',
    );
  });

  test('web memakai localhost, termasuk Chrome di HP Android', () {
    for (final platform in TargetPlatform.values) {
      expect(
        resolveApiBaseUrl(isWeb: true, platform: platform),
        'http://localhost:8000',
        reason: '$platform',
      );
    }
  });

  test('desktop dan simulator iOS memakai localhost', () {
    for (final platform in [
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
      TargetPlatform.iOS,
    ]) {
      expect(
        resolveApiBaseUrl(isWeb: false, platform: platform),
        'http://localhost:8000',
      );
    }
  });

  test('--dart-define API_BASE_URL selalu menang', () {
    expect(
      resolveApiBaseUrl(
        isWeb: false,
        platform: TargetPlatform.android,
        override: 'http://192.168.1.5:8000',
      ),
      'http://192.168.1.5:8000',
    );
  });
}
