import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/presentation/screens/hospital/request_responses_screen.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/data/models/blood_request_model.dart';
import 'package:sangvie/data/repositories/blood_request_repository.dart';
import 'package:sangvie/presentation/widgets/hospital_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HospitalRequestsScreen extends StatefulWidget {
  const HospitalRequestsScreen({super.key});

  @override
  State<HospitalRequestsScreen> createState() =>
      _HospitalRequestsScreenState();
}

class _HospitalRequestsScreenState extends State<HospitalRequestsScreen> {
  final BloodRequestRepository _repo = BloodRequestRepository();
  late Future<List<BloodRequest>> _requestsFuture;
  final TextEditingController _searchController = TextEditingController();
  List<BloodRequest> _allRequests = [];
  List<BloodRequest> _activeFiltered = [];
  List<BloodRequest> _doneFiltered = [];

  @override
  void initState() {
    super.initState();
    _requestsFuture = _fetchRequests();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<BloodRequest>> _fetchRequests() async {
    final res = await _repo.getHospitalRequests('');
    _allRequests = res;
    _onSearch();
    return res;
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      final base = q.isEmpty
          ? _allRequests
          : _allRequests.where((r) {
              return r.group.toLowerCase().contains(q) ||
                  r.description.toLowerCase().contains(q);
            }).toList();

      _activeFiltered = base.where((r) => r.status == 'active').toList();
      _doneFiltered = base.where((r) => r.status != 'active').toList();
    });
  }

  void _refresh() {
    setState(() {
      _requestsFuture = _fetchRequests();
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
              const SizedBox(height: AppSpacing.lg),

              SangVieInput(
                hint: 'Rechercher par groupe ou description...',
                prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.secondary),
                controller: _searchController,
                textInputAction: TextInputAction.search,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppSpacing.xl),

              FutureBuilder<List<BloodRequest>>(
                future: _requestsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _allRequests.isEmpty) {
                    return _buildLoadingState();
                  }

                  if (_activeFiltered.isEmpty && _doneFiltered.isEmpty) {
                    return _buildEmptyState().animate().fadeIn();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_activeFiltered.isNotEmpty) ...[
                        _buildSectionHeader('DEMANDES ACTIVES (${_activeFiltered.length})'),
                        ..._activeFiltered.map((r) => _buildRequestCard(r, isFulfilled: false))
                            .toList()
                            .animate(interval: 50.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),
                      ],
                      
                      if (_doneFiltered.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        _buildSectionHeader('HISTORIQUE (${_doneFiltered.length})'),
                        ..._doneFiltered.map((r) => _buildRequestCard(r, isFulfilled: true))
                            .toList()
                            .animate(interval: 50.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),
                      ],
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
        SangVieTypography.h1('Mes Demandes'),
        const SizedBox(height: 4),
        const Text('Gérez vos appels aux dons en temps réel', style: TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 1.5,
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildRequestCard(BloodRequest r, {required bool isFulfilled}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SangVieCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isFulfilled ? AppColors.successGreen.withOpacity(0.08) : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: Text(
                      r.group,
                      style: TextStyle(
                        color: isFulfilled ? AppColors.successGreen : AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.description.isNotEmpty ? r.description : 'Demande de sang ${r.group}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.calendar, size: 12, color: AppColors.mutedForeground),
                          const SizedBox(width: 4),
                          Text(r.date, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
                _urgencyBadge(r.urgency, isFulfilled),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _infoChip(LucideIcons.droplet, '${r.quantity} poche(s)'),
                    const SizedBox(width: AppSpacing.lg),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RequestResponsesScreen(
                              requestId: r.id,
                              group: r.group,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        child: _infoChip(LucideIcons.users, '${r.responses ?? 0} réponse(s)', color: AppColors.successGreen),
                      ),
                    ),
                  ],
                ),
                if (!isFulfilled)
                  TextButton(
                    onPressed: () => _closeRequest(r.id),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: AppColors.primarySoft,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                    child: const Text('CLÔTURER', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _closeRequest(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Text('Confirmer la clôture', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Cette demande ne sera plus visible pour les donneurs.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700))),
          SangVieButton(
            label: 'Confirmer', 
            onPressed: () => Navigator.pop(context, true),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _repo.closeRequest(id);
    if (mounted) _refresh();
  }

  Widget _urgencyBadge(String urgency, bool isFulfilled) {
    if (isFulfilled) {
      return const SangVieBadge(label: 'Satisfaite', color: AppColors.successGreen, icon: LucideIcons.checkCircle2);
    }
    final isCritical = urgency == 'critical';
    return SangVieBadge(
      label: isCritical ? 'Vitale' : 'Modérée',
      color: isCritical ? AppColors.destructive : AppColors.warningOrange,
      icon: isCritical ? LucideIcons.alertTriangle : LucideIcons.clock,
    );
  }

  Widget _infoChip(IconData icon, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.secondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color ?? AppColors.foreground),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      color: AppColors.inputBackground,
      hasBorder: false,
      child: const Center(
        child: Text('Aucune demande enregistrée.', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
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
