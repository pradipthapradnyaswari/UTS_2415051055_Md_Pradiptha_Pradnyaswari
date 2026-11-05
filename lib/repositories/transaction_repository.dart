import '../models/transaction_model.dart';
import '../services/supabase_service.dart';

class TransactionRepository {
  Future<List<TransactionModel>> getTransactions() async {
    final response = await SupabaseService.client
        .from('transactions')
        .select()
        .order('transaction_date', ascending: false)
        .order('created_at', ascending: false);

    return response.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    final data = transaction.toJson()
      ..remove('id')
      ..remove('created_at');

    final response = await SupabaseService.client
        .from('transactions')
        .insert(data)
        .select()
        .single();

    return TransactionModel.fromJson(response);
  }

  Future<TransactionModel> updateTransaction(
    TransactionModel transaction,
  ) async {
    final data = transaction.toJson()
      ..remove('id')
      ..remove('created_at');

    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await SupabaseService.client
        .from('transactions')
        .update(data)
        .eq('id', transaction.id)
        .select()
        .single();

    return TransactionModel.fromJson(response);
  }

  Future<void> deleteTransaction(String id) async {
    await SupabaseService.client.from('transactions').delete().eq('id', id);
  }
}
