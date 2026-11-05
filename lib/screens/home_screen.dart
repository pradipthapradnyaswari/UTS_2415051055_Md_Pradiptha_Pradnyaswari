import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../widgets/balance_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Finote',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Notifikasi',
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.sizeOf(context).width;

          final measuredWidth = constraints.maxWidth > 0
              ? constraints.maxWidth
              : screenWidth;

          final contentWidth = measuredWidth > 900 ? 900.0 : measuredWidth;

          final availableWidth = (contentWidth - 40)
              .clamp(0.0, double.infinity)
              .toDouble();

          final cardWidth = availableWidth > 600
              ? (availableWidth - 12) / 2
              : availableWidth;

          return SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: contentWidth,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Halo, selamat datang!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Yuk, pantau kondisi keuanganmu hari ini.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const BalanceCard(balance: 'Rp2.500.000'),

                      const SizedBox(height: 24),

                      const Text(
                        'Ringkasan Keuangan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: const SummaryCard(
                              title: 'Pemasukan',
                              amount: 'Rp3.500.000',
                              icon: Icons.trending_up,
                              color: AppColors.income,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: const SummaryCard(
                              title: 'Pengeluaran',
                              amount: 'Rp1.000.000',
                              icon: Icons.trending_down,
                              color: AppColors.expense,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transaksi Terbaru',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Lihat semua'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      const TransactionCard(
                        title: 'Uang Saku',
                        category: 'Pemasukan',
                        amount: 'Rp2.000.000',
                        date: '05 Nov 2026',
                        isIncome: true,
                      ),
                      const Divider(),

                      const TransactionCard(
                        title: 'Makan Siang',
                        category: 'Makanan',
                        amount: 'Rp25.000',
                        date: '05 Nov 2026',
                        isIncome: false,
                      ),
                      const Divider(),

                      const TransactionCard(
                        title: 'Transportasi',
                        category: 'Transportasi',
                        amount: 'Rp15.000',
                        date: '04 Nov 2026',
                        isIncome: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
