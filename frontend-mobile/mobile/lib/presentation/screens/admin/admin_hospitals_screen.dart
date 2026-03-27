import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/providers/admin_provider.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/data/models/hospital_model.dart';
import 'package:sangvie/presentation/widgets/admin_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminHospitalsScreen extends StatefulWidget {
  const AdminHospitalsScreen({super.key});

  @override
  State<AdminHospitalsScreen> createState() => _AdminHospitalsScreenState();
}

class _AdminHospitalsScreenState extends State<AdminHospitalsScreen> {
  final _searchController = TextEditingController();
  List<Hospital> _filtered = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchHospitals();
    });
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final provider = context.read<AdminProvider>();
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? provider.allHospitals
          : provider.allHospitals.where((h) {
              return h.nom.toLowerCase().contains(q) ||
                  (h.localisation ?? '').toLowerCase().contains(q);
            }).toList();
    });
  }

  Future<void> _refresh() async {
    await context.read<AdminProvider>().fetchHospitals();
    _onSearch();
  }

  Future<void> _approveHospital(String id) async {
    final success = await context.read<AdminProvider>().approveHospital(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Hôpital approuvé !'),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ));
      _onSearch();
    }
  }

  Future<void> _suspendHospital(String id, String currentStatus) async {
    final success =
        await context.read<AdminProvider>().suspendAccount(id, 'Hospital');
    if (success && mounted) {
      Navigator.pop(context); // Close modal
      final isNowSuspended = currentStatus != 'suspended';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isNowSuspended ? 'Compte suspendu' : 'Compte réactivé'),
        backgroundColor:
            isNowSuspended ? AppColors.destructive : AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ));
      _onSearch();
    }
  }

  Future<void> _deleteHospital(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text(
            'Voulez-vous vraiment supprimer cet hôpital définitivement ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer',
                  style: TextStyle(color: AppColors.destructive))),
        ],
      ),
    );

    if (confirm == true) {
      final success =
          await context.read<AdminProvider>().deleteAccount(id, 'Hospital');
      if (success && mounted) {
        Navigator.pop(context); // Close modal
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Compte supprimé définitivement'),
          backgroundColor: AppColors.destructive,
          behavior: SnackBarBehavior.floating,
        ));
        _onSearch();
      }
    }
  }

  void _showHospitalDetails(Hospital h) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle),
                        child: const Icon(LucideIcons.building2,
                            color: AppColors.primary, size: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(h.nom,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Center(child: _buildStatusBadge(h.verified, h.status)),
                    const SizedBox(height: 32),
                    _buildDetailRow(LucideIcons.mail, "Email", h.email),
                    _buildDetailRow(LucideIcons.phone, "Contact", h.contact),
                    _buildDetailRow(LucideIcons.fileText, "N° Agrément",
                        h.numeroAgrement ?? 'N/A'),
                    _buildDetailRow(LucideIcons.mapPin, "Localisation",
                        h.localisation ?? 'N/A'),
                    _buildDetailRow(
                        LucideIcons.home, "Région", h.region ?? 'N/A'),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: SangVieButton(
                            label: h.status == 'suspended'
                                ? "Réactiver"
                                : "Suspendre",
                            isSecondary: h.status != 'suspended',
                            backgroundColor: h.status == 'suspended'
                                ? AppColors.successGreen
                                : AppColors.warningOrange,
                            onPressed: () =>
                                _suspendHospital(h.id, h.status ?? 'active'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SangVieButton(
                            label: "Supprimer",
                            backgroundColor: AppColors.destructive,
                            onPressed: () => _deleteHospital(h.id),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.secondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      child: RefreshIndicator(
        onRefresh: _refresh,
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
              const SizedBox(height: AppSpacing.xl),
              _buildSearchBar(),
              const SizedBox(height: AppSpacing.xl),
              Consumer<AdminProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.allHospitals.isEmpty) {
                    return _buildLoadingState();
                  }

                  final all = provider.allHospitals;
                  final verified = all.where((h) => h.verified).length;
                  final pending = all.where((h) => !h.verified).length;

                  final displayList =
                      _searchController.text.isEmpty ? all : _filtered;

                  return Column(
                    children: [
                      _buildKPIRow(all.length, verified, pending),
                      const SizedBox(height: AppSpacing.xl),
                      if (displayList.isEmpty)
                        _buildEmptyState()
                      else
                        ...displayList
                            .map((h) => _buildHospitalListItem(h))
                            .toList()
                            .animate(interval: 50.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SangVieTypography.h1('Établissements'),
        const SizedBox(height: 4),
        const Text(
          'Gestion des hôpitaux partenaires',
          style: TextStyle(
              color: AppColors.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildSearchBar() {
    return SangVieInput(
      hint: "Rechercher un établissement...",
      prefixIcon:
          const Icon(LucideIcons.search, size: 20, color: AppColors.secondary),
      controller: _searchController,
      textInputAction: TextInputAction.search,
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildKPIRow(int total, int verified, int pending) {
    return Row(
      children: [
        Expanded(
            child: _buildKPIBox("TOTAUX", total.toString(), AppColors.primary)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
            child: _buildKPIBox(
                "VÉRIFIÉS", verified.toString(), AppColors.successGreen)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
            child: _buildKPIBox(
                "ATTENTE", pending.toString(), AppColors.warningOrange)),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildKPIBox(String label, String value, Color color) {
    return SangVieCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildHospitalListItem(Hospital h) {
    final isSuspended = h.status == 'suspended';
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SangVieCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSuspended
                        ? AppColors.secondarySoft
                        : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(LucideIcons.building2,
                      color:
                          isSuspended ? AppColors.secondary : AppColors.primary,
                      size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.nom,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              decoration: isSuspended
                                  ? TextDecoration.lineThrough
                                  : null)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin,
                              size: 12, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(
                                  h.address ??
                                      h.localisation ??
                                      'Non renseigné',
                                  style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(h.verified, h.status),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: SangVieButton(
                    label: "Détails",
                    isSecondary: true,
                    onPressed: () => _showHospitalDetails(h),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                if (!h.verified) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SangVieButton(
                      label: "Approuver",
                      onPressed: () => _approveHospital(h.id),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool verified, String? status) {
    if (status == 'suspended') {
      return const SangVieBadge(
        label: "SUSPENDU",
        color: AppColors.destructive,
        icon: LucideIcons.ban,
      );
    }

    final color = verified ? AppColors.successGreen : AppColors.warningOrange;
    return SangVieBadge(
      label: verified ? "VÉRIFIÉ" : "ATTENTE",
      color: color,
      icon: verified ? LucideIcons.checkCircle2 : LucideIcons.clock,
    );
  }

  Widget _buildEmptyState() {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: AppColors.inputBackground,
      hasBorder: false,
      child: const Center(
        child: Text("Aucun hôpital trouvé.",
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
