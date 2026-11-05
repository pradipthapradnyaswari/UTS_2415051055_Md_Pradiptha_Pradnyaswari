import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/exchange_rate_model.dart';

class ExchangeRateService {
  static const String _baseUrl = 'https://open.er-api.com/v6/latest/USD';

  Future<ExchangeRateModel> fetchExchangeRates() async {
    final response = await http
        .get(Uri.parse(_baseUrl))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data kurs. Kode: ${response.statusCode}',
      );
    }

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    if (jsonData['result'] != 'success') {
      throw Exception('API gagal mengembalikan data kurs.');
    }

    return ExchangeRateModel.fromJson(jsonData);
  }
}
