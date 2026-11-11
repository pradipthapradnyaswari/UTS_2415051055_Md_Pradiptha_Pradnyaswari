import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/financial_tip_model.dart';

class FinancialTipService {
  Future<List<FinancialTip>> fetchFinancialTips() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/financial_tips.json',
      );

      final List<dynamic> jsonData = jsonDecode(jsonString) as List<dynamic>;

      return jsonData
          .map((item) => FinancialTip.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat tips keuangan: $e');
    }
  }
}
