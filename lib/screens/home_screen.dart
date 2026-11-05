import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/balance_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';
import '../widgets/exchange_rate_card.dart';
import '../providers/notification_provider.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onViewAllTransactions;

  void _showNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  const HomeScreen({super.key, required this.onViewAllTransactions});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final unreadCount = notificationProvider.unreadCount;

    final transactions = provider.transactions;
    final theme = Theme.of(context);

    final totalIncome = transactions
        .where((transaction) => transaction.isIncome)
        .fold<double>(0, (total, transaction) => total + transaction.amount);

    final totalExpense = transactions
        .where((transaction) => transaction.isExpense)
        .fold<double>(0, (total, transaction) => total + transaction.amount);

    final balance = totalIncome - totalExpense;

    final recentTransactions = transactions.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Finote',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _showNotifications(context),
            tooltip: 'Notifikasi',
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()),
              child: const Icon(Icons.notifications_none),
            ),
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

          if (provider.isLoading && transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

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
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      BalanceCard(balance: formatRupiah(balance)),

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
                            child: SummaryCard(
                              title: 'Pemasukan',
                              amount: formatRupiah(totalIncome),
                              icon: Icons.trending_up,
                              color: AppColors.income,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: SummaryCard(
                              title: 'Pengeluaran',
                              amount: formatRupiah(totalExpense),
                              icon: Icons.trending_down,
                              color: AppColors.expense,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      const ExchangeRateCard(),

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
                            onPressed: onViewAllTransactions,
                            child: const Text('Lihat semua'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      if (provider.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gagal memuat data transaksi.',
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                provider.errorMessage!,
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: provider.fetchTransactions,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba lagi'),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (provider.isLoading) const LinearProgressIndicator(),

                      if (transactions.isEmpty && provider.errorMessage == null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Belum ada transaksi.',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Yuk, catat transaksi pertamamu!',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ...recentTransactions.map((transaction) {
                        return Column(
                          children: [
                            TransactionCard(
                              title: transaction.title,
                              category: transaction.category,
                              amount: formatRupiah(transaction.amount),
                              date: _formatDate(transaction.transactionDate),
                              isIncome: transaction.isIncome,
                            ),
                            const Divider(),
                          ],
                        );
                      }),
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }
}
