import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/donor_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DonorHistoryScreen extends StatefulWidget {
  const DonorHistoryScreen({super.key});

  @override
  State<DonorHistoryScreen> createState() => _DonorHistoryScreenState();
}

class _DonorHistoryScreenState extends State<DonorHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allHistory = [];
  List<Map<String, dynamic>> _filteredHistory = [];

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchHistory() async {
    final data = await ApiService.get(ApiConstants.myDonations);
    if (data == null) return [];
    final list = data is List ? data : (data['donations'] ?? data['data'] ?? []);
    _allHistory = List<Map<String, dynamic>>.from(list as List);
    _onSearch();
    return _allHistory;
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredHistory = q.isEmpty
          ? _allHistory
          : _allHistory.where((h) {
              final hosp = h['hopital'] ?? h['hospital'] ?? h['hospitalId'];
              final hospName = hosp is Map
                  ? hosp['nom'] ?? hosp['nomHopital'] ?? 'Hôpital'
                  : hosp?.toString() ?? 'Hôpital';
              final type = h['typeDon'] ?? 'Don de sang total';
              return hospName.toLowerCase().contains(q) ||
                  type.toLowerCase().contains(q);
            }).toList();
    });
  }

  void _refresh() {
    setState(() {
      _historyFuture = _fetchHistory();
    });
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString());
      final months = [
        '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DonorLayout(
      child: RefreshIndicator(
        onRefresh: () async => _refresh(),
        color: AppColors.primary,
        displacement: 20,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.lg),

              SangVieInput(
                hint: 'Rechercher par hôpital ou type...',
                prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.secondary),
                controller: _searchController,
                textInputAction: TextInputAction.search,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppSpacing.xl),

              FutureBuilder<List<Map<String, dynamic>>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _allHistory.isEmpty) {
                    return _buildLoadingState();
                  }

                  if (_filteredHistory.isEmpty) {
                    return _buildEmptyState().animate().fadeIn();
                  }

                  final data = _filteredHistory;
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final d = data[i];
                      final hosp = d['hopital'] ?? d['hospital'] ?? d['hospitalId'];
                      final hospName = hosp is Map
                          ? hosp['nom'] ?? hosp['nomHopital'] ?? 'Hôpital'
                          : hosp?.toString() ?? 'Hôpital';
                      final group = d['groupeSanguin'] ?? d['group'] ?? '';
                      final status = d['statut'] ?? d['status'] ?? 'valide';
                      final date = _formatDate(d['dateDon'] ?? d['createdAt']);
                      final type = d['typeDon'] ?? 'Don de sang total';

                      return _buildHistoryCard(
                        hospital: hospName,
                        date: date,
                        status: status,
                        type: type,
                        group: group,
                        onTap: () => _showDonationDetails(d, hospName, date, status, type, group),
                      ).animate().fadeIn(delay: (100 * i).ms).slideX(begin: 0.05, end: 0);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDonationDetails(Map<String, dynamic> data, String hospital, String date, String status, String type, String group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isFulfilled = status == 'valide' || status == 'fulfilled' || status == 'success';
        
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SangVieTypography.h2('Détails du don'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFulfilled ? AppColors.successGreen.withOpacity(0.1) : AppColors.secondarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      isFulfilled ? 'Terminé' : 'Prévu',
                      style: TextStyle(
                        color: isFulfilled ? AppColors.successGreen : AppColors.secondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildDetailRow(LucideIcons.building2, 'Lieu', hospital),
              _buildDetailRow(LucideIcons.calendar, 'Date', date),
              _buildDetailRow(LucideIcons.activity, 'Type de don', type),
              if (group.isNotEmpty)
                _buildDetailRow(LucideIcons.droplet, 'Groupe sanguin concerné', group),
              if (data['quantitePoches'] != null)
                _buildDetailRow(LucideIcons.shoppingBag, 'Quantité (poches)', data['quantitePoches'].toString()),
              const SizedBox(height: AppSpacing.xxl),
              SangVieButton(
                label: 'Fermer',
                isFullWidth: true,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: AppColors.foreground, fontSize: 15, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SangVieTypography.h1('Mon Historique'),
        const SizedBox(height: 4),
        const Text(
          'Suivi de mes actes de générosité',
          style: TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildHistoryCard({
    required String hospital,
    required String date,
    required String status,
    required String type,
    required String group,
    VoidCallback? onTap,
  }) {
    final isFulfilled = status == 'valide' || status == 'fulfilled' || status == 'success';
    
    return SangVieCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md + 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isFulfilled ? AppColors.successGreen.withOpacity(0.08) : AppColors.secondarySoft.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              isFulfilled ? LucideIcons.checkCircle2 : LucideIcons.clock,
              color: isFulfilled ? AppColors.successGreen : AppColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Text(type, style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 12, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(date, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          if (group.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: Text(
                group,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      color: AppColors.inputBackground,
      hasBorder: false,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.border.withOpacity(0.5))),
            child: const Icon(LucideIcons.history, size: 40, color: AppColors.secondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Aucun don pour le moment', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 4),
          const Text(
            'Votre impact commencera dès votre premier passage en centre.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondary, fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.xl),
          SangVieButton(
            label: 'Trouver un hôpital', 
            onPressed: () => context.go('/donor/map'),
            icon: const Icon(LucideIcons.map, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
      ),
    );
  }
}
