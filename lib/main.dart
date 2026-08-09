import 'package:flutter/material.dart';
import 'screens/stock_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StockTrackApp());
}

class StockTrackApp extends StatelessWidget {
  const StockTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E1E24),
          surface: const Color(0xFFF4F6F8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const StockListScreen(),
    );
  }
}
