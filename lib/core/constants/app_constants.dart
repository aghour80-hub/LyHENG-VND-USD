class AppConstants {
  AppConstants._();

  static const String appName = 'LyHENG VND-USD';
  static const String appVersion = '1.0.0';

  // Currency Codes
  static const String currencyUSD = 'USD';
  static const String currencyVND = 'VND';

  // Default Demo / Fallback Rates (Used strictly when DB is empty/uninitialized)
  // BUY: 26,300 VND | SELL: 26,500 VND
  static const String demoBuyRate = '26300';
  static const String demoSellRate = '26500';

  // Local Storage Keys
  static const String keySelectedLocale = 'lyheng_selected_locale';
  static const String keyThemeMode = 'lyheng_theme_mode';
  static const String keyCachedActiveRate = 'lyheng_cached_active_rate';
  static const String keyCachedRateVersion = 'lyheng_cached_rate_version';
  static const String keyCachedRateTimestamp = 'lyheng_cached_rate_timestamp';
  static const String keyCachedBuyRate = 'lyheng_cached_buy_rate';
  static const String keyCachedSellRate = 'lyheng_cached_sell_rate';
  static const String keyCachedIsDemo = 'lyheng_cached_is_demo';

  // SQLite Database config
  static const String dbName = 'lyheng_vnd_usd.db';
  static const int dbVersion = 1;

  // Supabase Table Names
  static const String tableExchangeRates = 'exchange_rates';
  static const String tableAdminUsers = 'admin_users';
  static const String tableExchangeRateHistory = 'exchange_rate_history';

  // Supported Locales
  static const String localeVietnamese = 'vi';
  static const String localeKhmer = 'km';
  static const String localeEnglish = 'en';
}
