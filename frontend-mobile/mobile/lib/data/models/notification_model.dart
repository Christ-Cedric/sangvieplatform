class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final String? type; // 'info', 'alert', 'success' etc

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
    this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      date: DateTime.parse(json['createdAt'] ?? json['date'] ?? DateTime.now().toIso8601String()),
      isRead: json['read'] ?? json['isRead'] ?? false,
      type: json['type'],
    );
  }
}
