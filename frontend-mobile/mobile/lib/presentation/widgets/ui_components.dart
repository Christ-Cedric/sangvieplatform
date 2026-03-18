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
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          gradient: (backgroundColor == null && !isSecondary && !isOutlined) ? AppColors.primaryGradient : null,
          color: (backgroundColor != null || isSecondary || isOutlined) ? (isOutlined ? Colors.transparent : bg) : null,
          border: isOutlined ? Border.all(color: backgroundColor ?? AppColors.primary, width: 2) : null,
          boxShadow: (isSecondary || isOutlined) ? [] : [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
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
        TextField(
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
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.destructive, width: 1),
            ),
            contentPadding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            prefixIcon: prefixIcon != null 
              ? Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: prefixIcon,
                ) 
              : null,
            suffixIcon: suffixIcon,
            errorText: errorText,
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

  const SangVieBottomNav({
    super.key,
    required this.items,
    required this.currentPath,
    required this.onTabTap,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ...items.sublist(0, (items.length / 2).floor()).map((item) => _buildNavItem(item)),
              if (actionButton != null) actionButton!,
              ...items.sublist((items.length / 2).floor()).map((item) => _buildNavItem(item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(SangVieNavItem item) {
    final isActive = currentPath.startsWith(item.path);
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabTap(item.path),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: 250.ms,
              scale: isActive ? 1.15 : 1.0,
              curve: Curves.easeOutBack,
              child: Icon(
                item.icon,
                color: isActive ? AppColors.primary : AppColors.mutedForeground.withOpacity(0.5),
                size: 24,
              ),
            ),

            const SizedBox(height: 2),
            AnimatedContainer(
              duration: 300.ms,
              width: isActive ? 4 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
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

  const SangVieDrawer({
    super.key,
    this.userImageUrl,
    required this.userName,
    required this.userSubtitle,
    required this.items,
    required this.currentPath,
    required this.onLogout,
    required this.onTabTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.85,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(AppRadius.xxl)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipPath(
                clipper: HeaderWaveClipper(),
                child: Container(
                  height: 240,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.mail, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              userSubtitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: items.map((item) {
                final isActive = currentPath.startsWith(item.path);
                return SangVieDrawerItem(
                  icon: item.icon,
                  label: item.label,
                  isActive: isActive,
                  onTap: () {
                    Navigator.pop(context);
                    onTabTap(item.path);
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SangVieButton(
              label: 'Déconnexion',
              onPressed: onLogout,
              isOutlined: true,
              isFullWidth: true,
              height: 50,
              icon: const Icon(Icons.logout, color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(height: 20),
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

  const SangVieDrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isActive ? Colors.white : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary, // Red text as in image
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
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
