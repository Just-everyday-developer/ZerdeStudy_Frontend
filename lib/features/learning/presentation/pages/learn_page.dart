import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
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
import '../../../app_guide/presentation/app_guide_controller.dart';
import '../../../app_guide/presentation/app_guide_target.dart';
import '../../../courses_backend/data/models/backend_course_query.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';
import '../widgets/course_discovery_widgets.dart';

class LearnPage extends ConsumerStatefulWidget {
  const LearnPage({super.key});

  @override
  ConsumerState<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends ConsumerState<LearnPage> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final ScrollController _scrollController;

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
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _focusSearchAndReveal() async {
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
    if (mounted) {
      _searchFocusNode.requestFocus();
    }
  }

  Future<void> _openFilters(
    BuildContext context,
    DemoCatalog catalog,
    AppLocalizations l10n,
    BackendCourseDictionaries dictionaries,
  ) async {
    var draftTopicKey = _selectedTopicKey;
    var draftLevel = _selectedLevel;
    var draftMinRating = _selectedMinRating;
    var draftDurationBucket = _selectedDurationBucket;
    var draftCertificateOnly = _certificateOnly;
    final topicOptions = dictionaries.topics.isEmpty
        ? <String>['', ...catalog.courseTopicKeys()]
        : <String>['', ...dictionaries.topics.map((topic) => topic.code)];
    final levelOptions = dictionaries.levels.isEmpty
        ? catalog.courseLevels()
        : <String>['All', ...dictionaries.levels.map((level) => level.code)];
    final durationOptions = dictionaries.durationCategories.isEmpty
        ? <String>[
            '',
            ...catalog.courseDurationBuckets().map((bucket) => bucket.code),
          ]
        : <String>[
            '',
            ...dictionaries.durationCategories.map((item) => item.code),
          ];

    await showAdaptivePanel<void>(
      context: context,
      wideMaxWidth: 680,
      builder: (context) {
        final panelHeight =
            MediaQuery.of(context).size.height *
            (context.isCompactLayout ? 0.9 : 0.78);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: panelHeight,
                child: SingleChildScrollView(
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
                      DiscoveryFilterPanelCard(
                        icon: Icons.grid_view_rounded,
                        title: l10n.text('filter_topic'),
                        subtitle: l10n.text('filter_topic_hint'),
                        highlighted: draftTopicKey != null,
                        child: DiscoveryFilterChoiceWrap<String>(
                          options: topicOptions,
                          selectedValue: draftTopicKey ?? '',
                          labelBuilder: (value) => value.isEmpty
                              ? l10n.text('all_topics')
                              : _topicFilterLabel(l10n, dictionaries, value),
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
                          options: levelOptions,
                          selectedValue: draftLevel,
                          labelBuilder: (value) =>
                              _levelFilterLabel(l10n, dictionaries, value),
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
                          options: durationOptions,
                          selectedValue: draftDurationBucket?.code ?? '',
                          labelBuilder: (value) {
                            if (value.isEmpty) {
                              return l10n.text('any_duration');
                            }
                            return _durationFilterLabel(
                              l10n,
                              dictionaries,
                              value,
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
                            setModalState(() => draftCertificateOnly = value);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedTopicKey = null;
                                _selectedLevel = 'All';
                                _selectedMinRating = null;
                                _selectedDurationBucket = null;
                                _certificateOnly = false;
                                _query = _searchController.text.trim();
                              });
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              foregroundColor: context.appColors.textSecondary,
                            ),
                            child: Text(_clearFiltersLabel(l10n)),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                _selectedTopicKey = draftTopicKey;
                                _selectedLevel = draftLevel;
                                _selectedMinRating = draftMinRating;
                                _selectedDurationBucket = draftDurationBucket;
                                _certificateOnly = draftCertificateOnly;
                                _query = _searchController.text.trim();
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text(_applyFiltersLabel(l10n)),
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
    final backendDictionaries = ref.watch(
      backendCourseDictionariesProvider.select(
        (value) => value.maybeWhen(
          data: (dictionaries) => dictionaries,
          orElse: () => const BackendCourseDictionaries.empty(),
        ),
      ),
    );
    final backendQuery = BackendCourseQuery(
      search: _query.isEmpty ? null : _query,
      minRating: _selectedMinRating,
      levelCode: normalizeBackendLevelCode(_selectedLevel),
      durationCode: _selectedDurationBucket?.code,
      topicCode: resolveBackendTopicCode(
        _selectedTopicKey,
        backendDictionaries.topics,
      ),
      hasCertificate: _certificateOnly ? true : null,
      limit: 24,
    );
    final backendCourses = ref.watch(
      backendCourseCatalogProvider(backendQuery),
    );
    final l10n = context.l10n;
    final colors = context.appColors;
    ref.listen<int>(courseSearchFocusRequestProvider, (previous, next) {
      if (previous == next) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusSearchAndReveal();
        }
      });
    });
    final compact = context.isCompactLayout;
    final remoteCourses = backendCourses.maybeWhen(
      data: (courses) => courses,
      orElse: () => const <CommunityCourse>[],
    );
    final remoteRailCourses = _filterRemoteCourses(remoteCourses);

    // Level-split sections: separate rails for beginner / intermediate / advanced.
    List<CommunityCourse> byLevel(String levelCode) => remoteCourses
        .where((c) => c.level.toLowerCase().startsWith(levelCode))
        .toList(growable: false);

    final beginnerCourses = byLevel('beginner');
    final intermediateCourses = byLevel('intermediate');
    final advancedCourses = byLevel('advanced');

    final sections = <_CourseRailSection>[
      if (remoteRailCourses.isNotEmpty)
        _CourseRailSection(
          title: l10n.text('section_popular_courses'),
          courses: remoteRailCourses,
        ),
      if (beginnerCourses.isNotEmpty)
        _CourseRailSection(
          title: _levelSectionLabel(l10n, 'beginner'),
          courses: beginnerCourses,
        ),
      if (intermediateCourses.isNotEmpty)
        _CourseRailSection(
          title: _levelSectionLabel(l10n, 'intermediate'),
          courses: intermediateCourses,
        ),
      if (advancedCourses.isNotEmpty)
        _CourseRailSection(
          title: _levelSectionLabel(l10n, 'advanced'),
          courses: advancedCourses,
        ),
    ];

    return AppPageScaffold(
      horizontalPadding: compact ? 0 : (context.isNativeWindowsApp ? 12 : 16),
      expandContent: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 0,
              8,
              compact ? 16 : 0,
              compact ? 120 : 48,
            ),
            children: [
              AppGuideTarget(
                id: AppGuideTargetIds.learnSearch,
                child: CourseDiscoverySearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: l10n.text('search_courses'),
                  onChanged: (_) {},
                  onSubmitted: (value) {
                    setState(() => _query = value.trim());
                  },
                  onFilterTap: () =>
                      _openFilters(context, catalog, l10n, backendDictionaries),
                ),
              ),
              const SizedBox(height: 36),
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
                        search: _query.isEmpty ? null : _query,
                        level: _selectedLevel == 'All' ? null : _selectedLevel,
                        minRating: _selectedMinRating,
                        duration: _selectedDurationBucket?.code,
                        certificate: _certificateOnly ? true : null,
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 88),
                    child: _CompactCourseRail(
                      section: section,
                      state: state,
                      catalog: catalog,
                      viewAllLabel: l10n.text('view_all_courses'),
                      levelLabelBuilder: (level) =>
                          _levelFilterLabel(l10n, backendDictionaries, level),
                      savedLabel: l10n.text('saved'),
                      onViewAllTap: viewAllTap,
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  List<CommunityCourse> _filterRemoteCourses(List<CommunityCourse> courses) {
    return courses
        .where((course) {
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
              course.learningOutcomes.any(
                (item) => item.toLowerCase().contains(normalizedQuery),
              ) ||
              course.searchKeywords.any(
                (keyword) => keyword.toLowerCase().contains(normalizedQuery),
              ) ||
              course.tags.any(
                (tag) => tag.toLowerCase().contains(normalizedQuery),
              ) ||
              course.author.name.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
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

  String _topicFilterLabel(
    AppLocalizations l10n,
    BackendCourseDictionaries dictionaries,
    String value,
  ) {
    return dictionaries.topicLabel(value) ?? l10n.courseTopicLabel(value);
  }

  String _levelSectionLabel(AppLocalizations l10n, String levelCode) {
    switch (levelCode) {
      case 'beginner':
        return switch (l10n.locale) {
          AppLocale.ru => 'Для начинающих',
          AppLocale.kk => 'Бастаушыларға',
          _ => 'Beginner Courses',
        };
      case 'intermediate':
        return switch (l10n.locale) {
          AppLocale.ru => 'Средний уровень',
          AppLocale.kk => 'Орта деңгей',
          _ => 'Intermediate Courses',
        };
      case 'advanced':
        return switch (l10n.locale) {
          AppLocale.ru => 'Продвинутый уровень',
          AppLocale.kk => 'Жоғары деңгей',
          _ => 'Advanced Courses',
        };
      default:
        return l10n.courseLevelLabel(levelCode);
    }
  }

  String _levelFilterLabel(
    AppLocalizations l10n,
    BackendCourseDictionaries dictionaries,
    String value,
  ) {
    if (value == 'All') {
      return l10n.text('all_levels');
    }

    return dictionaries.levelLabel(value) ??
        dictionaries.levelLabel(normalizeBackendLevelCode(value)) ??
        l10n.courseLevelLabel(value);
  }

  String _durationFilterLabel(
    AppLocalizations l10n,
    BackendCourseDictionaries dictionaries,
    String value,
  ) {
    return dictionaries.durationLabel(value) ??
        _durationLabel(l10n, CourseDurationBucket.fromCode(value));
  }
}

String _applyFiltersLabel(AppLocalizations l10n) {
  return switch (l10n.locale) {
    AppLocale.ru => 'Установить',
    AppLocale.en => 'Set',
    AppLocale.kk => 'Қолдану',
  };
}

String _clearFiltersLabel(AppLocalizations l10n) {
  return switch (l10n.locale) {
    AppLocale.ru => 'Очистить',
    AppLocale.en => 'Clear',
    AppLocale.kk => 'Тазалау',
  };
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
        const SizedBox(height: 18),
        SizedBox(
          height: context.isWideLayout ? 364 : 352,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: section.visibleCourses.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 34),
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
                rating: catalog.displayCourseRatingForCourse(state, course),
                reviewCount: catalog.displayCourseReviewCountForCourse(
                  state,
                  course,
                ),
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
  });

  final String title;
  final List<CommunityCourse> courses;

  List<CommunityCourse> get visibleCourses =>
      courses.take(10).toList(growable: false);
}
