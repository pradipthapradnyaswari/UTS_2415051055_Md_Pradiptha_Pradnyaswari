import 'package:flutter/material.dart';

import 'app.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';

const String studentName = 'Md. Pradiptha Pradnyaswari';
const String studentId = '2415051055';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();
  await NotificationService.instance.initialize();

  runApp(const FinoteApp());
}
