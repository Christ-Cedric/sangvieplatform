import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/services/language_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/public_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sangvie/core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Donor Controllers
  final _donorNomController = TextEditingController();
  final _donorPrenomController = TextEditingController();
  final _donorEmailController = TextEditingController();
  final _donorPhoneController = TextEditingController();
  final _donorPasswordController = TextEditingController();
  final _donorLieuController = TextEditingController();
  String _selectedBloodGroup = 'A+';

  // Hospital Controllers
  final _hospNomController = TextEditingController();
  final _hospEmailController = TextEditingController();
  final _hospPasswordController = TextEditingController();
  final _hospAgrementController = TextEditingController();
  final _hospContactController = TextEditingController();
  final _hospRegionController = TextEditingController();
  final _hospLocalisationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _donorNomController.dispose();
    _donorPrenomController.dispose();
    _donorEmailController.dispose();
    _donorPhoneController.dispose();
    _donorPasswordController.dispose();
    _donorLieuController.dispose();
    _hospNomController.dispose();
    _hospEmailController.dispose();
    _hospPasswordController.dispose();
    _hospAgrementController.dispose();
    _hospContactController.dispose();
    _hospRegionController.dispose();
    _hospLocalisationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final authService = Provider.of<AuthService>(context);
    final t = languageService.t;

    Future<void> _handleRegisterDonor() async {
      final userData = {
        'nom': _donorNomController.text,
        'prenom': _donorPrenomController.text,
        'email': _donorEmailController.text,
        'motDePasse': _donorPasswordController.text,
        'telephone': _donorPhoneController.text,
        'lieuResidence': _donorLieuController.text,
        'groupeSanguin': _selectedBloodGroup,
      };

      if (userData.values.any((v) => (v as String).isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir tous les champs"), behavior: SnackBarBehavior.floating));
        return;
      }

      final success = await authService.registerDonor(userData);
      if (success) {
        context.go('/donor/feed');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authService.error ?? "Erreur lors de l'inscription"), backgroundColor: AppColors.destructive, behavior: SnackBarBehavior.floating));
      }
    }

    Future<void> _handleRegisterHospital() async {
      final hospitalData = {
        'nom': _hospNomController.text,
        'email': _hospEmailController.text,
        'motDePasse': _hospPasswordController.text,
        'numeroAgrement': _hospAgrementController.text,
        'contact': _hospContactController.text,
        'region': _hospRegionController.text,
        'localisation': _hospLocalisationController.text,
      };

      if (hospitalData.values.any((v) => (v as String).isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir tous les champs"), behavior: SnackBarBehavior.floating));
        return;
      }

      final success = await authService.registerHospital(hospitalData);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inscription réussie, attendez la validation de l'administrateur."), backgroundColor: AppColors.successGreen, behavior: SnackBarBehavior.floating));
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authService.error ?? "Erreur lors de l'inscription"), backgroundColor: AppColors.destructive, behavior: SnackBarBehavior.floating));
      }
    }

    return PublicLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                const SizedBox(height: AppSpacing.md),
                SangVieTypography.h1(t('auth.register.title')).animate().fadeIn().slideX(begin: -0.1, end: 0),
                const SizedBox(height: 8),
                Text(
                  t('auth.register.subtitle'), 
                  style: const TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2)
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Segmented Tab Control
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.secondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: -0.2),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: t('auth.register.donorTab')),
                      Tab(text: t('auth.register.hospitalTab')),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Form Content
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return IndexedStack(
                      index: _tabController.index,
                      children: [
                        _buildDonorForm(t, authService, _handleRegisterDonor),
                        _buildHospitalForm(t, authService, _handleRegisterHospital),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t('auth.register.already'), style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        child: Text(t('auth.register.login'), style: const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
    );
  }

  Widget _buildDonorForm(String Function(String) t, AuthService auth, VoidCallback onSubmit) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: SangVieInput(label: "Nom", hint: "Nom", controller: _donorNomController, prefixIcon: const Icon(LucideIcons.user, size: 18))),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: SangVieInput(label: "Prénom", hint: "Prénom", controller: _donorPrenomController)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SangVieInput(label: "Email", hint: "votre@email.com", controller: _donorEmailController, keyboardType: TextInputType.emailAddress, prefixIcon: const Icon(LucideIcons.mail, size: 18)),
        const SizedBox(height: AppSpacing.lg),
        SangVieInput(label: "Téléphone", hint: "+226 70 00 00 00", controller: _donorPhoneController, keyboardType: TextInputType.phone, prefixIcon: const Icon(LucideIcons.phone, size: 18)),
        const SizedBox(height: AppSpacing.lg),
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text("Groupe Sanguin", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: -0.2)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: Colors.transparent),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBloodGroup,
                  isExpanded: true,
                  icon: const Icon(LucideIcons.chevronDown, size: 18, color: AppColors.secondary),
                  onChanged: (String? newValue) => setState(() => _selectedBloodGroup = newValue!),
                  items: <String>['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.foreground)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SangVieInput(label: "Lieu de résidence", hint: "Ville / Quartier", controller: _donorLieuController, prefixIcon: const Icon(LucideIcons.mapPin, size: 18)),
        const SizedBox(height: AppSpacing.lg),
        SangVieInput(label: t('auth.register.password'), hint: "Min. 8 caractères", controller: _donorPasswordController, obscureText: true, prefixIcon: const Icon(LucideIcons.lock, size: 18)),
        const SizedBox(height: AppSpacing.xl + 8),
        SangVieButton(label: "Créer mon compte", onPressed: onSubmit, isLoading: auth.isLoading, icon: const Icon(LucideIcons.userPlus, size: 20, color: Colors.white)),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildHospitalForm(String Function(String) t, AuthService auth, VoidCallback onSubmit) {
    return Column(
      children: [
        SangVieInput(label: t('auth.register.hospitalName'), hint: "Nom de l'établissement", controller: _hospNomController, prefixIcon: const Icon(LucideIcons.building, size: 18)),
        const SizedBox(height: AppSpacing.lg),
        SangVieInput(label: "Email professionnel", hint: "contact@hopital.bf", controller: _hospEmailController, keyboardType: TextInputType.emailAddress, prefixIcon: const Icon(LucideIcons.mail, size: 18)),
        const SizedBox(height: AppSpacing.lg),
        SangVieInput(label: "Contact téléphonique", hint: "+226 25 30 00 00", controller: _hospContactController, keyboardType: TextInputType.phone, prefixIcon: const Icon(LucideIcons.phone, size: 18)),
        const SizedBox(height: AppSpacing.lg),
        SangVieInput(label: "Numéro d'agrément", hint: "Autorisation officielle", controller: _hospAgrementController, prefixIcon: const Icon(LucideIcons.fileCheck, size: 18)),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(child: SangVieInput(label: "Région", hint: "ex: Centre", controller: _hospRegionController)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: SangVieInput(label: "Ville", hint: "ex: Ouaga", controller: _hospLocalisationController)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SangVieInput(label: t('auth.register.password'), hint: "Min. 8 caractères", controller: _hospPasswordController, obscureText: true, prefixIcon: const Icon(LucideIcons.lock, size: 18)),
        const SizedBox(height: AppSpacing.xl + 8),
        SangVieButton(label: "S'inscrire comme établissement", onPressed: onSubmit, isLoading: auth.isLoading, icon: const Icon(LucideIcons.plusCircle, size: 20, color: Colors.white)),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}
