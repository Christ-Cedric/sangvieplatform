import 'package:flutter/material.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Professional Spacing Scale
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Professional Radius Scale
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

class SangVieTypography {
  static const String fontFamily = 'Outfit'; // Fallback to system if not loaded

  static Widget h1(String text, {TextStyle? style, TextAlign? textAlign}) {
    return Text(
      text,
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.foreground,
        letterSpacing: -0.8,
        height: 1.2,
      ).merge(style),
    );
  }

  static Widget h2(String text, {TextStyle? style, TextAlign? textAlign}) {
    return Text(
      text,
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.foreground,
        letterSpacing: -0.5,
      ).merge(style),
    );
  }

  static Widget h3(String text, {TextStyle? style, TextAlign? textAlign}) {
    return Text(
      text,
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.foreground,
        letterSpacing: -0.3,
      ).merge(style),
    );
  }

  static Widget body(String text, {TextStyle? style, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.foreground,
        height: 1.5,
      ).merge(style),
    );
  }

  static Widget small(String text, {TextStyle? style, TextAlign? textAlign}) {
    return Text(
      text,
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.secondary,
        height: 1.4,
      ).merge(style),
    );
  }

  static Widget label(String text, {TextStyle? style, TextAlign? textAlign}) {
    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.mutedForeground,
        letterSpacing: 1.2,
      ).merge(style),
    );
  }
}

class SangVieButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final bool isLoading;
  final Widget? icon;
  final bool isSecondary;
  final bool isOutlined;
  final EdgeInsetsGeometry? padding;

  const SangVieButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isFullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.isLoading = false,
    this.icon,
    this.isSecondary = false,
    this.isOutlined = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSecondary ? AppColors.inputBackground : (backgroundColor ?? AppColors.primary);
    final fg = isOutlined ? (backgroundColor ?? AppColors.primary) : (isSecondary ? AppColors.foreground : (foregroundColor ?? Colors.white));

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 56,
      child: AnimatedContainer(
        duration: 200.ms,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: (backgroundColor == null && !isSecondary && !isOutlined) ? AppColors.primaryGradient : null,
          color: (backgroundColor != null || isSecondary || isOutlined) ? (isOutlined ? Colors.transparent : bg) : null,
          border: isOutlined ? Border.all(color: backgroundColor ?? AppColors.primary, width: 2) : null,
          boxShadow: (isSecondary || isOutlined) ? [] : [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            child: Padding(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(fg),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            fontSize: 16,
                            color: fg,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class SangVieCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool hasBorder;
  final double? width;
  final double? height;

  const SangVieCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderRadius,
    this.boxShadow,
    this.hasBorder = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
        border: hasBorder ? Border.all(color: AppColors.border.withOpacity(0.6), width: 1.2) : null,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}

class SangVieBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const SangVieBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class SangVieStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final EdgeInsetsGeometry? padding;

  const SangVieStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SangVieCard(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SangVieActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const SangVieActionItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return SangVieCard(
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: activeColor, size: 26),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.foreground,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class SangVieInput extends StatelessWidget {
  final String? label;
  final String hint;
  final bool obscureText;
  final TextEditingController? controller;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int? maxLines;
  final EdgeInsetsGeometry? padding;

  const SangVieInput({
    super.key,
    this.label,
    required this.hint,
    this.obscureText = false,
    this.controller,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.padding,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.foreground,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.destructive, width: 1),
              ),
              contentPadding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              errorText: errorText,
            ),
          ),
        ),
      ],
    );
  }
}

class SangVieNavItem {
  final IconData icon;
  final String label;
  final String path;

  SangVieNavItem({
    required this.icon,
    required this.label,
    required this.path,
  });
}

class SangVieBottomNav extends StatelessWidget {
  final List<SangVieNavItem> items;
  final String currentPath;
  final Function(String) onTabTap;
  final Widget? actionButton;
  final Color? activeColor;

  const SangVieBottomNav({
    super.key,
    required this.items,
    required this.currentPath,
    required this.onTabTap,
    this.actionButton,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // The bar itself
        Container(
          height: 85,
          margin: const EdgeInsets.only(
              top: 15), // Create space for the FAB overlap
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ...items
                    .sublist(0, (items.length / 2).floor())
                    .map((item) => _buildNavItem(item)),
                if (actionButton != null)
                  const SizedBox(width: 60), // Space for action button
                ...items
                    .sublist((items.length / 2).floor())
                    .map((item) => _buildNavItem(item)),
              ],
            ),
          ),
        ),
        // The Action Button (Floating & Diamond)
        if (actionButton != null)
          Positioned(
            top: -15, // Floating overlap
            child: actionButton!,
          ),
      ],
    );
  }

  Widget _buildNavItem(SangVieNavItem item) {
    final isActive = currentPath.startsWith(item.path);
    final color = isActive
        ? (activeColor ?? AppColors.primary)
        : const Color(0xFF94A3B8);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabTap(item.path),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SangVieDrawer extends StatelessWidget {
  final String? userImageUrl;
  final String userName;
  final String userSubtitle;
  final List<SangVieNavItem> items;
  final String currentPath;
  final VoidCallback onLogout;
  final Function(String) onTabTap;
  final Gradient? gradient;
  final Color? activeColor;

  const SangVieDrawer({
    super.key,
    this.userImageUrl,
    required this.userName,
    required this.userSubtitle,
    required this.items,
    required this.currentPath,
    required this.onLogout,
    required this.onTabTap,
    this.gradient,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              Navigator.pop(context);
              onTabTap('/hospital/profile');
            },
            child: Container(
              padding: const EdgeInsets.only(
                  top: 60, left: 20, right: 20, bottom: 30),
              decoration: BoxDecoration(
                gradient: gradient ?? AppColors.primaryGradient,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: userImageUrl != null
                          ? NetworkImage(userImageUrl!)
                          : null,
                      child: userImageUrl == null
                          ? Icon(LucideIcons.user,
                              size: 35, color: activeColor ?? AppColors.primary)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star,
                                color: Colors.yellow.shade600, size: 16),
                            Icon(Icons.star,
                                color: Colors.yellow.shade600, size: 16),
                            Icon(Icons.star,
                                color: Colors.yellow.shade600, size: 16),
                            Icon(Icons.star,
                                color: Colors.yellow.shade600, size: 16),
                            const Icon(Icons.star_outline,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              "4.8",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight,
                      color: Colors.white70, size: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: items.map((item) {
                final isActive = currentPath.startsWith(item.path);
                return SangVieDrawerItem(
                  icon: item.icon,
                  label: item.label,
                  isActive: isActive,
                  activeColor: activeColor,
                  onTap: () {
                    Navigator.pop(context);
                    onTabTap(item.path);
                  },
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(LucideIcons.logOut,
                        color: activeColor ?? AppColors.primary, size: 22),
                    const SizedBox(width: 20),
                    Text(
                      'Déconnexion',
                      style: TextStyle(
                        color: activeColor ?? AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class SangVieDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;

  const SangVieDrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? (activeColor ?? AppColors.primary).withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive
                    ? (activeColor ?? AppColors.primary)
                    : const Color(0xFF718096),
                size: 24,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? (activeColor ?? AppColors.primary)
                        : const Color(0xFF2D3748),
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 80);

    var controlPoint = Offset(size.width * 0.4, size.height + 40);
    var endPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
