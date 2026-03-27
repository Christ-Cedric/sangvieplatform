import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/data/models/donation_model.dart';

class DonationRepository {
  /// Récupérer l'historique de mes dons (donneur)
  Future<List<Donation>> getMyDonations() async {
    final data = await ApiService.get(ApiConstants.myDonations);
    if (data == null) return [];
    
    final list = data is List ? data : (data['donations'] ?? data['data'] ?? []);
    return (list as List)
        .map((d) => Donation.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  /// Récupérer les dons d'un hôpital
  Future<List<Donation>> getHospitalDonations() async {
    // Supposons une route spécifique, sinon on utilise hospitalStats et on transforme
    // En l'absence de route, on pourrait adapter myRequests si c'est combiné
    final data = await ApiService.get('${ApiConstants.baseUrl}/hospitals/my-donations');
    if (data == null) return [];
    
    final list = data is List ? data : (data['donations'] ?? data['data'] ?? []);
    return (list as List)
        .map((d) => Donation.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  /// Créer un don (souvent déclenché par l'action 'respondToRequest')
  Future<bool> respondToRequest(String requestId, {String? message}) async {
    final res = await ApiService.post(
      ApiConstants.respondToRequest(requestId), 
      {'message': message},
    );
    return res != null;
  }
}
