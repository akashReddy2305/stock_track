import 'package:flutter/material.dart';
import '../models/stock_item.dart';
import '../services/stock_service.dart';
import '../widgets/stock_card.dart';
import '../widgets/empty_stock_state.dart';
import '../widgets/add_stock_modal.dart';
import 'stock_detail_screen.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  final StockService _stockService = StockService();
  List<StockItem> _stocks = [];
  final Set<String> _newlyAddedSymbols = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedStocks();
  }

  Future<void> _loadSavedStocks() async {
    setState(() {
      _isLoading = true;
    });

    final symbols = await _stockService.getSavedSymbols();
    List<StockItem> cachedStocks = [];

    // Load instantly from persistent local cache across app restarts & updates
    for (final sym in symbols) {
      final cached = await _stockService.getCachedStockItem(sym);
      if (cached != null) {
        cachedStocks.add(cached);
      }
    }

    if (mounted && cachedStocks.isNotEmpty) {
      setState(() {
        _stocks = cachedStocks;
        _isLoading = false;
      });
    }

    // Refresh live market prices
    List<StockItem> freshStocks = [];
    for (final sym in symbols) {
      final item = await _stockService.fetchStockData(sym);
      freshStocks.add(item);
    }

    if (mounted) {
      setState(() {
        _stocks = freshStocks;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshStocks() async {
    final symbols = await _stockService.getSavedSymbols();
    List<StockItem> updatedStocks = [];

    for (final sym in symbols) {
      final item = await _stockService.fetchStockData(sym);
      updatedStocks.add(item);
    }

    if (mounted) {
      setState(() {
        _stocks = updatedStocks;
      });
    }
  }

  Future<bool> _handleAddStock(String symbol) async {
    final cleanSymbol = symbol.trim().toUpperCase();
    final item = await _stockService.fetchStockData(cleanSymbol);

    await _stockService.addSymbol(cleanSymbol);

    if (mounted) {
      setState(() {
        _newlyAddedSymbols.add(item.symbol);
        // Replace if already in list, otherwise add
        final index = _stocks.indexWhere((s) => s.symbol == item.symbol);
        if (index != -1) {
          _stocks[index] = item;
        } else {
          _stocks.add(item);
        }
      });
    }
    return true;
  }

  Future<void> _handleDeleteStock(String symbol) async {
    await _stockService.removeSymbol(symbol);
    if (mounted) {
      setState(() {
        _newlyAddedSymbols.remove(symbol);
        _stocks.removeWhere((s) => s.symbol == symbol);
      });
    }
  }

  Future<void> _clearAllStocks() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Stocks?'),
        content: const Text(
          'Are you sure you want to clear all saved stocks from your watchlist?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _stockService.clearAllSymbols();
      if (mounted) {
        setState(() {
          _stocks = [];
        });
      }
    }
  }

  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddStockModal(
        onAddStock: _handleAddStock,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 16,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE5E7EB),
            height: 1.0,
          ),
        ),
        title: Row(
          children: [
            // Branding Chart Icon matching prompt screenshot
            Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.show_chart_rounded,
                color: Color(0xFF1E1E24),
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'StockTrack',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E24),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Clear Watchlist Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF1E1E24)),
            onSelected: (value) {
              if (value == 'clear') {
                _clearAllStocks();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Clear Watchlist', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF1E1E24),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Fetching live market data...',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : _stocks.isEmpty
              ? const EmptyStockState()
              : RefreshIndicator(
                  color: const Color(0xFF1E1E24),
                  onRefresh: _refreshStocks,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 12, bottom: 88),
                    itemCount: _stocks.length,
                    itemBuilder: (context, index) {
                      final stock = _stocks[index];
                      final isNewlyAdded = _newlyAddedSymbols.contains(stock.symbol);
                      return StockCard(
                        key: ValueKey(stock.symbol),
                        stock: stock,
                        animateEntry: isNewlyAdded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockDetailScreen(stock: stock),
                            ),
                          );
                        },
                        onDelete: () => _handleDeleteStock(stock.symbol),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        backgroundColor: const Color(0xFF1E1E24),
        foregroundColor: Colors.white,
        tooltip: 'Add Stock',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
