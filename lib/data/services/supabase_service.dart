import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/exchange_rate.dart';
import '../models/exchange_rate_history.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static bool _initialized = false;
  static bool _isDemoFallback = false;

  SupabaseClient? _client;
  RealtimeChannel? _ratesChannel;
  final _rateUpdatesController = StreamController<ExchangeRate>.broadcast();

  SupabaseService._();

  static SupabaseService get instance => _instance ??= SupabaseService._();

  Stream<ExchangeRate> get rateUpdatesStream => _rateUpdatesController.stream;

  bool get isConfigured => _initialized && !_isDemoFallback && _client != null;
  bool get isDemoFallback => _isDemoFallback;

  SupabaseClient? get client => _client;

  /// Initializes Supabase safely with environment variables or fallback
  static Future<void> initialize() async {
    const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const anonKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY', defaultValue: '');

    // Check if configuration is missing or placeholder
    if (url.isEmpty || 
        anonKey.isEmpty || 
        url.contains('placeholder') || 
        url.contains('YOUR_PROJECT_ID')) {
      _isDemoFallback = true;
      _initialized = true;
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        publishableKey: anonKey,
        realtimeClientOptions: const RealtimeClientOptions(
          eventsPerSecond: 10,
        ),
      );
      instance._client = Supabase.instance.client;
      _isDemoFallback = false;
      _initialized = true;
    } catch (e) {
      // In case of network initialization failure, fallback gracefully
      _isDemoFallback = true;
      _initialized = true;
    }
  }

  /// Sets up a resilient Realtime subscription on public.exchange_rates
  void subscribeToExchangeRates(void Function(ExchangeRate) onUpdate) {
    if (!isConfigured || _client == null) return;

    // Remove existing subscription if present to avoid duplicate listeners
    unsubscribeExchangeRates();

    try {
      _ratesChannel = _client!
          .channel('public:exchange_rates')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: AppConstants.tableExchangeRates,
            callback: (payload) {
              final newRecord = payload.newRecord;
              if (newRecord.isNotEmpty && newRecord['is_active'] == true) {
                try {
                  final rate = ExchangeRate.fromJson(newRecord);
                  _rateUpdatesController.add(rate);
                  onUpdate(rate);
                } catch (_) {}
              }
            },
          )
          .subscribe();
    } catch (_) {
      // Realtime subscription error handled gracefully
    }
  }

  void unsubscribeExchangeRates() {
    if (_ratesChannel != null && _client != null) {
      try {
        _client!.removeChannel(_ratesChannel!);
      } catch (_) {}
      _ratesChannel = null;
    }
  }

  /// Fetch active published rate from Supabase
  Future<ExchangeRate?> fetchActiveRate() async {
    if (!isConfigured || _client == null) {
      return null;
    }

    try {
      final response = await _client!
          .from(AppConstants.tableExchangeRates)
          .select()
          .eq('is_active', true)
          .maybeSingle();

      if (response != null) {
        return ExchangeRate.fromJson(response);
      }
    } catch (e) {
      throw DatabaseExceptionApp('Failed to fetch active rate: $e');
    }
    return null;
  }

  /// Fetch rate history from Supabase (Admins only)
  Future<List<ExchangeRateHistory>> fetchRateHistory() async {
    if (!isConfigured || _client == null) {
      return [];
    }

    try {
      final response = await _client!
          .from(AppConstants.tableExchangeRateHistory)
          .select()
          .order('version', ascending: false)
          .limit(50);

      return (response as List<dynamic>)
          .map((item) => ExchangeRateHistory.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DatabaseExceptionApp('Failed to fetch history: $e');
    }
  }

  /// Publish a new rate atomically via PostgreSQL RPC function
  Future<ExchangeRate> publishRate({
    required Decimal buyRate,
    required Decimal sellRate,
  }) async {
    if (!isConfigured || _client == null) {
      throw const DatabaseExceptionApp('Backend is not configured.');
    }

    try {
      final response = await _client!.rpc(
        'publish_exchange_rate',
        params: {
          'p_buy_rate': double.parse(buyRate.toString()),
          'p_sell_rate': double.parse(sellRate.toString()),
        },
      );

      if (response != null && response is Map<String, dynamic>) {
        return ExchangeRate.fromJson(response);
      } else {
        throw const DatabaseExceptionApp('Invalid response from publish_exchange_rate RPC.');
      }
    } catch (e) {
      throw DatabaseExceptionApp('Publish rate failed: $e');
    }
  }

  /// Restore an older rate atomically via PostgreSQL RPC function
  Future<ExchangeRate> restoreRate(String historyId) async {
    if (!isConfigured || _client == null) {
      throw const DatabaseExceptionApp('Backend is not configured.');
    }

    try {
      final response = await _client!.rpc(
        'restore_exchange_rate',
        params: {'p_history_id': historyId},
      );

      if (response != null && response is Map<String, dynamic>) {
        return ExchangeRate.fromJson(response);
      } else {
        throw const DatabaseExceptionApp('Invalid response from restore_exchange_rate RPC.');
      }
    } catch (e) {
      throw DatabaseExceptionApp('Restore rate failed: $e');
    }
  }

  /// Verifies whether the authenticated user has Admin role
  Future<bool> verifyAdminStatus(String userId) async {
    if (!isConfigured || _client == null) {
      return false;
    }

    try {
      final response = await _client!.rpc(
        'is_authorized_admin',
        params: {'p_user_id': userId},
      );
      return response == true;
    } catch (_) {
      return false;
    }
  }

  /// Admin authentication
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (!isConfigured || _client == null) {
      throw const AuthExceptionApp('Supabase backend is unconfigured. Please provide valid SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY.');
    }

    try {
      return await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthExceptionApp(e.message, code: e.statusCode);
    } catch (e) {
      throw AuthExceptionApp('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    if (_client != null) {
      try {
        await _client!.auth.signOut();
      } catch (_) {}
    }
  }

  User? get currentAuthUser => _client?.auth.currentUser;
}
