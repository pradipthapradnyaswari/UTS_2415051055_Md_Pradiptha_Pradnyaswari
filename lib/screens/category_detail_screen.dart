import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/formatters.dart';
import 'transaction_detail_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryName;
  final String transactionType;
  final List<TransactionModel> transactions;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
    required this.transactionType,
    required this.transactions,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late List<TransactionModel> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = List.from(widget.transactions);
  }

  Future<void> _openTransactionDetail(TransactionModel transaction) async {
    final result = await Navigator.push<TransactionDetailResult>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transaction: transaction),
      ),
    );

    if (!mounted || result == null) return;

    final provider = context.read<TransactionProvider>();

    if (result.isDeleted) {
      final success = await provider.deleteTransaction(transaction.id);

      if (!mounted) return;

      if (success) {
        setState(() {
          _transactions.removeWhere((item) => item.id == transaction.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dihapus.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus transaksi.')),
        );
      }

      return;
    }

    if (result.transaction != null) {
      final updatedTransaction = result.transaction!;

      final success = await provider.updateTransaction(updatedTransaction);

      if (!mounted) return;

      if (success) {
        setState(() {
          final index = _transactions.indexWhere(
            (item) => item.id == updatedTransaction.id,
          );

          if (index != -1) {
            final stillInCategory =
                updatedTransaction.category == widget.categoryName &&
                updatedTransaction.type == widget.transactionType;

            if (stillInCategory) {
              _transactions[index] = updatedTransaction;
            } else {
              _transactions.removeAt(index);
            }
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil diperbarui.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui transaksi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _transactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );

    final isExpense = widget.transactionType == 'expense';

    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExpense ? 'Total Pengeluaran' : 'Total Pemasukan',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatRupiah(total),
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('${_transactions.length} transaksi tercatat'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Daftar Transaksi',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('Belum ada transaksi pada kategori ini.'),
              ),
            )
          else
            ..._transactions.map((transaction) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                    ),
                  ),
                  title: Text(transaction.title),
                  subtitle: Text(
                    transaction.note.isNotEmpty
                        ? '${transaction.category} • ${transaction.note}'
                        : transaction.category,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    formatRupiah(transaction.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _openTransactionDetail(transaction),
                ),
              );
            }),
        ],
      ),
    );
  }
}
