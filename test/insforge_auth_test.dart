import 'package:flutter_test/flutter_test.dart';
import 'package:hela/services/insforge_auth_service.dart';

void main() {
  group('InsForge Auth Models & Service Tests', () {
    test('InsForgeUser parsing from JSON', () {
      final json = {
        'id': 'usr_9823471',
        'email': 'explorer@hela.lk',
        'emailVerified': true,
        'providers': ['email', 'google'],
        'profile': {
          'name': 'Ceylon Adventurer',
          'avatar_url': 'https://example.com/avatar.jpg'
        },
        'metadata': {'tier': 'Gold'}
      };

      final user = InsForgeUser.fromJson(json);

      expect(user.id, equals('usr_9823471'));
      expect(user.email, equals('explorer@hela.lk'));
      expect(user.name, equals('Ceylon Adventurer'));
      expect(user.avatarUrl, equals('https://example.com/avatar.jpg'));
      expect(user.emailVerified, isTrue);
      expect(user.providers, contains('google'));
      expect(user.metadata['tier'], equals('Gold'));
    });

    test('InsForgeAuthResult success and failure helpers', () {
      const user = InsForgeUser(
        id: '123',
        email: 'test@example.com',
        name: 'Tester',
      );

      final successResult = InsForgeAuthResult.success(
        user: user,
        accessToken: 'jwt_token_abc',
        refreshToken: 'refresh_token_xyz',
      );

      expect(successResult.isSuccess, isTrue);
      expect(successResult.user?.name, equals('Tester'));
      expect(successResult.accessToken, equals('jwt_token_abc'));
      expect(successResult.refreshToken, equals('refresh_token_xyz'));

      final failureResult = InsForgeAuthResult.failure('Invalid credentials');
      expect(failureResult.isSuccess, isFalse);
      expect(failureResult.errorMessage, equals('Invalid credentials'));
      expect(failureResult.user, isNull);
    });

    test('InsForgeAuthService singleton endpoints and keys', () {
      final service = InsForgeAuthService.instance;

      expect(InsForgeAuthService.baseUrl, equals('https://tvf24g8r.us-east.insforge.app'));
      expect(InsForgeAuthService.anonKey, isNotEmpty);
      expect(service.currentUser, isNull);
      expect(service.isAuthenticated, isFalse);
    });
  });
}
