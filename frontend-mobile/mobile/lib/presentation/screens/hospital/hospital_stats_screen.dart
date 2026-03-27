import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/hospital_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPremiumHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _statsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: _buildLoadingState(),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState();
                    }

                    final s = snapshot.data!;
                    final requests = s['totalRequests'] ?? 0;
                    final donors = s['uniqueDonors'] ?? 0;
                    final donations = s['confirmedDonations'] ?? 0;
                    final rate = s['responseRate'] ?? 0;
                    
                    final monthlyData = (s['monthlyData'] as List?) ?? [];
                    final bloodGroupData = (s['bloodGroupData'] as List?) ?? [];
                    final activityLog = (s['activityLog'] as List?) ?? [];

                    return Column(
                      children: [
                        _buildKPIGrid(requests, donors, donations, rate),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildChartSection(monthlyData),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildBloodGroupsSection(bloodGroupData),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildRecentActivitySection(activityLog),
                        const SizedBox(height: 100),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 85, AppSpacing.lg, AppSpacing.xxl),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Analytique'.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              _buildDateSelector(),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Performances',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIGrid(var requests, var donors, var donations, var rate) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.25,
      children: [
        _buildKPICard("Demandes", requests.toString(), LucideIcons.activity, AppColors.primary),
        _buildKPICard("Donneurs", donors.toString(), LucideIcons.users, Colors.blue),
        _buildKPICard("Dons validés", donations.toString(), LucideIcons.droplets, AppColors.successGreen),
        _buildKPICard("Taux réponse", "$rate%", LucideIcons.trendingUp, AppColors.warningOrange),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color) {
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
                decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(List monthlyData) {
    if (monthlyData.isEmpty) return const SizedBox.shrink();

    // Trouver le max pour mettre à l'échelle les barres
    int maxDonations = 1;
    for (var m in monthlyData) {
      int d = m['donations'] ?? 0;
      if (d > maxDonations) maxDonations = d;
    }

    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Donations mensuelles",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: -0.5)),
              Icon(LucideIcons.barChart,
                  size: 20, color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: monthlyData.map((m) {
                double factor = (m['donations'] ?? 0) / maxDonations;
                if (factor < 0.05 && (m['donations'] ?? 0) > 0) factor = 0.05;
                return _buildBar(m['month'] ?? '', factor, m['donations'] ?? 0);
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildBar(String month, double heightFactor, int value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: "$value dons",
          child: Container(
            width: 28,
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
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(month,
            style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildBloodGroupsSection(List distribution) {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Répartition par groupe",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: -0.5)),
          const SizedBox(height: 24),
          if (distribution.isEmpty)
            const Center(child: Text("Aucune donnée de groupe.", style: TextStyle(color: AppColors.secondary)))
          else
            ...distribution.map((g) {
              final group = g['group']?.toString() ?? 'N/A';
              final count = g['count'] ?? 0;
              final pct = (g['percentage'] ?? 0) / 100.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(group,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 14)),
                        Text(
                            "$count poches (${(pct * 100).toInt()}%)",
                            style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.inputBackground,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }).toList()
              .animate(interval: 50.ms)
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.1, end: 0),
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
          const Text("Activité récente",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: -0.5)),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(
                    child: Text("Aucune activité récente.",
                        style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600))))
          else
            ...activities.map((a) {
              DateTime? date;
              try {
                date = DateTime.parse(a['time']);
              } catch (_) {}
              
              final timeStr = date != null ? DateFormat('dd/MM HH:mm').format(date) : '';

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: AppColors.border, width: 0.5))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a['action']?.toString() ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(a['detail']?.toString() ?? '',
                              style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Text(timeStr,
                        style: const TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            }).toList()
              .animate(interval: 50.ms)
              .fadeIn(delay: 800.ms)
              .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 100),
        const Icon(LucideIcons.barChart3, size: 64, color: AppColors.secondarySoft),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            "Aucune donnée analytique disponible.\nCommencez par créer des demandes.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 24),
        SangVieButton(
          label: "Actualiser",
          onPressed: _refresh,
          isFullWidth: false,
        ),
      ],
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
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.calendar, size: 14, color: AppColors.primary),
          SizedBox(width: 8),
          Text("TOUT",
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5)),
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
        child:
            CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
      ),
    );
  }
}
