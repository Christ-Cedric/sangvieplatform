import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/data/models/hospital_model.dart';

class AdminRepository {
  /// Récupérer les statistiques globales pour le dashboard admin
  Future<Map<String, dynamic>> getGlobalStats() async {
    final data = await ApiService.get(ApiConstants.adminStats);
    if (data == null) return {};
    return Map<String, dynamic>.from(data);
  }

  /// Récupérer la liste des utilisateurs (admin)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final data = await ApiService.get(ApiConstants.adminUsers);
    if (data == null) return [];

    final list = data is List ? data : (data['users'] ?? data['data'] ?? []);
    return List<Map<String, dynamic>>.from(list as List);
  }

  /// Récupérer la liste des hôpitaux (admin)
  Future<List<Hospital>> getAllHospitals({bool pendingOnly = false}) async {
    final endpoint =
        pendingOnly ? ApiConstants.pendingHospitals : ApiConstants.adminHospitals;
    final data = await ApiService.get(endpoint);
    if (data == null) return [];

    final list =
        data is List ? data : (data['hospitals'] ?? data['data'] ?? []);
    return (list as List)
        .map((h) => Hospital.fromJson(h as Map<String, dynamic>))
        .toList();
  }

  /// Approuver un hôpital (admin)
  Future<bool> approveHospital(String id) async {
    final res = await ApiService.put(ApiConstants.verifyHospital(id), {});
    return res != null;
  }

  /// Suspendre/Réactiver un compte
  Future<bool> suspendAccount(String id, String type) async {
    final res = await ApiService.put(ApiConstants.suspendAccount(id, type), {});
    return res != null;
  }

  /// Supprimer/Désactiver un utilisateur/hôpital
  Future<bool> deleteEntity(String id, String type) async {
    final res = await ApiService.delete(ApiConstants.deleteAccount(id, type));
    return res == true;
  }

  /// Récupérer les rapports détaillés (admin)
  Future<Map<String, dynamic>> getReports() async {
    final data = await ApiService.get(ApiConstants.adminReports);
    if (data == null) return {};
    return Map<String, dynamic>.from(data);
  }
}
