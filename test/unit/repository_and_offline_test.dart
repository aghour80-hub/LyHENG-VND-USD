import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lyheng_vnd_usd/data/local/local_database_service.dart';
import 'package:lyheng_vnd_usd/data/local/preferences_service.dart';
import 'package:lyheng_vnd_usd/data/models/exchange_rate.dart';
import 'package:lyheng_vnd_usd/data/repositories/exchange_rate_repository.dart';
import 'package:lyheng_vnd_usd/data/services/connectivity_service.dart';
import 'package:lyheng_vnd_usd/data/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSupabaseService extends Mock implements SupabaseService {}
class MockLocalDatabaseService extends Mock implements LocalDatabaseService {}
class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockSupabaseService mockSupabase;
  late MockLocalDatabaseService mockLocalDb;
  late MockConnectivityService mockConnectivity;
  late StreamController<NetworkStatus> networkStatusController;

  setUpAll(() {
    registerFallbackValue(ExchangeRate.demo());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
    mockSupabase = MockSupabaseService();
    mockLocalDb = MockLocalDatabaseService();
    mockConnectivity = MockConnectivityService();
    networkStatusController = StreamController<NetworkStatus>.broadcast();

    when(() => mockConnectivity.statusStream)
        .thenAnswer((_) => networkStatusController.stream);
    when(() => mockSupabase.subscribeToExchangeRates(any()))
        .thenReturn(null);
    when(() => mockSupabase.unsubscribeExchangeRates())
        .thenReturn(null);
    when(() => mockSupabase.isConfigured).thenReturn(true);
  });

  tearDown(() {
    networkStatusController.close();
  });

  group('ExchangeRateRepository Offline & Cache Tests', () {
    test('Loads cached rate immediately on initialization when available', () async {
      final cachedRate = ExchangeRate(
        id: 'cached-uuid-1',
        buyRate: Decimal.parse('26320'),
        sellRate: Decimal.parse('26520'),
        version: 3,
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        isActive: true,
      );

      when(() => mockLocalDb.getCachedActiveRate())
          .thenAnswer((_) async => cachedRate);
      when(() => mockConnectivity.isConnected())
          .thenAnswer((_) async => false); // Offline

      final repo = ExchangeRateRepository(
        supabaseService: mockSupabase,
        localDb: mockLocalDb,
        connectivity: mockConnectivity,
      );

      await repo.init();

      expect(repo.currentRate.id, equals('cached-uuid-1'));
      expect(repo.currentRate.buyRate, equals(Decimal.parse('26320')));
      expect(repo.currentRate.sellRate, equals(Decimal.parse('26520')));
      expect(repo.currentRate.version, equals(3));
      expect(repo.currentRate.isDemo, isFalse);

      repo.dispose();
    });

    test('Falls back to DEMO rate when no local cache exists', () async {
      when(() => mockLocalDb.getCachedActiveRate())
          .thenAnswer((_) async => null);
      when(() => mockConnectivity.isConnected())
          .thenAnswer((_) async => false);

      final repo = ExchangeRateRepository(
        supabaseService: mockSupabase,
        localDb: mockLocalDb,
        connectivity: mockConnectivity,
      );

      await repo.init();

      expect(repo.currentRate.isDemo, isTrue);
      expect(repo.currentRate.buyRate, equals(Decimal.parse('26300')));
      expect(repo.currentRate.sellRate, equals(Decimal.parse('26500')));
      expect(repo.currentRate.version, equals(0));

      repo.dispose();
    });

    test('Preserves valid cached rate when remote network fetch throws exception', () async {
      final cachedRate = ExchangeRate(
        id: 'cached-safe-id',
        buyRate: Decimal.parse('26310'),
        sellRate: Decimal.parse('26510'),
        version: 2,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        isActive: true,
      );

      when(() => mockLocalDb.getCachedActiveRate())
          .thenAnswer((_) async => cachedRate);
      when(() => mockConnectivity.isConnected())
          .thenAnswer((_) async => true);
      // Simulate network / server crash
      when(() => mockSupabase.fetchActiveRate())
          .thenThrow(Exception('503 Service Unavailable'));

      final repo = ExchangeRateRepository(
        supabaseService: mockSupabase,
        localDb: mockLocalDb,
        connectivity: mockConnectivity,
      );

      await repo.init();
      final refreshed = await repo.refreshActiveRate();

      // Ensure valid cache was NOT wiped or replaced with null/demo
      expect(refreshed.id, equals('cached-safe-id'));
      expect(refreshed.buyRate, equals(Decimal.parse('26310')));
      expect(repo.currentRate.version, equals(2));

      repo.dispose();
    });

    test('Updates cache when higher version rate arrives from remote', () async {
      final cachedRate = ExchangeRate(
        id: 'v1-id',
        buyRate: Decimal.parse('26300'),
        sellRate: Decimal.parse('26500'),
        version: 1,
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
      );

      final remoteNewerRate = ExchangeRate(
        id: 'v2-id',
        buyRate: Decimal.parse('26350'),
        sellRate: Decimal.parse('26550'),
        version: 2,
        updatedAt: DateTime.now(),
        isActive: true,
      );

      when(() => mockLocalDb.getCachedActiveRate())
          .thenAnswer((_) async => cachedRate);
      when(() => mockConnectivity.isConnected())
          .thenAnswer((_) async => true);
      when(() => mockSupabase.fetchActiveRate())
          .thenAnswer((_) async => remoteNewerRate);
      when(() => mockLocalDb.saveActiveRate(any()))
          .thenAnswer((_) async {});

      final repo = ExchangeRateRepository(
        supabaseService: mockSupabase,
        localDb: mockLocalDb,
        connectivity: mockConnectivity,
      );

      await repo.init();
      expect(repo.currentRate.version, equals(2));
      expect(repo.currentRate.buyRate, equals(Decimal.parse('26350')));

      verify(() => mockLocalDb.saveActiveRate(remoteNewerRate)).called(1);

      repo.dispose();
    });
  });
}
