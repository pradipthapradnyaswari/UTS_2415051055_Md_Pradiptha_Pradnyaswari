class ExchangeRateModel {
  final String result;
  final String baseCode;
  final String lastUpdateUtc;
  final String nextUpdateUtc;
  final Map<String, double> rates;

  const ExchangeRateModel({
    required this.result,
    required this.baseCode,
    required this.lastUpdateUtc,
    required this.nextUpdateUtc,
    required this.rates,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>;

    return ExchangeRateModel(
      result: json['result'] as String,
      baseCode: json['base_code'] as String,
      lastUpdateUtc: json['time_last_update_utc'] as String,
      nextUpdateUtc: json['time_next_update_utc'] as String,
      rates: rawRates.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  double? get idrRate => rates['IDR'];
}
