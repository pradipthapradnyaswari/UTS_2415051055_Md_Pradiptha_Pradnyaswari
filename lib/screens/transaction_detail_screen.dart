import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../utils/formatters.dart';
import 'edit_transaction_screen.dart';

class TransactionDetailResult {
  final TransactionModel? transaction;
  final bool isDeleted;

  const TransactionDetailResult({this.transaction, this.isDeleted = false});
}

class TransactionDetailScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late TransactionModel _transaction;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  Future<void> _editTransaction() async {
    final result = await Navigator.push<TransactionModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: _transaction),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      Navigator.pop(context, TransactionDetailResult(transaction: result));
    }
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Transaksi?'),
          content: Text(
            'Apakah kamu yakin ingin menghapus transaksi '
            '"${_transaction.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    Navigator.pop(context, const TransactionDetailResult(isDeleted: true));
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = _transaction.isIncome;

    final transactionColor = isIncome
        ? theme.colorScheme.secondary
        : theme.colorScheme.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: transactionColor.withValues(alpha: 0.12),
                    child: Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: transactionColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _transaction.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isIncome ? '+' : '-'}${formatRupiah(_transaction.amount)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: transactionColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(isIncome ? 'Pemasukan' : 'Pengeluaran'),
                    backgroundColor: transactionColor.withValues(alpha: 0.12),
                    labelStyle: TextStyle(
                      color: transactionColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Informasi Transaksi',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailItem(
              context,
              icon: Icons.category_outlined,
              title: 'Kategori',
              value: _transaction.category,
            ),
            _buildDetailItem(
              context,
              icon: Icons.calendar_today_outlined,
              title: 'Tanggal',
              value: _formatDate(_transaction.transactionDate),
            ),
            _buildDetailItem(
              context,
              icon: Icons.notes_outlined,
              title: 'Catatan',
              value: _transaction.note.isEmpty
                  ? 'Tidak ada catatan'
                  : _transaction.note,
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _editTransaction,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Transaksi'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _deleteTransaction,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus Transaksi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
