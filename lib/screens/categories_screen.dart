import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../utils/formatters.dart';
import 'category_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _selectedType = 'expense';

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Makanan', 'icon': Icons.restaurant},
    {'name': 'Transportasi', 'icon': Icons.directions_bus},
    {'name': 'Obat-obatan', 'icon': Icons.medical_services},
    {'name': 'Belanjaan', 'icon': Icons.shopping_bag},
    {'name': 'Uang Sewa', 'icon': Icons.home},
    {'name': 'Hadiah', 'icon': Icons.card_giftcard},
    {'name': 'Tabungan', 'icon': Icons.savings},
    {'name': 'Hiburan', 'icon': Icons.movie},
    {'name': 'Lainnya', 'icon': Icons.category},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.transactions;

    final filteredTransactions = transactions
        .where((transaction) => transaction.type == _selectedType)
        .toList();

    final categoryData = _categories
        .map((category) {
          final categoryTransactions = filteredTransactions
              .where((transaction) => transaction.category == category['name'])
              .toList();

          final total = categoryTransactions.fold<double>(
            0,
            (sum, transaction) => sum + transaction.amount,
          );

          return {
            'name': category['name'],
            'icon': category['icon'],
            'count': categoryTransactions.length,
            'total': total,
          };
        })
        .where((category) => category['count'] as int > 0)
        .toList();

    final grandTotal = filteredTransactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Kategori'), centerTitle: false),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.fetchTransactions(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'expense',
                    label: Text('Pengeluaran'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text('Pemasukan'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (selection) {
                  setState(() {
                    _selectedType = selection.first;
                  });
                },
              ),
              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedType == 'expense'
                            ? 'Total Pengeluaran'
                            : 'Total Pemasukan',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatRupiah(grandTotal),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${filteredTransactions.length} transaksi',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Rincian Kategori',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (provider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (provider.errorMessage != null)
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 40),
                      const SizedBox(height: 8),
                      Text(provider.errorMessage!),
                      TextButton(
                        onPressed: provider.fetchTransactions,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              else if (categoryData.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.pie_chart_outline, size: 48),
                        SizedBox(height: 12),
                        Text('Belum ada transaksi pada kategori ini.'),
                      ],
                    ),
                  ),
                )
              else
                ...categoryData.map((category) {
                  final total = category['total'] as double;
                  final count = category['count'] as int;
                  final percentage = grandTotal > 0 ? total / grandTotal : 0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        final selectedCategory = category['name'] as String;

                        final categoryTransactions = filteredTransactions
                            .where(
                              (transaction) =>
                                  transaction.category == selectedCategory,
                            )
                            .toList();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryDetailScreen(
                              categoryName: selectedCategory,
                              transactionType: _selectedType,
                              transactions: categoryTransactions,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.12),
                                  child: Icon(
                                    category['icon'] as IconData,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category['name'] as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '$count transaksi',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatRupiah(total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: percentage.clamp(0.0, 1.0),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${(percentage * 100).toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
