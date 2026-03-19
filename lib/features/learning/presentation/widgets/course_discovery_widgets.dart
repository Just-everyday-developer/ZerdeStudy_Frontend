import 'package:flutter/material.dart';

import '../../../../app/state/demo_models.dart';
import '../../../../core/theme/app_theme_colors.dart';

class CourseDiscoverySearchBar extends StatelessWidget {
  const CourseDiscoverySearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colors.surface,
        border: Border.all(color: colors.divider),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, color: colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: onFilterTap,
            icon: Icon(Icons.tune_rounded, color: colors.primary),
          ),
        ],
      ),
    );
  }
}

class CourseDiscoverySectionHeader extends StatelessWidget {
  const CourseDiscoverySectionHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class DiscoveryCourseCard extends StatelessWidget {
  const DiscoveryCourseCard({
    super.key,
    required this.course,
    required this.saved,
    required this.levelLabel,
    required this.savedLabel,
    required this.onTap,
  });

  final CommunityCourse course;
  final bool saved;
  final String levelLabel;
  final String savedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 232,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surface,
              colors.surfaceSoft,
            ],
          ),
          border: Border.all(color: course.color.withValues(alpha: 0.24)),
          boxShadow: [
            BoxShadow(
              color: course.color.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: course.color.withValues(alpha: 0.14),
                    ),
                    child: Text(
                      saved ? savedLabel : levelLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: course.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              course.title.en,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              course.subtitle.en,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textSecondary,
                height: 1.35,
              ),
            ),
            const Spacer(),
            Text(
              course.author.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.star_rounded, size: 16, color: course.color),
                const SizedBox(width: 6),
                Text(
                  course.rating.toStringAsFixed(1),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.schedule_rounded, size: 16, color: colors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${course.estimatedHours}h',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DiscoveryViewAllCard extends StatelessWidget {
  const DiscoveryViewAllCard({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 232,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: colors.surface,
          border: Border.all(color: colors.divider),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ),
    );
  }
}

class DiscoveryAuthorCard extends StatelessWidget {
  const DiscoveryAuthorCard({
    super.key,
    required this.author,
    required this.followersLabel,
    required this.coursesLabel,
    required this.onTap,
  });

  final CommunityCourseAuthor author;
  final String followersLabel;
  final String coursesLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = _authorAccent(author.id);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 188,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: colors.surface,
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: accent.withValues(alpha: 0.16),
              child: Text(
                author.name.isEmpty ? '?' : author.name.substring(0, 1),
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              author.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              author.role,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textSecondary,
                height: 1.3,
              ),
            ),
            const Spacer(),
            Text(
              '$followersLabel ${author.followersCount}',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$coursesLabel ${author.courseCount}',
              style: TextStyle(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  static Color _authorAccent(String id) {
    final accents = <Color>[
      const Color(0xFF00B4D8),
      const Color(0xFFFF8A65),
      const Color(0xFFA78BFA),
      const Color(0xFF4DB6AC),
      const Color(0xFFE66BA1),
    ];
    var hash = 0;
    for (final codeUnit in id.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return accents[hash % accents.length];
  }
}
