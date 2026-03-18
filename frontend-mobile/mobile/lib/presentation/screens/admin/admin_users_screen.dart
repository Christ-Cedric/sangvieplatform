import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/admin_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late Future<List<Map<String, dynamic>>> _usersFuture;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final data = await ApiService.get('${ApiConstants.users}?role=user');
    if (data == null) return [];
    final list = data is List ? data : (data['users'] ?? data['data'] ?? []);
    _allUsers = List<Map<String, dynamic>>.from(list as List);
    _onSearch();
    return _allUsers;
  }

  void _onSearch() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _allUsers
          : _allUsers.where((u) {
              final name = '${u['prenom'] ?? ''} ${u['nom'] ?? ''}'.toLowerCase();
              final phone = (u['telephone'] ?? '').toString().toLowerCase();
              return name.contains(q) || phone.contains(q);
            }).toList();
    });
  }

  void _refresh() {
    setState(() {
      _usersFuture = _fetchUsers();
    });
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
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _allUsers.isEmpty) {
                    return _buildLoadingState();
                  }

                  final actives = _allUsers.where((u) => u['status'] == 'active' || u['statut'] == 'active' || u['isActive'] == true).length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKPIRow(actives),
                      const SizedBox(height: AppSpacing.xl + 4),

                      if (_filtered.isEmpty)
                        _buildEmptyState()
                      else
                        ..._filtered.map((u) => _buildUserListItem(u))
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
        SangVieTypography.h1('Communauté'),
        const SizedBox(height: 4),
        const Text(
          'Gestion des donneurs inscrits',
          style: TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildSearchBar() {
    return SangVieInput(
      hint: 'Rechercher par nom ou téléphone...',
      prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.secondary),
      controller: _searchController,
      textInputAction: TextInputAction.search,
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildKPIRow(int actives) {
    return Row(
      children: [
        Expanded(child: _buildKPIBox("TOTAL", _allUsers.length.toString(), AppColors.primary)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildKPIBox("ACTIFS", actives.toString(), AppColors.successGreen)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildKPIBox("VUE", _filtered.length.toString(), AppColors.foreground)),
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

  Widget _buildUserListItem(Map<String, dynamic> u) {
    final prenom = u['prenom'] ?? '';
    final nom = u['nom'] ?? u['nomUtilisateur'] ?? '';
    final fullName = '$prenom $nom'.trim();
    final phone = u['telephone'] ?? u['contact'] ?? 'Non renseigné';
    final bloodGroup = u['groupeSanguin'] ?? '';
    final isActive = u['status'] == 'active' || u['statut'] == 'active' || u['isActive'] == true;

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
                  child: const Icon(LucideIcons.user, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName.isNotEmpty ? fullName : 'Donneur Anonyme', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(LucideIcons.phone, size: 12, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(phone, style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (bloodGroup.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(AppRadius.md)),
                    child: Text(bloodGroup, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                _buildStatusCircle(isActive),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: SangVieButton(
                    label: 'Profil', 
                    isSecondary: true,
                    onPressed: () {}, 
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SangVieButton(
                    label: 'Contacter', 
                    onPressed: () {}, 
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCircle(bool active) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? AppColors.successGreen : AppColors.secondary,
        shape: BoxShape.circle,
        boxShadow: [
          if (active) BoxShadow(color: AppColors.successGreen.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: AppColors.inputBackground,
      hasBorder: false,
      child: const Center(
        child: Text('Aucun donneur trouvé.', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
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
