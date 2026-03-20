import 'package:flutter/material.dart';

import '../../../../app/state/demo_models.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';

class CourseDiscoverySearchBar extends StatelessWidget {
  const CourseDiscoverySearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onFilterTap,
    this.focusNode,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tall = !context.isCompactLayout;

    return Container(
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: tall ? 12 : 10,
      ),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, color: colors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: tall ? 26 : 24,
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  scrollPadding: EdgeInsets.zero,
                  textAlignVertical: TextAlignVertical.center,
                  maxLines: 1,
                  minLines: 1,
                  style: TextStyle(
                    color: colors.textPrimary,
                    height: 1,
                    fontSize: tall ? 17 : 16,
                  ),
                  cursorHeight: tall ? 19 : 18,
                  cursorWidth: 1.6,
                  cursorRadius: const Radius.circular(1.2),
                  strutStyle: const StrutStyle(
                    height: 1,
                    forceStrutHeight: true,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: colors.textSecondary,
                      fontSize: tall ? 17 : 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: colors.primary.withValues(alpha: 0.12),
                border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, color: colors.primary, size: 18),
                  if (!context.isCompactLayout) ...[
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.text('filters'),
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiscoveryFilterPanelCard extends StatelessWidget {
  const DiscoveryFilterPanelCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: colors.surface,
        border: Border.all(
          color: highlighted ? colors.primary : colors.divider,
        ),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: colors.surfaceSoft,
            ),
            child: Icon(icon, color: highlighted ? colors.primary : colors.textSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DiscoveryFilterChoiceWrap<T> extends StatelessWidget {
  const DiscoveryFilterChoiceWrap({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.labelBuilder,
    required this.onSelected,
  });

  final List<T> options;
  final T selectedValue;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final selected = option == selectedValue;
        return InkWell(
          onTap: () => onSelected(option),
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: selected
                  ? colors.primary.withValues(alpha: 0.16)
                  : colors.surfaceSoft,
              border: Border.all(
                color: selected ? colors.primary : colors.divider,
              ),
            ),
            child: Text(
              labelBuilder(option),
              style: TextStyle(
                color: selected ? colors.primary : colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class DiscoveryFilterToggleTile extends StatelessWidget {
  const DiscoveryFilterToggleTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colors.surfaceSoft,
          border: Border.all(color: value ? colors.primary : colors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 54,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: value
                    ? colors.primary.withValues(alpha: 0.18)
                    : colors.backgroundElevated,
              ),
              child: Align(
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value ? colors.primary : colors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseDiscoverySectionHeader extends StatelessWidget {
  const CourseDiscoverySectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        if (actionLabel != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionLabel!,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
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
    required this.rating,
    required this.reviewCount,
    required this.onTap,
  });

  final CommunityCourse course;
  final bool saved;
  final String levelLabel;
  final String savedLabel;
  final double rating;
  final int reviewCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _BaseDiscoveryCourseCard(
      course: course,
      saved: saved,
      levelLabel: levelLabel,
      savedLabel: savedLabel,
      rating: rating,
      reviewCount: reviewCount,
      onTap: onTap,
      width: 244,
      showExtendedMeta: false,
    );
  }
}

class DiscoveryWideCourseCard extends StatelessWidget {
  const DiscoveryWideCourseCard({
    super.key,
    required this.course,
    required this.saved,
    required this.levelLabel,
    required this.savedLabel,
    required this.rating,
    required this.reviewCount,
    required this.onTap,
  });

  final CommunityCourse course;
  final bool saved;
  final String levelLabel;
  final String savedLabel;
  final double rating;
  final int reviewCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _BaseDiscoveryCourseCard(
      course: course,
      saved: saved,
      levelLabel: levelLabel,
      savedLabel: savedLabel,
      rating: rating,
      reviewCount: reviewCount,
      onTap: onTap,
      width: double.infinity,
      showExtendedMeta: true,
    );
  }
}

class _BaseDiscoveryCourseCard extends StatelessWidget {
  const _BaseDiscoveryCourseCard({
    required this.course,
    required this.saved,
    required this.levelLabel,
    required this.savedLabel,
    required this.rating,
    required this.reviewCount,
    required this.onTap,
    required this.width,
    required this.showExtendedMeta,
  });

  final CommunityCourse course;
  final bool saved;
  final String levelLabel;
  final String savedLabel;
  final double rating;
  final int reviewCount;
  final VoidCallback onTap;
  final double width;
  final bool showExtendedMeta;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final compactCard = !showExtendedMeta;
    final heroHeight = showExtendedMeta ? 132.0 : 108.0;
    final heroPadding = showExtendedMeta ? 14.0 : 12.0;
    final bodyPadding = showExtendedMeta ? 18.0 : 14.0;
    final titleMaxLines = showExtendedMeta ? 2 : 2;
    final subtitleMaxLines = showExtendedMeta ? 2 : 1;
    final heroHeadlineMaxLines = showExtendedMeta ? 2 : 1;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
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
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: heroHeight,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    course.color.withValues(alpha: 0.28),
                    colors.backgroundElevated,
                    colors.surface,
                  ],
                ),
              ),
              padding: EdgeInsets.all(heroPadding),
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
                            color: colors.surface.withValues(alpha: 0.92),
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
                        Icons.arrow_outward_rounded,
                        color: colors.textPrimary,
                        size: 18,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    course.heroHeadline,
                    maxLines: heroHeadlineMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.16,
                          fontSize: showExtendedMeta ? null : 16,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    course.heroBadge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(bodyPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title.en,
                      maxLines: titleMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.18,
                            fontSize: showExtendedMeta ? null : 17,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.subtitle.en,
                      maxLines: subtitleMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        height: 1.3,
                        fontSize: 13,
                      ),
                    ),
                    if (showExtendedMeta) ...[
                      const SizedBox(height: 8),
                      Text(
                        course.description.en,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MetaChip(
                          icon: Icons.star_rounded,
                          label: rating.toStringAsFixed(1),
                          color: course.color,
                        ),
                        _MetaChip(
                          icon: Icons.rate_review_rounded,
                          label: '$reviewCount',
                          color: colors.textSecondary,
                        ),
                        _MetaChip(
                          icon: Icons.schedule_rounded,
                          label: '${course.estimatedHours}h',
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!compactCard) ...[
                      const SizedBox(height: 2),
                      Text(
                        course.author.role,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
    this.width = 252,
  });

  final String label;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: colors.surface,
          border: Border.all(color: colors.divider),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
        width: context.isCompactLayout ? 188 : 224,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: colors.surface,
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: accent.withValues(alpha: 0.16),
              child: Text(
                author.name.isEmpty ? '?' : author.name.substring(0, 1),
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 12),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textSecondary,
                height: 1.3,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              author.summary.isEmpty ? author.accentLabel : author.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textSecondary,
                height: 1.35,
                fontSize: 13,
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

class CatalogFilterCard extends StatelessWidget {
  const CatalogFilterCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colors.surface,
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.surfaceSoft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
