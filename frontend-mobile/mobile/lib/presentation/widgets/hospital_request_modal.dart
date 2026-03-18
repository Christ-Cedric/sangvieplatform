import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HospitalRequestModal extends StatefulWidget {
  final VoidCallback? onCreated;

  const HospitalRequestModal({super.key, this.onCreated});

  @override
  State<HospitalRequestModal> createState() => _HospitalRequestModalState();
}

class _HospitalRequestModalState extends State<HospitalRequestModal> {
  final _groupController = TextEditingController();
  final _qtyController = TextEditingController();
  final _reasonController = TextEditingController();
  String _urgency = 'urgent'; // Default to urgent for backend
  bool _submitting = false;

  @override
  void dispose() {
    _groupController.dispose();
    _qtyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final group = _groupController.text.trim().toUpperCase();
    final qty = int.tryParse(_qtyController.text.trim()) ?? 1;
    final reason = _reasonController.text.trim();

    if (group.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un groupe sanguin'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _submitting = true);

    final body = {
      'groupeSanguin': group,
      'quantitePoches': qty,
      'niveauUrgence': _urgency,
      'description': reason,
    };

    final result = await ApiService.post(ApiConstants.createHospitalRequest, body);
    setState(() => _submitting = false);

    if (result != null && mounted) {
      if (widget.onCreated != null) widget.onCreated!();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande créée avec succès !'), 
          backgroundColor: AppColors.successGreen, 
          behavior: SnackBarBehavior.floating
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la création de la demande.'), 
          backgroundColor: AppColors.destructive, 
          behavior: SnackBarBehavior.floating
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            SangVieTypography.h3('Nouvelle demande de sang'),
            const SizedBox(height: 4),
            const Text('Remplissez les informations ci-dessous', style: TextStyle(color: AppColors.secondary, fontSize: 14)),
            
            const SizedBox(height: AppSpacing.xl),
            
            Row(
              children: [
                Expanded(child: SangVieInput(label: 'Groupe', hint: 'ex: O+', controller: _groupController)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: SangVieInput(label: 'Quantité', hint: 'Poches', controller: _qtyController, keyboardType: TextInputType.number)),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            SangVieInput(label: 'Raison (Optionnel)', hint: 'ex: Chirurgie programmée', controller: _reasonController),
            
            const SizedBox(height: AppSpacing.lg),
            
            const Text('Niveau d\'urgence', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: -0.2)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _urgency,
                  isExpanded: true,
                  icon: const Icon(LucideIcons.chevronDown, size: 18),
                  onChanged: (v) => setState(() => _urgency = v ?? 'urgent'),
                  items: const [
                    DropdownMenuItem(value: 'critique', child: Text('Urgence Vitale', style: TextStyle(fontWeight: FontWeight.w700))),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgence Modérée', style: TextStyle(fontWeight: FontWeight.w700))),
                    DropdownMenuItem(value: 'normal', child: Text('Faible Priorité', style: TextStyle(fontWeight: FontWeight.w700))),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            Row(
              children: [
                Expanded(
                  child: SangVieButton(
                    label: 'Annuler',
                    isSecondary: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SangVieButton(
                    label: 'Créer',
                    onPressed: _submitting ? () {} : _submitRequest,
                    isLoading: _submitting,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1.0, end: 0.0, duration: 400.ms, curve: Curves.easeOutQuart);
  }
}
