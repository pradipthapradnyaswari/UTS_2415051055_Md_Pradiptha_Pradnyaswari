import 'package:flutter/material.dart';

import 'utils/app_theme.dart';

class FinoteApp extends StatelessWidget {
  const FinoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finote',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      themeMode: ThemeMode.system,

      home: const Scaffold(
        body: Center(
          child: Text(
            'Finote',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
