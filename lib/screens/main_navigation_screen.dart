import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/exchange_rate_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'transaction_list_screen.dart';
import 'analysis_screen.dart';
import 'categories_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ExchangeRateProvider>().fetchExchangeRates();
    });
  }

  late final List<Widget> _pages = [
    const HomeScreen(),
    const AnalysisScreen(),
    const TransactionListScreen(),
    const CategoriesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
