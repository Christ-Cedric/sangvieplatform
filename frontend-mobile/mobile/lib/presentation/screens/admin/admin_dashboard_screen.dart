import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/admin_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, dynamic>> _statsFuture;
  late Future<List<Map<String, dynamic>>> _pendingHospsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchStats();
    _pendingHospsFuture = _fetchPendingHospitals();
  }

  Future<Map<String, dynamic>> _fetchStats() async {
    final data = await ApiService.get(ApiConstants.adminStats);
    if (data == null) return {};
    return Map<String, dynamic>.from(data);
  }

  Future<List<Map<String, dynamic>>> _fetchPendingHospitals() async {
    final data = await ApiService.get(
        '${ApiConstants.hospitals}?verified=false&status=pending');
    if (data == null) return [];
    final list =
        data is List ? data : (data['hospitals'] ?? data['data'] ?? []);
    return List<Map<String, dynamic>>.from(list as List);
  }

  void _refresh() {
    setState(() {
      _statsFuture = _fetchStats();
      _pendingHospsFuture = _fetchPendingHospitals();
    });
  }

  Future<void> _validateHospital(String id) async {
    final res = await ApiService.put(
        ApiConstants.hospitalById(id), {'verified': true, 'status': 'active'});
    if (res != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Hôpital validé avec succès !'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating));
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      child: RefreshIndicator(
        onRefresh: () async => _refresh(),
        color: AppColors.primary,
        displacement: 20,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.xxl),
              FutureBuilder<Map<String, dynamic>>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }
                  final s = snapshot.data ?? {};
                  return _buildStatsGrid(s);
                },
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SangVieTypography.label('Hôpitaux en attente de validation')
                  .animate()
                  .fadeIn(delay: 400.ms),
              const SizedBox(height: AppSpacing.md),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _pendingHospsFuture,
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  return _buildPendingHospitalsList(list,
                      isLoading:
                          snapshot.connectionState == ConnectionState.waiting);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SangVieTypography.h1('Tableau de bord'),
        const SizedBox(height: 4),
        const Text(
          'Vue d\'ensemble de la plateforme',
          style: TextStyle(
              color: AppColors.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildStatsGrid(Map<String, dynamic> s) {
    final stats = [
      {
        'label': 'Donneurs inscrits',
        'value': '${s['totalDonneurs'] ?? s['users'] ?? 0}',
        'icon': LucideIcons.users,
        'color': AppColors.successGreen,
      },
      {
        'label': 'Hôpitaux partenaires',
        'value': '${s['totalHopitaux'] ?? s['hospitals'] ?? 0}',
        'icon': LucideIcons.building2,
        'color': AppColors.primary,
      },
      {
        'label': 'Dons totaux',
        'value': '${s['totalDons'] ?? s['donations'] ?? 0}',
        'icon': LucideIcons.droplets,
        'color': Colors.blue,
      },
      {
        'label': 'Alertes critiques',
        'value': '${s['alertesCritiques'] ?? s['criticalRequests'] ?? 0}',
        'icon': LucideIcons.alertTriangle,
        'color': AppColors.warningOrange,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.4,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) {
        final st = stats[i];
        return SangVieCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (st['color'] as Color).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(st['icon'] as IconData,
                    color: st['color'] as Color, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(st['value'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          letterSpacing: -0.5)),
                  Text(st['label'] as String,
                      style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPendingHospitalsList(List<Map<String, dynamic>> list,
      {bool isLoading = false}) {
    if (isLoading) return _buildLoadingState();
    if (list.isEmpty) return _buildEmptyState();

    return Column(
      children: list
          .map((h) => _buildPendingHospitalCard(h))
          .toList()
          .animate(interval: 100.ms)
          .fadeIn(delay: 500.ms)
          .slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildPendingHospitalCard(Map<String, dynamic> h) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SangVieCard(
        padding: const EdgeInsets.all(AppSpacing.md + 4),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(LucideIcons.building,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h['nom'] ?? h['name'] ?? 'Nom inconnu',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    h['email'] ?? 'Aucun email',
                    style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SangVieButton(
              label: 'Valider',
              onPressed: () => _validateHospital(h['_id'] ?? ''),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              // Use a smaller button style if possible, or just keep it compact
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: AppColors.inputBackground,
      hasBorder: false,
      child: const Center(
        child: Text(
          'Aucun hôpital en attente de validation.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.secondary, fontWeight: FontWeight.w600),
        ),
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
