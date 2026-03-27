import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/providers/notification_provider.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () =>
                context.read<NotificationProvider>().fetchNotifications(),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final n = provider.notifications[index];
              return _NotificationTile(notification: n);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.bellOff, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          const Text(
            'Aucune notification',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const Text(
            'Vous serez alerté dès qu\'un hôpital a besoin de vous.',
            style: TextStyle(color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final dynamic notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'alert':
        icon = LucideIcons.alertTriangle;
        color = AppColors.destructive;
        break;
      case 'success':
        icon = LucideIcons.checkCircle2;
        color = AppColors.successGreen;
        break;
      default:
        icon = LucideIcons.info;
        color = AppColors.primary;
    }

    return SangVieCard(
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationProvider>().markAsRead(notification.id);
        }
      },
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead
                              ? FontWeight.w600
                              : FontWeight.w800,
                          fontSize: 16,
                          color: notification.isRead
                              ? AppColors.secondary
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    color: AppColors.foreground.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd/MM HH:mm').format(notification.date),
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
