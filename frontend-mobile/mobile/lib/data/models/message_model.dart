class MessageModel {
  final String id;
  final String senderId;
  final String senderType;
  final String receiverId;
  final String receiverType;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final String? requestId;
  final String? donationId;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.receiverId,
    required this.receiverType,
    required this.content,
    required this.createdAt,
    required this.isRead,
    this.requestId,
    this.donationId,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'],
      senderId: json['senderId'],
      senderType: json['senderType'],
      receiverId: json['receiverId'],
      receiverType: json['receiverType'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      requestId: json['requestId'],
      donationId: json['donationId'],
    );
  }
}

class ConversationModel {
  final String otherId;
  final String otherType;
  final String lastMessage;
  final DateTime date;
  final bool isRead;

  ConversationModel({
    required this.otherId,
    required this.otherType,
    required this.lastMessage,
    required this.date,
    required this.isRead,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      otherId: json['otherId'],
      otherType: json['otherType'],
      lastMessage: json['lastMessage'],
      date: DateTime.parse(json['date']),
      isRead: json['isRead'] ?? false,
    );
  }
}
