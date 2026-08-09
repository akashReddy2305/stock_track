import 'package:flutter/material.dart';
import '../models/stock_item.dart';

class _EmaLineItem {
  final String name;
  final double value;
  final Color color;
  final bool isCmp;

  _EmaLineItem({
    required this.name,
    required this.value,
    required this.color,
    this.isCmp = false,
  });
}

class EmaIndicatorCard extends StatelessWidget {
  final StockItem stock;

  const EmaIndicatorCard({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final double cmp = stock.currentPrice;
    final double? ema20 = stock.ema20;
    final double? ema50 = stock.ema50;
    final double? ema100 = stock.ema100;
    final double? ema150 = stock.ema150;
    final double? ema200 = stock.ema200;

    // Define the 6 line items with exact requested colors
    final List<_EmaLineItem> rawLines = [
      _EmaLineItem(
        name: 'CMP',
        value: cmp,
        color: const Color(0xFF7C3AED), // Distinct Purple for Current Price
        isCmp: true,
      ),
      if (ema20 != null)
        _EmaLineItem(
          name: '20 EMA',
          value: ema20,
          color: const Color(0xFF2563EB), // 5. 20 EMA line - Blue Color
        ),
      if (ema50 != null)
        _EmaLineItem(
          name: '50 EMA',
          value: ema50,
          color: const Color(0xFF16A34A), // 4. 50 EMA line - Green Color
        ),
      if (ema100 != null)
        _EmaLineItem(
          name: '100 EMA',
          value: ema100,
          color: const Color(0xFFCA8A04), // 3. 100 EMA line - Yellow Color
        ),
      if (ema150 != null)
        _EmaLineItem(
          name: '150 EMA',
          value: ema150,
          color: const Color(0xFFEA580C), // 2. 150 EMA line - Orange Color
        ),
      if (ema200 != null)
        _EmaLineItem(
          name: '200 EMA',
          value: ema200,
          color: const Color(0xFFDC2626), // 1. 200 EMA line - Red Color
        ),
    ];

    // Sort lines by value descending (Highest price level at top, lowest at bottom)
    rawLines.sort((a, b) => b.value.compareTo(a.value));

    return Container(
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_graph_rounded,
                      size: 20,
                      color: Color(0xFF1E1E24),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'MOVING AVERAGES (EMA)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E24),
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '6 Levels',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Render the 6 Horizontal Lines in Price Hierarchy Order
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8ECEF)),
            ),
            child: Column(
              children: List.generate(rawLines.length, (index) {
                final line = rawLines[index];
                final isLast = index == rawLines.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          // Left Label Badge
                          Container(
                            width: 72,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: line.isCmp
                                  ? line.color
                                  : line.color.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: line.color.withAlpha(60),
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              line.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: line.isCmp ? Colors.white : line.color,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Horizontal Line Representation
                          Expanded(
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Container(
                                  height: line.isCmp ? 3.5 : 2.0,
                                  decoration: BoxDecoration(
                                    color: line.color,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: line.isCmp
                                        ? [
                                            BoxShadow(
                                              color: line.color.withAlpha(100),
                                              blurRadius: 4,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                                if (line.isCmp)
                                  Positioned(
                                    left: 0,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: line.color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Price Value
                          SizedBox(
                            width: 82,
                            child: Text(
                              '₹${line.value.toStringAsFixed(2)}',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: line.isCmp
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: line.isCmp
                                    ? line.color
                                    : const Color(0xFF1E1E24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const SizedBox(height: 4),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 14),

          // Color Legend Row
          const Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _LegendDot(label: '200 EMA', color: Color(0xFFDC2626)),
              _LegendDot(label: '150 EMA', color: Color(0xFFEA580C)),
              _LegendDot(label: '100 EMA', color: Color(0xFFCA8A04)),
              _LegendDot(label: '50 EMA', color: Color(0xFF16A34A)),
              _LegendDot(label: '20 EMA', color: Color(0xFF2563EB)),
              _LegendDot(label: 'CMP', color: Color(0xFF7C3AED)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendDot({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
