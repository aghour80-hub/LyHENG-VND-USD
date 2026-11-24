import 'package:decimal/decimal.dart';
import '../../core/constants/app_constants.dart';

class ExchangeRate {
  final String id;
  final Decimal buyRate;
  final Decimal sellRate;
  final String currencyBase;
  final String currencyQuote;
  final int version;
  final DateTime updatedAt;
  final String? updatedBy;
  final bool isActive;
  final bool isDemo;

  const ExchangeRate({
    required this.id,
    required this.buyRate,
    required this.sellRate,
    this.currencyBase = AppConstants.currencyUSD,
    this.currencyQuote = AppConstants.currencyVND,
    required this.version,
    required this.updatedAt,
    this.updatedBy,
    this.isActive = true,
    this.isDemo = false,
  });

  /// Factory creating default DEMO rates when no backend rate has been published
  factory ExchangeRate.demo() {
    return ExchangeRate(
      id: 'demo-rate-id',
      buyRate: Decimal.parse(AppConstants.demoBuyRate),
      sellRate: Decimal.parse(AppConstants.demoSellRate),
      version: 0,
      updatedAt: DateTime.now(),
      isActive: true,
      isDemo: true,
    );
  }

  factory ExchangeRate.fromJson(Map<String, dynamic> json, {bool isDemo = false}) {
    final rawActive = json['is_active'];
    final bool parsedActive = rawActive is bool
        ? rawActive
        : (rawActive == 1 || rawActive == 'true' || rawActive == null);

    final rawDemo = json['is_demo'];
    final bool parsedDemo = isDemo ||
        (rawDemo is bool ? rawDemo : (rawDemo == 1 || rawDemo == 'true'));

    int parsedVersion = 1;
    if (json['version'] is num) {
      parsedVersion = (json['version'] as num).toInt();
    } else if (json['version'] != null) {
      parsedVersion = int.tryParse(json['version'].toString()) ?? 1;
    }

    return ExchangeRate(
      id: json['id'] as String? ?? 'rate-unknown',
      buyRate: Decimal.parse(json['buy_rate'].toString()),
      sellRate: Decimal.parse(json['sell_rate'].toString()),
      currencyBase: json['currency_base'] as String? ?? AppConstants.currencyUSD,
      currencyQuote: json['currency_quote'] as String? ?? AppConstants.currencyVND,
      version: parsedVersion,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : DateTime.now(),
      updatedBy: json['updated_by'] as String?,
      isActive: parsedActive,
      isDemo: parsedDemo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buy_rate': buyRate.toString(),
      'sell_rate': sellRate.toString(),
      'currency_base': currencyBase,
      'currency_quote': currencyQuote,
      'version': version,
      'updated_at': updatedAt.toIso8601String(),
      'updated_by': updatedBy,
      'is_active': isActive,
      'is_demo': isDemo,
    };
  }

  factory ExchangeRate.fromSqlite(Map<String, dynamic> map) {
    return ExchangeRate(
      id: map['id'] as String,
      buyRate: Decimal.parse(map['buy_rate'].toString()),
      sellRate: Decimal.parse(map['sell_rate'].toString()),
      currencyBase: map['currency_base'] as String? ?? AppConstants.currencyUSD,
      currencyQuote: map['currency_quote'] as String? ?? AppConstants.currencyVND,
      version: (map['version'] as num).toInt(),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      updatedBy: map['updated_by'] as String?,
      isActive: (map['is_active'] as int) == 1,
      isDemo: (map['is_demo'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'buy_rate': buyRate.toString(),
      'sell_rate': sellRate.toString(),
      'currency_base': currencyBase,
      'currency_quote': currencyQuote,
      'version': version,
      'updated_at': updatedAt.toIso8601String(),
      'updated_by': updatedBy,
      'is_active': isActive ? 1 : 0,
      'is_demo': isDemo ? 1 : 0,
    };
  }

  ExchangeRate copyWith({
    String? id,
    Decimal? buyRate,
    Decimal? sellRate,
    String? currencyBase,
    String? currencyQuote,
    int? version,
    DateTime? updatedAt,
    String? updatedBy,
    bool? isActive,
    bool? isDemo,
  }) {
    return ExchangeRate(
      id: id ?? this.id,
      buyRate: buyRate ?? this.buyRate,
      sellRate: sellRate ?? this.sellRate,
      currencyBase: currencyBase ?? this.currencyBase,
      currencyQuote: currencyQuote ?? this.currencyQuote,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      isActive: isActive ?? this.isActive,
      isDemo: isDemo ?? this.isDemo,
    );
  }
}
