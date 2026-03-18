import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/data/repositories/blood_request_repository.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/chat_screen.dart';

class RequestResponsesScreen extends StatefulWidget {
  final String requestId;
  final String group;

  const RequestResponsesScreen({
    super.key,
    required this.requestId,
    required this.group,
  });

  @override
  State<RequestResponsesScreen> createState() => _RequestResponsesScreenState();
}

class _RequestResponsesScreenState extends State<RequestResponsesScreen> {
  final BloodRequestRepository _repo = BloodRequestRepository();
  late Future<List<Map<String, dynamic>>> _responsesFuture;

  @override
  void initState() {
    super.initState();
    _responsesFuture = _repo.getRequestResponses(widget.requestId);
  }

  void _refresh() {
    setState(() {
      _responsesFuture = _repo.getRequestResponses(widget.requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Réponses (${widget.group})'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _responsesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final responses = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: responses.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final res = responses[index];
              final user = res['userId'];
              final message = res['message'] as String?;
              final isConfirmed = res['statut'] == 'complete';

              return SangVieCard(
                padding: const EdgeInsets.all(AppSpacing.md + 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primarySoft,
                          child: Text(
                            '${user['nom'][0]}${user['prenom'][0]}',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user['nom']} ${user['prenom']}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              Text(
                                user['telephone'] ?? '',
                                style: const TextStyle(color: AppColors.secondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        if (isConfirmed)
                          const SangVieBadge(label: 'CONFIRMÉ', color: AppColors.successGreen, icon: LucideIcons.checkCircle2)
                        else
                          IconButton(
                            icon: const Icon(LucideIcons.checkCircle2, color: AppColors.successGreen),
                            onPressed: () => _confirm(res['_id']),
                          ),
                      ],
                    ),
                    if (message != null && message.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Text(
                          '"$message"',
                          style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: SangVieButton(
                            label: 'Appeler',
                            icon: const Icon(LucideIcons.phone, size: 18),
                            isSecondary: true,
                            onPressed: () => _call(user['telephone']),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: SangVieButton(
                            label: 'Chat',
                            icon: const Icon(LucideIcons.messageSquare, size: 18),
                            onPressed: () => _openChat(user['_id'], '${user['nom']} ${user['prenom']}'),
                          ),
                        ),
                      ],
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

  void _call(String? phone) async {
    if (phone == null) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openChat(String userId, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          otherId: userId,
          otherName: name,
          otherType: 'User',
        ),
      ),
    );
  }

  Future<void> _confirm(String donationId) async {
    final ok = await _repo.confirmDonation(donationId);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Don confirmé !'), backgroundColor: AppColors.successGreen),
      );
      _refresh();
    }
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('Aucun donneur n\'a encore répondu.'));
  }
}
