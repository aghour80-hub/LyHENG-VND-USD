import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lyheng_vnd_usd/data/repositories/auth_repository.dart';
import 'package:lyheng_vnd_usd/data/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseService extends Mock implements SupabaseService {}
class MockUser extends Mock implements User {}
class MockAuthResponse extends Mock implements AuthResponse {}

void main() {
  late MockSupabaseService mockSupabase;

  setUp(() {
    mockSupabase = MockSupabaseService();
  });

  group('AuthRepository Security & Access Control Tests', () {
    test('Default initial state is unauthenticated and non-admin', () {
      when(() => mockSupabase.isConfigured).thenReturn(false);
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith(
            () => AuthRepository(),
          ),
        ],
      );

      final state = container.read(authRepositoryProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.isAuthorizedAdmin, isFalse);
      expect(state.userId, isNull);
      expect(state.userEmail, isNull);

      container.dispose();
    });

    test('Non-admin credentials are systematically rejected with UnauthorizedException', () async {
      when(() => mockSupabase.isConfigured).thenReturn(true);
      when(() => mockSupabase.currentAuthUser).thenReturn(null);

      final regularUser = MockUser();
      when(() => regularUser.id).thenReturn('regular-user-uuid');
      when(() => regularUser.email).thenReturn('customer@gmail.com');

      final authResponse = MockAuthResponse();
      when(() => authResponse.user).thenReturn(regularUser);

      when(() => mockSupabase.signInWithEmailPassword(
            email: 'customer@gmail.com',
            password: 'Password123!',
          )).thenAnswer((_) async => authResponse);

      // Backend security check returns FALSE (user is not an admin)
      when(() => mockSupabase.verifyAdminStatus('regular-user-uuid'))
          .thenAnswer((_) async => false);
      when(() => mockSupabase.signOut()).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith(
            () => AuthRepository(mockSupabase),
          ),
        ],
      );
      final notifier = container.read(authRepositoryProvider.notifier);

      final success = await notifier.signIn(
        email: 'customer@gmail.com',
        password: 'Password123!',
      );

      expect(success, isFalse);
      final state = container.read(authRepositoryProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.isAuthorizedAdmin, isFalse);
      expect(state.errorMessage, contains('Access denied'));

      // Verify that the unauthorized session was immediately killed
      verify(() => mockSupabase.signOut()).called(1);

      container.dispose();
    });

    test('Authorized admin credentials grant authenticated admin access', () async {
      when(() => mockSupabase.isConfigured).thenReturn(true);
      when(() => mockSupabase.currentAuthUser).thenReturn(null);

      final adminUser = MockUser();
      when(() => adminUser.id).thenReturn('admin-uuid-123');
      when(() => adminUser.email).thenReturn('admin@lyheng.com');

      final authResponse = MockAuthResponse();
      when(() => authResponse.user).thenReturn(adminUser);

      when(() => mockSupabase.signInWithEmailPassword(
            email: 'admin@lyheng.com',
            password: 'AdminPassword123!',
          )).thenAnswer((_) async => authResponse);

      // Backend security check returns TRUE
      when(() => mockSupabase.verifyAdminStatus('admin-uuid-123'))
          .thenAnswer((_) async => true);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith(
            () => AuthRepository(mockSupabase),
          ),
        ],
      );
      final notifier = container.read(authRepositoryProvider.notifier);

      final success = await notifier.signIn(
        email: 'admin@lyheng.com',
        password: 'AdminPassword123!',
      );

      expect(success, isTrue);
      final state = container.read(authRepositoryProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.isAuthorizedAdmin, isTrue);
      expect(state.userId, equals('admin-uuid-123'));
      expect(state.userEmail, equals('admin@lyheng.com'));

      // Logout test
      when(() => mockSupabase.signOut()).thenAnswer((_) async {});
      await notifier.signOut();

      final loggedOutState = container.read(authRepositoryProvider);
      expect(loggedOutState.isAuthenticated, isFalse);
      expect(loggedOutState.isAuthorizedAdmin, isFalse);

      container.dispose();
    });
  });
}
