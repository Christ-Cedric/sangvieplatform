import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/core/services/auth_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/data/models/blood_request_model.dart';
import 'package:sangvie/data/repositories/blood_request_repository.dart';
import 'package:sangvie/presentation/widgets/donor_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DonorFeedScreen extends StatefulWidget {
  const DonorFeedScreen({super.key});

  @override
  State<DonorFeedScreen> createState() => _DonorFeedScreenState();
}

class _DonorFeedScreenState extends State<DonorFeedScreen> {
  final BloodRequestRepository _repository = BloodRequestRepository();
  bool _isActive = true;
  late Future<List<BloodRequest>> _requestsFuture;
  final TextEditingController _searchController = TextEditingController();
  List<BloodRequest> _allRequests = [];
  List<BloodRequest> _filteredRequests = [];

  @override
  void initState() {
    super.initState();
    _requestsFuture = _fetchInitialData();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<BloodRequest>> _fetchInitialData() async {
    final res = await _repository.getAllRequests();
    _allRequests = res;
    _onSearch();
    return res;
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredRequests = q.isEmpty
          ? _allRequests
          : _allRequests.where((r) {
              return r.hospital.toLowerCase().contains(q) ||
                  r.group.toLowerCase().contains(q);
            }).toList();
    });
  }

  void _refresh() {
    setState(() {
      _requestsFuture = _fetchInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final firstName = user?.prenom ?? user?.nom ?? 'Donneur';

    return DonorLayout(
      child: RefreshIndicator(
        onRefresh: () async => _refresh(),
        color: AppColors.primary,
        displacement: 20,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Modern Premium Header ───────────────────────────
              _buildHeader(firstName),

              // ─── Main Content ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),

                    // Status Card
                    _buildStatusCard()
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: AppSpacing.lg),

                    // Search Bar
                    SangVieInput(
                      hint: 'Rechercher un hôpital ou un groupe...',
                      prefixIcon: const Icon(LucideIcons.search,
                          size: 20, color: AppColors.secondary),
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                    ).animate().fadeIn(delay: 350.ms),

                    const SizedBox(height: AppSpacing.xl),

                    // Urgent Requests Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SangVieTypography.label('Demandes Urgentes')
                            .animate()
                            .fadeIn(delay: 500.ms),
                        _buildRefreshButton(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Urgent Feed
                    FutureBuilder<List<BloodRequest>>(
                      future: _requestsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting && _allRequests.isEmpty) {
                          return _buildLoadingState();
                        }
                        if (_filteredRequests.isEmpty) {
                          return _buildEmptyState().animate().fadeIn();
                        }
                        final requests = _filteredRequests;
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: requests.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) =>
                              _buildRequestCard(requests[index])
                                  .animate()
                                  .fadeIn(delay: (100 * index).ms)
                                  .slideY(begin: 0.1, end: 0),
                        );
                      },
                    ),

                    const SizedBox(height: 120), // Padding for NAV
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String firstName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xxl),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(AppRadius.xxl)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour, $firstName 👋'.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ).animate().fadeIn().slideX(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          const Text(
            'Prêt à sauver des vies aujourd\'hui ?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return SangVieCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md + 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (_isActive ? AppColors.successGreen : AppColors.secondary)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isActive ? LucideIcons.checkCircle2 : LucideIcons.copySlash,
              color: _isActive ? AppColors.successGreen : AppColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SangVieTypography.h3(
                  'Disponibilité',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  _isActive ? 'Visible pour les urgences' : 'Mode privé activé',
                  style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isActive,
            onChanged: (val) => setState(() => _isActive = val),
            activeColor: Colors.white,
            activeTrackColor: AppColors.successGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.8,
      children: [
        SangVieActionItem(
          label: 'Carte',
          icon: LucideIcons.map,
          color: Colors.blue,
          onTap: () => context.go('/donor/map'),
        ),
        SangVieActionItem(
          label: 'Historique',
          icon: LucideIcons.history,
          color: AppColors.warningOrange,
          onTap: () => context.go('/donor/history'),
        ),
        SangVieActionItem(
          label: 'Profil',
          icon: LucideIcons.userCircle,
          color: Colors.purple,
          onTap: () => context.go('/donor/profile'),
        ),
        SangVieActionItem(
          label: 'Infos',
          icon: LucideIcons.heartPulse,
          color: AppColors.sangVieRed,
          onTap: () => _showDonationInfo(context),
        ),
      ],
    );
  }

  Widget _buildRefreshButton() {
    return GestureDetector(
      onTap: _refresh,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.refreshCw,
                size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Actualiser'.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
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

  Widget _buildEmptyState() {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: AppColors.inputBackground,
      hasBorder: false,
      child: Column(
        children: [
          Icon(LucideIcons.shieldCheck,
              size: 48, color: AppColors.successGreen.withOpacity(0.5)),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Tout est calme pour le moment.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.secondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Aucune demande urgente signalée dans votre zone.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BloodRequest d) {
    return SangVieCard(
      onTap: () => _showRequestDetails(d),
      padding: const EdgeInsets.all(AppSpacing.md + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    d.group,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.hospital,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(LucideIcons.droplet,
                            size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${d.quantity} poche(s) demandée(s)',
                          style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SangVieBadge(
                label: d.urgency == 'critical' ? 'Vital' : 'Modéré',
                color: d.urgency == 'critical'
                    ? AppColors.destructive
                    : AppColors.warningOrange,
                icon: d.urgency == 'critical'
                    ? LucideIcons.alertTriangle
                    : LucideIcons.clock,
              ),
            ],
          ),
          if (d.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              d.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.foreground, height: 1.4),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.calendar,
                      size: 14, color: AppColors.mutedForeground),
                  const SizedBox(width: 6),
                  Text(d.date,
                      style: const TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              Text(
                'Détails'.toUpperCase(),
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(BloodRequest d) {
    final TextEditingController messageController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: AppSpacing.xl),
    
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Center(
                  child: Text(d.group,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 32)),
                ),
              ),
    
              const SizedBox(height: AppSpacing.lg),
    
              SangVieBadge(
                label:
                    d.urgency == 'critical' ? 'Urgence Vitale' : 'Urgence Modérée',
                color: d.urgency == 'critical'
                    ? AppColors.destructive
                    : AppColors.warningOrange,
                icon: LucideIcons.alertCircle,
              ),
    
              const SizedBox(height: AppSpacing.md),
    
              SangVieTypography.h3(d.hospital, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('${d.quantity} poche(s) • Demandé le ${d.date}',
                  style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
    
              const SizedBox(height: AppSpacing.xl),
    
              if (d.description.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                  ),
                  child: Text(d.description,
                      style: const TextStyle(
                          fontSize: 15, color: AppColors.foreground, height: 1.5)),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Message optionnel pour l\'hôpital',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SangVieInput(
                hint: 'Ex: Je serai là dans 20 minutes...',
                controller: messageController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xl),
    
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SangVieButton(
                      label: 'Fermer',
                      isSecondary: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SangVieButton(
                      label: 'Répondre',
                      onPressed: () {
                        final msg = messageController.text.trim();
                        Navigator.pop(context);
                        _respondToRequest(d.id, message: msg);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  void _showDonationInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
                child: Icon(LucideIcons.heartPulse,
                    color: AppColors.primary, size: 48)),
            const SizedBox(height: AppSpacing.lg),
            const Center(
                child: Text('Le Don de Sang',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: -0.5))),
            const SizedBox(height: AppSpacing.xl),
            _buildInfoRow(
                LucideIcons.checkCircle2, 'Volume', '450 ml prélevés par don.'),
            _buildInfoRow(
                LucideIcons.clock, 'Temps', 'Environ 10 à 15 minutes.'),
            _buildInfoRow(LucideIcons.calendar, 'Fréquence',
                '8 semaines entre deux dons.'),
            _buildInfoRow(LucideIcons.coffee, 'Repos',
                '15 mins de repos avec collation après.'),
            const SizedBox(height: AppSpacing.xl),
            SangVieButton(
                label: 'J\'ai compris',
                onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _respondToRequest(String requestId, {String? message}) async {
    final res = await ApiService.post(
      ApiConstants.respondToRequest(requestId), 
      {'message': message},
    );
    if (!mounted) return;
    
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci pour votre engagement ! L\'hôpital a été notifié.'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la réponse. Veuillez réessayer.'),
          backgroundColor: AppColors.destructive,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.secondary, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
