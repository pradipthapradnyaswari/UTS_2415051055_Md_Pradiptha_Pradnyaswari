import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class BalanceCard extends StatefulWidget {
  final String balance;

  const BalanceCard({super.key, required this.balance});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  static const String _visibilityKey = 'finote_balance_visible';

  final ValueNotifier<bool> _isBalanceVisible = ValueNotifier<bool>(false);

  bool _isPreferenceLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBalanceVisibility();
  }

  Future<void> _loadBalanceVisibility() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVisibility = prefs.getBool(_visibilityKey) ?? true;

      if (!mounted) return;

      _isBalanceVisible.value = savedVisibility;
      setState(() {
        _isPreferenceLoaded = true;
      });
    } catch (e) {
      debugPrint('Gagal memuat preferensi saldo: $e');

      if (mounted) {
        setState(() {
          _isPreferenceLoaded = true;
        });
      }
    }
  }

  Future<void> _toggleBalanceVisibility(bool isVisible) async {
    final newVisibility = !isVisible;

    _isBalanceVisible.value = newVisibility;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_visibilityKey, newVisibility);
    } catch (e) {
      debugPrint('Gagal menyimpan preferensi saldo: $e');
    }
  }

  @override
  void dispose() {
    _isBalanceVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Saldo',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _isBalanceVisible,
                builder: (context, isVisible, child) {
                  return IconButton(
                    onPressed: _isPreferenceLoaded
                        ? () => _toggleBalanceVisibility(isVisible)
                        : null,
                    tooltip: isVisible
                        ? 'Sembunyikan saldo'
                        : 'Tampilkan saldo',
                    icon: Icon(
                      isVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white70,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<bool>(
            valueListenable: _isBalanceVisible,
            builder: (context, isVisible, child) {
              return Text(
                isVisible ? widget.balance : '••••••••',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white70,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Ringkasan keuanganmu',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
