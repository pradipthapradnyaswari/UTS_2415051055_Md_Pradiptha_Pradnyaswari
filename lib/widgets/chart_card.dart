import 'package:flutter/material.dart';

class ChartEntry {
  final String label;
  double income;
  double expense;

  ChartEntry({required this.label, this.income = 0, this.expense = 0});
}

class ChartCard extends StatelessWidget {
  final List<ChartEntry> entries;

  const ChartCard({super.key, required this.entries});

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
