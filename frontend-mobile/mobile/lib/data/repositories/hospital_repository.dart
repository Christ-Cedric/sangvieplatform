import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/data/models/hospital_model.dart';

class HospitalRepository {
  /// Récupérer tous les hôpitaux (filtrables par vérification)
  Future<List<Hospital>> getAllHospitals({bool? verified}) async {
    String url = ApiConstants.hospitals;
    if (verified != null) {
      url += '?verified=$verified';
    }
    
    final data = await ApiService.get(url);
    if (data == null) return [];
    
    final list = data is List ? data : (data['hospitals'] ?? data['data'] ?? []);
    return (list as List)
        .map((h) => Hospital.fromJson(h as Map<String, dynamic>))
        .toList();
  }

  /// Approuver un hôpital (admin)
  Future<bool> approveHospital(String id) async {
    final res = await ApiService.put(
      ApiConstants.hospitalById(id), 
      {'verified': true, 'status': 'active'}
    );
    return res != null;
  }

  /// Récupérer les stats d'un hôpital
  Future<Map<String, dynamic>> getHospitalStats() async {
    final data = await ApiService.get(ApiConstants.hospitalStats);
    return data ?? {};
  }
}
