import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_catalog.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
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

  bool get _hasActiveFilters =>
      _selectedTopicKey != null || _selectedLevel != 'All';

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

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final colors = context.appColors;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
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
                        children: catalog.courseLevels().map(
                          (level) {
                            return ChoiceChip(
                              label: Text(l10n.courseLevelLabel(level)),
                              selected: draftLevel == level,
                              onSelected: (_) {
                                setModalState(() => draftLevel = level);
                              },
                            );
                          },
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
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
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
                if (_query.isNotEmpty || _hasActiveFilters) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (_query.isNotEmpty)
                        _FilterPill(
                          label: _query,
                          icon: Icons.search_rounded,
                        ),
                      if (_selectedTopicKey != null)
                        _FilterPill(
                          label: l10n.courseTopicLabel(_selectedTopicKey!),
                          icon: Icons.category_rounded,
                        ),
                      if (_selectedLevel != 'All')
                        _FilterPill(
                          label: l10n.courseLevelLabel(_selectedLevel),
                          icon: Icons.signal_cellular_alt_rounded,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
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
            ...sections.expand(
              (section) => <Widget>[
                CourseDiscoverySectionHeader(title: section.title),
                const SizedBox(height: 12),
                SizedBox(
                  height: 270,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: section.visibleCourses.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      if (index == section.visibleCourses.length) {
                        return DiscoveryViewAllCard(
                          label: l10n.text('view_all_courses'),
                          onTap: () => context.push(
                            AppRoutes.coursesCatalog(
                              topic: section.topicKey,
                              search: _query.isEmpty ? null : _query,
                              level: _selectedLevel == 'All'
                                  ? null
                                  : _selectedLevel,
                            ),
                          ),
                        );
                      }

                      final course = section.visibleCourses[index];
                      final saved =
                          state.savedCommunityCourseIds.contains(course.id);
                      return DiscoveryCourseCard(
                        course: course,
                        saved: saved,
                        levelLabel: l10n.courseLevelLabel(course.level),
                        savedLabel: l10n.text('saved'),
                        onTap: () => context.push(
                          AppRoutes.courseById(course.id),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          CourseDiscoverySectionHeader(
            title: l10n.text('section_popular_authors'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 246,
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
          author.accentLabel.toLowerCase().contains(normalizedQuery);
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

class _CourseRailSection {
  const _CourseRailSection({
    required this.title,
    required this.courses,
    this.topicKey,
  });

  final String title;
  final List<CommunityCourse> courses;
  final String? topicKey;

  List<CommunityCourse> get visibleCourses => courses.take(13).toList(growable: false);
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
