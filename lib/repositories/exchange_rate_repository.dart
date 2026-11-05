import '../models/exchange_rate_model.dart';
import '../services/exchange_rate_service.dart';

class ExchangeRateRepository {
  final ExchangeRateService _service;

  ExchangeRateRepository({ExchangeRateService? service})
    : _service = service ?? ExchangeRateService();

  Future<ExchangeRateModel> getExchangeRates() {
    return _service.fetchExchangeRates();
  }
}
