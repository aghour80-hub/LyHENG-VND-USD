import 'package:decimal/decimal.dart';

class ExchangeRateHistory {
  final String id;
  final Decimal buyRate;
  final Decimal sellRate;
  final int version;
  final String? updatedBy;
  final DateTime createdAt;
  final String actionType;

  const ExchangeRateHistory({
    required this.id,
    required this.buyRate,
    required this.sellRate,
    required this.version,
    this.updatedBy,
    required this.createdAt,
    required this.actionType,
  });

  factory ExchangeRateHistory.fromJson(Map<String, dynamic> json) {
    int parsedVersion = 1;
    if (json['version'] is num) {
      parsedVersion = (json['version'] as num).toInt();
    } else if (json['version'] != null) {
      parsedVersion = int.tryParse(json['version'].toString()) ?? 1;
    }

    return ExchangeRateHistory(
      id: json['id'] as String,
      buyRate: Decimal.parse(json['buy_rate'].toString()),
      sellRate: Decimal.parse(json['sell_rate'].toString()),
      version: parsedVersion,
      updatedBy: json['updated_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      actionType: json['action_type'] as String? ?? 'PUBLISH',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buy_rate': buyRate.toString(),
      'sell_rate': sellRate.toString(),
      'version': version,
      'updated_by': updatedBy,
      'created_at': createdAt.toIso8601String(),
      'action_type': actionType,
    };
  }

  factory ExchangeRateHistory.fromSqlite(Map<String, dynamic> map) {
    return ExchangeRateHistory(
      id: map['id'] as String,
      buyRate: Decimal.parse(map['buy_rate'].toString()),
      sellRate: Decimal.parse(map['sell_rate'].toString()),
      version: (map['version'] as num).toInt(),
      updatedBy: map['updated_by'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      actionType: map['action_type'] as String? ?? 'PUBLISH',
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'buy_rate': buyRate.toString(),
      'sell_rate': sellRate.toString(),
      'version': version,
      'updated_by': updatedBy,
      'created_at': createdAt.toIso8601String(),
      'action_type': actionType,
    };
  }
}
