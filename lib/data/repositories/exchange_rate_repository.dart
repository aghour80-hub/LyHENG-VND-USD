import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/app_exception.dart';
import '../local/local_database_service.dart';
import '../local/preferences_service.dart';
import '../models/exchange_rate.dart';
import '../models/exchange_rate_history.dart';
import '../services/connectivity_service.dart';
import '../services/supabase_service.dart';

final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  final supabaseService = SupabaseService.instance;
  final localDb = LocalDatabaseService.instance;
  final connectivity = ref.watch(connectivityServiceProvider);
  final repo = ExchangeRateRepository(
    supabaseService: supabaseService,
    localDb: localDb,
    connectivity: connectivity,
  )..init();
  ref.onDispose(() => repo.dispose());
  return repo;
});

final activeExchangeRateStreamProvider = StreamProvider<ExchangeRate>((ref) {
  final repo = ref.watch(exchangeRateRepositoryProvider);
  return repo.activeRateStream;
});

class ExchangeRateRepository {
  final SupabaseService supabaseService;
  final LocalDatabaseService localDb;
  final ConnectivityService connectivity;

  final _activeRateController = StreamController<ExchangeRate>.broadcast();
  ExchangeRate _currentRate = ExchangeRate.demo();
  DateTime? _lastSyncTime;

  ExchangeRateRepository({
    required this.supabaseService,
    required this.localDb,
    required this.connectivity,
  });

  Stream<ExchangeRate> get activeRateStream => _activeRateController.stream;
  ExchangeRate get currentRate => _currentRate;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void> init() async {
    // 1. Instantly load from local SQLite cache if available
    final cached = await localDb.getCachedActiveRate();
    if (cached != null) {
      _currentRate = cached;
      _lastSyncTime = PreferencesService.getLastSyncTimestamp();
      _activeRateController.add(_currentRate);
    } else {
      // Default initial demo rate
      _currentRate = ExchangeRate.demo();
      _activeRateController.add(_currentRate);
    }

    // 2. Fetch fresh rates if connected
    if (await connectivity.isConnected()) {
      await refreshActiveRate();
    }

    // 3. Set up Supabase Realtime synchronization
    supabaseService.subscribeToExchangeRates((newRate) async {
      _currentRate = newRate;
      _lastSyncTime = DateTime.now();
      await localDb.saveActiveRate(newRate);
      await PreferencesService.setLastSyncTimestamp(_lastSyncTime!);
      _activeRateController.add(newRate);
    });

    // 4. Auto-refresh when internet connection is restored
    connectivity.statusStream.listen((status) {
      if (status == NetworkStatus.online) {
        refreshActiveRate();
      }
    });
  }

  /// Manually refresh active rate from backend
  Future<ExchangeRate> refreshActiveRate() async {
    if (!supabaseService.isConfigured) {
      // Return cached or demo rate
      return _currentRate;
    }

    try {
      final remoteRate = await supabaseService.fetchActiveRate();
      if (remoteRate != null) {
        // Prevent concurrent or older versions from replacing newer data
        if (_currentRate.isDemo || remoteRate.version >= _currentRate.version) {
          _currentRate = remoteRate;
          _lastSyncTime = DateTime.now();
          await localDb.saveActiveRate(remoteRate);
          await PreferencesService.setLastSyncTimestamp(_lastSyncTime!);
          _activeRateController.add(remoteRate);
        }
        return _currentRate;
      }
    } catch (_) {
      // Network/DB error: preserve cached data safely
    }
    return _currentRate;
  }

  /// Publish a new exchange rate (Admin operation)
  Future<ExchangeRate> publishNewRate({
    required Decimal buyRate,
    required Decimal sellRate,
  }) async {
    if (!supabaseService.isConfigured) {
      throw const DatabaseExceptionApp(
        'Cannot publish rates: Backend credentials are not configured in config/dev.json.',
      );
    }

    final published = await supabaseService.publishRate(
      buyRate: buyRate,
      sellRate: sellRate,
    );

    _currentRate = published;
    _lastSyncTime = DateTime.now();
    await localDb.saveActiveRate(published);
    await PreferencesService.setLastSyncTimestamp(_lastSyncTime!);
    _activeRateController.add(published);

    return published;
  }

  /// Restore an older exchange rate version (Admin operation)
  Future<ExchangeRate> restoreRate(String historyId) async {
    if (!supabaseService.isConfigured) {
      throw const DatabaseExceptionApp(
        'Cannot restore rates: Backend credentials are not configured.',
      );
    }

    final restored = await supabaseService.restoreRate(historyId);

    _currentRate = restored;
    _lastSyncTime = DateTime.now();
    await localDb.saveActiveRate(restored);
    await PreferencesService.setLastSyncTimestamp(_lastSyncTime!);
    _activeRateController.add(restored);

    return restored;
  }

  /// Fetch rate history
  Future<List<ExchangeRateHistory>> getRateHistory() async {
    if (await connectivity.isConnected() && supabaseService.isConfigured) {
      try {
        final remoteHistory = await supabaseService.fetchRateHistory();
        if (remoteHistory.isNotEmpty) {
          await localDb.saveHistory(remoteHistory);
          return remoteHistory;
        }
      } catch (_) {}
    }

    // Fallback to local cached history
    return await localDb.getCachedHistory();
  }

  void dispose() {
    supabaseService.unsubscribeExchangeRates();
    _activeRateController.close();
  }
}
