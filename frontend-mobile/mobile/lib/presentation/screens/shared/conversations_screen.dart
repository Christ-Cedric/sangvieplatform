import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/data/models/message_model.dart';
import 'package:sangvie/data/repositories/message_repository.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final MessageRepository _repository = MessageRepository();
  late Future<List<ConversationModel>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _conversationsFuture = _repository.getConversations();
  }

  void _refresh() {
    setState(() {
      _conversationsFuture = _repository.getConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Discussions'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<ConversationModel>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final convs = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: convs.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final c = convs[index];
              return SangVieCard(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        otherId: c.otherId,
                        otherName: c.otherType == 'Hospital' ? 'Hôpital' : 'Donneur',
                        otherType: c.otherType,
                      ),
                    ),
                  );
                  _refresh();
                },
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primarySoft,
                      child: Icon(
                        c.otherType == 'Hospital' ? LucideIcons.building2 : LucideIcons.user,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                c.otherType == 'Hospital' ? 'Hôpital' : 'Donneur',
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                DateFormat('HH:mm').format(c.date),
                                style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: c.isRead ? AppColors.mutedForeground : AppColors.foreground,
                              fontWeight: c.isRead ? FontWeight.normal : FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!c.isRead)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
              );
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
          Icon(LucideIcons.messageSquare, size: 64, color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          const Text('Aucune discussion', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.secondary)),
          const Text('Répondez à une demande pour discuter.', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}
