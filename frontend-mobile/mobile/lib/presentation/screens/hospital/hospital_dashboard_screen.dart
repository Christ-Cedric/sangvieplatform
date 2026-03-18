import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/core/services/auth_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/data/models/blood_request_model.dart';
import 'package:sangvie/data/repositories/blood_request_repository.dart';
import 'package:sangvie/presentation/widgets/hospital_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HospitalDashboardScreen extends StatefulWidget {
  const HospitalDashboardScreen({super.key});

  @override
  State<HospitalDashboardScreen> createState() =>
      _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen> {
  final BloodRequestRepository _repository = BloodRequestRepository();
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _fetchDashboard();
  }

  Future<Map<String, dynamic>> _fetchDashboard() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    final hospitalId = user?.id ?? '';

    final requestsData = await _repository.getHospitalRequests(hospitalId);
    final statsData = await ApiService.get(ApiConstants.hospitalStats);

    final activeCount = requestsData.where((r) => r.status == 'active').length;
    final donsCount = statsData?['confirmedDonations'] ?? 0;
    final donneursTotal = statsData?['uniqueDonors'] ?? 0;
    
    // Taux de réponse : Dons / Demandes (%)
    String tauxReponse = '–';
    if (requestsData.isNotEmpty) {
      final rate = (donsCount / requestsData.length) * 100;
      tauxReponse = '${rate.toStringAsFixed(0)}%';
    }

    return {
      'requests': requestsData,
      'activeCount': activeCount,
      'donsCount': donsCount,
      'tauxReponse': tauxReponse,
      'donneursTotal': donneursTotal,
    };
  }

  void _refresh() {
    setState(() {
      _dashboardFuture = _fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final hospName = user?.nom ?? 'Établissement';

    return HospitalLayout(
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
               // Header
              _buildHeader(hospName),

              const SizedBox(height: AppSpacing.xl),

              FutureBuilder<Map<String, dynamic>>(
                future: _dashboardFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }

                  final data = snapshot.data ?? {};
                  final requests = (data['requests'] as List<BloodRequest>?) ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsGrid(data),
                      const SizedBox(height: AppSpacing.xl + 8),
                      _buildRecentRequestsSection(requests),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String hospName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SangVieTypography.h1('Tableau de bord'),
        const SizedBox(height: 4),
        Text(
          'Bienvenue, $hospName',
          style: const TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildStatsGrid(Map<String, dynamic> data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.25,
      children: [
        _buildStatCard('Demandes actives', '${data['activeCount'] ?? 0}', LucideIcons.activity, AppColors.warningOrange),
        _buildStatCard('Dons du mois', '${data['donsCount'] ?? 0}', LucideIcons.droplets, AppColors.successGreen),
        _buildStatCard('Taux de réponse', '${data['tauxReponse'] ?? '–'}', LucideIcons.trendingUp, AppColors.primary),
        _buildStatCard('Total donneurs', '${data['donneursTotal'] ?? 0}', LucideIcons.users, AppColors.foreground),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
              Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequestsSection(List<BloodRequest> requests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SangVieTypography.label('Dernières demandes'),
            GestureDetector(
              onTap: () => context.go('/hospital/requests'),
              child: const Text(
                'VOIR TOUT',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (requests.isEmpty)
          _buildEmptyState()
        else
          ...requests.take(5).map((r) => _buildRequestListItem(r)).toList().animate(interval: 50.ms).fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildRequestListItem(BloodRequest r) {
    final isActive = r.status == 'active';
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SangVieCard(
        onTap: () => context.go('/hospital/requests'),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Text(
                  r.group,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${r.quantity} poche(s)', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  Text(r.date, style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            SangVieBadge(
              label: isActive ? 'En cours' : 'Clôturée',
              color: isActive ? AppColors.warningOrange : AppColors.successGreen,
              icon: isActive ? LucideIcons.clock : LucideIcons.checkCircle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: AppColors.secondarySoft,
      hasBorder: false,
      child: const Center(
        child: Text('Aucune demande pour le moment.', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
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
