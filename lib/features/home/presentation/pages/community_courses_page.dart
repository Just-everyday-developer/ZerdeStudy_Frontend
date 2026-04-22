import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_catalog.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/adaptive_panel.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/course_search_focus_provider.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../courses_backend/data/models/backend_course_query.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';
import '../../../learning/presentation/widgets/course_discovery_widgets.dart';

class CommunityCoursesPage extends ConsumerStatefulWidget {
  const CommunityCoursesPage({
    super.key,
    this.initialTopicKey,
    this.initialSearchQuery,
    this.initialLevel,
    this.initialMinRating,
    this.initialDurationCode,
    this.initialCertificateOnly = false,
  });

  final String? initialTopicKey;
  final String? initialSearchQuery;
  final String? initialLevel;
  final double? initialMinRating;
  final String? initialDurationCode;
  final bool initialCertificateOnly;

  @override
  ConsumerState<CommunityCoursesPage> createState() =>
      _CommunityCoursesPageState();
}

class _CommunityCoursesPageState extends ConsumerState<CommunityCoursesPage> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  late String _query;
  String? _selectedTopicKey;
  late String _selectedLevel;
  double? _selectedMinRating;
  CourseDurationBucket? _selectedDurationBucket;
  late bool _certificateOnly;

  @override
  void initState() {
    super.initState();
    _query = widget.initialSearchQuery ?? '';
    _selectedTopicKey = widget.initialTopicKey;
    _selectedLevel = widget.initialLevel ?? 'All';
    _selectedMinRating = widget.initialMinRating;
    _selectedDurationBucket = widget.initialDurationCode == null
        ? null
        : CourseDurationBucket.fromCode(widget.initialDurationCode);
    _certificateOnly = widget.initialCertificateOnly;
    _searchController = TextEditingController(text: _query);
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
      wideMaxWidth: 720,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  : _topicFilterLabel(
                                      l10n,
                                      dictionaries,
                                      value,
                                    ),
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
                                setModalState(() {
                                  draftCertificateOnly = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          TextButton(
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
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 14,
                              ),
                              foregroundColor: context.appColors.textSecondary,
                            ),
                            child: Text(_clearFiltersLabel(l10n)),
                          ),
                          FilledButton(
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
      limit: 48,
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
          _searchFocusNode.requestFocus();
        }
      });
    });

    final results = catalog.searchCourses(
      state: state,
      query: _query,
      topicKey: _resolvedMockTopicKey(),
      level: normalizeMockLevelLabel(_selectedLevel),
      minRating: _selectedMinRating,
      durationBucket: _selectedDurationBucket,
      certificateOnly: _certificateOnly ? true : null,
    );
    final comparisonCourse = catalog.courseById('course_sql_for_analysts');
    final remoteResults = backendCourses.maybeWhen(
      data: (courses) => courses,
      orElse: () => const <CommunityCourse>[],
    );
    final remoteSourceCourses = _shouldPinComparisonCourse()
        ? withComparisonCourse(
            backendCourses: remoteResults,
            comparisonCourse: comparisonCourse,
          )
        : remoteResults;
    final visibleRemoteResults = remoteResults.isEmpty
        ? const <CommunityCourse>[]
        : _filterRemoteCourses(remoteSourceCourses);
    final totalVisibleResults = results.length + visibleRemoteResults.length;
    final hasAnyResults = totalVisibleResults > 0;
    final authors = _filteredAuthors(catalog.courseAuthors());

    return AppPageScaffold(
      title: context.isCompactLayout ? l10n.text('catalog_title') : null,
      horizontalPadding: context.isCompactLayout ? 0 : 16,
      expandContent: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          final wide = constraints.maxWidth >= 1080;
          return ListView(
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 0,
              8,
              compact ? 16 : 0,
              compact ? 40 : 56,
            ),
            children: [
              CourseDiscoverySearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: l10n.text('search_courses'),
                onChanged: (value) => setState(() => _query = value),
                onSubmitted: (value) => setState(() => _query = value.trim()),
                onFilterTap: () =>
                    _openFilters(context, catalog, l10n, backendDictionaries),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ResultSignalChip(
                    label: l10n.format('catalog_results', <String, Object>{
                      'count': totalVisibleResults,
                    }),
                    color: colors.primary,
                  ),
                  if (_selectedTopicKey != null)
                    _ResultSignalChip(
                      label: _topicFilterLabel(
                        l10n,
                        backendDictionaries,
                        _selectedTopicKey!,
                      ),
                      color: colors.accent,
                    ),
                  if (_selectedLevel != 'All')
                    _ResultSignalChip(
                      label: _levelFilterLabel(
                        l10n,
                        backendDictionaries,
                        _selectedLevel,
                      ),
                      color: colors.primary,
                    ),
                  if (_selectedMinRating != null)
                    _ResultSignalChip(
                      label:
                          '${_selectedMinRating!.toStringAsFixed(_selectedMinRating! % 1 == 0 ? 0 : 1)}+',
                      color: colors.success,
                    ),
                  if (_selectedDurationBucket != null)
                    _ResultSignalChip(
                      label: _durationFilterLabel(
                        l10n,
                        backendDictionaries,
                        _selectedDurationBucket!.code,
                      ),
                      color: colors.textSecondary,
                    ),
                  if (_certificateOnly)
                    _ResultSignalChip(
                      label: l10n.text('filter_certificate'),
                      color: colors.success,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (visibleRemoteResults.isNotEmpty) ...[
                CourseDiscoverySectionHeader(
                  title: l10n.text('section_popular_courses'),
                ),
                const SizedBox(height: 14),
                if (compact)
                  ...visibleRemoteResults.map(
                    (course) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        height: 416,
                        child: DiscoveryWideCourseCard(
                          course: course,
                          saved: state.savedCommunityCourseIds.contains(
                            course.id,
                          ),
                          levelLabel: _levelFilterLabel(
                            l10n,
                            backendDictionaries,
                            course.level,
                          ),
                          savedLabel: l10n.text('saved'),
                          rating: catalog.displayCourseRatingForCourse(
                            state,
                            course,
                          ),
                          reviewCount: catalog
                              .displayCourseReviewCountForCourse(state, course),
                          onTap: () =>
                              context.push(AppRoutes.courseById(course.id)),
                        ),
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visibleRemoteResults.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: wide ? 3 : 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: wide ? 0.83 : 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final course = visibleRemoteResults[index];
                      return DiscoveryWideCourseCard(
                        course: course,
                        saved: state.savedCommunityCourseIds.contains(
                          course.id,
                        ),
                        levelLabel: _levelFilterLabel(
                          l10n,
                          backendDictionaries,
                          course.level,
                        ),
                        savedLabel: l10n.text('saved'),
                        rating: catalog.displayCourseRatingForCourse(
                          state,
                          course,
                        ),
                        reviewCount: catalog.displayCourseReviewCountForCourse(
                          state,
                          course,
                        ),
                        onTap: () =>
                            context.push(AppRoutes.courseById(course.id)),
                      );
                    },
                  ),
                const SizedBox(height: 24),
              ],
              if (!hasAnyResults)
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
              else if (results.isNotEmpty && compact)
                ...results.map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      height: 416,
                      child: DiscoveryWideCourseCard(
                        course: course,
                        saved: state.savedCommunityCourseIds.contains(
                          course.id,
                        ),
                        levelLabel: l10n.courseLevelLabel(course.level),
                        savedLabel: l10n.text('saved'),
                        rating: catalog.displayCourseRatingFor(
                          state,
                          course.id,
                        ),
                        reviewCount: catalog.displayCourseReviewCountFor(
                          state,
                          course.id,
                        ),
                        onTap: () =>
                            context.push(AppRoutes.courseById(course.id)),
                      ),
                    ),
                  ),
                )
              else if (results.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: results.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: wide ? 3 : 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: wide ? 0.83 : 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final course = results[index];
                    return DiscoveryWideCourseCard(
                      course: course,
                      saved: state.savedCommunityCourseIds.contains(course.id),
                      levelLabel: l10n.courseLevelLabel(course.level),
                      savedLabel: l10n.text('saved'),
                      rating: catalog.displayCourseRatingFor(state, course.id),
                      reviewCount: catalog.displayCourseReviewCountFor(
                        state,
                        course.id,
                      ),
                      onTap: () =>
                          context.push(AppRoutes.courseById(course.id)),
                    );
                  },
                ),
              const SizedBox(height: 26),
              if (authors.isNotEmpty) ...[
                CourseDiscoverySectionHeader(
                  title: l10n.text('section_popular_authors'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: compact ? 264 : 284,
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
                          AppRoutes.coursesCatalog(search: author.name),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<CommunityCourseAuthor> _filteredAuthors(
    List<CommunityCourseAuthor> authors,
  ) {
    final allowedTopicKeys = resolveMockTopicKeys(_selectedTopicKey);
    return authors
        .where((author) {
          if (_selectedTopicKey != null &&
              !allowedTopicKeys.any(author.topicKeys.contains)) {
            return false;
          }
          if (_query.trim().isEmpty) {
            return true;
          }
          final normalized = _query.trim().toLowerCase();
          return author.name.toLowerCase().contains(normalized) ||
              author.role.toLowerCase().contains(normalized) ||
              author.summary.toLowerCase().contains(normalized);
        })
        .toList(growable: false);
  }

  String? _resolvedMockTopicKey() {
    if (_selectedTopicKey == null) {
      return null;
    }

    final allowedTopicKeys = resolveMockTopicKeys(_selectedTopicKey);
    if (allowedTopicKeys.isNotEmpty) {
      return allowedTopicKeys.first;
    }

    return _selectedTopicKey;
  }

  List<CommunityCourse> _filterRemoteCourses(List<CommunityCourse> courses) {
    return courses
        .where((course) {
          if (_certificateOnly && !course.facts.hasCertificate) {
            return false;
          }
          if (_query.trim().isEmpty) {
            return true;
          }

          final normalized = _query.trim().toLowerCase();
          return course.title.en.toLowerCase().contains(normalized) ||
              course.subtitle.en.toLowerCase().contains(normalized) ||
              course.description.en.toLowerCase().contains(normalized) ||
              course.heroBadge.toLowerCase().contains(normalized) ||
              course.heroHeadline.toLowerCase().contains(normalized) ||
              course.learningOutcomes.any(
                (item) => item.toLowerCase().contains(normalized),
              ) ||
              course.searchKeywords.any(
                (keyword) => keyword.toLowerCase().contains(normalized),
              ) ||
              course.tags.any(
                (tag) => tag.toLowerCase().contains(normalized),
              ) ||
              course.author.name.toLowerCase().contains(normalized);
        })
        .toList(growable: false);
  }

  bool _shouldPinComparisonCourse() {
    return _query.trim().isEmpty &&
        _selectedTopicKey == null &&
        _selectedLevel == 'All' &&
        _selectedMinRating == null &&
        _selectedDurationBucket == null &&
        !_certificateOnly;
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

class _ResultSignalChip extends StatelessWidget {
  const _ResultSignalChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color == colors.textSecondary ? colors.textPrimary : color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
