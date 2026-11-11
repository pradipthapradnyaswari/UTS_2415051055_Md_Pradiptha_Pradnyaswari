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
    HomeScreen(
      onViewAllTransactions: () {
        setState(() {
          _currentIndex = 2;
        });
      },
    ),
    const AnalysisScreen(),
    const TransactionListScreen(),
    const CategoriesScreen(),
    const ProfileScreen(),
  ];

  final List<NavigationRailDestination> _railDestinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('Beranda'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.insights_outlined),
      selectedIcon: Icon(Icons.insights),
      label: Text('Analisis'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: Text('Transaksi'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.category_outlined),
      selectedIcon: Icon(Icons.category),
      label: Text('Kategori'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: Text('Profil'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isExpanded = screenWidth >= 840;

    return Scaffold(
      body: isExpanded
          ? Row(
              children: [
                SizedBox(
                  width: 88,
                  child: Column(
                    children: List.generate(_railDestinations.length, (index) {
                      final destination = _railDestinations[index];
                      final isSelected = _currentIndex == index;
                      final colorScheme = Theme.of(context).colorScheme;

                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.secondary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  isSelected
                                      ? (destination.selectedIcon as Icon).icon
                                      : (destination.icon as Icon).icon,
                                  color: isSelected
                                      ? colorScheme.onSecondary
                                      : colorScheme.onSurface,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              DefaultTextStyle(
                                style: Theme.of(context).textTheme.labelSmall!
                                    .copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                child: destination.label,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: _pages),
                ),
              ],
            )
          : IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: isExpanded
          ? null
          : BottomNavBar(
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
