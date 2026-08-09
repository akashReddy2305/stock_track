import 'package:flutter/material.dart';
import '../models/stock_item.dart';

class StockCard extends StatefulWidget {
  final StockItem stock;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool animateEntry;

  const StockCard({
    super.key,
    required this.stock,
    this.onTap,
    this.onDelete,
    this.animateEntry = false,
  });

  @override
  State<StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<StockCard> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  
  late AnimationController _deleteController;
  late Animation<double> _deleteOpacity;
  late Animation<double> _deleteScale;
  late Animation<double> _deleteHeightFactor;

  late AnimationController _entryController;
  late Animation<double> _entryOpacity;
  late Animation<double> _entryScale;
  late Animation<double> _entryHeightFactor;

  double _dragOffset = 0.0;
  static const double _maxSlideWidth = 80.0;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // Controller for swiping right-to-left
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _slideController.addListener(() {
      setState(() {
        _dragOffset = _slideAnimation.value;
      });
    });

    // Controller for smooth deletion animation
    _deleteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _deleteOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _deleteController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _deleteScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _deleteController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _deleteHeightFactor = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _deleteController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _deleteController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onDelete != null) {
          widget.onDelete!();
        }
      }
    });

    // Controller for smooth entry addition animation
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _entryOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _entryScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _entryHeightFactor = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    if (widget.animateEntry) {
      _entryController.forward();
    } else {
      _entryController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant StockCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stock.symbol != widget.stock.symbol) {
      _dragOffset = 0.0;
      _isDeleting = false;
      _slideController.reset();
      _deleteController.reset();
      if (widget.animateEntry) {
        _entryController.forward(from: 0.0);
      } else {
        _entryController.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _deleteController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _slideAnimation = Tween<double>(begin: _dragOffset, end: target).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _slideController.forward(from: 0.0);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isDeleting) return;
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(-_maxSlideWidth, 0.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isDeleting) return;
    if (_dragOffset < -_maxSlideWidth / 2 || details.primaryVelocity! < -300) {
      _animateTo(-_maxSlideWidth);
    } else {
      _animateTo(0.0);
    }
  }

  void _triggerDeleteAnimation() {
    if (_isDeleting) return;
    setState(() {
      _isDeleting = true;
    });
    _deleteController.forward();
  }

  String _formatTwoDecimals(double val) {
    return val.abs().toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final stock = widget.stock;
    final formattedPrice = '₹${stock.currentPrice.toStringAsFixed(2)}';
    final isPos = stock.isPositive;
    final formattedChange = '${isPos ? '+' : ''}${_formatTwoDecimals(stock.changePercent)}%';

    final badgeBg = isPos ? const Color(0xFFDCF6E6) : const Color(0xFFFDE8E8);
    final badgeText = isPos ? const Color(0xFF1E8E3E) : const Color(0xFFD93025);

    final isOpened = _dragOffset < -10;

    return SizeTransition(
      sizeFactor: _deleteHeightFactor,
      axisAlignment: 0.0,
      child: FadeTransition(
        opacity: _deleteOpacity,
        child: ScaleTransition(
          scale: _deleteScale,
          child: SizeTransition(
            sizeFactor: _entryHeightFactor,
            axisAlignment: 0.0,
            child: FadeTransition(
              opacity: _entryOpacity,
              child: ScaleTransition(
                scale: _entryScale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Stack(
                    children: [
                      // Background Red Delete Button revealed when swiped right-to-left
                      Positioned.fill(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: _triggerDeleteAnimation,
                              child: Container(
                                width: _maxSlideWidth - 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Sliding Front Card
                      Transform.translate(
                        offset: Offset(_dragOffset, 0),
                        child: GestureDetector(
                          onHorizontalDragUpdate: _onHorizontalDragUpdate,
                          onHorizontalDragEnd: _onHorizontalDragEnd,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE8ECEF),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  if (_isDeleting) return;
                                  if (isOpened) {
                                    _animateTo(0.0);
                                  } else if (widget.onTap != null) {
                                    widget.onTap!();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Left side: Ticker & Company Name
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              stock.symbol,
                                              style: const TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E1E24),
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              stock.companyName,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF757575),
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 16),

                                      // Right side: Price & Percent Badge
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            formattedPrice,
                                            style: const TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E1E24),
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: badgeBg,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isPos
                                                      ? Icons.north_east_rounded
                                                      : Icons.south_east_rounded,
                                                  size: 13,
                                                  color: badgeText,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  formattedChange,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: badgeText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
