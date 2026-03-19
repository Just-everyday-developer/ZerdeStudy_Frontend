import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_app_state.dart';
import '../../../../app/state/demo_catalog.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/adaptive_panel.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../widgets/course_discovery_widgets.dart';

class LearnPage extends ConsumerStatefulWidget {
  const LearnPage({super.key});

  @override
  ConsumerState<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends ConsumerState<LearnPage> {
  late final TextEditingController _searchController;

  String _query = '';
  String? _selectedTopicKey;
  String _selectedLevel = 'All';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
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
    var draftTopicKey = _selectedTopicKey;
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
                        selected: draftTopicKey == null,
                        onSelected: (_) {
                          setModalState(() => draftTopicKey = null);
                        },
                      ),
                      ...catalog.courseTopicKeys().map(
                            (topicKey) => ChoiceChip(
                              label: Text(l10n.courseTopicLabel(topicKey)),
                              selected: draftTopicKey == topicKey,
                              onSelected: (_) {
                                setModalState(() => draftTopicKey = topicKey);
                              },
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
                    children: catalog.courseLevels().map((level) {
                      return ChoiceChip(
                        label: Text(l10n.courseLevelLabel(level)),
                        selected: draftLevel == level,
                        onSelected: (_) {
                          setModalState(() => draftLevel = level);
                        },
                      );
                    }).toList(growable: false),
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
                              _selectedTopicKey = draftTopicKey;
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
    final authors = _filterAuthors(catalog.popularAuthors());

    final sections = <_CourseRailSection>[
      _CourseRailSection(
        title: l10n.text('section_programming_languages'),
        topicKey: courseTopicProgrammingLanguages,
        courses: _filterCourses(
          catalog.coursesForTopic(courseTopicProgrammingLanguages),
        ),
      ),
      _CourseRailSection(
        title: l10n.text('section_data_analytics'),
        topicKey: courseTopicDataAnalytics,
        courses: _filterCourses(
          catalog.coursesForTopic(courseTopicDataAnalytics),
        ),
      ),
      _CourseRailSection(
        title: l10n.text('section_ai'),
        topicKey: courseTopicAi,
        courses: _filterCourses(
          catalog.coursesForTopic(courseTopicAi),
        ),
      ),
      _CourseRailSection(
        title: l10n.text('section_sql_databases'),
        topicKey: courseTopicSqlDatabases,
        courses: _filterCourses(
          catalog.coursesForTopic(courseTopicSqlDatabases),
        ),
      ),
      _CourseRailSection(
        title: l10n.text('section_soft_skills'),
        topicKey: courseTopicSoftSkills,
        courses: _filterCourses(
          catalog.coursesForTopic(courseTopicSoftSkills),
        ),
      ),
      _CourseRailSection(
        title: l10n.text('section_popular_courses'),
        courses: _filterCourses(catalog.popularCourses()),
      ),
      _CourseRailSection(
        title: l10n.text('section_recommended_courses'),
        courses: _filterCourses(catalog.recommendedCourses(state)),
      ),
    ].where((section) => section.courses.isNotEmpty).toList(growable: false);

    return AppPageScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          return ListView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, compact ? 120 : 48),
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
                child: compact
                    ? _DiscoveryHero(
                        query: _query,
                        selectedTopicKey: _selectedTopicKey,
                        selectedLevel: _selectedLevel,
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _DiscoveryHero(
                              query: _query,
                              selectedTopicKey: _selectedTopicKey,
                              selectedLevel: _selectedLevel,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 2,
                            child: _DiscoverySignalCard(
                              sectionCount: sections.length,
                              authorCount: authors.length,
                              recommendationCount:
                                  catalog.recommendedCourses(state).length,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              if (sections.isEmpty)
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
                ...sections.map((section) {
                  void viewAllTap() {
                    context.push(
                      AppRoutes.coursesCatalog(
                        topic: section.topicKey,
                        search: _query.isEmpty ? null : _query,
                        level:
                            _selectedLevel == 'All' ? null : _selectedLevel,
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: compact
                        ? _CompactCourseRail(
                            section: section,
                            state: state,
                            viewAllLabel: l10n.text('view_all_courses'),
                            levelLabelBuilder: l10n.courseLevelLabel,
                            savedLabel: l10n.text('saved'),
                            onViewAllTap: viewAllTap,
                          )
                        : _DesktopCourseRail(
                            section: section,
                            state: state,
                            viewAllLabel: l10n.text('view_all_courses'),
                            levelLabelBuilder: l10n.courseLevelLabel,
                            savedLabel: l10n.text('saved'),
                            onViewAllTap: viewAllTap,
                          ),
                  );
                }),
              CourseDiscoverySectionHeader(
                title: l10n.text('section_popular_authors'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: compact ? 264 : 288,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: authors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final author = authors[index];
                    return DiscoveryAuthorCard(
                      author: author,
                      followersLabel: l10n.text('followers'),
                      coursesLabel: l10n.text('courses_label'),
                      onTap: () => context.push(
                        AppRoutes.coursesCatalog(author: author.id),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              GlowCard(
                accent: colors.accent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.text('section_frequent_searches'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: catalog.frequentSearchTerms().map((termKey) {
                        return ActionChip(
                          label: Text(l10n.frequentSearchLabel(termKey)),
                          onPressed: () => context.push(
                            AppRoutes.coursesCatalog(
                              search: _searchQueryForFrequentTerm(termKey),
                            ),
                          ),
                        );
                      }).toList(growable: false),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<CommunityCourse> _filterCourses(List<CommunityCourse> courses) {
    return courses.where((course) {
      if (_selectedTopicKey != null &&
          !course.topicKeys.contains(_selectedTopicKey)) {
        return false;
      }
      if (_selectedLevel != 'All' && course.level != _selectedLevel) {
        return false;
      }
      if (_query.isEmpty) {
        return true;
      }

      final normalizedQuery = _query.trim().toLowerCase();
      return course.title.en.toLowerCase().contains(normalizedQuery) ||
          course.subtitle.en.toLowerCase().contains(normalizedQuery) ||
          course.description.en.toLowerCase().contains(normalizedQuery) ||
          course.heroBadge.toLowerCase().contains(normalizedQuery) ||
          course.heroHeadline.toLowerCase().contains(normalizedQuery) ||
          course.learningOutcomes.any(
            (item) => item.toLowerCase().contains(normalizedQuery),
          ) ||
          course.moduleSections.any(
            (section) =>
                section.title.toLowerCase().contains(normalizedQuery) ||
                section.items.any(
                  (item) => item.title.toLowerCase().contains(normalizedQuery),
                ),
          ) ||
          course.searchKeywords.any(
            (keyword) => keyword.toLowerCase().contains(normalizedQuery),
          ) ||
          course.tags.any(
            (tag) => tag.toLowerCase().contains(normalizedQuery),
          ) ||
          course.author.name.toLowerCase().contains(normalizedQuery);
    }).toList(growable: false);
  }

  List<CommunityCourseAuthor> _filterAuthors(List<CommunityCourseAuthor> authors) {
    return authors.where((author) {
      if (_selectedTopicKey != null &&
          !author.topicKeys.contains(_selectedTopicKey)) {
        return false;
      }
      if (_query.isEmpty) {
        return true;
      }
      final normalizedQuery = _query.trim().toLowerCase();
      return author.name.toLowerCase().contains(normalizedQuery) ||
          author.role.toLowerCase().contains(normalizedQuery) ||
          author.accentLabel.toLowerCase().contains(normalizedQuery) ||
          author.summary.toLowerCase().contains(normalizedQuery);
    }).toList(growable: false);
  }

  String _searchQueryForFrequentTerm(String key) {
    switch (key) {
      case 'qa_testing':
        return 'qa';
      default:
        return key;
    }
  }
}

class _DiscoveryHero extends ConsumerWidget {
  const _DiscoveryHero({
    required this.query,
    required this.selectedTopicKey,
    required this.selectedLevel,
  });

  final String query;
  final String? selectedTopicKey;
  final String selectedLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.appColors;

    return Column(
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
        if (query.isNotEmpty || selectedTopicKey != null || selectedLevel != 'All') ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (query.isNotEmpty)
                _FilterPill(
                  label: query,
                  icon: Icons.search_rounded,
                ),
              if (selectedTopicKey != null)
                _FilterPill(
                  label: l10n.courseTopicLabel(selectedTopicKey!),
                  icon: Icons.category_rounded,
                ),
              if (selectedLevel != 'All')
                _FilterPill(
                  label: l10n.courseLevelLabel(selectedLevel),
                  icon: Icons.signal_cellular_alt_rounded,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DiscoverySignalCard extends StatelessWidget {
  const _DiscoverySignalCard({
    required this.sectionCount,
    required this.authorCount,
    required this.recommendationCount,
  });

  final int sectionCount;
  final int authorCount;
  final int recommendationCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: colors.surfaceSoft,
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.text('section_recommended_courses'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          _SignalRow(label: l10n.text('learn_signal_sections'), value: '$sectionCount'),
          _SignalRow(label: l10n.text('learn_signal_authors'), value: '$authorCount'),
          _SignalRow(
            label: l10n.text('learn_signal_curated'),
            value: '$recommendationCount',
          ),
        ],
      ),
    );
  }
}

class _CompactCourseRail extends ConsumerWidget {
  const _CompactCourseRail({
    required this.section,
    required this.state,
    required this.viewAllLabel,
    required this.levelLabelBuilder,
    required this.savedLabel,
    required this.onViewAllTap,
  });

  final _CourseRailSection section;
  final DemoAppState state;
  final String viewAllLabel;
  final String Function(String level) levelLabelBuilder;
  final String savedLabel;
  final VoidCallback onViewAllTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CourseDiscoverySectionHeader(title: section.title),
        const SizedBox(height: 12),
        SizedBox(
          height: 352,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: section.visibleCourses.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              if (index == section.visibleCourses.length) {
                return DiscoveryViewAllCard(
                  label: viewAllLabel,
                  onTap: onViewAllTap,
                );
              }

              final course = section.visibleCourses[index];
              return DiscoveryCourseCard(
                course: course,
                saved: state.savedCommunityCourseIds.contains(course.id),
                levelLabel: levelLabelBuilder(course.level),
                savedLabel: savedLabel,
                onTap: () => context.push(AppRoutes.courseById(course.id)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DesktopCourseRail extends ConsumerWidget {
  const _DesktopCourseRail({
    required this.section,
    required this.state,
    required this.viewAllLabel,
    required this.levelLabelBuilder,
    required this.savedLabel,
    required this.onViewAllTap,
  });

  final _CourseRailSection section;
  final DemoAppState state;
  final String viewAllLabel;
  final String Function(String level) levelLabelBuilder;
  final String savedLabel;
  final VoidCallback onViewAllTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = context.isWideLayout ? 4 : 3;
    final courses = section.visibleCourses
        .take(context.isWideLayout ? 8 : 6)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CourseDiscoverySectionHeader(
          title: section.title,
          actionLabel: viewAllLabel,
          onActionTap: onViewAllTap,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final course = courses[index];
            return DiscoveryWideCourseCard(
              course: course,
              saved: state.savedCommunityCourseIds.contains(course.id),
              levelLabel: levelLabelBuilder(course.level),
              savedLabel: savedLabel,
              onTap: () => context.push(AppRoutes.courseById(course.id)),
            );
          },
        ),
      ],
    );
  }
}

class _CourseRailSection {
  const _CourseRailSection({
    required this.title,
    required this.courses,
    this.topicKey,
  });

  final String title;
  final List<CommunityCourse> courses;
  final String? topicKey;

  List<CommunityCourse> get visibleCourses =>
      courses.take(13).toList(growable: false);
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
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

class _SignalRow extends StatelessWidget {
  const _SignalRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
