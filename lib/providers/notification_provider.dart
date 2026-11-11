import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _storageKey = 'finote_notifications';

  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  Future<void> loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_storageKey);

      if (savedData == null) return;

      final List<dynamic> decodedData = jsonDecode(savedData);

      _notifications
        ..clear()
        ..addAll(
          decodedData.map(
            (item) =>
                NotificationModel.fromJson(Map<String, dynamic>.from(item)),
          ),
        );

      _sortNotifications();
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal membaca riwayat notifikasi: $e');
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final encodedData = jsonEncode(
        _notifications.map((notification) => notification.toJson()).toList(),
      );

      await prefs.setString(_storageKey, encodedData);
    } catch (e) {
      debugPrint('Gagal menyimpan riwayat notifikasi: $e');
    }
  }

  Future<void> addNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().microsecondsSinceEpoch,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      type: type,
    );

    _notifications.insert(0, notification);

    await _saveNotifications();
    notifyListeners();

    try {
      await NotificationService.instance.showNotification(
        id: notification.id.remainder(2147483647),
        title: notification.title,
        body: notification.body,
      );
    } catch (e) {
      debugPrint('Gagal menampilkan notifikasi Android: $e');
    }
  }

  Future<void> markAsRead(int id) async {
    final index = _notifications.indexWhere(
      (notification) => notification.id == id,
    );

    if (index == -1 || _notifications[index].isRead) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);

    await _saveNotifications();
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;

    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }

    await _saveNotifications();
    notifyListeners();
  }

  Future<void> deleteNotification(int id) async {
    _notifications.removeWhere((notification) => notification.id == id);

    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearNotifications() async {
    _notifications.clear();

    await _saveNotifications();
    notifyListeners();
  }

  void _sortNotifications() {
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
