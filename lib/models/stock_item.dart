import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

class StockItem {
  final String symbol;
  final String companyName;
  final double currentPrice;
  final double changePercent;
  final double changeAmount;
  final bool isPositive;
  final DateTime? lastUpdated;
  final List<YahooFinanceCandleData> candles;

  StockItem({
    required this.symbol,
    required this.companyName,
    required this.currentPrice,
    required this.changePercent,
    required this.changeAmount,
    required this.isPositive,
    this.lastUpdated,
    this.candles = const [],
  });

  StockItem copyWith({
    String? symbol,
    String? companyName,
    double? currentPrice,
    double? changePercent,
    double? changeAmount,
    bool? isPositive,
    DateTime? lastUpdated,
    List<YahooFinanceCandleData>? candles,
  }) {
    return StockItem(
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      currentPrice: currentPrice ?? this.currentPrice,
      changePercent: changePercent ?? this.changePercent,
      changeAmount: changeAmount ?? this.changeAmount,
      isPositive: isPositive ?? this.isPositive,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      candles: candles ?? this.candles,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'companyName': companyName,
        'currentPrice': currentPrice,
        'changePercent': changePercent,
        'changeAmount': changeAmount,
        'isPositive': isPositive,
        'lastUpdated': lastUpdated?.toIso8601String(),
      };

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
        symbol: json['symbol'] ?? '',
        companyName: json['companyName'] ?? '',
        currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
        changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0.0,
        changeAmount: (json['changeAmount'] as num?)?.toDouble() ?? 0.0,
        isPositive: json['isPositive'] ?? true,
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.tryParse(json['lastUpdated'])
            : null,
      );

  /// Calculate Exponential Moving Average (EMA) for period N
  double? calculateEMA(int period) {
    if (candles.length < period) return null;
    final prices = candles.map((c) => c.close).toList();

    final multiplier = 2.0 / (period + 1);

    // Initial SMA seed from the first N prices
    double ema = 0.0;
    for (int i = 0; i < period; i++) {
      ema += prices[i];
    }
    ema /= period;

    // Standard EMA recursive formula iteration
    for (int i = period; i < prices.length; i++) {
      ema = (prices[i] - ema) * multiplier + ema;
    }

    return ema;
  }

  double? get ema9 => calculateEMA(9);
  double? get ema20 => calculateEMA(20);
  double? get ema50 => calculateEMA(50);
  double? get ema100 => calculateEMA(100);
  double? get ema150 => calculateEMA(150);
  double? get ema200 => calculateEMA(200);
}
