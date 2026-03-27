import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/providers/notification_provider.dart';
import 'package:sangvie/core/services/auth_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';

import 'package:sangvie/presentation/widgets/notification_modal.dart';

class DonorLayout extends StatelessWidget {
  final Widget child;

  const DonorLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final mainNavItems = [
      SangVieNavItem(
          icon: LucideIcons.home, label: 'Accueil', path: '/donor/feed'),
      SangVieNavItem(
          icon: LucideIcons.messageCircle,
          label: 'Messages',
          path: '/conversations'),
      SangVieNavItem(
          icon: LucideIcons.history,
          label: 'Historique',
          path: '/donor/history'),
      SangVieNavItem(
          icon: LucideIcons.settings, label: 'Paramètres', path: '/settings'),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
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
                  color: AppColors.foreground),
              onPressed: () =>
                  canPop ? context.pop() : Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: _buildAppBarTitle(location),
        actions: [
          _buildNotificationIcon(context),
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
      drawer: _buildDrawer(
          context, [...mainNavItems, ...settingsNavItems], location),
      body: child,
      bottomNavigationBar: SangVieBottomNav(
        items: mainNavItems,
        currentPath: location,
        onTabTap: (path) => context.go(path),
        actionButton: _buildCenterItem(context),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final hasUnread = provider.unreadCount > 0;
        return _buildActionCircle(
          LucideIcons.bell,
          () => NotificationModal.show(context),
          badge: hasUnread,
        );
      },
    );
  }

  Widget _buildCenterItem(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/donor/map'),
      child: Transform.rotate(
        angle: 3.14159 / 4,
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
            child: const Icon(LucideIcons.map, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(String location) {
    String title = 'SangVie';
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
    } else if (location.startsWith('/donor/profile')) {
      title = 'Mon Profil';
      showLogo = false;
    } else if (location.startsWith('/donor/history')) {
      title = 'Mon Historique';
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
          child: const Icon(LucideIcons.droplets,
              color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.8,
            color: AppColors.foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(
      BuildContext context, List<SangVieNavItem> items, String location) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return SangVieDrawer(
      userName: user?.nom ?? 'Donneur',
      userSubtitle: user?.email ?? 'Membre SangVie',
      items: items,
      currentPath: location,
      onLogout: () {
        authService.logout();
        context.go('/login');
      },
      onTabTap: (path) => context.go(path),
    );
  }

  Widget _buildActionCircle(IconData icon, VoidCallback onTap,
      {bool badge = false}) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10),
          child: Material(
            color: AppColors.inputBackground,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, size: 20, color: AppColors.foreground),
              ),
            ),
          ),
        ),
        if (badge)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
