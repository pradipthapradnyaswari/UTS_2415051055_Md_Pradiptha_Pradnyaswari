import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/transaction_model.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;

  final List<String> _expenseCategories = [
    'Makanan',
    'Transportasi',
    'Obat-obatan',
    'Belanjaan',
    'Uang Sewa',
    'Hiburan',
    'Lainnya',
  ];

  final List<String> _incomeCategories = [
    'Uang Saku',
    'Gaji',
    'Hadiah',
    'Tabungan',
    'Lainnya',
  ];

  List<String> get _categories {
    return _selectedType == 'income' ? _incomeCategories : _expenseCategories;
  }

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;

    _titleController = TextEditingController(text: transaction.title);

    _amountController = TextEditingController(
      text: transaction.amount.toStringAsFixed(0),
    );

    _noteController = TextEditingController(text: transaction.note);

    _selectedType = transaction.type;
    _selectedCategory = _categories.contains(transaction.category)
        ? transaction.category
        : _categories.first;
    _selectedDate = transaction.transactionDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (!mounted || pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedTransaction = TransactionModel(
      id: widget.transaction.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      type: _selectedType,
      category: _selectedCategory,
      note: _noteController.text.trim(),
      transactionDate: _selectedDate,
      createdAt: widget.transaction.createdAt,
    );

    Navigator.pop(context, updatedTransaction);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Transaksi')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jenis Transaksi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton(
                        title: 'Pemasukan',
                        type: 'income',
                        icon: Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeButton(
                        title: 'Pengeluaran',
                        type: 'expense',
                        icon: Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildLabel(context, 'Nama Transaksi'),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Makan siang',
                    prefixIcon: Icon(Icons.edit_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama transaksi wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildLabel(context, 'Nominal'),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'Contoh: 25000',
                    prefixText: 'Rp ',
                    prefixIcon: Icon(Icons.payments_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nominal wajib diisi';
                    }

                    final amount = double.tryParse(value);

                    if (amount == null || !amount.isFinite || amount <= 0) {
                      return 'Masukkan nominal yang valid';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildLabel(context, 'Kategori'),
                DropdownButtonFormField<String>(
                  initialValue: _categories.contains(_selectedCategory)
                      ? _selectedCategory
                      : _categories.first,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                _buildLabel(context, 'Tanggal Transaksi'),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/'
                      '${_selectedDate.month.toString().padLeft(2, '0')}/'
                      '${_selectedDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel(context, 'Catatan (Opsional)'),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Tambahkan catatan jika ada',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTypeButton({
    required String title,
    required String type,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedType == type;

    final color = type == 'income'
        ? theme.colorScheme.secondary
        : theme.colorScheme.error;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedType = type;

          if (!_categories.contains(_selectedCategory)) {
            _selectedCategory = _categories.first;
          }
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? color.withValues(alpha: 0.12)
            : theme.colorScheme.surface,
        foregroundColor: isSelected ? color : theme.colorScheme.onSurface,
        side: BorderSide(
          color: isSelected ? color : theme.colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        children: [Icon(icon), const SizedBox(height: 6), Text(title)],
      ),
    );
  }
}
