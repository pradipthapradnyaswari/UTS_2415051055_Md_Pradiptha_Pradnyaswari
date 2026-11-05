import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/transaction_provider.dart';
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
      ],
      child: MaterialApp(
        title: 'Finote',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
