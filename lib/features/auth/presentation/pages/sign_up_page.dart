import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'init User();',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your profile to start learning.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),
            _buildTechTextField(hint: 'Name', icon: Icons.person_outline),
            const SizedBox(height: 16),
            _buildTechTextField(hint: 'Email', icon: Icons.email_outlined),
            const SizedBox(height: 16),
            _buildTechTextField(hint: 'Password', icon: Icons.lock_outline, isObscure: true),
            const SizedBox(height: 32),
            _buildRoleSelector(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  context.go("/welcome");
                },
                child: const Text('Compile & Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechTextField({required String hint, required IconData icon, bool isObscure = false}) {
    return TextField(
      obscureText: isObscure,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildRoleButton(title: 'Student', isActive: true, icon: Icons.school_outlined),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRoleButton(title: 'Instructor', isActive: false, icon: Icons.computer),
        ),
      ],
    );
  }

  Widget _buildRoleButton({required String title, required bool isActive, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
        border: Border.all(color: isActive ? AppColors.primary : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? AppColors.primary : AppColors.textSecondary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}