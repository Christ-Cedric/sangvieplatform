import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/admin_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.xl),
            
            _buildKPIList(),
            const SizedBox(height: AppSpacing.xxl),
            
            _buildSection("Évolution mensuelle", _buildTrendChart()),
            const SizedBox(height: AppSpacing.xl),
            
            _buildSection("Distribution régionale", _buildRegionalDistribution()),
            const SizedBox(height: AppSpacing.xl),
            
            _buildSection("Détails analytiques", _buildAnalyticsTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SangVieTypography.h1("Rapports"),
            const SizedBox(height: 4),
            const Text("Analyse globale des activités", style: TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        SangVieButton(
          label: "Exporter", 
          onPressed: () {}, 
          backgroundColor: AppColors.successGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          icon: const Icon(LucideIcons.download, size: 16, color: Colors.white),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildKPIList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildGlobalKPI("DONS TOTAUX", "4,250", "+12%", AppColors.primary, LucideIcons.droplets),
          const SizedBox(width: AppSpacing.md),
          _buildGlobalKPI("DONNEURS", "8,921", "+8%", AppColors.successGreen, LucideIcons.users),
          const SizedBox(width: AppSpacing.md),
          _buildGlobalKPI("HÔPITAUX", "42", "+5%", AppColors.warningOrange, LucideIcons.building2),
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

  Widget _buildTrendChart() {
    return SizedBox(
      height: 160,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTrendBar("Oct", 0.6),
          _buildTrendBar("Nov", 0.75),
          _buildTrendBar("Déc", 0.55),
          _buildTrendBar("Jan", 0.85),
          _buildTrendBar("Fév", 0.8),
          _buildTrendBar("Mar", 1.0),
        ],
      ),
    );
  }

  Widget _buildTrendBar(String month, double factor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 110 * factor,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(month, style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildRegionalDistribution() {
    return Column(
      children: [
        _buildRegionRow("Centre", 0.85, "672 dons", "+12%"),
        _buildRegionRow("Hauts-Bassins", 0.55, "298 dons", "+8%"),
        _buildRegionRow("Cascades", 0.25, "124 dons", "-3%"),
      ],
    );
  }

  Widget _buildRegionRow(String name, double factor, String info, String growth) {
    bool isPositive = !growth.startsWith('-');
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              Row(
                children: [
                  Text(info, style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text(growth, style: TextStyle(color: isPositive ? AppColors.successGreen : AppColors.destructive, fontSize: 11, fontWeight: FontWeight.w800)),
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
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        _buildTableHeader(),
        _buildTableRow("Centre", "18", "672", isFirst: true),
        _buildTableRow("Hauts", "8", "298"),
        _buildTableRow("Cascades", "4", "124"),
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
        Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Text(r, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Text(h, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Text(d, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primary))),
      ],
    );
  }
}
