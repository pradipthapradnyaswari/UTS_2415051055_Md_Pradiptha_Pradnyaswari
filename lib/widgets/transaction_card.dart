import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String title;
  final String category;
  final String amount;
  final String date;
  final bool isIncome;

  const TransactionCard({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? const Color(0xFF287C78) : const Color(0xFFA34C36);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('$category • $date'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isIncome ? '+' : '-'}$amount',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          Text(
            isIncome ? 'Pemasukan' : 'Pengeluaran',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
