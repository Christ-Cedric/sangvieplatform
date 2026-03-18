import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/services/auth_service.dart';
import 'package:sangvie/core/services/language_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final t = languageService.t;
    final location = GoRouterState.of(context).uri.toString();

    final mainNavItems = [
      SangVieNavItem(
          icon: LucideIcons.layoutDashboard,
          label: t('nav.admin.dashboard'),
          path: '/admin/dashboard'),
      SangVieNavItem(
          icon: LucideIcons.building2,
          label: t('nav.admin.hospitals'),
          path: '/admin/hospitals'),
      SangVieNavItem(
          icon: LucideIcons.users,
          label: t('nav.admin.users'),
          path: '/admin/users'),
      SangVieNavItem(
          icon: LucideIcons.barChart3,
          label: t('nav.admin.reports'),
          path: '/admin/reports'),
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
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0F172A), // Slate 900 (Admin Dark Theme)
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 65,
        centerTitle: false,
        leading: Builder(
          builder: (context) {
            final canPop = GoRouter.of(context).canPop();
            return IconButton(
              icon: Icon(canPop ? LucideIcons.arrowLeft : LucideIcons.menu,
                  color: Colors.white),
              onPressed: () =>
                  canPop ? context.pop() : Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: _buildAppBarTitle(location),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.bell, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildAdminDrawer(
          context, [...mainNavItems, ...settingsNavItems], location),
      body: child,
    );
  }

  Widget _buildAppBarTitle(String location) {
    String title = 'Admin Central';
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
    }

    if (!showLogo) {
      return Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: Colors.white,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(LucideIcons.shieldCheck,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminDrawer(
      BuildContext context, List<SangVieNavItem> items, String location) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return SangVieDrawer(
      userName: user?.nom ?? 'Administrateur',
      userSubtitle: 'Gestion Centralisée',
      items: items,
      currentPath: location,
      onLogout: () {
        authService.logout();
        context.go('/login');
      },
      onTabTap: (path) => context.go(path),
    );
  }
}
