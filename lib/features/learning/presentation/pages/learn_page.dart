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
import '../../../../core/providers/course_search_focus_provider.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../widgets/course_discovery_widgets.dart';

class LearnPage extends ConsumerStatefulWidget {
  const LearnPage({super.key});

  @override
  ConsumerState<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends ConsumerState<LearnPage> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  String _query = '';
  String? _selectedTopicKey;
  String _selectedLevel = 'All';
  double? _selectedMinRating;
  CourseDurationBucket? _selectedDurationBucket;
  bool _certificateOnly = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openFilters(
    BuildContext context,
    DemoCatalog catalog,
    AppLocalizations l10n,
  ) async {
    var draftTopicKey = _selectedTopicKey;
    var draftLevel = _selectedLevel;
    var draftMinRating = _selectedMinRating;
    var draftDurationBucket = _selectedDurationBucket;
    var draftCertificateOnly = _certificateOnly;

    await showAdaptivePanel<void>(
      context: context,
      wideMaxWidth: 680,
      builder: (context) {
        final panelHeight = MediaQuery.of(context).size.height *
            (context.isCompactLayout ? 0.8 : 0.78);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: panelHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AdaptivePanelHandle(),
                    const SizedBox(height: 18),
                    Text(
                      l10n.text('filters'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DiscoveryFilterPanelCard(
                              icon: Icons.grid_view_rounded,
                              title: l10n.text('filter_topic'),
                              subtitle: l10n.text('filter_topic_hint'),
                              highlighted: draftTopicKey != null,
                              child: DiscoveryFilterChoiceWrap<String>(
                                options: <String>[
                                  '',
                                  ...catalog.courseTopicKeys(),
                                ],
                                selectedValue: draftTopicKey ?? '',
                                labelBuilder: (value) => value.isEmpty
                                    ? l10n.text('all_topics')
                                    : l10n.courseTopicLabel(value),
                                onSelected: (value) {
                                  setModalState(() {
                                    draftTopicKey = value.isEmpty ? null : value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            DiscoveryFilterPanelCard(
                              icon: Icons.signal_cellular_alt_rounded,
                              title: l10n.text('filter_level'),
                              subtitle: l10n.text('filter_level_hint'),
                              highlighted: draftLevel != 'All',
                              child: DiscoveryFilterChoiceWrap<String>(
                                options: catalog.courseLevels(),
                                selectedValue: draftLevel,
                                labelBuilder: l10n.courseLevelLabel,
                                onSelected: (value) {
                                  setModalState(() => draftLevel = value);
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            DiscoveryFilterPanelCard(
                              icon: Icons.star_outline_rounded,
                              title: l10n.text('filter_min_rating'),
                              subtitle: l10n.text('filter_rating_hint'),
                              highlighted: draftMinRating != null,
                              child: DiscoveryFilterChoiceWrap<double>(
                                options: const <double>[0, 3, 4, 4.5],
                                selectedValue: draftMinRating ?? 0,
                                labelBuilder: (value) {
                                  if (value == 0) {
                                    return l10n.text('any_rating');
                                  }
                                  return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}+';
                                },
                                onSelected: (value) {
                                  setModalState(() {
                                    draftMinRating = value == 0 ? null : value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            DiscoveryFilterPanelCard(
                              icon: Icons.schedule_rounded,
                              title: l10n.text('filter_duration'),
                              subtitle: l10n.text('filter_duration_hint'),
                              highlighted: draftDurationBucket != null,
                              child: DiscoveryFilterChoiceWrap<String>(
                                options: <String>[
                                  '',
                                  ...catalog
                                      .courseDurationBuckets()
                                      .map((bucket) => bucket.code),
                                ],
                                selectedValue: draftDurationBucket?.code ?? '',
                                labelBuilder: (value) {
                                  if (value.isEmpty) {
                                    return l10n.text('any_duration');
                                  }
                                  return _durationLabel(
                                    l10n,
                                    CourseDurationBucket.fromCode(value),
                                  );
                                },
                                onSelected: (value) {
                                  setModalState(() {
                                    draftDurationBucket = value.isEmpty
                                        ? null
                                        : CourseDurationBucket.fromCode(value);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            DiscoveryFilterPanelCard(
                              icon: Icons.workspace_premium_outlined,
                              title: l10n.text('filter_certificate'),
                              subtitle: l10n.text('filter_certificate_hint'),
                              highlighted: draftCertificateOnly,
                              child: DiscoveryFilterToggleTile(
                                label: l10n.text('filter_certificate'),
                                value: draftCertificateOnly,
                                onChanged: (value) {
                                  setModalState(
                                    () => draftCertificateOnly = value,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                _selectedMinRating = null;
                                _selectedDurationBucket = null;
                                _certificateOnly = false;
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
                                _selectedMinRating = draftMinRating;
                                _selectedDurationBucket = draftDurationBucket;
                                _certificateOnly = draftCertificateOnly;
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
    ref.listen<int>(courseSearchFocusRequestProvider, (previous, next) {
      if (previous == next) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    });
    final authors = _filterAuthors(catalog.courseAuthors());

    final sections = <_CourseRailSection>[
      _CourseRailSection(
        title: l10n.text('section_programming_languages'),
        topicKey: courseTopicProgrammingLanguages,
        courses: _filterCourses(
          state,
          catalog,
          catalog.coursesForTopic(courseTopicProgrammingLanguages),
        ),
      ),
      _CourseRailSection(
        title: l10n.text('section_data_analytics'),
        topicKey: courseTopicDataAnalytics,
        courses: _filterCourses(
          state,
          catalog,
          catalog.coursesForTopic(courseTopicDataAnalytics),
        ),
      ),
      _CourseRailSection(
        title: l10n.text('section_ai'),
        topicKey: courseTopicAi,
        courses: _filterCourses(
          state,
          catalog,
          catalog.coursesForTopic(courseTopicAi),
        ),
      ),
      _CourseRailSection(
        title: l10n.text('section_sql_databases'),
        topicKey: courseTopicSqlDatabases,
        courses: _filterCourses(
          state,
          catalog,
          catalog.coursesForTopic(courseTopicSqlDatabases),
        ),
      ),
      _CourseRailSection(
        title: l10n.text('section_soft_skills'),
        topicKey: courseTopicSoftSkills,
        courses: _filterCourses(
          state,
          catalog,
          catalog.coursesForTopic(courseTopicSoftSkills),
        ),
      ),
      _CourseRailSection(
        title: l10n.text('section_popular_courses'),
        courses: _filterCourses(state, catalog, catalog.popularCourses()),
      ),
      _CourseRailSection(
        title: l10n.text('section_recommended_courses'),
        courses: _filterCourses(state, catalog, catalog.recommendedCourses(state)),
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
                focusNode: _searchFocusNode,
                hintText: l10n.text('search_courses'),
                onChanged: (value) => setState(() => _query = value),
                onFilterTap: () => _openFilters(context, catalog, l10n),
              ),
              const SizedBox(height: 28),
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
                        minRating: _selectedMinRating,
                        duration: _selectedDurationBucket?.code,
                        certificate: _certificateOnly ? true : null,
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 64),
                    child: _CompactCourseRail(
                      section: section,
                      state: state,
                      catalog: catalog,
                      viewAllLabel: l10n.text('view_all_courses'),
                      levelLabelBuilder: l10n.courseLevelLabel,
                      savedLabel: l10n.text('saved'),
                      onViewAllTap: viewAllTap,
                    ),
                  );
                }),
              const SizedBox(height: 6),
              CourseDiscoverySectionHeader(
                title: l10n.text('section_popular_authors'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: compact ? 264 : 288,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: authors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 18),
                  itemBuilder: (context, index) {
                    final author = authors[index];
                    return DiscoveryAuthorCard(
                      author: author,
                      followersLabel: l10n.text('followers'),
                      coursesLabel: l10n.text('courses_label'),
                      onTap: () => context.push(
                        AppRoutes.coursesCatalog(search: author.name),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 48),
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

  List<CommunityCourse> _filterCourses(
    DemoAppState state,
    DemoCatalog catalog,
    List<CommunityCourse> courses,
  ) {
    return courses.where((course) {
      if (_selectedTopicKey != null && !course.topicKeys.contains(_selectedTopicKey)) {
        return false;
      }
      if (_selectedLevel != 'All' && course.level != _selectedLevel) {
        return false;
      }
      if (_selectedMinRating != null &&
          catalog.displayCourseRatingFor(state, course.id) < _selectedMinRating!) {
        return false;
      }
      if (_selectedDurationBucket != null &&
          catalog.courseDurationBucketFor(course) != _selectedDurationBucket) {
        return false;
      }
      if (_certificateOnly && !course.facts.hasCertificate) {
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
          course.learningOutcomes.any((item) => item.toLowerCase().contains(normalizedQuery)) ||
          course.moduleSections.any(
            (section) =>
                section.title.toLowerCase().contains(normalizedQuery) ||
                section.items.any((item) => item.title.toLowerCase().contains(normalizedQuery)),
          ) ||
          course.searchKeywords.any((keyword) => keyword.toLowerCase().contains(normalizedQuery)) ||
          course.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery)) ||
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

  String _durationLabel(AppLocalizations l10n, CourseDurationBucket bucket) {
    switch (bucket) {
      case CourseDurationBucket.quick:
        return l10n.text('duration_quick');
      case CourseDurationBucket.focused:
        return l10n.text('duration_focused');
      case CourseDurationBucket.deep:
        return l10n.text('duration_deep');
    }
  }
}

class _CompactCourseRail extends ConsumerWidget {
  const _CompactCourseRail({
    required this.section,
    required this.state,
    required this.catalog,
    required this.viewAllLabel,
    required this.levelLabelBuilder,
    required this.savedLabel,
    required this.onViewAllTap,
  });

  final _CourseRailSection section;
  final DemoAppState state;
  final DemoCatalog catalog;
  final String viewAllLabel;
  final String Function(String level) levelLabelBuilder;
  final String savedLabel;
  final VoidCallback onViewAllTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CourseDiscoverySectionHeader(
          title: section.title,
          actionLabel: viewAllLabel,
          onActionTap: onViewAllTap,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: context.isWideLayout ? 364 : 352,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: section.visibleCourses.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 22),
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
                rating: catalog.displayCourseRatingFor(state, course.id),
                reviewCount: catalog.displayCourseReviewCountFor(state, course.id),
                onTap: () => context.push(AppRoutes.courseById(course.id)),
              );
            },
          ),
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
      courses.take(10).toList(growable: false);
}
