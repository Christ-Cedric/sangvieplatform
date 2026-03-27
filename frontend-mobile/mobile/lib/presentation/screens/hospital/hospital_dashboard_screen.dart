import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/services/auth_service.dart';
import 'package:sangvie/core/providers/hospital_provider.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/data/models/blood_request_model.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthService>().currentUser;
      if (user != null) {
        context.read<HospitalProvider>().fetchDashboardData(user.id);
      }
    });
  }

  Future<void> _refresh() async {
    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      await context.read<HospitalProvider>().fetchDashboardData(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final hospName = user?.nom ?? 'Établissement';

    return HospitalLayout(
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        displacement: 20,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildPremiumHeader(context, hospName),
              Consumer<HospitalProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.myRequests.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: _buildLoadingState(),
                    );
                  }

                  final stats = provider.stats;
                  final requests = provider.myRequests;

                  final activeCount =
                      requests.where((r) => r.status == 'active').length;
                  final donsCount = stats['confirmedDonations'] ?? 0;
                  final donneursTotal = stats['uniqueDonors'] ?? 0;
                  final responseRate = stats['responseRate'] ?? 0;

                  final dashboardData = {
                    'activeCount': activeCount,
                    'donsCount': donsCount,
                    'tauxReponse': '$responseRate%',
                    'donneursTotal': donneursTotal,
                  };

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsGrid(dashboardData),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildRecentRequestsSection(requests),
                        const SizedBox(height: 100), // Spacing for bottom nav
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, String hospName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 85, AppSpacing.lg, AppSpacing.xxl), // Increased top padding for AppBar
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tableau de bord'.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hospName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.shieldCheck,
                    color: AppColors.primary, size: 14),
                const SizedBox(width: 6),
                const Text(
                  'Établissement Certifié',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SangVieTypography.label('Statistiques mensuelles'),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.1,
          children: [
            _buildStatCard('Demandes', '${data['activeCount'] ?? 0}',
                LucideIcons.activity, AppColors.warningOrange),
            _buildStatCard('Dons Reçus', '${data['donsCount'] ?? 0}',
                LucideIcons.droplets, AppColors.primary),
            _buildStatCard('Taux', '${data['tauxReponse'] ?? '–'}',
                LucideIcons.trendingUp, AppColors.successGreen),
            _buildStatCard('Donneurs', '${data['donneursTotal'] ?? 0}',
                LucideIcons.users, const Color(0xFF6366F1)),
          ],
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return SangVieCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: -1)),
              ),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
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
          children: [
            SangVieTypography.label('Suivi des demandes'),
            TextButton(
              onPressed: () => context.go('/hospital/requests'),
              child: const Text('VOIR TOUT',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (requests.isEmpty)
          _buildEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: requests.length > 3 ? 3 : requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _buildRequestListItem(requests[index]),
          ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildRequestListItem(BloodRequest r) {
    final isActive = r.status == 'active';
    return SangVieCard(
      onTap: () => context.go('/hospital/requests'),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Center(
              child: Text(
                r.group,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${r.quantity} poche(s) demandée(s)',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.calendar,
                        size: 12, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(r.date,
                        style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          SangVieBadge(
            label: isActive ? 'Actif' : 'Clôturé',
            color: isActive ? AppColors.warningOrange : AppColors.successGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: AppColors.secondarySoft,
      hasBorder: false,
      child: const Center(
        child: Text('Aucune demande pour le moment.',
            style: TextStyle(
                color: AppColors.secondary, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child:
            CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
      ),
    );
  }
}
