import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/admin_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminHospitalsScreen extends StatefulWidget {
  const AdminHospitalsScreen({super.key});

  @override
  State<AdminHospitalsScreen> createState() => _AdminHospitalsScreenState();
}

class _AdminHospitalsScreenState extends State<AdminHospitalsScreen> {
  late Future<List<Map<String, dynamic>>> _hospitalsFuture;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _allHospitals = [];
  List<Map<String, dynamic>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _hospitalsFuture = _fetchHospitals();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchHospitals() async {
    final data = await ApiService.get(ApiConstants.hospitals);
    if (data == null) return [];
    final list = data is List ? data : (data['hospitals'] ?? data['data'] ?? []);
    _allHospitals = List<Map<String, dynamic>>.from(list as List);
    _onSearch();
    return _allHospitals;
  }

  void _onSearch() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _allHospitals
          : _allHospitals.where((h) {
              final name = (h['nom'] ?? h['nomHopital'] ?? '').toString().toLowerCase();
              return name.contains(q);
            }).toList();
    });
  }

  void _refresh() {
    setState(() {
      _hospitalsFuture = _fetchHospitals();
    });
  }

  Future<void> _approveHospital(String id) async {
    final res = await ApiService.put(ApiConstants.hospitalById(id), {'verified': true, 'status': 'active'});
    if (res != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Hôpital approuvé !'),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ));
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
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.xl),
              
              _buildSearchBar(),
              const SizedBox(height: AppSpacing.xl),
              
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _hospitalsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }
                  
                  final verified = _allHospitals.where((h) => h['verified'] == true).length;
                  final pending = _allHospitals.where((h) => h['verified'] != true).length;

                  return Column(
                    children: [
                      _buildKPIRow(verified, pending),
                      const SizedBox(height: AppSpacing.xl),
                      
                      if (_filtered.isEmpty)
                        _buildEmptyState()
                      else
                        ..._filtered.map((h) => _buildHospitalListItem(h))
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
          style: TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildSearchBar() {
    return SangVieInput(
      hint: "Rechercher un établissement...", 
      prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.secondary),
      controller: _searchController,
      textInputAction: TextInputAction.search,
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildKPIRow(int verified, int pending) {
    return Row(
      children: [
        Expanded(child: _buildKPIBox("TOTAUX", _allHospitals.length.toString(), AppColors.primary)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildKPIBox("VÉRIFIÉS", verified.toString(), AppColors.successGreen)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildKPIBox("ATTENTE", pending.toString(), AppColors.warningOrange)),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildKPIBox(String label, String value, Color color) {
    return SangVieCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildHospitalListItem(Map<String, dynamic> h) {
    final isVerified = h['verified'] == true;
    final name = h['nom'] ?? h['nomHopital'] ?? 'Inconnu';
    final location = h['adresse'] ?? h['location'] ?? 'Non renseigné';
    final id = h['_id'] ?? '';

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
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(LucideIcons.building2, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin, size: 12, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Expanded(child: Text(location, style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(isVerified),
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
                    onPressed: () {}, 
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                if (!isVerified) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SangVieButton(
                      label: "Approuver", 
                      onPressed: () => _approveHospital(id), 
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

  Widget _buildStatusBadge(bool verified) {
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
        child: Text("Aucun hôpital trouvé.", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
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
