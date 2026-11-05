import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/formatters.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';
import 'transaction_detail_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedType = 'all';
  String? _selectedCategory;
  DateTimeRange? _selectedDateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TransactionProvider>().fetchTransactions();
    });
  }

  Future<void> _openAddTransaction() async {
    final result = await Navigator.push<TransactionModel>(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );

    if (!mounted || result == null) return;

    final success = await context.read<TransactionProvider>().addTransaction(
      result,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Transaksi berhasil ditambahkan!'
              : context.read<TransactionProvider>().errorMessage ??
                    'Gagal menambahkan transaksi.',
        ),
      ),
    );
  }

  Future<void> _openTransactionDetail(TransactionModel transaction) async {
    final result = await Navigator.push<TransactionDetailResult>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(transaction: transaction),
      ),
    );

    if (!mounted || result == null) return;

    final provider = context.read<TransactionProvider>();
    bool success = false;
    String message = '';

    if (result.isDeleted) {
      success = await provider.deleteTransaction(transaction.id);
      message = success
          ? 'Transaksi berhasil dihapus!'
          : provider.errorMessage ?? 'Gagal menghapus transaksi.';
    } else if (result.transaction != null) {
      success = await provider.updateTransaction(result.transaction!);
      message = success
          ? 'Data transaksi berhasil diperbarui!'
          : provider.errorMessage ?? 'Gagal memperbarui transaksi.';
    }

    if (!mounted) return;

    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
  ) {
    return transactions.where((transaction) {
      // Filter berdasarkan nama transaksi
      final query = _searchController.text.trim().toLowerCase();
      final matchesSearch = transaction.title.toLowerCase().contains(query);

      // Filter berdasarkan jenis transaksi
      final matchesType =
          _selectedType == 'all' ||
          (_selectedType == 'income' && transaction.isIncome) ||
          (_selectedType == 'expense' && transaction.isExpense);

      // Filter berdasarkan kategori
      final matchesCategory =
          _selectedCategory == null ||
          transaction.category == _selectedCategory;

      // Filter berdasarkan rentang tanggal
      bool matchesDate = true;

      if (_selectedDateRange != null) {
        final date = transaction.transactionDate;
        final start = _selectedDateRange!.start;
        final end = _selectedDateRange!.end;

        final startDate = DateTime(start.year, start.month, start.day);
        final endDate = DateTime(end.year, end.month, end.day);
        final transactionDate = DateTime(date.year, date.month, date.day);

        matchesDate =
            !transactionDate.isBefore(startDate) &&
            !transactionDate.isAfter(endDate);
      }

      return matchesSearch && matchesType && matchesCategory && matchesDate;
    }).toList();
  }

  Widget _buildFilterChip({required String label, required String value}) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedType == value,
      onSelected: (selected) {
        setState(() {
          _selectedType = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.transactions;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi'), centerTitle: false),

      body: _buildBody(context, provider, transactions),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTransaction,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TransactionProvider provider,
    List<TransactionModel> transactions,
  ) {
    if (provider.isLoading && transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && transactions.isEmpty) {
      return _buildErrorState(context, provider);
    }

    if (transactions.isEmpty) {
      return _buildEmptyState(context);
    }

    final theme = Theme.of(context);
    final filteredTransactions = _filterTransactions(transactions);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (provider.isLoading) const LinearProgressIndicator(),

        Text(
          'Riwayat Transaksi',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${transactions.length} transaksi telah dicatat',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),

        _buildSummary(context, transactions),

        const SizedBox(height: 24),

        Text(
          'Daftar Transaksi',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Cari transaksi...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const SizedBox(height: 16),

        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip(label: 'Semua', value: 'all'),
            _buildFilterChip(label: 'Pemasukan', value: 'income'),
            _buildFilterChip(label: 'Pengeluaran', value: 'expense'),
          ],
        ),

        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: InputDecoration(
            labelText: 'Pilih Kategori',
            prefixIcon: const Icon(Icons.category_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          hint: const Text('Semua kategori'),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Semua kategori'),
            ),
            ...{for (final transaction in transactions) transaction.category}
                .toList()
                .map(
                  (category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ),
                ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),

        const SizedBox(height: 16),

        OutlinedButton.icon(
          onPressed: () async {
            final now = DateTime.now();

            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(now.year + 5),
              initialDateRange: _selectedDateRange,
              helpText: 'Pilih Periode Tanggal',
              cancelText: 'BATAL',
              confirmText: 'TERAPKAN',
            );

            if (!mounted || picked == null) return;

            setState(() {
              _selectedDateRange = picked;
            });
          },
          icon: const Icon(Icons.date_range),
          label: Text(
            _selectedDateRange == null
                ? 'Pilih Periode Tanggal'
                : '${_formatDate(_selectedDateRange!.start)} - '
                      '${_formatDate(_selectedDateRange!.end)}',
          ),
        ),

        const SizedBox(height: 8),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedType = 'all';
                _selectedCategory = null;
                _selectedDateRange = null;
              });
            },
            icon: const Icon(Icons.restart_alt),
            label: const Text('Atur Ulang Filter'),
          ),
        ),

        const SizedBox(height: 16),

        ...filteredTransactions.map(
          (transaction) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _openTransactionDetail(transaction),
              borderRadius: BorderRadius.circular(12),
              child: TransactionCard(
                title: transaction.title,
                category: transaction.category,
                date: _formatDate(transaction.transactionDate),
                amount: _formatAmount(transaction.amount),
                isIncome: transaction.isIncome,
              ),
            ),
          ),
        ),

        if (filteredTransactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada transaksi yang sesuai',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, TransactionProvider provider) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Transaksi',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: provider.fetchTransactions,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
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

  Widget _buildSummary(
    BuildContext context,
    List<TransactionModel> transactions,
  ) {
    final totalIncome = transactions
        .where((transaction) => transaction.isIncome)
        .fold<double>(0, (total, transaction) => total + transaction.amount);

    final totalExpense = transactions
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

  String _formatAmount(double amount) {
    return formatRupiah(amount);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
