import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../utils/formatters.dart';
import 'transaction_detail_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final total = transactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );

    final isExpense = transactionType == 'expense';

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
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
                  Text('${transactions.length} transaksi'),
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
          ...transactions.map((transaction) {
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
                onTap: () async {
                  await Navigator.push<TransactionDetailResult>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TransactionDetailScreen(transaction: transaction),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
