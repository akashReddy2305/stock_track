import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/stock_item.dart';
import '../services/stock_service.dart';
import '../widgets/reasons_to_buy_card.dart';
import '../widgets/notes_card.dart';
import '../widgets/quarterly_results_card.dart';

class StockDetailScreen extends StatelessWidget {
  final StockItem stock;

  const StockDetailScreen({
    super.key,
    required this.stock,
  });

  String _formatTwoDecimals(double val) {
    return val.abs().toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  Future<void> _openGrowwApp(BuildContext context, StockItem stockItem) async {
    final List<String> urlCandidates = StockService.getGrowwUrlCandidates(
      stockItem.symbol,
      stockItem.companyName,
    );

    for (final urlStr in urlCandidates) {
      try {
        final Uri uri = Uri.parse(urlStr);
        if (await canLaunchUrl(uri)) {
          final bool launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) return;
        }
      } catch (_) {}
    }

    try {
      final cleanSymbol = StockService.getDisplaySymbol(stockItem.symbol);
      final Uri fallbackUri = Uri.parse('https://groww.in/search?q=$cleanSymbol');
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open Groww for ${stockItem.companyName}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice = '₹${stock.currentPrice.toStringAsFixed(2)}';
    final isPos = stock.isPositive;
    final formattedChange =
        '${isPos ? '+' : ''}₹${_formatTwoDecimals(stock.changeAmount)} (${isPos ? '+' : ''}${_formatTwoDecimals(stock.changePercent)}%)';
    final changeColor = isPos ? const Color(0xFF1E8E3E) : const Color(0xFFD93025);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1E24), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              stock.symbol,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E24),
              ),
            ),
            Text(
              stock.companyName,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price & Day Change Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8ECEF)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT PRICE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        formattedPrice,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E24),
                          letterSpacing: -0.5,
                        ),
                      ),

                      // Tappable Groww Logo Image to navigate to Groww App
                      GestureDetector(
                        onTap: () => _openGrowwApp(context, stock),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(12),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/groww_logo.png',
                              width: 38,
                              height: 38,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        isPos
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: changeColor,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedChange,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Reasons to Buy Card
            ReasonsToBuyCard(symbol: stock.symbol),

            const SizedBox(height: 20),

            // Notes Card
            NotesCard(symbol: stock.symbol),

            const SizedBox(height: 20),

            // Quarterly Results Observations Card
            QuarterlyResultsCard(symbol: stock.symbol),
          ],
        ),
      ),
    );
  }
}
