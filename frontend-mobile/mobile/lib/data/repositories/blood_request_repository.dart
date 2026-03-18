import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/data/models/blood_request_model.dart';

class BloodRequestRepository {
  /// Demandes urgentes (feed donneur)
  Future<List<BloodRequest>> getUrgentRequests() async {
    final data = await ApiService.get('${ApiConstants.requests}?urgence=critical&statut=active');
    if (data == null) return [];
    final list = data is List ? data : (data['requests'] ?? data['data'] ?? []);
    return (list as List)
        .map((e) => BloodRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Toutes les demandes (feed donneur - général)
  Future<List<BloodRequest>> getAllRequests() async {
    final data = await ApiService.get('${ApiConstants.requests}?statut=active');
    if (data == null) return [];
    final list = data is List ? data : (data['requests'] ?? data['data'] ?? []);
    return (list as List)
        .map((e) => BloodRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Demandes d'un hôpital spécifique
  Future<List<BloodRequest>> getHospitalRequests(String hospitalId) async {
    final data = await ApiService.get(ApiConstants.myRequests);
    if (data == null) return [];
    final list = data is List ? data : (data['requests'] ?? data['data'] ?? []);
    return (list as List)
        .map((e) => BloodRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Créer une demande de sang (hôpital)
  Future<BloodRequest?> createRequest(Map<String, dynamic> body) async {
    final data = await ApiService.post(ApiConstants.createHospitalRequest, body);
    if (data == null) return null;
    return BloodRequest.fromJson(data['request'] ?? data);
  }

  /// Clôturer une demande
  Future<bool> closeRequest(String id) async {
    final data = await ApiService.put(
      '$baseUrl/hospitals/request/$id',
      {'statut': 'satisfait'},
    );
    return data != null;
  }

  /// Voir les réponses à une demande
  Future<List<Map<String, dynamic>>> getRequestResponses(String requestId) async {
    final data = await ApiService.get('$baseUrl/hospitals/request-responses/$requestId');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data);
  }

  /// Confirmer un don
  Future<bool> confirmDonation(String donationId) async {
    final data = await ApiService.put('$baseUrl/hospitals/confirm-donation/$donationId', {});
    return data != null;
  }

  static String get baseUrl => ApiConstants.baseUrl;
}
