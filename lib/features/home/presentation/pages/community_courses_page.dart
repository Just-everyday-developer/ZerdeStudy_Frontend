import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_catalog.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/adaptive_panel.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/layout/app_breakpoints.dart';
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

    await showAdaptivePanel<void>(
      context: context,
      wideMaxWidth: 680,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdaptivePanelHandle(),
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
    final authors = catalog.popularAuthors();

    return AppPageScaffold(
      title: context.isCompactLayout ? l10n.text('catalog_title') : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          final wide = constraints.maxWidth >= 1024;

          return ListView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, compact ? 40 : 48),
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
                      l10n.text('catalog_title'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
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
                            label: authors
                                .firstWhere(
                                  (author) => author.id == _selectedAuthorId,
                                  orElse: () => authors.first,
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
              else if (compact)
                ...results.map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      height: 432,
                      child: DiscoveryWideCourseCard(
                        course: course,
                        saved: state.savedCommunityCourseIds.contains(course.id),
                        levelLabel: l10n.courseLevelLabel(course.level),
                        savedLabel: l10n.text('saved'),
                        onTap: () => context.push(AppRoutes.courseById(course.id)),
                      ),
                    ),
                  ),
                )
              else
                _DesktopCatalogLayout(
                  results: results,
                  authors: authors,
                  selectedAuthorId: _selectedAuthorId,
                  selectedLevel: _selectedLevel,
                  selectedTopicKey: _selectedTopicKey,
                  isWide: wide,
                  onAuthorTap: (authorId) {
                    setState(() => _selectedAuthorId = authorId);
                  },
                  onClearAuthor: () {
                    setState(() => _selectedAuthorId = null);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DesktopCatalogLayout extends ConsumerWidget {
  const _DesktopCatalogLayout({
    required this.results,
    required this.authors,
    required this.selectedAuthorId,
    required this.selectedLevel,
    required this.selectedTopicKey,
    required this.isWide,
    required this.onAuthorTap,
    required this.onClearAuthor,
  });

  final List<CommunityCourse> results;
  final List<CommunityCourseAuthor> authors;
  final String? selectedAuthorId;
  final String selectedLevel;
  final String? selectedTopicKey;
  final bool isWide;
  final ValueChanged<String> onAuthorTap;
  final VoidCallback onClearAuthor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isWide ? 280 : 240,
          child: Column(
            children: [
              CatalogFilterCard(
                title: l10n.text('filter_topic'),
                child: Text(
                  selectedTopicKey == null
                      ? l10n.text('all_topics')
                      : l10n.courseTopicLabel(selectedTopicKey!),
                ),
              ),
              const SizedBox(height: 14),
              CatalogFilterCard(
                title: l10n.text('filter_level'),
                child: Text(l10n.courseLevelLabel(selectedLevel)),
              ),
              const SizedBox(height: 14),
              CatalogFilterCard(
                title: l10n.text('section_popular_authors'),
                child: Column(
                  children: [
                    ...authors.take(5).map(
                          (author) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              onTap: () => onAuthorTap(author.id),
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: selectedAuthorId == author.id
                                        ? context.appColors.primary
                                        : context.appColors.divider,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      child: Text(author.name.substring(0, 1)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            author.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            author.role,
                                            style: TextStyle(
                                              color: context.appColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    if (selectedAuthorId != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: onClearAuthor,
                          child: Text(l10n.text('clear_filters')),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isWide ? 0.88 : 0.82,
            ),
            itemBuilder: (context, index) {
              final course = results[index];
              return DiscoveryWideCourseCard(
                course: course,
                saved: state.savedCommunityCourseIds.contains(course.id),
                levelLabel: l10n.courseLevelLabel(course.level),
                savedLabel: l10n.text('saved'),
                onTap: () => context.push(AppRoutes.courseById(course.id)),
              );
            },
          ),
        ),
      ],
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
