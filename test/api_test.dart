import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_track/services/stock_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('test Indian stock RELIANCE.NS fetch', () async {
    SharedPreferences.setMockInitialValues({});
    final stockService = StockService();
    final stock = await stockService.fetchStockData('RELIANCE.NS');

    expect(stock.symbol, contains('RELIANCE'));
    expect(stock.currentPrice, greaterThan(0));
  });
}
