class BloodRequest {
  final String id;
  final String? hospitalId;
  final String hospital;
  final String group;
  final String urgency; // 'critical' | 'moderate' | 'low'
  final int quantity;
  final String? reason;
  final String description;
  final String status; // 'active' | 'fulfilled' | 'pending'
  final String date;
  final int? responses;

  BloodRequest({
    required this.id,
    this.hospitalId,
    required this.hospital,
    required this.group,
    required this.urgency,
    this.quantity = 1,
    this.reason,
    required this.description,
    this.status = 'active',
    required this.date,
    this.responses,
  });

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    // Support both backend format and legacy mock format
    final hosp = json['hopital'] ?? json['hospital'] ?? json['hospitalId'];
    String hospName = '';
    String hospId = '';
    if (hosp is Map) {
      hospName = hosp['nom'] ?? hosp['nomHopital'] ?? '';
      hospId = hosp['_id'] ?? '';
    } else if (hosp is String) {
      hospName = hosp;
      hospId = hosp;
    }

    final backendUrgency = json['niveauUrgence'] ?? json['urgence'] ?? json['urgency'];
    String mappedUrgency = 'moderate';
    if (backendUrgency == 'critique' || backendUrgency == 'critical') {
      mappedUrgency = 'critical';
    } else if (backendUrgency == 'urgent' || backendUrgency == 'moderate') {
      mappedUrgency = 'moderate';
    } else {
      mappedUrgency = 'low';
    }

    final backendStatus = json['statut'] ?? json['status'];
    String mappedStatus = 'active';
    if (backendStatus == 'en_attente' || backendStatus == 'pending' || backendStatus == 'active') {
      mappedStatus = 'active';
    } else if (backendStatus == 'satisfait' || backendStatus == 'fulfilled') {
      mappedStatus = 'fulfilled';
    } else if (backendStatus == 'annule' || backendStatus == 'cancelled') {
      mappedStatus = 'cancelled';
    }

    return BloodRequest(
      id: json['_id'] ?? json['id']?.toString() ?? '',
      hospitalId: hospId.isNotEmpty ? hospId : null,
      hospital: hospName.isNotEmpty ? hospName : 'Hôpital',
      group: json['groupeSanguin'] ?? json['group'] ?? '',
      urgency: mappedUrgency,
      quantity: json['quantitePoches'] ?? json['quantite'] ?? json['quantity'] ?? 1,
      reason: json['description'] ?? json['raison'] ?? json['reason'],
      description: json['description'] ?? json['raison'] ?? json['reason'] ?? '',
      status: mappedStatus,
      date: _formatDate(json['createdAt'] ?? json['dateDemande'] ?? json['date']),
      responses: json['reponses'] ?? json['responses'],
    );
  }

  static String _formatDate(dynamic raw) {
    if (raw == null) return 'À l\'instant';
    if (raw is String) {
      try {
        final dt = DateTime.parse(raw);
        final diff = DateTime.now().difference(dt);
        if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
        if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
        if (diff.inDays == 1) return 'Hier';
        return 'Il y a ${diff.inDays} jours';
      } catch (_) {
        return raw;
      }
    }
    return raw.toString();
  }
}
