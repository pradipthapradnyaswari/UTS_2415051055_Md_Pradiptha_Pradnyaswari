import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../utils/formatters.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: '1',
      title: 'Uang Saku',
      amount: 1500000,
      type: 'income',
      category: 'Uang Saku',
      note: 'Uang saku bulanan',
      transactionDate: DateTime(2026, 11, 5),
    ),
    TransactionModel(
      id: '2',
      title: 'Makan Siang',
      amount: 25000,
      type: 'expense',
      category: 'Makanan',
      transactionDate: DateTime(2026, 11, 5),
    ),
    TransactionModel(
      id: '3',
      title: 'Transportasi',
      amount: 15000,
      type: 'expense',
      category: 'Transportasi',
      transactionDate: DateTime(2026, 11, 4),
    ),
    TransactionModel(
      id: '4',
      title: 'Hadiah',
      amount: 100000,
      type: 'income',
      category: 'Hadiah',
      transactionDate: DateTime(2026, 11, 3),
    ),
  ];

  Future<void> _openAddTransaction() async {
    final result = await Navigator.push<TransactionModel>(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _transactions.add(result);

        _transactions.sort(
          (a, b) => b.transactionDate.compareTo(a.transactionDate),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil ditambahkan!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi'), centerTitle: false),

      body: _transactions.isEmpty
          ? _buildEmptyState(context)
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Riwayat Transaksi',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_transactions.length} transaksi tercatat',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                _buildSummary(context),

                const SizedBox(height: 24),

                Text(
                  'Semua Transaksi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ..._transactions.map(
                  (transaction) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TransactionCard(
                      title: transaction.title,
                      category: transaction.category,
                      date: _formatDate(transaction.transactionDate),
                      amount: _formatAmount(transaction.amount),
                      isIncome: transaction.isIncome,
                    ),
                  ),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTransaction,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final totalIncome = _transactions
        .where((transaction) => transaction.isIncome)
        .fold<double>(0, (total, transaction) => total + transaction.amount);

    final totalExpense = _transactions
        .where((transaction) => transaction.isExpense)
        .fold<double>(0, (total, transaction) => total + transaction.amount);

    return Row(
      children: [
        Expanded(
          child: _summaryItem(
            context,
            title: 'Pemasukan',
            amount: totalIncome,
            icon: Icons.arrow_downward,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryItem(
            context,
            title: 'Pengeluaran',
            amount: totalExpense,
            icon: Icons.arrow_upward,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _summaryItem(
    BuildContext context, {
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(title, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            _formatAmount(amount),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Transaksi',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transaksi yang kamu tambahkan akan muncul di sini.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return formatRupiah(amount);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
