import 'package:sangvie/core/services/auth_service.dart';

class UserModel {
  final String id;
  final String nom;
  final String? prenom;
  final String email;
  final String? telephone;
  final String role;
  final String? groupeSanguin;
  final String? token;
  final bool? verified;

  UserModel({
    required this.id,
    required this.nom,
    this.prenom,
    required this.email,
    this.telephone,
    required this.role,
    this.groupeSanguin,
    this.token,
    this.verified,
  });

  String get fullName => prenom != null ? "$prenom $nom" : nom;

  UserType get userType {
    switch (role) {
      case 'admin':
        return UserType.admin;
      case 'hospital':
        return UserType.hospital;
      default:
        return UserType.donor;
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      nom: json['nom'] ?? json['nomUtilisateur'] ?? '',
      prenom: json['prenom'],
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? json['contact'],
      role: json['role'] ?? 'user',
      groupeSanguin: json['groupeSanguin'],
      token: json['token'],
      verified: json['verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'role': role,
      'groupeSanguin': groupeSanguin,
      'token': token,
      'verified': verified,
    };
  }
}

