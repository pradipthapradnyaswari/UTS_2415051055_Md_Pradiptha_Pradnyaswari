import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../utils/formatters.dart';

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

  List<_ChartEntry> _createChartEntries(List<dynamic> transactions) {
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

    final entries = labels.map((label) => _ChartEntry(label: label)).toList();

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

    // Data grafik dibuat setelah filteredTransactions tersedia.
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
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Pantau kondisi keuanganmu',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 20),

                  SegmentedButton<AnalysisPeriod>(
                    segments: const [
                      ButtonSegment(
                        value: AnalysisPeriod.daily,
                        label: Text('Harian'),
                      ),
                      ButtonSegment(
                        value: AnalysisPeriod.weekly,
                        label: Text('Mingguan'),
                      ),
                      ButtonSegment(
                        value: AnalysisPeriod.monthly,
                        label: Text('Bulanan'),
                      ),
                      ButtonSegment(
                        value: AnalysisPeriod.yearly,
                        label: Text('Tahunan'),
                      ),
                    ],
                    selected: {_selectedPeriod},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _selectedPeriod = selection.first;
                      });
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

                    _FinanceChart(entries: chartEntries),

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

class _ChartEntry {
  final String label;
  double income;
  double expense;

  _ChartEntry({required this.label}) : income = 0, expense = 0;
}

class _FinanceChart extends StatelessWidget {
  final List<_ChartEntry> entries;

  const _FinanceChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final maxAmount = entries.fold<double>(0, (maximum, entry) {
      final current = entry.income > entry.expense
          ? entry.income
          : entry.expense;

      return current > maximum ? current : maximum;
    });

    const incomeColor = Color(0xFF287C78);
    const expenseColor = Color(0xFFA34C36);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: const [
                _ChartLegend(color: incomeColor, label: 'Pemasukan'),
                _ChartLegend(color: expenseColor, label: 'Pengeluaran'),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 180,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: entries.map((entry) {
                    final incomeHeight = maxAmount == 0
                        ? 0.0
                        : (entry.income / maxAmount) * 120;

                    final expenseHeight = maxAmount == 0
                        ? 0.0
                        : (entry.expense / maxAmount) * 120;

                    return SizedBox(
                      width: 44,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 130,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: 12,
                                  height: incomeHeight,
                                  decoration: BoxDecoration(
                                    color: incomeColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 12,
                                  height: expenseHeight,
                                  decoration: BoxDecoration(
                                    color: expenseColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(entry.label, style: theme.textTheme.labelSmall),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            if (maxAmount == 0)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Belum ada data untuk ditampilkan.'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
