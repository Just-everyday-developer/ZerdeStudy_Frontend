import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Аватар с неоновой рамкой
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15)],
              ),
              child: const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.surface,
                child: Icon(Icons.person, size: 40, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Julia M.', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: const Text('450 XP', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                child: ListView(
                  children: [
                    _buildSettingsTile(Icons.book_outlined, 'Manage Courses'),
                    _buildSettingsTile(Icons.assignment_turned_in_outlined, 'Student Submissions'),
                    _buildSettingsTile(Icons.question_answer_outlined, 'Q&A'),
                    const Divider(color: AppColors.background, height: 32),
                    _buildSettingsTile(Icons.add_circle_outline, 'Create New Course', color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {Color color = AppColors.textPrimary}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
      onTap: () {},
    );
  }
}