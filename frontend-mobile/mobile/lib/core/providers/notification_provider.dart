import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/auth_service.dart';
import 'package:sangvie/data/models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  final AuthService _auth;

  NotificationProvider(this._auth) {
    if (_auth.currentUser != null) {
      fetchNotifications();
    }
  }

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    final token = _auth.currentUser?.token;
    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.notifications),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        _notifications = data.map((n) => NotificationModel.fromJson(n)).toList();
        // Sort by date descending
        _notifications.sort((a, b) => b.date.compareTo(a.date));
      } else {
        // Fallback for demo/dev if endpoint doesn't exist yet
        _notifications = _getMockNotifications();
      }
    } catch (e) {
      print("Error fetching notifications: $e");
      _notifications = _getMockNotifications();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final token = _auth.currentUser?.token;
    if (token == null) return;

    try {
      await http.put(
        Uri.parse(ApiConstants.markNotificationRead(id)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final n = _notifications[index];
        _notifications[index] = NotificationModel(
          id: n.id,
          title: n.title,
          message: n.message,
          date: n.date,
          isRead: true,
          type: n.type,
        );
        notifyListeners();
      }
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  List<NotificationModel> _getMockNotifications() {
    return [
      NotificationModel(
        id: '1',
        title: 'Urgence Vitale',
        message: 'L\'Hôpital Central a besoin de sang O- en urgence.',
        date: DateTime.now().subtract(const Duration(minutes: 45)),
        type: 'alert',
      ),
      NotificationModel(
        id: '2',
        title: 'Don validé',
        message: 'Votre dernier don de sang a été validé. Merci !',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        type: 'success',
      ),
      NotificationModel(
        id: '3',
        title: 'Nouveau Message',
        message: 'Un hôpital vous a envoyé un message.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: 'info',
      ),
    ];
  }
}
