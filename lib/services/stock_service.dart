import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';
import '../models/stock_item.dart';
import '../models/quarter_observation.dart';

class StockService {
  static const String _storageKey = 'added_stock_symbols';
  final YahooFinanceDailyReader _dailyReader = const YahooFinanceDailyReader();

  static const Map<String, String> companyNames = {
    'RELIANCE.NS': 'Reliance Industries Ltd.',
    'TCS.NS': 'Tata Consultancy Services Ltd.',
    'INFY.NS': 'Infosys Limited',
    'HDFCBANK.NS': 'HDFC Bank Limited',
    'ICICIBANK.NS': 'ICICI Bank Limited',
    'TATAMOTORS.NS': 'Tata Motors Limited',
    'SBIN.NS': 'State Bank of India',
    'BHARTIARTL.NS': 'Bharti Airtel Limited',
    'ITC.NS': 'ITC Limited',
    'LT.NS': 'Larsen & Toubro Limited',
    'WIPRO.NS': 'Wipro Limited',
    'MARUTI.NS': 'Maruti Suzuki India Ltd.',
    'SUNPHARMA.NS': 'Sun Pharmaceutical Industries Ltd.',
    'TITAN.NS': 'Titan Company Limited',
    'AXISBANK.NS': 'Axis Bank Limited',
    'HCLTECH.NS': 'HCL Technologies Limited',
    'ZOMATO.NS': 'Zomato Limited',
    'PAYTM.NS': 'One97 Communications Ltd (Paytm)',
    'JIOFIN.NS': 'Jio Financial Services Ltd.',
    'ASIANPAINT.NS': 'Asian Paints Limited',
    'BAJFINANCE.NS': 'Bajaj Finance Limited',
    'ULTRACEMCO.NS': 'UltraTech Cement Limited',
    'NTPC.NS': 'NTPC Limited',
    'POWERGRID.NS': 'Power Grid Corp of India',
    'ONGC.NS': 'Oil & Natural Gas Corp Ltd',
    'ADANIENT.NS': 'Adani Enterprises Limited',
    'ADANIPORTS.NS': 'Adani Ports & SEZ Ltd',
    'TATASTEEL.NS': 'Tata Steel Limited',
    'HAL.NS': 'Hindustan Aeronautics Limited',
    'BEL.NS': 'Bharat Electronics Limited',
  };

  static const Map<String, String> growwStockSlugs = {
    'RELIANCE': 'reliance-industries-ltd',
    'TCS': 'tata-consultancy-services-ltd',
    'INFY': 'infosys-ltd',
    'HDFCBANK': 'hdfc-bank-ltd',
    'ICICIBANK': 'icici-bank-ltd',
    'TATAMOTORS': 'tata-motors-ltd',
    'SBIN': 'state-bank-of-india',
    'BHARTIARTL': 'bharti-airtel-ltd',
    'ITC': 'itc-ltd',
    'LT': 'larsen-toubro-ltd',
    'WIPRO': 'wipro-ltd',
    'MARUTI': 'maruti-suzuki-india-ltd',
    'SUNPHARMA': 'sun-pharmaceutical-industries-ltd',
    'TITAN': 'titan-company-ltd',
    'AXISBANK': 'axis-bank-ltd',
    'HCLTECH': 'hcl-technologies-ltd',
    'ZOMATO': 'zomato-ltd',
    'PAYTM': 'one97-communications-ltd',
    'JIOFIN': 'jio-financial-services-ltd',
    'ASIANPAINT': 'asian-paints-ltd',
    'BAJFINANCE': 'bajaj-finance-ltd',
    'ULTRACEMCO': 'ultratech-cement-ltd',
    'NTPC': 'ntpc-ltd',
    'POWERGRID': 'power-grid-corporation-of-india-ltd',
    'ONGC': 'oil-natural-gas-corporation-ltd',
    'ADANIENT': 'adani-enterprises-ltd',
    'ADANIPORTS': 'adani-ports-and-special-economic-zone-ltd',
    'TATASTEEL': 'tata-steel-ltd',
    'HAL': 'hindustan-aeronautics-ltd',
    'BEL': 'bharat-electronics-ltd',
  };

  /// Get exact Groww stock URL slug for deep linking directly to stock detail page
  static String getGrowwSlug(String symbol, [String? companyName]) {
    final cleanSym = getDisplaySymbol(normalizeSymbol(symbol)).toUpperCase();
    if (growwStockSlugs.containsKey(cleanSym)) {
      return growwStockSlugs[cleanSym]!;
    }
    if (companyName != null && companyName.isNotEmpty) {
      String slug = companyName.toLowerCase();
      slug = slug.replaceAll(RegExp(r'[^a-z0-9\s-]'), '');
      slug = slug.replaceAll(RegExp(r'\s+'), '-');
      if (slug.endsWith('-limited')) {
        slug = '${slug.substring(0, slug.length - 8)}-ltd';
      }
      if (slug.isNotEmpty) return slug;
    }
    return cleanSym.toLowerCase();
  }

  /// Normalize user symbol (e.g., RELIANCE -> RELIANCE.NS)
  static String normalizeSymbol(String rawSymbol) {
    String clean = rawSymbol.trim().toUpperCase();
    if (clean.isEmpty) return clean;
    if (!clean.contains('.')) {
      clean = '$clean.NS';
    }
    return clean;
  }

  /// Get reasons to buy for a specific stock symbol
  Future<List<String>> getReasonsForStock(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanSymbol = getDisplaySymbol(normalizeSymbol(symbol));
    final List<String>? reasons = prefs.getStringList('reasons_$cleanSymbol');
    return reasons ?? [];
  }

  /// Save reasons to buy for a specific stock symbol
  Future<void> saveReasonsForStock(String symbol, List<String> reasons) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanSymbol = getDisplaySymbol(normalizeSymbol(symbol));
    await prefs.setStringList('reasons_$cleanSymbol', reasons);
  }

  /// Add a new reason point for a stock
  Future<List<String>> addReasonForStock(String symbol, String reason) async {
    final cleanText = reason.trim();
    if (cleanText.isEmpty) return await getReasonsForStock(symbol);

    final reasons = await getReasonsForStock(symbol);
    reasons.add(cleanText);
    await saveReasonsForStock(symbol, reasons);
    return reasons;
  }

  /// Remove a reason point by index for a stock
  Future<List<String>> removeReasonForStock(String symbol, int index) async {
    final reasons = await getReasonsForStock(symbol);
    if (index >= 0 && index < reasons.length) {
      reasons.removeAt(index);
      await saveReasonsForStock(symbol, reasons);
    }
    return reasons;
  }

  /// Get personal notes for a specific stock symbol
  Future<List<String>> getNotesForStock(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanSymbol = getDisplaySymbol(normalizeSymbol(symbol));
    final List<String>? notes = prefs.getStringList('notes_$cleanSymbol');
    return notes ?? [];
  }

  /// Save personal notes for a specific stock symbol
  Future<void> saveNotesForStock(String symbol, List<String> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanSymbol = getDisplaySymbol(normalizeSymbol(symbol));
    await prefs.setStringList('notes_$cleanSymbol', notes);
  }

  /// Add a new personal note for a stock
  Future<List<String>> addNoteForStock(String symbol, String note) async {
    final cleanText = note.trim();
    if (cleanText.isEmpty) return await getNotesForStock(symbol);

    final notes = await getNotesForStock(symbol);
    notes.add(cleanText);
    await saveNotesForStock(symbol, notes);
    return notes;
  }

  /// Remove a personal note by index for a stock
  Future<List<String>> removeNoteForStock(String symbol, int index) async {
    final notes = await getNotesForStock(symbol);
    if (index >= 0 && index < notes.length) {
      notes.removeAt(index);
      await saveNotesForStock(symbol, notes);
    }
    return notes;
  }

  /// Get quarterly observations for a stock symbol
  Future<List<QuarterObservation>> getQuarterlyObservations(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanSymbol = getDisplaySymbol(normalizeSymbol(symbol));
    final String? jsonStr = prefs.getString('quarterly_obs_$cleanSymbol');
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      return QuarterObservation.decodeList(jsonStr);
    } catch (_) {
      return [];
    }
  }

  /// Save quarterly observations for a stock symbol
  Future<void> saveQuarterlyObservations(String symbol, List<QuarterObservation> list) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanSymbol = getDisplaySymbol(normalizeSymbol(symbol));
    await prefs.setString('quarterly_obs_$cleanSymbol', QuarterObservation.encodeList(list));
  }

  /// Add a new quarterly observation for a stock
  Future<List<QuarterObservation>> addQuarterlyObservation(
    String symbol,
    String quarterTitle,
    String content,
  ) async {
    final cleanTitle = quarterTitle.trim();
    final cleanContent = content.trim();
    if (cleanTitle.isEmpty && cleanContent.isEmpty) {
      return await getQuarterlyObservations(symbol);
    }

    final list = await getQuarterlyObservations(symbol);
    final now = DateTime.now();
    final dateStr = '${now.day} ${_getMonthName(now.month)} ${now.year}';

    final newItem = QuarterObservation(
      id: now.millisecondsSinceEpoch.toString(),
      quarterTitle: cleanTitle.isEmpty ? 'Quarterly Result' : cleanTitle,
      content: cleanContent,
      date: dateStr,
    );

    list.insert(0, newItem); // Put latest quarter on top
    await saveQuarterlyObservations(symbol, list);
    return list;
  }

  /// Remove a quarterly observation by ID for a stock
  Future<List<QuarterObservation>> removeQuarterlyObservation(String symbol, String id) async {
    final list = await getQuarterlyObservations(symbol);
    list.removeWhere((item) => item.id == id);
    await saveQuarterlyObservations(symbol, list);
    return list;
  }

  static String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  /// Get display symbol without extension for clean UI (e.g. RELIANCE.NS -> RELIANCE)
  static String getDisplaySymbol(String symbol) {
    if (symbol.endsWith('.NS')) {
      return symbol.substring(0, symbol.length - 3);
    } else if (symbol.endsWith('.BO')) {
      return symbol.substring(0, symbol.length - 3);
    }
    return symbol;
  }

  /// Retrieve list of saved stock tickers from SharedPreferences
  Future<List<String>> getSavedSymbols() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? symbols = prefs.getStringList(_storageKey);
    if (symbols == null) {
      return [];
    }
    return symbols;
  }

  /// Save stock tickers list to SharedPreferences
  Future<void> saveSymbols(List<String> symbols) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, symbols);
  }

  /// Add a new symbol to saved list
  Future<bool> addSymbol(String symbol) async {
    final symbolToSave = normalizeSymbol(symbol);
    if (symbolToSave.isEmpty) return false;

    final symbols = await getSavedSymbols();
    if (!symbols.contains(symbolToSave)) {
      symbols.add(symbolToSave);
      await saveSymbols(symbols);
    }
    return true;
  }

  /// Remove a symbol from saved list
  Future<void> removeSymbol(String symbol) async {
    final symbolToRemove = normalizeSymbol(symbol);
    final symbols = await getSavedSymbols();
    symbols.remove(symbolToRemove);
    await saveSymbols(symbols);
  }

  /// Reset / Clear all saved symbols
  Future<void> clearAllSymbols() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Fetch single Indian stock data from Yahoo Finance API using yahoo_finance_data_reader
  Future<StockItem> fetchStockData(String symbol) async {
    final formattedSymbol = normalizeSymbol(symbol);
    final displaySymbol = getDisplaySymbol(formattedSymbol);
    final String name = companyNames[formattedSymbol] ?? '$displaySymbol Ltd.';

    _log('==================================================');
    _log('🚀 [YahooFinance] Initiating API request for Indian stock: $formattedSymbol');

    try {
      final Map<String, dynamic> rawData = await _dailyReader.getDailyData(formattedSymbol);

      _log('📦 [YahooFinance] Raw Response Received for $formattedSymbol:');
      _log('   Keys: ${rawData.keys.toList()}');

      final YahooFinanceResponse response = YahooFinanceResponse.fromJson(rawData);
      final candles = response.candlesData;

      _log('📊 [YahooFinance] Parsed ${candles.length} candle records for $formattedSymbol.');

      if (candles.isEmpty) {
        throw Exception('No market data returned for $formattedSymbol');
      }

      final YahooFinanceCandleData latestCandle = candles.last;
      double currentPrice = latestCandle.close;

      // Find previous close candle
      double prevClose = currentPrice;
      if (candles.length > 1) {
        prevClose = candles[candles.length - 2].close;
      }

      double changeAmount = currentPrice - prevClose;
      double changePercent = prevClose != 0 ? (changeAmount / prevClose) * 100 : 0.0;
      bool isPositive = changeAmount >= 0;

      _log('📈 [YahooFinance] Latest Candle Details for $formattedSymbol (₹):');
      _log('   Date: ${latestCandle.date}');
      _log('   Close Price: ₹${currentPrice.toStringAsFixed(2)}');
      _log('   Open Price:  ₹${latestCandle.open.toStringAsFixed(2)}');
      _log('   High Price:  ₹${latestCandle.high.toStringAsFixed(2)}');
      _log('   Low Price:   ₹${latestCandle.low.toStringAsFixed(2)}');
      _log('   Volume:      ${latestCandle.volume}');
      _log('   Prev Close:  ₹${prevClose.toStringAsFixed(2)}');
      _log('   Day Change:  ${isPositive ? "+" : ""}₹${changeAmount.abs().toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')} (${isPositive ? "+" : ""}${changePercent.abs().toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}%)');
      _log('==================================================');

      final stockItem = StockItem(
        symbol: displaySymbol,
        companyName: name,
        currentPrice: currentPrice,
        changePercent: changePercent,
        changeAmount: changeAmount,
        isPositive: isPositive,
        lastUpdated: DateTime.now(),
        candles: candles,
      );

      await cacheStockItem(stockItem);
      return stockItem;
    } catch (e, stackTrace) {
      _log('⚠️ [YahooFinance Error] Failed to fetch live data for $formattedSymbol: $e');
      _log('   StackTrace: $stackTrace');
      _log('🔄 [YahooFinance Fallback] Using fallback INR data for $formattedSymbol.');
      _log('==================================================');

      final cached = await getCachedStockItem(displaySymbol);
      if (cached != null) {
        return cached;
      }

      final fallbackPrice = _getMockPrice(displaySymbol);
      final fallbackChange = _getMockChange(displaySymbol);
      final fallbackItem = StockItem(
        symbol: displaySymbol,
        companyName: name,
        currentPrice: fallbackPrice,
        changePercent: fallbackChange,
        changeAmount: (fallbackPrice * fallbackChange / 100),
        isPositive: fallbackChange >= 0,
        lastUpdated: DateTime.now(),
        candles: [],
      );

      await cacheStockItem(fallbackItem);
      return fallbackItem;
    }
  }

  /// Cache a stock item to persistent storage
  Future<void> cacheStockItem(StockItem stock) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanSymbol = getDisplaySymbol(normalizeSymbol(stock.symbol));
    await prefs.setString('cached_stock_$cleanSymbol', json.encode(stock.toJson()));
  }

  /// Retrieve cached stock item from persistent storage
  Future<StockItem?> getCachedStockItem(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanSymbol = getDisplaySymbol(normalizeSymbol(symbol));
    final String? jsonStr = prefs.getString('cached_stock_$cleanSymbol');
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final Map<String, dynamic> map = json.decode(jsonStr);
      return StockItem.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  void _log(String message) {
    developer.log(message, name: 'YahooFinance');
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Helper Indian mock values in Rupees (₹)
  double _getMockPrice(String symbol) {
    switch (symbol) {
      case 'RELIANCE':
        return 1334.80;
      case 'TCS':
        return 4185.50;
      case 'INFY':
        return 1820.25;
      case 'TATAMOTORS':
        return 1015.40;
      case 'HDFCBANK':
        return 1640.90;
      case 'ICICIBANK':
        return 1210.60;
      case 'SBIN':
        return 845.30;
      case 'ZOMATO':
        return 265.10;
      default:
        return 1250.00;
    }
  }

  double _getMockChange(String symbol) {
    switch (symbol) {
      case 'RELIANCE':
        return 0.74;
      case 'TCS':
        return 1.45;
      case 'INFY':
        return -0.65;
      case 'TATAMOTORS':
        return 2.30;
      case 'HDFCBANK':
        return 0.85;
      case 'ICICIBANK':
        return 1.12;
      case 'SBIN':
        return -0.40;
      case 'ZOMATO':
        return 3.10;
      default:
        return 0.80;
    }
  }
}
