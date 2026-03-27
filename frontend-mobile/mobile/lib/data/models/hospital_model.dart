class Hospital {
  final String id;
  final String nom;
  final String email;
  final String contact;
  final String? numeroAgrement;
  final String? region;
  final String? localisation;
  final bool verified;
  final String role;
  final String? status;
  final String? address;

  Hospital({
    required this.id,
    required this.nom,
    required this.email,
    required this.contact,
    this.numeroAgrement,
    this.region,
    this.localisation,
    this.verified = false,
    this.role = 'hospital',
    this.status,
    this.address,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['_id'] ?? '',
      nom: json['nom'] ?? json['nomHopital'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
      numeroAgrement: json['numeroAgrement'],
      region: json['region'],
      localisation: json['localisation'],
      verified: json['verified'] ?? false,
      role: json['role'] ?? 'hospital',
      status: json['status'],
      address: json['adresse'] ?? json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nom': nom,
      'email': email,
      'contact': contact,
      'numeroAgrement': numeroAgrement,
      'region': region,
      'localisation': localisation,
      'verified': verified,
      'role': role,
      'status': status,
      'adresse': address,
    };
  }
}
