import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/providers/notification_provider.dart';
import 'package:sangvie/core/services/auth_service.dart';
import 'package:sangvie/core/services/language_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/notification_modal.dart';
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
      SangVieNavItem(
          icon: LucideIcons.layoutDashboard,
          label: t('nav.hospital.dashboard'),
          path: '/hospital/dashboard'),
      SangVieNavItem(
          icon: LucideIcons.messageCircle,
          label: 'Messages',
          path: '/conversations'),
      SangVieNavItem(
          icon: LucideIcons.stethoscope,
          label: t('nav.hospital.requests'),
          path: '/hospital/requests'),
      SangVieNavItem(
          icon: LucideIcons.barChart3,
          label: t('nav.hospital.stats'),
          path: '/hospital/stats'),
      SangVieNavItem(
          icon: LucideIcons.user, label: 'Profil', path: '/hospital/profile'),
    ];

    final settingsNavItems = [
      SangVieNavItem(
          icon: LucideIcons.helpCircle, label: 'Aide', path: '/info/help'),
      SangVieNavItem(
          icon: LucideIcons.info, label: 'À propos', path: '/info/about'),
      SangVieNavItem(
          icon: LucideIcons.shield,
          label: 'Confidentialité',
          path: '/info/privacy'),
    ];

    final isGradientScreen = [
      '/hospital/dashboard',
      '/hospital/requests',
      '/hospital/stats',
      '/hospital/profile'
    ].any((path) => location == path);

    final appBarIconColor =
        isGradientScreen ? Colors.white : AppColors.foreground;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: location.startsWith('/settings') ? 0 : 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) {
            final canPop = GoRouter.of(context).canPop();
            return IconButton(
              icon: Icon(canPop ? LucideIcons.arrowLeft : LucideIcons.menu,
                  color: appBarIconColor),
              onPressed: () =>
                  canPop ? context.pop() : Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: _buildAppBarTitle(location, appBarIconColor),
        actions: [
          _buildNotificationIcon(context, appBarIconColor),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      drawer: _buildDrawer(
          context,
          [
            ...mainNavItems,
            SangVieNavItem(
                icon: LucideIcons.mapPin,
                label: t('nav.hospital.map'),
                path: '/hospital/map'),
            ...settingsNavItems
          ],
          location,
          t),
      body: child,
      bottomNavigationBar: MediaQuery.of(context).size.width < 1024
          ? SangVieBottomNav(
              items: mainNavItems
                  .where((item) => item.path != '/hospital/profile')
                  .toList(),
              currentPath: location,
              onTabTap: (path) => context.go(path),
              actionButton: _buildCenterItem(context),
            )
          : null,
    );
  }

  Widget _buildNotificationIcon(BuildContext context, Color color) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final unread = provider.unreadCount;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: () => NotificationModal.show(context),
              icon: Icon(LucideIcons.bell, size: 22, color: color),
            ),
            if (unread > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAppBarTitle(String location, Color color) {
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
    } else if (location.startsWith('/hospital/dashboard')) {
      showLogo =
          false; // Don't show redundant logo on dashboard as it has custom header
    } else if (location.startsWith('/conversations')) {
      title = 'Mes Discussions';
      showLogo = false;
    }

    if (!showLogo) {
      if (location == '/hospital/dashboard') return const SizedBox.shrink();
      return Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: color,
        ),
      );
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color == Colors.white
                ? Colors.white.withOpacity(0.2)
                : AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(LucideIcons.droplets,
              color: color == Colors.white ? Colors.white : AppColors.primary,
              size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.8,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, List<SangVieNavItem> items,
      String location, Function t) {
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
      child: Transform.rotate(
        angle: 3.14159 / 4, // 45 degrees
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Transform.rotate(
            angle: -3.14159 / 4,
            child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
