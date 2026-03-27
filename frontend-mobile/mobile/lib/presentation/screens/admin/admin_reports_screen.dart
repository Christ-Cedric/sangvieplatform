import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/providers/admin_provider.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/admin_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchReports();
      context.read<AdminProvider>().fetchGlobalStats();
    });
  }

  Future<void> _refresh() async {
    await context.read<AdminProvider>().fetchReports();
    await context.read<AdminProvider>().fetchGlobalStats();
  }

  void _handleExport() async {
    setState(() => _isExporting = true);

    // Simulation de génération de PDF/CSV
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Rapport exporté avec succès (PDF)"),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: Consumer<AdminProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.reportsData.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (provider.error != null && provider.reportsData.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.alertTriangle,
                        size: 48, color: AppColors.destructive),
                    const SizedBox(height: 16),
                    Text(provider.error!),
                    const SizedBox(height: 16),
                    SangVieButton(
                      label: "Réessayer",
                      onPressed: _refresh,
                      isFullWidth: false,
                    ),
                  ],
                ),
              );
            }

            final reports = provider.reportsData;
            final stats = provider.globalStats;
            final regionalData = (reports['regionalData'] as List?) ?? [];
            final monthlyTrends = (reports['monthlyTrends'] as List?) ?? [];

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildKPIList(stats),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSection(
                      "Évolution mensuelle", _buildTrendChart(monthlyTrends)),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSection("Distribution régionale",
                      _buildRegionalDistribution(regionalData)),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSection("Détails analytiques",
                      _buildAnalyticsTable(regionalData)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SangVieTypography.h1("Rapports"),
              const SizedBox(height: 4),
              const Text("Analyse globale des activités",
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SangVieButton(
          label: "Exporter",
          onPressed: _handleExport,
          isLoading: _isExporting,
          backgroundColor: AppColors.successGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          isFullWidth: false,
          height: 40,
          icon: const Icon(LucideIcons.download, size: 16, color: Colors.white),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildKPIList(Map<String, dynamic> stats) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildGlobalKPI("DONS TOTAUX", "${stats['dons'] ?? 0}", "+12%",
              AppColors.primary, LucideIcons.droplets),
          const SizedBox(width: AppSpacing.md),
          _buildGlobalKPI("DONNEURS", "${stats['utilisateurs'] ?? 0}", "+8%",
              AppColors.successGreen, LucideIcons.users),
          const SizedBox(width: AppSpacing.md),
          _buildGlobalKPI("HÔPITAUX", "${stats['hopitaux'] ?? 0}", "+5%",
              AppColors.warningOrange, LucideIcons.building2),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildGlobalKPI(String label, String value, String growth, Color color, IconData icon) {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      width: 180,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Text(growth, style: const TextStyle(color: AppColors.successGreen, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.3)),
        ),
        SangVieCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTrendChart(List monthlyTrends) {
    if (monthlyTrends.isEmpty) return const Center(child: Text("Aucune donnée disponible"));
    
    // Trouver le max pour normaliser les hauteurs
    int maxVal = 0;
    for (var t in monthlyTrends) {
      if (t['donations'] > maxVal) maxVal = t['donations'];
    }
    if (maxVal == 0) maxVal = 1;

    return SizedBox(
      height: 160,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: monthlyTrends.map((t) {
          final factor = t['donations'] / maxVal;
          return _buildTrendBar(t['month'], factor);
        }).toList(),
      ),
    );
  }

  Widget _buildTrendBar(String month, double factor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: (110 * factor).clamp(5.0, 110.0),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
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

  Widget _buildRegionalDistribution(List regionalData) {
    if (regionalData.isEmpty) {
      return const Center(child: Text("Aucune donnée régionale disponible"));
    }

    // Top 3 regions
    final sorted = List.from(regionalData)
      ..sort((a, b) =>
          ((b['donations'] ?? 0) as int).compareTo((a['donations'] ?? 0) as int));
    final top3 = sorted.take(3).toList();

    int maxDonations = 0;
    if (top3.isNotEmpty) maxDonations = (top3[0]['donations'] ?? 0) as int;
    if (maxDonations == 0) maxDonations = 1;

    return Column(
      children: top3.map((r) {
        final donorsVal = (r['donations'] ?? 0) as int;
        final factor = donorsVal / maxDonations;
        final growthVal = (r['growth'] ?? 0) as int;
        return _buildRegionRow(r['region'] ?? 'Inconnu', factor, "$donorsVal dons",
            "${growthVal > 0 ? '+' : ''}$growthVal%");
      }).toList(),
    );
  }

  Widget _buildRegionRow(
      String name, double factor, String info, String growth) {
    bool isPositive = !growth.startsWith('-');
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14)),
              Row(
                children: [
                  Text(info,
                      style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text(growth,
                      style: TextStyle(
                          color: isPositive
                              ? AppColors.successGreen
                              : AppColors.destructive,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: factor,
              backgroundColor: AppColors.inputBackground,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTable(List regionalData) {
    if (regionalData.isEmpty) {
      return const Center(child: Text("Aucune donnée détaillée disponible"));
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        _buildTableHeader(),
        ...regionalData
            .take(5)
            .map((r) => _buildTableRow(
                r['region'] ?? 'Inconnu', "${r['hospitals'] ?? 0}", "${r['donations'] ?? 0}",
                isFirst: regionalData.indexOf(r) == 0))
            .toList(),
      ],
    );
  }

  TableRow _buildTableHeader() {
    return const TableRow(
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text("RÉGION", style: TextStyle(color: AppColors.mutedForeground, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text("HÔP.", style: TextStyle(color: AppColors.mutedForeground, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text("DONS", style: TextStyle(color: AppColors.mutedForeground, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5))),
      ],
    );
  }

  TableRow _buildTableRow(String r, String h, String d, {bool isFirst = false}) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Text(r, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14), overflow: TextOverflow.ellipsis)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Text(h, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Text(d, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primary))),
      ],
    );
  }
}
