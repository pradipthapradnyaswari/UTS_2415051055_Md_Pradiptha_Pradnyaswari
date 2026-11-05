import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/exchange_rate_provider.dart';

class ExchangeRateCard extends StatelessWidget {
  const ExchangeRateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExchangeRateProvider>();
    final theme = Theme.of(context);
    final exchangeRate = provider.exchangeRate;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.currency_exchange, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Kurs Mata Uang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Perbarui kurs',
                  onPressed: provider.isLoading
                      ? null
                      : provider.fetchExchangeRates,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (provider.isLoading && exchangeRate == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.errorMessage != null && exchangeRate == null)
              _buildError(context, provider)
            else if (exchangeRate != null && exchangeRate.idrRate != null) ...[
              const Text('1 USD setara dengan', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 6),
              Text(
                'Rp ${_formatRate(exchangeRate.idrRate!)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Terakhir diperbarui: ${exchangeRate.lastUpdateUtc}',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (provider.errorMessage != null)
                Text(
                  'Pembaruan terbaru gagal. Menampilkan data sebelumnya.',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.error,
                  ),
                ),
            ] else
              const Text('Data kurs IDR tidak tersedia.'),

            const SizedBox(height: 12),
            const Divider(),
            Text(
              'Sumber: ExchangeRate-API',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, ExchangeRateProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gagal mengambil data kurs.'),
        TextButton.icon(
          onPressed: provider.fetchExchangeRates,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba lagi'),
        ),
      ],
    );
  }

  String _formatRate(double rate) {
    return rate
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
  }
}
