import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../models/exchange_rate.dart';
import '../models/exchange_rate_history.dart';

class LocalDatabaseService {
  static LocalDatabaseService? _instance;
  static Database? _database;

  LocalDatabaseService._();

  static LocalDatabaseService get instance => _instance ??= LocalDatabaseService._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cached_exchange_rate (
            id TEXT PRIMARY KEY,
            buy_rate TEXT NOT NULL,
            sell_rate TEXT NOT NULL,
            currency_base TEXT NOT NULL,
            currency_quote TEXT NOT NULL,
            version INTEGER NOT NULL,
            updated_at TEXT NOT NULL,
            updated_by TEXT,
            is_active INTEGER NOT NULL,
            is_demo INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE cached_rate_history (
            id TEXT PRIMARY KEY,
            buy_rate TEXT NOT NULL,
            sell_rate TEXT NOT NULL,
            version INTEGER NOT NULL,
            updated_by TEXT,
            created_at TEXT NOT NULL,
            action_type TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Save or update the active published rate locally.
  /// Never overwrites valid data with invalid data.
  Future<void> saveActiveRate(ExchangeRate rate) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await txn.delete('cached_exchange_rate');
        await txn.insert(
          'cached_exchange_rate',
          rate.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    } catch (_) {
      // Avoid crashing if local db fails
    }
  }

  /// Get cached active exchange rate, or null if none
  Future<ExchangeRate?> getCachedActiveRate() async {
    try {
      final db = await database;
      final results = await db.query(
        'cached_exchange_rate',
        where: 'is_active = 1',
        limit: 1,
      );

      if (results.isNotEmpty) {
        return ExchangeRate.fromSqlite(results.first);
      }
    } catch (_) {}
    return null;
  }

  /// Save history list locally
  Future<void> saveHistory(List<ExchangeRateHistory> historyList) async {
    try {
      final db = await database;
      final batch = db.batch();
      for (final item in historyList) {
        batch.insert(
          'cached_rate_history',
          item.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (_) {}
  }

  /// Get cached history items
  Future<List<ExchangeRateHistory>> getCachedHistory() async {
    try {
      final db = await database;
      final results = await db.query(
        'cached_rate_history',
        orderBy: 'version DESC, created_at DESC',
      );
      return results.map((m) => ExchangeRateHistory.fromSqlite(m)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Clear all cache (used for testing or explicit reset)
  Future<void> clearCache() async {
    try {
      final db = await database;
      await db.delete('cached_exchange_rate');
      await db.delete('cached_rate_history');
    } catch (_) {}
  }
}
