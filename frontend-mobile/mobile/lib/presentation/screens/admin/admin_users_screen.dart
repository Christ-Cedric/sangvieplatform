import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/providers/admin_provider.dart';
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
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _filtered = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
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
          ? provider.allUsers
          : provider.allUsers.where((u) {
              final prenom = (u['prenom'] ?? '').toString().toLowerCase();
              final nom = (u['nom'] ?? '').toString().toLowerCase();
              final phone = (u['telephone'] ?? '').toString().toLowerCase();
              return prenom.contains(q) || nom.contains(q) || phone.contains(q);
            }).toList();
    });
  }

  Future<void> _refresh() async {
    await context.read<AdminProvider>().fetchUsers();
    _onSearch();
  }

  Future<void> _suspendUser(String id, String currentStatus) async {
    final success = await context.read<AdminProvider>().suspendAccount(id, 'User');
    if (success && mounted) {
      Navigator.pop(context); // Close modal
      final isNowSuspended = currentStatus != 'suspended';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isNowSuspended ? 'Donneur suspendu' : 'Donneur réactivé'),
        backgroundColor: isNowSuspended ? AppColors.destructive : AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ));
      _onSearch();
    }
  }

  Future<void> _deleteUser(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment supprimer cet utilisateur définitivement ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Supprimer', style: TextStyle(color: AppColors.destructive))
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await context.read<AdminProvider>().deleteAccount(id, 'User');
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

  void _showUserDetails(Map<String, dynamic> u) {
    final id = u['_id'] ?? '';
    final prenom = u['prenom'] ?? '';
    final nom = u['nom'] ?? '';
    final fullName = '$prenom $nom'.trim();
    final phone = u['telephone'] ?? 'Non renseigné';
    final email = u['email'] ?? 'Non renseigné';
    final bloodGroup = u['groupeSanguin'] ?? 'N/A';
    final city = u['lieuResidence'] ?? 'Non renseigné';
    final status = u['status'] ?? 'active';

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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                        child: const Icon(LucideIcons.user, color: AppColors.primary, size: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(fullName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Center(child: _buildStatusBadge(status == 'active')),
                    const SizedBox(height: 32),
                    
                    _buildDetailRow(LucideIcons.droplet, "Groupe Sanguin", bloodGroup),
                    _buildDetailRow(LucideIcons.phone, "Téléphone", phone),
                    _buildDetailRow(LucideIcons.mail, "Email", email),
                    _buildDetailRow(LucideIcons.mapPin, "Lieu de résidence", city),
                    
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: SangVieButton(
                            label: status == 'suspended' ? "Réactiver" : "Suspendre", 
                            isSecondary: status != 'suspended',
                            backgroundColor: status == 'suspended' ? AppColors.successGreen : AppColors.warningOrange,
                            onPressed: () => _suspendUser(id, status), 
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SangVieButton(
                            label: "Supprimer", 
                            backgroundColor: AppColors.destructive,
                            onPressed: () => _deleteUser(id), 
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
                Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool active) {
    return SangVieBadge(
      label: active ? "ACTIF" : "SUSPENDU", 
      color: active ? AppColors.successGreen : AppColors.destructive,
      icon: active ? LucideIcons.checkCircle2 : LucideIcons.ban,
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
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.xl),
              _buildSearchBar(),
              const SizedBox(height: AppSpacing.xl),
              Consumer<AdminProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.allUsers.isEmpty) {
                    return _buildLoadingState();
                  }
                  
                  final actives = provider.allUsers.where((u) => u['status'] != 'suspended').length;
                  final displayList = _searchController.text.isEmpty ? provider.allUsers : _filtered;

                  return Column(
                    children: [
                      _buildKPIRow(provider.allUsers.length, actives, displayList.length),
                      const SizedBox(height: AppSpacing.xl),
                      
                      if (displayList.isEmpty)
                        _buildEmptyState()
                      else
                        ...displayList.map((u) => _buildUserListItem(u))
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

  Widget _buildKPIRow(int total, int actives, int viewCount) {
    return Row(
      children: [
        Expanded(child: _buildKPIBox("TOTAL", total.toString(), AppColors.primary)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildKPIBox("ACTIFS", actives.toString(), AppColors.successGreen)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildKPIBox("VUE", viewCount.toString(), AppColors.foreground)),
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
    final nom = u['nom'] ?? '';
    final fullName = '$prenom $nom'.trim();
    final phone = u['telephone'] ?? 'N/A';
    final bloodGroup = u['groupeSanguin'] ?? '';
    final isSuspended = u['status'] == 'suspended';

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
                    color: isSuspended ? AppColors.secondarySoft : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(LucideIcons.user, color: isSuspended ? AppColors.secondary : AppColors.primary, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName.isNotEmpty ? fullName : 'Donneur Anonyme', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, decoration: isSuspended ? TextDecoration.lineThrough : null)),
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
                _buildStatusCircle(!isSuspended),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: SangVieButton(
                    label: 'Détails', 
                    isSecondary: true,
                    onPressed: () => _showUserDetails(u), 
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
        color: active ? AppColors.successGreen : AppColors.destructive,
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
