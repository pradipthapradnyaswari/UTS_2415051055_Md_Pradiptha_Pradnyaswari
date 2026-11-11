import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../utils/formatters.dart';
import '../widgets/chart_card.dart';
import '../models/transaction_model.dart';

enum AnalysisPeriod { daily, weekly, monthly, yearly }

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  AnalysisPeriod _selectedPeriod = AnalysisPeriod.monthly;

  String get _periodLabel {
    switch (_selectedPeriod) {
      case AnalysisPeriod.daily:
        return 'Hari ini';
      case AnalysisPeriod.weekly:
        return 'Minggu ini';
      case AnalysisPeriod.monthly:
        return 'Bulan ini';
      case AnalysisPeriod.yearly:
        return 'Tahun ini';
    }
  }

  bool _isWithinPeriod(DateTime date) {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case AnalysisPeriod.daily:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

      case AnalysisPeriod.weekly:
        final today = DateTime(now.year, now.month, now.day);
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));

        return !date.isBefore(startOfWeek) && date.isBefore(endOfWeek);

      case AnalysisPeriod.monthly:
        return date.year == now.year && date.month == now.month;

      case AnalysisPeriod.yearly:
        return date.year == now.year;
    }
  }

  List<ChartEntry> _createChartEntries(List<TransactionModel> transactions) {
    final now = DateTime.now();

    late List<String> labels;

    switch (_selectedPeriod) {
      case AnalysisPeriod.daily:
        labels = ['Hari ini'];
        break;

      case AnalysisPeriod.weekly:
        labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
        break;

      case AnalysisPeriod.monthly:
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        labels = List.generate(daysInMonth, (index) => '${index + 1}');
        break;

      case AnalysisPeriod.yearly:
        labels = [
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
        break;
    }

    final entries = labels.map((label) => ChartEntry(label: label)).toList();

    for (final transaction in transactions) {
      final date = transaction.transactionDate;

      int index;

      switch (_selectedPeriod) {
        case AnalysisPeriod.daily:
          index = 0;
          break;
        case AnalysisPeriod.weekly:
          index = date.weekday - 1;
          break;
        case AnalysisPeriod.monthly:
          index = date.day - 1;
          break;
        case AnalysisPeriod.yearly:
          index = date.month - 1;
          break;
      }

      if (index < 0 || index >= entries.length) continue;

      if (transaction.isIncome) {
        entries[index].income += transaction.amount;
      } else if (transaction.isExpense) {
        entries[index].expense += transaction.amount;
      }
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final filteredTransactions = provider.transactions
        .where((item) => _isWithinPeriod(item.transactionDate))
        .toList();

    final income = filteredTransactions
        .where((item) => item.isIncome)
        .fold<double>(0, (sum, item) => sum + item.amount);

    final expense = filteredTransactions
        .where((item) => item.isExpense)
        .fold<double>(0, (sum, item) => sum + item.amount);

    final balance = income - expense;

    final chartEntries = _createChartEntries(filteredTransactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisis Keuangan'),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Pantau kondisi keuanganmu',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 20),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isPortraitPhone = constraints.maxWidth < 500;
                      final crossAxisCount = isPortraitPhone ? 2 : 4;

                      final periods = [
                        (AnalysisPeriod.daily, 'Harian'),
                        (AnalysisPeriod.weekly, 'Mingguan'),
                        (AnalysisPeriod.monthly, 'Bulanan'),
                        (AnalysisPeriod.yearly, 'Tahunan'),
                      ];

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: periods.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          mainAxisExtent: 48,
                        ),
                        itemBuilder: (context, index) {
                          final period = periods[index].$1;
                          final label = periods[index].$2;
                          final isSelected = _selectedPeriod == period;

                          return Material(
                            color: isSelected
                                ? Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                setState(() {
                                  _selectedPeriod = period;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                        : Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Ringkasan $_periodLabel',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 12),

                  if (provider.isLoading && provider.transactions.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (provider.errorMessage != null &&
                      provider.transactions.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('Gagal memuat data transaksi.'),
                            TextButton(
                              onPressed: provider.fetchTransactions,
                              child: const Text('Coba lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    _SummaryTile(
                      title: 'Total Pemasukan',
                      amount: income,
                      icon: Icons.trending_up,
                      color: const Color(0xFF287C78),
                    ),

                    const SizedBox(height: 12),

                    _SummaryTile(
                      title: 'Total Pengeluaran',
                      amount: expense,
                      icon: Icons.trending_down,
                      color: const Color(0xFFA34C36),
                    ),

                    const SizedBox(height: 12),

                    _SummaryTile(
                      title: 'Selisih Keuangan',
                      amount: balance,
                      icon: Icons.account_balance_wallet_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Grafik Pemasukan dan Pengeluaran',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 12),

                    ChartCard(entries: chartEntries),

                    const SizedBox(height: 20),

                    if (filteredTransactions.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'Belum ada transaksi pada periode ini.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(
          formatRupiah(amount),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
