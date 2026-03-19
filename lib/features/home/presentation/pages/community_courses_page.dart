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
import '../../../../core/providers/course_search_focus_provider.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../learning/presentation/widgets/course_discovery_widgets.dart';

class CommunityCoursesPage extends ConsumerStatefulWidget {
  const CommunityCoursesPage({
    super.key,
    this.initialTopicKey,
    this.initialSearchQuery,
    this.initialLevel,
    this.initialAuthorId,
    this.initialMinRating,
    this.initialDurationCode,
    this.initialCertificateOnly = false,
  });

  final String? initialTopicKey;
  final String? initialSearchQuery;
  final String? initialLevel;
  final String? initialAuthorId;
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
  String? _selectedAuthorId;
  double? _selectedMinRating;
  CourseDurationBucket? _selectedDurationBucket;
  late bool _certificateOnly;

  @override
  void initState() {
    super.initState();
    _query = widget.initialSearchQuery ?? '';
    _selectedTopicKey = widget.initialTopicKey;
    _selectedLevel = widget.initialLevel ?? 'All';
    _selectedAuthorId = widget.initialAuthorId;
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
  ) async {
    var draftTopic = _selectedTopicKey;
    var draftLevel = _selectedLevel;
    var draftAuthor = _selectedAuthorId;
    var draftMinRating = _selectedMinRating;
    var draftDuration = _selectedDurationBucket;
    var draftCertificateOnly = _certificateOnly;

    await showAdaptivePanel<void>(
      context: context,
      wideMaxWidth: 720,
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
                  DropdownButtonFormField<String>(
                    initialValue: draftTopic ?? '',
                    decoration: InputDecoration(
                      labelText: l10n.text('filter_topic'),
                    ),
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text(l10n.text('all_topics')),
                      ),
                      ...catalog.courseTopicKeys().map(
                            (topicKey) => DropdownMenuItem<String>(
                              value: topicKey,
                              child: Text(l10n.courseTopicLabel(topicKey)),
                            ),
                          ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        draftTopic = value == null || value.isEmpty ? null : value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: draftLevel,
                    decoration: InputDecoration(
                      labelText: l10n.text('filter_level'),
                    ),
                    items: catalog.courseLevels()
                        .map(
                          (level) => DropdownMenuItem<String>(
                            value: level,
                            child: Text(l10n.courseLevelLabel(level)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      setModalState(() => draftLevel = value ?? 'All');
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: draftAuthor ?? '',
                    decoration: InputDecoration(
                      labelText: l10n.text('filter_author'),
                    ),
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text(l10n.text('all_authors')),
                      ),
                      ...catalog.courseAuthors().map(
                            (author) => DropdownMenuItem<String>(
                              value: author.id,
                              child: Text(author.name),
                            ),
                          ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        draftAuthor = value == null || value.isEmpty ? null : value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<double>(
                    initialValue: draftMinRating ?? 0,
                    decoration: InputDecoration(
                      labelText: l10n.text('filter_min_rating'),
                    ),
                    items: <DropdownMenuItem<double>>[
                      DropdownMenuItem<double>(
                        value: 0,
                        child: Text(l10n.text('any_rating')),
                      ),
                      const DropdownMenuItem<double>(value: 3, child: Text('3.0+')),
                      const DropdownMenuItem<double>(value: 4, child: Text('4.0+')),
                      const DropdownMenuItem<double>(value: 4.5, child: Text('4.5+')),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        draftMinRating = value == null || value == 0 ? null : value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: draftDuration?.code ?? '',
                    decoration: InputDecoration(
                      labelText: l10n.text('filter_duration'),
                    ),
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text(l10n.text('any_duration')),
                      ),
                      ...catalog.courseDurationBuckets().map(
                            (bucket) => DropdownMenuItem<String>(
                              value: bucket.code,
                              child: Text(_durationLabel(l10n, bucket)),
                            ),
                          ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        draftDuration = value == null || value.isEmpty
                            ? null
                            : CourseDurationBucket.fromCode(value);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.text('filter_certificate')),
                    value: draftCertificateOnly,
                    onChanged: (value) {
                      setModalState(() => draftCertificateOnly = value);
                    },
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
                              _selectedTopicKey = draftTopic;
                              _selectedLevel = draftLevel;
                              _selectedAuthorId = draftAuthor;
                              _selectedMinRating = draftMinRating;
                              _selectedDurationBucket = draftDuration;
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

    final results = catalog.searchCourses(
      state: state,
      query: _query,
      topicKey: _selectedTopicKey,
      level: _selectedLevel,
      authorId: _selectedAuthorId,
      minRating: _selectedMinRating,
      durationBucket: _selectedDurationBucket,
      certificateOnly: _certificateOnly ? true : null,
    );
    final authors = catalog.courseAuthors();

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
                focusNode: _searchFocusNode,
                hintText: l10n.text('search_courses'),
                onChanged: (value) => setState(() => _query = value),
                onFilterTap: () => _openFilters(context, catalog, l10n),
              ),
              const SizedBox(height: 18),
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
                        if (_selectedMinRating != null)
                          _CatalogPill(
                            label:
                                '${_selectedMinRating!.toStringAsFixed(_selectedMinRating! % 1 == 0 ? 0 : 1)}+',
                            icon: Icons.star_rounded,
                          ),
                        if (_selectedDurationBucket != null)
                          _CatalogPill(
                            label: _durationLabel(l10n, _selectedDurationBucket!),
                            icon: Icons.schedule_rounded,
                          ),
                        if (_certificateOnly)
                          _CatalogPill(
                            label: l10n.text('filter_certificate'),
                            icon: Icons.workspace_premium_rounded,
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
              const SizedBox(height: 18),
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
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      height: 432,
                      child: DiscoveryWideCourseCard(
                        course: course,
                        saved: state.savedCommunityCourseIds.contains(course.id),
                        levelLabel: l10n.courseLevelLabel(course.level),
                        savedLabel: l10n.text('saved'),
                        rating: catalog.displayCourseRatingFor(state, course.id),
                        reviewCount:
                            catalog.displayCourseReviewCountFor(state, course.id),
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
                  selectedMinRating: _selectedMinRating,
                  selectedDurationBucket: _selectedDurationBucket,
                  certificateOnly: _certificateOnly,
                  isWide: wide,
                  catalog: catalog,
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

class _DesktopCatalogLayout extends ConsumerWidget {
  const _DesktopCatalogLayout({
    required this.results,
    required this.authors,
    required this.selectedAuthorId,
    required this.selectedLevel,
    required this.selectedTopicKey,
    required this.selectedMinRating,
    required this.selectedDurationBucket,
    required this.certificateOnly,
    required this.isWide,
    required this.catalog,
    required this.onAuthorTap,
    required this.onClearAuthor,
  });

  final List<CommunityCourse> results;
  final List<CommunityCourseAuthor> authors;
  final String? selectedAuthorId;
  final String selectedLevel;
  final String? selectedTopicKey;
  final double? selectedMinRating;
  final CourseDurationBucket? selectedDurationBucket;
  final bool certificateOnly;
  final bool isWide;
  final DemoCatalog catalog;
  final ValueChanged<String> onAuthorTap;
  final VoidCallback onClearAuthor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: isWide ? 220 : 200,
              child: CatalogFilterCard(
                title: l10n.text('filter_topic'),
                child: Text(
                  selectedTopicKey == null
                      ? l10n.text('all_topics')
                      : l10n.courseTopicLabel(selectedTopicKey!),
                ),
              ),
            ),
            SizedBox(
              width: isWide ? 220 : 200,
              child: CatalogFilterCard(
                title: l10n.text('filter_level'),
                child: Text(l10n.courseLevelLabel(selectedLevel)),
              ),
            ),
            SizedBox(
              width: isWide ? 220 : 200,
              child: CatalogFilterCard(
                title: l10n.text('filter_min_rating'),
                child: Text(
                  selectedMinRating == null
                      ? l10n.text('any_rating')
                      : '${selectedMinRating!.toStringAsFixed(selectedMinRating! % 1 == 0 ? 0 : 1)}+',
                ),
              ),
            ),
            SizedBox(
              width: isWide ? 220 : 200,
              child: CatalogFilterCard(
                title: l10n.text('filter_duration'),
                child: Text(
                  selectedDurationBucket == null
                      ? l10n.text('any_duration')
                      : switch (selectedDurationBucket!) {
                          CourseDurationBucket.quick => l10n.text('duration_quick'),
                          CourseDurationBucket.focused => l10n.text('duration_focused'),
                          CourseDurationBucket.deep => l10n.text('duration_deep'),
                        },
                ),
              ),
            ),
            SizedBox(
              width: isWide ? 220 : 200,
              child: CatalogFilterCard(
                title: l10n.text('filter_certificate'),
                child: Text(
                  certificateOnly
                      ? l10n.text('course_certificate')
                      : l10n.text('show_all'),
                ),
              ),
            ),
            SizedBox(
              width: isWide ? 320 : 300,
              child: CatalogFilterCard(
                title: l10n.text('section_popular_authors'),
                child: Column(
                  children: [
                    ...authors.take(isWide ? 4 : 3).map(
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            author.name,
                                            style: const TextStyle(fontWeight: FontWeight.w700),
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
                        child: TextButton.icon(
                          onPressed: onClearAuthor,
                          icon: const Icon(Icons.close_rounded),
                          label: Text(l10n.text('clear_filters')),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 3 : 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: isWide ? 0.9 : 0.82,
          ),
          itemBuilder: (context, index) {
            final course = results[index];
            return DiscoveryWideCourseCard(
              course: course,
              saved: state.savedCommunityCourseIds.contains(course.id),
              levelLabel: l10n.courseLevelLabel(course.level),
              savedLabel: l10n.text('saved'),
              rating: catalog.displayCourseRatingFor(state, course.id),
              reviewCount: catalog.displayCourseReviewCountFor(state, course.id),
              onTap: () => context.push(AppRoutes.courseById(course.id)),
            );
          },
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
