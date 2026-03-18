import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/services/auth_service.dart';
import 'package:sangvie/core/services/language_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';

import 'package:sangvie/presentation/widgets/hospital_request_modal.dart';

class HospitalLayout extends StatelessWidget {
  final Widget child;

  const HospitalLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final t = languageService.t;
    final location = GoRouterState.of(context).uri.toString();

    final mainNavItems = [
      SangVieNavItem(icon: LucideIcons.layoutDashboard, label: t('nav.hospital.dashboard'), path: '/hospital/dashboard'),
      SangVieNavItem(icon: LucideIcons.messageSquare, label: 'Messages', path: '/conversations'),
      SangVieNavItem(icon: LucideIcons.stethoscope, label: t('nav.hospital.requests'), path: '/hospital/requests'),
      SangVieNavItem(icon: LucideIcons.barChart3, label: t('nav.hospital.stats'), path: '/hospital/stats'),
    ];

    final settingsNavItems = [
      SangVieNavItem(icon: LucideIcons.helpCircle, label: 'Aide', path: '/info/help'),
      SangVieNavItem(icon: LucideIcons.info, label: 'À propos', path: '/info/about'),
      SangVieNavItem(icon: LucideIcons.shield, label: 'Confidentialité', path: '/info/privacy'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) {
            final canPop = GoRouter.of(context).canPop();
            return IconButton(
              icon: Icon(
                canPop ? LucideIcons.arrowLeft : LucideIcons.menu, 
                color: AppColors.foreground
              ),
              onPressed: () => canPop ? context.pop() : Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: _buildAppBarTitle(location),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(LucideIcons.bell, size: 22, color: AppColors.foreground.withOpacity(0.8)),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      drawer: _buildDrawer(context, [
        ...mainNavItems, 
        SangVieNavItem(icon: LucideIcons.mapPin, label: t('nav.hospital.map'), path: '/hospital/map'),
        ...settingsNavItems
      ], location, t),
      body: child,
      bottomNavigationBar: MediaQuery.of(context).size.width < 1024 
        ? SangVieBottomNav(
            items: mainNavItems,
            currentPath: location,
            onTabTap: (path) => context.go(path),
            actionButton: _buildCenterItem(context),
          )
        : null,
    );
  }

  Widget _buildAppBarTitle(String location) {
    String title = 'SangVie Pro';
    bool showLogo = true;

    if (location.startsWith('/settings')) {
      title = 'Paramètres';
      showLogo = false;
    } else if (location.startsWith('/info/about')) {
      title = 'À propos';
      showLogo = false;
    } else if (location.startsWith('/info/help')) {
      title = 'Aide & Support';
      showLogo = false;
    } else if (location.startsWith('/info/privacy')) {
      title = 'Confidentialité';
      showLogo = false;
    } else if (location.startsWith('/hospital/profile')) {
      title = 'Profil Établissement';
      showLogo = false;
    } else if (location.startsWith('/conversations')) {
      title = 'Mes Discussions';
      showLogo = false;
    }

    if (!showLogo) {
      return Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: AppColors.foreground,
        ),
      );
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Icon(LucideIcons.droplets, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.8,
            color: AppColors.foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, List<SangVieNavItem> items, String location, Function t) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return SangVieDrawer(
      userName: user?.nom ?? 'Établissement',
      userSubtitle: user?.email ?? 'Compte Pro',
      items: items,
      currentPath: location,
      onLogout: () {
        authService.logout();
        context.go('/login');
      },
      onTabTap: (path) => context.go(path),
    );
  }

  Widget _buildCenterItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const HospitalRequestModal(),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 24),
      ),
    );
  }
}
