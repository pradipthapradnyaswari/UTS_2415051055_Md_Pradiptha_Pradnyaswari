import 'package:flutter/foundation.dart';

import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import 'notification_provider.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;

  TransactionProvider(this._repository);

  NotificationProvider? _notificationProvider;

  void setNotificationProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }

  Future<void> _createNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      await _notificationProvider?.addNotification(
        title: title,
        body: body,
        type: type,
      );
    } catch (e) {
      debugPrint('Gagal menyimpan notifikasi transaksi: $e');
    }
  }

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTransactions() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _transactions = await _repository.getTransactions();
    } catch (e) {
      _errorMessage = 'Gagal mengambil transaksi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      final newTransaction = await _repository.addTransaction(transaction);

      _transactions.insert(0, newTransaction);
      _sortTransactions();
      notifyListeners();

      await _createNotification(
        title: 'Transaksi berhasil ditambahkan',
        body: '${newTransaction.title} berhasil dicatat.',
        type: 'add',
      );

      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambahkan transaksi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    try {
      final updatedTransaction = await _repository.updateTransaction(
        transaction,
      );

      final index = _transactions.indexWhere(
        (item) => item.id == updatedTransaction.id,
      );

      if (index != -1) {
        _transactions[index] = updatedTransaction;
      }

      _sortTransactions();
      notifyListeners();

      await _createNotification(
        title: 'Transaksi berhasil diperbarui',
        body: '${updatedTransaction.title} berhasil diperbarui.',
        type: 'update',
      );

      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui transaksi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      final matchingTransactions = _transactions.where((item) => item.id == id);

      final deletedTransaction = matchingTransactions.isEmpty
          ? null
          : matchingTransactions.first;

      await _repository.deleteTransaction(id);

      _transactions.removeWhere((item) => item.id == id);
      notifyListeners();

      if (deletedTransaction != null) {
        await _createNotification(
          title: 'Transaksi berhasil dihapus',
          body: '${deletedTransaction.title} telah dihapus.',
          type: 'delete',
        );
      }

      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus transaksi: $e';
      notifyListeners();
      return false;
    }
  }

  void _sortTransactions() {
    _transactions.sort(
      (a, b) => b.transactionDate.compareTo(a.transactionDate),
    );
  }
}
