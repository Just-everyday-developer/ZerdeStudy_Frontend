import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/tree_painter.dart';
import '../widgets/skill_node.dart';

class KnowledgeTreePage extends StatelessWidget {
  const KnowledgeTreePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Skill Tree', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: CustomPaint(
          size: const Size(300, 400),
          painter: TreePainter(),
          child: const SizedBox(
            width: 300,
            height: 400,
            child: Stack(
              children: [
                SkillNode(x: 150, y: 50, icon: Icons.code, color: AppColors.accent),
                SkillNode(x: 80, y: 150, icon: Icons.storage, color: AppColors.primary),
                SkillNode(x: 220, y: 150, icon: Icons.api, color: AppColors.primary),
                SkillNode(x: 150, y: 250, icon: Icons.security, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}