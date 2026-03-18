import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/hospital_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HospitalStatsScreen extends StatefulWidget {
  const HospitalStatsScreen({super.key});

  @override
  State<HospitalStatsScreen> createState() => _HospitalStatsScreenState();
}

class _HospitalStatsScreenState extends State<HospitalStatsScreen> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchStats();
  }

  Future<Map<String, dynamic>> _fetchStats() async {
    final data = await ApiService.get(ApiConstants.hospitalStats);
    if (data == null) return {};
    return Map<String, dynamic>.from(data);
  }

  void _refresh() {
    setState(() {
      _statsFuture = _fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(),
              const SizedBox(height: AppSpacing.xl + 4),
              
              FutureBuilder<Map<String, dynamic>>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }
                  
                  final s = snapshot.data ?? {};
                  final requests = s['requestsCount'] ?? s['totalRequests'] ?? 0;
                  final donors = s['donorsCount'] ?? s['totalDonors'] ?? 0;
                  final bags = s['bagsCount'] ?? s['totalBags'] ?? 0;
                  final rate = s['rate'] ?? s['tauxReponse'] ?? '0%';
                  final recent = (s['recentActivity'] as List?) ?? [];
                  final distribution = (s['distribution'] as List?) ?? _getMockDistribution();

                  return Column(
                    children: [
                      _buildKPIGrid(requests, donors, bags, rate),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildChartSection(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildBloodGroupsSection(distribution),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildRecentActivitySection(recent),
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

  List _getMockDistribution() {
    return [
      {'label': 'O+', 'pct': 0.45, 'count': 45},
      {'label': 'A+', 'pct': 0.30, 'count': 30},
      {'label': 'B+', 'pct': 0.15, 'count': 15},
      {'label': 'AB+', 'pct': 0.10, 'count': 10},
    ];
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SangVieTypography.h1("Statistiques"),
            const SizedBox(height: 4),
            const Text(
              "Analyse des performances",
              style: TextStyle(color: AppColors.secondary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        _buildDateSelector(),
      ],
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildKPIGrid(var requests, var donors, var bags, var rate) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.25,
      children: [
        _buildKPICard("Demandes", requests.toString(), "+12%", LucideIcons.activity, AppColors.primary),
        _buildKPICard("Donneurs", donors.toString(), "+5%", LucideIcons.users, Colors.blue),
        _buildKPICard("Poches", bags.toString(), "+8%", LucideIcons.droplets, AppColors.successGreen),
        _buildKPICard("Réponse", rate.toString(), "+2%", LucideIcons.trendingUp, AppColors.warningOrange),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildKPICard(String label, String value, String change, IconData icon, Color color) {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.successGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(change, style: const TextStyle(color: AppColors.successGreen, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Évolution hebdomadaire", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5)),
              const Icon(LucideIcons.moreHorizontal, size: 20, color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar("Lun", 0.4),
                _buildBar("Mar", 0.7),
                _buildBar("Mer", 0.5),
                _buildBar("Jeu", 0.9),
                _buildBar("Ven", 0.6),
                _buildBar("Sam", 0.8),
                _buildBar("Dim", 0.3),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildBar(String day, double heightFactor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 120 * heightFactor,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(day, style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildBloodGroupsSection(List distribution) {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Répartition par groupe", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          ...distribution.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(g['label']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text(
                          "${g['count']} sacs (${(( (g['pct'] ?? 0.0) as double) * 100).toInt()}%)", 
                          style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (g['pct'] ?? 0.0) as double,
                        backgroundColor: AppColors.inputBackground,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              )).toList().animate(interval: 50.ms).fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(List activities) {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Activité récente", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5)),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            const Padding(padding: EdgeInsets.all( AppSpacing.lg), child: Center(child: Text("Aucune activité récente.", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600))))
          else
            ...activities.map((a) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a['title']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(a['detail']?.toString() ?? '', style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Text(a['time']?.toString() ?? '', style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                )).toList().animate(interval: 50.ms).fadeIn(delay: 800.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.calendar, size: 14, color: AppColors.primary),
          SizedBox(width: 8),
          Text("CE MOIS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          SizedBox(width: 4),
          Icon(LucideIcons.chevronDown, size: 14, color: AppColors.secondary),
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
