import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/transaction_provider.dart';
import 'providers/exchange_rate_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/exchange_rate_repository.dart';
import 'repositories/transaction_repository.dart';
import 'screens/main_navigation_screen.dart';
import 'utils/app_theme.dart';

class FinoteApp extends StatelessWidget {
  const FinoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(TransactionRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ExchangeRateProvider(ExchangeRateRepository()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Finote',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
