import 'package:flutter/foundation.dart';

import '../models/exchange_rate_model.dart';
import '../repositories/exchange_rate_repository.dart';

class ExchangeRateProvider extends ChangeNotifier {
  final ExchangeRateRepository _repository;

  ExchangeRateProvider(this._repository);

  ExchangeRateModel? _exchangeRate;
  bool _isLoading = false;
  String? _errorMessage;

  ExchangeRateModel? get exchangeRate => _exchangeRate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchExchangeRates() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _exchangeRate = await _repository.getExchangeRates();
    } catch (e) {
      _errorMessage = 'Gagal mengambil data kurs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
