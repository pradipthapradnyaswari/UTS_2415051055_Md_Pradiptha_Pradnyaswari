import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String _publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static Future<void> initialize() async {
    if (_supabaseUrl.isEmpty || _publishableKey.isEmpty) {
      throw StateError(
        'Supabase URL atau Publishable Key belum dikonfigurasi.',
      );
    }

    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _publishableKey,
    );
  }

  static SupabaseClient get client {
    return Supabase.instance.client;
  }
}
