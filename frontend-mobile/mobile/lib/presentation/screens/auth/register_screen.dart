import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/services/language_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/public_layout.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sangvie/core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Donor Controllers ---
  final _donorNomController = TextEditingController();
  final _donorPrenomController = TextEditingController();
  final _donorEmailController = TextEditingController();
  final _donorPhoneController = TextEditingController();
  final _donorPasswordController = TextEditingController();
  final _donorLieuController = TextEditingController();
  String _selectedBloodGroup = 'A+';
  bool _obscureDonorPassword = true;

  // --- Hospital Controllers ---
  final _hospNomController = TextEditingController();
  final _hospEmailController = TextEditingController();
  final _hospPasswordController = TextEditingController();
  final _hospAgrementController = TextEditingController();
  final _hospContactController = TextEditingController();
  final _hospRegionController = TextEditingController();
  final _hospLocalisationController = TextEditingController();
  bool _obscureHospPassword = true;

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

    return PublicLayout(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFF0F2F5),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 40,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.droplets,
                        size: 40,
                        color: Color(0xFFE53E3E),
                      ),
                    ).animate().fadeIn().scale(delay: 100.ms),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "S'inscrire",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A5568),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  Text(
                    t('auth.register.subtitle'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 32),

                  _buildTabSelector().animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 32),

                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      return IndexedStack(
                        index: _tabController.index,
                        children: [
                          _buildDonorForm(authService, t),
                          _buildHospitalForm(authService, t),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Already have account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t('auth.register.already'),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFE53E3E),
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          t('auth.register.login'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    final languageService = Provider.of<LanguageService>(context);
    final t = languageService.t;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFFE53E3E),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF718096),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: t('auth.register.donorTab')),
          Tab(text: t('auth.register.hospitalTab')),
        ],
      ),
    );
  }

  Widget _buildAuthInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
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
            borderSide: const BorderSide(
              color: Color(0xFFE53E3E),
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildDonorForm(AuthService authService, String Function(String) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAuthInput(
                label: "Nom",
                hint: "Nom",
                controller: _donorNomController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAuthInput(
                label: "Prénom",
                hint: "Prénom",
                controller: _donorPrenomController,
              ),
            ),
          ],
        ),
        _buildAuthInput(
          label: "Email",
          hint: "votre@email.com",
          controller: _donorEmailController,
          keyboardType: TextInputType.emailAddress,
        ),
        _buildAuthInput(
          label: "Téléphone",
          hint: "+226 70 00 00 00",
          controller: _donorPhoneController,
          keyboardType: TextInputType.phone,
        ),
        _buildBloodGroupSelector(),
        const SizedBox(height: 16),
        _buildAuthInput(
          label: "Lieu de résidence",
          hint: "Ville / Quartier",
          controller: _donorLieuController,
        ),
        _buildAuthInput(
          label: t('auth.register.password'),
          hint: "Min. 8 caractères",
          controller: _donorPasswordController,
          obscureText: _obscureDonorPassword,
          isPassword: true,
          onToggleVisibility: () {
            setState(() => _obscureDonorPassword = !_obscureDonorPassword);
          },
        ),
        const SizedBox(height: 24),
        _buildSubmitButton(
          label: "S'INSCRIRE",
          onPressed: () => _handleRegisterDonor(authService, t),
          isLoading: authService.isLoading,
        ),
      ],
    );
  }

  Widget _buildHospitalForm(AuthService authService, String Function(String) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAuthInput(
          label: t('auth.register.hospitalName'),
          hint: "Nom de l'établissement",
          controller: _hospNomController,
        ),
        _buildAuthInput(
          label: "Email professionnel",
          hint: "contact@hopital.bf",
          controller: _hospEmailController,
          keyboardType: TextInputType.emailAddress,
        ),
        _buildAuthInput(
          label: "Contact téléphonique",
          hint: "+226 25 30 00 00",
          controller: _hospContactController,
          keyboardType: TextInputType.phone,
        ),
        _buildAuthInput(
          label: "Numéro d'agrément",
          hint: "Autorisation officielle",
          controller: _hospAgrementController,
        ),
        Row(
          children: [
            Expanded(
              child: _buildAuthInput(
                label: "Région",
                hint: "ex: Centre",
                controller: _hospRegionController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAuthInput(
                label: "Ville",
                hint: "ex: Ouaga",
                controller: _hospLocalisationController,
              ),
            ),
          ],
        ),
        _buildAuthInput(
          label: t('auth.register.password'),
          hint: "Min. 8 caractères",
          controller: _hospPasswordController,
          obscureText: _obscureHospPassword,
          isPassword: true,
          onToggleVisibility: () {
            setState(() => _obscureHospPassword = !_obscureHospPassword);
          },
        ),
        const SizedBox(height: 24),
        _buildSubmitButton(
          label: "S'INSCRIRE",
          onPressed: () => _handleRegisterHospital(authService, t),
          isLoading: authService.isLoading,
        ),
      ],
    );
  }

  Widget _buildBloodGroupSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: _selectedBloodGroup,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: "Groupe Sanguin",
            labelStyle: TextStyle(
              color: Color(0xFF718096),
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() => _selectedBloodGroup = value!);
          },
          items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53E3E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: const Color(0xFFE53E3E).withOpacity(0.6),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Future<void> _handleRegisterDonor(
    AuthService authService,
    String Function(String) t,
  ) async {
    final userData = {
      'nom': _donorNomController.text.trim(),
      'prenom': _donorPrenomController.text.trim(),
      'email': _donorEmailController.text.trim(),
      'motDePasse': _donorPasswordController.text,
      'telephone': _donorPhoneController.text.trim(),
      'lieuResidence': _donorLieuController.text.trim(),
      'groupeSanguin': _selectedBloodGroup,
    };

    if (userData.values.any((v) => (v as String).isEmpty)) {
      _showSnackBar("Veuillez remplir tous les champs");
      return;
    }

    final success = await authService.registerDonor(userData);
    if (success) {
      context.go('/donor/feed');
    } else {
      _showSnackBar(authService.error ?? "Erreur lors de l'inscription",
          isError: true);
    }
  }

  Future<void> _handleRegisterHospital(
    AuthService authService,
    String Function(String) t,
  ) async {
    final hospitalData = {
      'nom': _hospNomController.text.trim(),
      'email': _hospEmailController.text.trim(),
      'motDePasse': _hospPasswordController.text,
      'numeroAgrement': _hospAgrementController.text.trim(),
      'contact': _hospContactController.text.trim(),
      'region': _hospRegionController.text.trim(),
      'localisation': _hospLocalisationController.text.trim(),
    };

    if (hospitalData.values.any((v) => (v as String).isEmpty)) {
      _showSnackBar("Veuillez remplir tous les champs");
      return;
    }

    final success = await authService.registerHospital(hospitalData);
    if (success) {
      _showSnackBar(
        "Inscription réussie, attendez la validation de l'administrateur.",
        isError: false,
        isSuccess: true,
      );
      context.go('/login');
    } else {
      _showSnackBar(authService.error ?? "Erreur lors de l'inscription",
          isError: true);
    }
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppColors.destructive : AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}