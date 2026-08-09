import 'package:flutter/material.dart';

class EmptyStockState extends StatelessWidget {
  const EmptyStockState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Decorative illustration container
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.currency_rupee_rounded,
                size: 54,
                color: Color(0xFF1E1E24),
              ),
            ),

            const SizedBox(height: 28),

            // Title
            const Text(
              'No Stocks Added',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E24),
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 10),

            // Description
            const Text(
              'Track real-time prices in Rupees (₹), daily market performance, and NSE/BSE trends by adding stocks to your watchlist.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF6B7280),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
