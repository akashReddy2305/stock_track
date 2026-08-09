import 'package:flutter/material.dart';
import '../services/stock_service.dart';

class ReasonsToBuyCard extends StatefulWidget {
  final String symbol;

  const ReasonsToBuyCard({
    super.key,
    required this.symbol,
  });

  @override
  State<ReasonsToBuyCard> createState() => _ReasonsToBuyCardState();
}

class _ReasonsToBuyCardState extends State<ReasonsToBuyCard> {
  final StockService _stockService = StockService();
  final TextEditingController _inputController = TextEditingController();
  List<String> _reasons = [];
  bool _isLoading = true;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadReasons();
  }

  Future<void> _loadReasons() async {
    final list = await _stockService.getReasonsForStock(widget.symbol);
    if (mounted) {
      setState(() {
        _reasons = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _addReason() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    setState(() {
      _isAdding = false;
    });

    final updated = await _stockService.addReasonForStock(widget.symbol, text);
    if (mounted) {
      setState(() {
        _reasons = updated;
      });
    }
  }

  Future<void> _removeReason(int index) async {
    final updated = await _stockService.removeReasonForStock(widget.symbol, index);
    if (mounted) {
      setState(() {
        _reasons = updated;
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 20,
                    color: Color(0xFF1E1E24),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'REASONS TO BUY',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E24),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              if (_reasons.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_reasons.length} ${_reasons.length == 1 ? "point" : "points"}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Loading indicator or List of Reasons
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF1E1E24),
                      ),
                    ),
                  ),
                )
              : _reasons.isEmpty && !_isAdding
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.note_add_outlined,
                            size: 28,
                            color: Color(0xFF9CA3AF),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No reasons added yet',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Record your key investment rationale and notes for this stock.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: List.generate(_reasons.length, (index) {
                        final reasonText = _reasons[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE8ECEF),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    size: 16,
                                    color: Color(0xFF1E8E3E),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    reasonText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1E1E24),
                                      height: 1.35,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => _removeReason(index),
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

          const SizedBox(height: 12),

          // Add Reason Action Input or Button
          if (_isAdding) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'e.g. Strong Q3 earnings & market share...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF1E1E24),
                          width: 1.5,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _addReason(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addReason,
                  icon: const Icon(Icons.check_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E24),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _inputController.clear();
                    setState(() {
                      _isAdding = false;
                    });
                  },
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isAdding = true;
                  });
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'Add Reason',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E1E24),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
