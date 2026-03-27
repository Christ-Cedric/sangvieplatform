import 'package:flutter/material.dart';
import 'package:sangvie/data/models/hospital_model.dart';
import 'package:sangvie/data/repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _adminRepo = AdminRepository();

  Map<String, dynamic> _globalStats = {};
  Map<String, dynamic> _reportsData = {};
  List<Hospital> _allHospitals = [];
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get globalStats => _globalStats;
  Map<String, dynamic> get reportsData => _reportsData;
  List<Hospital> get allHospitals => _allHospitals;
  List<Map<String, dynamic>> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch global platform stats
  Future<void> fetchGlobalStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _globalStats = await _adminRepo.getGlobalStats();
    } catch (e) {
      _error = "Une erreur est survenue lors de la récupération des rapports globaux.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch all hospitals for administration
  Future<void> fetchHospitals({bool? verified}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // If verified is false, we only want pending ones
      _allHospitals = await _adminRepo.getAllHospitals(
        pendingOnly: verified == false,
      );
    } catch (e) {
      _error = "Une erreur est survenue lors de la récupération des hôpitaux.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch all users for administration
  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allUsers = await _adminRepo.getAllUsers();
    } catch (e) {
      _error = "Une erreur est survenue lors de la récupération des listes utilisateurs.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve a hospital account
  Future<bool> approveHospital(String id) async {
    final success = await _adminRepo.approveHospital(id);
    if (success) {
      await fetchHospitals(); // Refresh the list
    }
    return success;
  }

  /// Suspend/Activate an account
  Future<bool> suspendAccount(String id, String type) async {
    final success = await _adminRepo.suspendAccount(id, type);
    if (success) {
      if (type == 'Hospital') {
        await fetchHospitals();
      } else {
        await fetchUsers();
      }
    }
    return success;
  }

  /// Delete an account
  Future<bool> deleteAccount(String id, String type) async {
    final success = await _adminRepo.deleteEntity(id, type);
    if (success) {
      if (type == 'Hospital') {
        await fetchHospitals();
      } else {
        await fetchUsers();
      }
    }
    return success;
  }

  /// Fetch national reports and detailed stats
  Future<void> fetchReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reportsData = await _adminRepo.getReports();
    } catch (e) {
      _error = "Une erreur est survenue lors de la récupération des rapports détaillés.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
