import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/providers/donor_provider.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/data/models/donation_model.dart';
import 'package:sangvie/presentation/widgets/donor_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DonorHistoryScreen extends StatefulWidget {
  const DonorHistoryScreen({super.key});

  @override
  State<DonorHistoryScreen> createState() => _DonorHistoryScreenState();
}

class _DonorHistoryScreenState extends State<DonorHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Donation> _filteredHistory = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DonorProvider>().fetchHistory();
    });
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final provider = context.read<DonorProvider>();
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredHistory = q.isEmpty
          ? provider.history
          : provider.history.where((h) {
              final hospName = h.hospital?.nom ?? 'Hôpital';
              final type = h.typeDon;
              return hospName.toLowerCase().contains(q) ||
                  type.toLowerCase().contains(q);
            }).toList();
    });
  }

  Future<void> _refresh() async {
    await context.read<DonorProvider>().fetchHistory();
    _onSearch();
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      final months = [
        '',
        'Janvier',
        'Février',
        'Mars',
        'Avril',
        'Mai',
        'Juin',
        'Juillet',
        'Août',
        'Septembre',
        'Octobre',
        'Novembre',
        'Décembre'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DonorLayout(
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        displacement: 20,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.lg),
              SangVieInput(
                hint: 'Rechercher par hôpital ou type...',
                prefixIcon: const Icon(LucideIcons.search,
                    size: 20, color: AppColors.secondary),
                controller: _searchController,
                textInputAction: TextInputAction.search,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: AppSpacing.xl),
              Consumer<DonorProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.history.isEmpty) {
                    return _buildLoadingState();
                  }

                  final data = _searchController.text.isEmpty
                      ? provider.history
                      : _filteredHistory;

                  if (data.isEmpty) {
                    return _buildEmptyState().animate().fadeIn();
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final d = data[i];
                      final hospName = d.hospital?.nom ?? 'Hôpital';
                      final group = d.group;
                      final status = d.status;
                      final date = _formatDate(d.date);
                      final type = d.typeDon;

                      return _buildHistoryCard(
                        hospital: hospName,
                        date: date,
                        status: status,
                        type: type,
                        group: group,
                        onTap: () => _showDonationDetails(d),
                      )
                          .animate()
                          .fadeIn(delay: (100 * i).ms)
                          .slideX(begin: 0.05, end: 0);
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

  void _showDonationDetails(Donation d) {
    final hospName = d.hospital?.nom ?? 'Hôpital';
    final date = _formatDate(d.date);
    final status = d.status;
    final type = d.typeDon;
    final group = d.group;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isFulfilled =
            status == 'valide' || status == 'fulfilled' || status == 'success';

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFulfilled
                          ? AppColors.successGreen.withOpacity(0.1)
                          : AppColors.secondarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      isFulfilled ? 'Terminé' : 'Prévu',
                      style: TextStyle(
                        color: isFulfilled
                            ? AppColors.successGreen
                            : AppColors.secondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildDetailRow(LucideIcons.building2, 'Lieu', hospName),
              _buildDetailRow(LucideIcons.calendar, 'Date', date),
              _buildDetailRow(LucideIcons.activity, 'Type de don', type),
              if (group.isNotEmpty)
                _buildDetailRow(
                    LucideIcons.droplet, 'Groupe sanguin concerné', group),
              if (d.quantityPoches > 0)
                _buildDetailRow(LucideIcons.shoppingBag, 'Quantité (poches)',
                    d.quantityPoches.toString()),
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
                Text(label,
                    style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: AppColors.foreground,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
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
      children: [],
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
    final isFulfilled =
        status == 'valide' || status == 'fulfilled' || status == 'success';

    return SangVieCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md + 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isFulfilled
                  ? AppColors.successGreen.withOpacity(0.08)
                  : AppColors.secondarySoft.withOpacity(0.5),
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
                Text(hospital,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Text(type,
                    style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.calendar,
                        size: 12, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(date,
                        style: const TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
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
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Text(
                group,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14),
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
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border.withOpacity(0.5))),
            child: const Icon(LucideIcons.history,
                size: 40, color: AppColors.secondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Aucun don pour le moment',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
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
        child:
            CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
      ),
    );
  }
}
