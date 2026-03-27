import 'package:flutter/material.dart';
import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/data/models/blood_request_model.dart';
import 'package:sangvie/data/models/donation_model.dart';
import 'package:sangvie/data/repositories/blood_request_repository.dart';
import 'package:sangvie/data/repositories/donation_repository.dart';

class DonorProvider extends ChangeNotifier {
  final BloodRequestRepository _requestRepo = BloodRequestRepository();
  final DonationRepository _donationRepo = DonationRepository();

  List<BloodRequest> _requests = [];
  List<Donation> _history = [];
  bool _isLoading = false;
  bool _isActive = true;
  String? _error;

  List<BloodRequest> get requests => _requests;
  List<Donation> get history => _history;
  bool get isLoading => _isLoading;
  bool get isActive => _isActive;
  String? get error => _error;

  /// Fetch blood requests for the donor's feed
  Future<void> fetchRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _requests = await _requestRepo.getAllRequests();
      // On pourrait aussi récupérer le statut ici si le backend l'inclut dans /me
    } catch (e) {
      _error = "Une erreur est survenue lors de la récupération des demandes.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle visibility (disponibilité) on/off
  Future<void> toggleStatus(bool val) async {
    _isActive = val;
    notifyListeners();
    
    try {
      await ApiService.put(ApiConstants.updateDonorStatus, {'isActive': val});
    } catch (e) {
      debugPrint("Error toggling status: $e");
    }
  }

  /// Fetch the donor's donation history
  Future<void> fetchHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _history = await _donationRepo.getMyDonations();
    } catch (e) {
      _error = "Impossible de charger votre historique.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Respond to a request
  Future<bool> respondToRequest(String requestId, {String? message}) async {
    final success = await _donationRepo.respondToRequest(requestId, message: message);
    if (success) {
      await fetchRequests(); // Refresh list to reflect changes
    }
    return success;
  }
}
