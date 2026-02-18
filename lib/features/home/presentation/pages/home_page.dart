import 'package:flutter/material.dart';
import 'package:frontend_flutter/features/home/presentation/widgets/CourseCard.dart';
import '../../../../core/constants/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
            'Dashboard', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          IconButton(icon: const Icon(
              Icons.notifications_outlined, color: AppColors.primary),
              onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Recommended for you',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 12),
          CourseCard(title: 'Advanced Flutter', progress: 0.0),
          const SizedBox(height: 24),
          const Text('My Learning',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 12),
          CourseCard(title: 'Python for Data Science', progress: 0.65),
          const SizedBox(height: 12),
          CourseCard(title: 'Algorithms & Data Structures', progress: 0.30),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}