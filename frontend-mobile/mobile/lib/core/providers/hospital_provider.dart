import 'package:flutter/material.dart';
import 'package:sangvie/data/models/blood_request_model.dart';
import 'package:sangvie/data/repositories/blood_request_repository.dart';
import 'package:sangvie/data/repositories/hospital_repository.dart';

class HospitalProvider extends ChangeNotifier {
  final BloodRequestRepository _requestRepo = BloodRequestRepository();
  final HospitalRepository _hospitalRepo = HospitalRepository();

  List<BloodRequest> _myRequests = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _error;

  List<BloodRequest> get myRequests => _myRequests;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch dashboard stats for the hospital
  Future<void> fetchDashboardData(String hospitalId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _hospitalRepo.getHospitalStats();
      _myRequests = await _requestRepo.getHospitalRequests(hospitalId);
    } catch (e) {
      _error = "Une erreur est survenue lors de la récupération des données de votre tableau de bord.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new blood request (hospital)
  Future<BloodRequest?> createRequest(Map<String, dynamic> body, String hospitalId) async {
    final res = await _requestRepo.createRequest(body);
    if (res != null) {
      await fetchDashboardData(hospitalId); // Refresh to include newly created request
    }
    return res;
  }

  /// Close an existing request
  Future<bool> closeRequest(String id, String hospitalId) async {
    final res = await _requestRepo.closeRequest(id);
    if (res) {
       await fetchDashboardData(hospitalId); // Refresh to reflect change
    }
    return res;
  }
}
