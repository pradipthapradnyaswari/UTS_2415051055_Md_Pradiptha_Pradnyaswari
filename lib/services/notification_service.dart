import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('ic_notification');

    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: settings);

    _isInitialized = true;
  }

  Future<bool> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final granted = await androidPlugin?.requestNotificationsPermission();

    return granted ?? false;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final granted = await requestPermission();

    if (!granted) {
      debugPrint('Izin notifikasi Android belum diberikan.');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'finote_transactions',
      'Notifikasi Transaksi',
      channelDescription: 'Informasi aktivitas transaksi Finote',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}
