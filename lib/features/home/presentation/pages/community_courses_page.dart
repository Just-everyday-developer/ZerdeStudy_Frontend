import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_catalog.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../learning/presentation/widgets/course_discovery_widgets.dart';

class CommunityCoursesPage extends ConsumerStatefulWidget {
  const CommunityCoursesPage({
    super.key,
    this.initialTopicKey,
    this.initialSearchQuery,
    this.initialLevel,
    this.initialAuthorId,
  });

  final String? initialTopicKey;
  final String? initialSearchQuery;
  final String? initialLevel;
  final String? initialAuthorId;

  @override
  ConsumerState<CommunityCoursesPage> createState() =>
      _CommunityCoursesPageState();
}

class _CommunityCoursesPageState extends ConsumerState<CommunityCoursesPage> {
  late final TextEditingController _searchController;

  late String _query;
  String? _selectedTopicKey;
  late String _selectedLevel;
  String? _selectedAuthorId;

  @override
  void initState() {
    super.initState();
    _query = widget.initialSearchQuery ?? '';
    _selectedTopicKey = widget.initialTopicKey;
    _selectedLevel = widget.initialLevel ?? 'All';
    _selectedAuthorId = widget.initialAuthorId;
    _searchController = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilters(
    BuildContext context,
    DemoCatalog catalog,
    AppLocalizations l10n,
  ) async {
    var draftTopic = _selectedTopicKey;
    var draftLevel = _selectedLevel;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = context.appColors;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.divider,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l10n.text('filters'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l10n.text('filter_topic'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ChoiceChip(
                            label: Text(l10n.text('all_topics')),
                            selected: draftTopic == null,
                            onSelected: (_) =>
                                setModalState(() => draftTopic = null),
                          ),
                          ...catalog.courseTopicKeys().map(
                                (topicKey) => ChoiceChip(
                                  label: Text(l10n.courseTopicLabel(topicKey)),
                                  selected: draftTopic == topicKey,
                                  onSelected: (_) => setModalState(
                                    () => draftTopic = topicKey,
                                  ),
                                ),
                              ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.text('filter_level'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: catalog.courseLevels().map(
                          (level) => ChoiceChip(
                            label: Text(l10n.courseLevelLabel(level)),
                            selected: draftLevel == level,
                            onSelected: (_) =>
                                setModalState(() => draftLevel = level),
                          ),
                        ).toList(growable: false),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTopicKey = null;
                                  _selectedLevel = 'All';
                                  _selectedAuthorId = null;
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text(l10n.text('clear_filters')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTopicKey = draftTopic;
                                  _selectedLevel = draftLevel;
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text(l10n.text('show_all')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final l10n = context.l10n;
    final colors = context.appColors;
    final results = catalog.searchCourses(
      query: _query,
      topicKey: _selectedTopicKey,
      level: _selectedLevel,
      authorId: _selectedAuthorId,
    );

    return AppPageScaffold(
      title: l10n.text('catalog_title'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          CourseDiscoverySearchBar(
            controller: _searchController,
            hintText: l10n.text('search_courses'),
            onChanged: (value) => setState(() => _query = value),
            onFilterTap: () => _openFilters(context, catalog, l10n),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.text('catalog_subtitle'),
                  style: TextStyle(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (_query.isNotEmpty)
                      _CatalogPill(
                        label: _query,
                        icon: Icons.search_rounded,
                      ),
                    if (_selectedTopicKey != null)
                      _CatalogPill(
                        label: l10n.courseTopicLabel(_selectedTopicKey!),
                        icon: Icons.category_rounded,
                      ),
                    if (_selectedLevel != 'All')
                      _CatalogPill(
                        label: l10n.courseLevelLabel(_selectedLevel),
                        icon: Icons.signal_cellular_alt_rounded,
                      ),
                    if (_selectedAuthorId != null)
                      _CatalogPill(
                        label: catalog
                            .popularAuthors()
                            .firstWhere(
                              (author) => author.id == _selectedAuthorId,
                              orElse: () => catalog.popularAuthors().first,
                            )
                            .name,
                        icon: Icons.person_rounded,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.format(
                    'catalog_results',
                    <String, Object>{'count': results.length},
                  ),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (results.isEmpty)
            GlowCard(
              accent: colors.accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.text('catalog_empty_title'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.text('catalog_empty_subtitle'),
                    style: TextStyle(
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            )
          else
            ...results.map(
              (course) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlowCard(
                  accent: course.color,
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.courseById(course.id)),
                    borderRadius: BorderRadius.circular(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.title.en,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    course.subtitle.en,
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: course.color.withValues(alpha: 0.14),
                              ),
                              child: Text(
                                state.savedCommunityCourseIds.contains(course.id)
                                    ? l10n.text('saved')
                                    : l10n.courseLevelLabel(course.level),
                                style: TextStyle(
                                  color: course.color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          course.description.en,
                          style: TextStyle(
                            color: colors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _CatalogMeta(
                              label:
                                  '${course.rating.toStringAsFixed(1)} ${l10n.text('rating')}',
                            ),
                            _CatalogMeta(
                              label:
                                  '${course.enrollmentCount} ${l10n.text('enrolled')}',
                            ),
                            _CatalogMeta(label: '${course.estimatedHours}h'),
                            _CatalogMeta(label: course.author.name),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CatalogPill extends StatelessWidget {
  const _CatalogPill({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.surfaceSoft,
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogMeta extends StatelessWidget {
  const _CatalogMeta({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.surfaceSoft,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
