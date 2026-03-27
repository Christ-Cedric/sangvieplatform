import 'package:sangvie/data/models/hospital_model.dart';

class Donation {
  final String id;
  final String? requestId;
  final String donorId;
  final String? hospitalId;
  final String group;
  final String status;
  final int quantityPoches;
  final String date;
  final String typeDon;
  final Hospital? hospital;

  Donation({
    required this.id,
    this.requestId,
    required this.donorId,
    this.hospitalId,
    required this.group,
    this.status = 'pending',
    this.quantityPoches = 0,
    required this.date,
    this.typeDon = 'Don de sang total',
    this.hospital,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['_id'] ?? '',
      requestId: json['requestId'],
      donorId: json['donorId'] ?? '',
      hospitalId: json['hospitalId'],
      group: json['groupeSanguin'] ?? json['group'] ?? '',
      status: json['statut'] ?? json['status'] ?? 'pending',
      quantityPoches: json['quantitePoches'] ?? 0,
      date: json['dateDon'] ?? json['createdAt'] ?? '',
      typeDon: json['typeDon'] ?? 'Don de sang total',
      hospital: json['hopital'] != null ? Hospital.fromJson(json['hopital']) : (json['hospital'] != null ? Hospital.fromJson(json['hospital']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'requestId': requestId,
      'donorId': donorId,
      'hospitalId': hospitalId,
      'groupeSanguin': group,
      'statut': status,
      'quantitePoches': quantityPoches,
      'dateDon': date,
      'typeDon': typeDon,
      'hopital': hospital?.toJson(),
    };
  }
}
