import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/services/auth_service.dart';
import 'package:sangvie/presentation/widgets/donor_layout.dart';
import 'package:sangvie/presentation/widgets/hospital_layout.dart';
import 'package:sangvie/presentation/widgets/admin_layout.dart';

class DynamicInfoLayout extends StatelessWidget {
  final Widget child;

  const DynamicInfoLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        body: child,
      );
    }

    // Wrap the screen content in the appropriate layout based on user type
    switch (user.userType) {
      case UserType.donor:
        return DonorLayout(child: child);
      case UserType.hospital:
        return HospitalLayout(child: child);
      case UserType.admin:
        return AdminLayout(child: child);
    }
  }
}
