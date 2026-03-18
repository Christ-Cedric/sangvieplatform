import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/data/models/message_model.dart';

class MessageRepository {
  Future<List<ConversationModel>> getConversations() async {
    final response = await ApiService.get('${ApiConstants.baseUrl}/messages/conversations');
    if (response != null && response is List) {
      return response.map((json) => ConversationModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<MessageModel>> getMessages(String otherId) async {
    final response = await ApiService.get('${ApiConstants.baseUrl}/messages/$otherId');
    if (response != null && response is List) {
      return response.map((json) => MessageModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<MessageModel?> sendMessage({
    required String receiverId,
    required String receiverType,
    required String content,
    String? requestId,
    String? donationId,
  }) async {
    final data = {
      'receiverId': receiverId,
      'receiverType': receiverType,
      'content': content,
      if (requestId != null) 'requestId': requestId,
      if (donationId != null) 'donationId': donationId,
    };
    final response = await ApiService.post('${ApiConstants.baseUrl}/messages', data);
    if (response != null) {
      return MessageModel.fromJson(response);
    }
    return null;
  }
}
