import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/demo_models.dart';
import '../community_text.dart';

final communityGroupsProvider =
    NotifierProvider<CommunityGroupsController, List<CommunityGroup>>(
      CommunityGroupsController.new,
    );

class CommunityGroupsController extends Notifier<List<CommunityGroup>> {
  @override
  List<CommunityGroup> build() {
    return <CommunityGroup>[
      CommunityGroup(
        id: 'flutter_builders',
        title: communityText(
          ru: 'Flutter Builders Hub',
          en: 'Flutter Builders Hub',
          kk: 'Flutter Builders Hub',
        ),
        summary: communityText(
          ru: 'Группа для совместной сборки pet-проектов, ревью интерфейсов и обмена UI-референсами.',
          en: 'A group for pet projects, UI reviews, and sharing interface references.',
          kk: 'Pet-жобалар, UI ревью және интерфейс референстерімен алмасуға арналған топ.',
        ),
        topic: communityText(ru: 'Frontend', en: 'Frontend', kk: 'Frontend'),
        visibility: communityText(
          ru: 'Открытая группа',
          en: 'Open group',
          kk: 'Ашық топ',
        ),
        category: CommunityGroupCategory.project,
        isJoined: true,
        memberCount: 24,
        mediaCount: 18,
        linkCount: 6,
        members: const <CommunityMember>[
          CommunityMember(
            name: 'Aruzhan B.',
            role: 'UI Designer',
            accent: 'Figma systems',
          ),
          CommunityMember(
            name: 'Dias M.',
            role: 'Flutter Developer',
            accent: 'Animations',
          ),
          CommunityMember(
            name: 'Aigerim T.',
            role: 'Frontend Student',
            accent: 'Practice squad',
          ),
          CommunityMember(
            name: 'Ruslan K.',
            role: 'Mentor',
            accent: 'Code review',
          ),
        ],
        media: const <CommunityMediaItem>[
          CommunityMediaItem(
            title: 'Sprint board screenshot',
            kind: 'PNG',
            description: 'Current kanban flow for the mobile module.',
          ),
          CommunityMediaItem(
            title: 'Component map',
            kind: 'PDF',
            description: 'Latest component relationships for the dashboard.',
          ),
          CommunityMediaItem(
            title: 'Motion references',
            kind: 'Link pack',
            description: 'Shortlist of onboarding animation references.',
          ),
        ],
        links: const <CommunityLinkItem>[
          CommunityLinkItem(
            label: 'Figma workspace',
            url: 'https://figma.com/community/flutter-builders',
            kind: 'Design',
          ),
          CommunityLinkItem(
            label: 'Sprint notes',
            url: 'https://notion.so/flutter-builders-notes',
            kind: 'Notes',
          ),
          CommunityLinkItem(
            label: 'GitHub repository',
            url: 'https://github.com/example/flutter-builders',
            kind: 'Code',
          ),
        ],
        tags: const <String>['Flutter', 'UI', 'Collaboration'],
      ),
      CommunityGroup(
        id: 'sql_circle',
        title: communityText(
          ru: 'SQL Interview Circle',
          en: 'SQL Interview Circle',
          kk: 'SQL Interview Circle',
        ),
        summary: communityText(
          ru: 'Разбор SQL-задач, подготовка к интервью и обмен полезными схемами запросов.',
          en: 'A focused circle for SQL interview drills, query patterns, and mock sessions.',
          kk: 'SQL сұхбат жаттығулары, query pattern және mock-сессияларға арналған топ.',
        ),
        topic: communityText(ru: 'SQL', en: 'SQL', kk: 'SQL'),
        visibility: communityText(
          ru: 'Частная группа',
          en: 'Private group',
          kk: 'Жабық топ',
        ),
        category: CommunityGroupCategory.study,
        isJoined: true,
        memberCount: 16,
        mediaCount: 9,
        linkCount: 5,
        members: const <CommunityMember>[
          CommunityMember(
            name: 'Madina S.',
            role: 'Data Analyst',
            accent: 'Window functions',
          ),
          CommunityMember(
            name: 'Adil N.',
            role: 'Backend Student',
            accent: 'Join patterns',
          ),
          CommunityMember(
            name: 'Alina D.',
            role: 'Mentor',
            accent: 'Mock interviews',
          ),
        ],
        media: const <CommunityMediaItem>[
          CommunityMediaItem(
            title: 'Query cheat sheet',
            kind: 'PDF',
            description: 'Compact guide to joins, CTEs, and window functions.',
          ),
          CommunityMediaItem(
            title: 'ERD examples',
            kind: 'PNG',
            description: 'Diagrams used in the latest practice round.',
          ),
        ],
        links: const <CommunityLinkItem>[
          CommunityLinkItem(
            label: 'Practice sheet',
            url: 'https://docs.google.com/sql-circle-sheet',
            kind: 'Sheet',
          ),
          CommunityLinkItem(
            label: 'Interview queue',
            url: 'https://calendar.app/sql-circle',
            kind: 'Schedule',
          ),
        ],
        tags: const <String>['SQL', 'Interviews', 'Data'],
      ),
      CommunityGroup(
        id: 'career_lift',
        title: communityText(
          ru: 'Career Lift for Juniors',
          en: 'Career Lift for Juniors',
          kk: 'Career Lift for Juniors',
        ),
        summary: communityText(
          ru: 'Вакансии, совместная подготовка CV, peer-review сопроводительных писем и обмен полезными ссылками.',
          en: 'Jobs, CV feedback, cover letter reviews, and weekly career check-ins.',
          kk: 'Вакансиялар, CV фидбегі, cover letter review және апталық career check-in.',
        ),
        topic: communityText(ru: 'Career', en: 'Career', kk: 'Career'),
        visibility: communityText(
          ru: 'Открытая группа',
          en: 'Open group',
          kk: 'Ашық топ',
        ),
        category: CommunityGroupCategory.career,
        isJoined: false,
        memberCount: 31,
        mediaCount: 11,
        linkCount: 7,
        members: const <CommunityMember>[
          CommunityMember(
            name: 'Yernar A.',
            role: 'Recruiter',
            accent: 'CV feedback',
          ),
          CommunityMember(
            name: 'Dana P.',
            role: 'Frontend Junior',
            accent: 'Portfolio review',
          ),
          CommunityMember(
            name: 'Sanzhar R.',
            role: 'Career Mentor',
            accent: 'Interview prep',
          ),
        ],
        media: const <CommunityMediaItem>[
          CommunityMediaItem(
            title: 'CV examples',
            kind: 'DOCX',
            description:
                'Annotated CV examples for product and frontend tracks.',
          ),
          CommunityMediaItem(
            title: 'Interview notes',
            kind: 'PDF',
            description: 'Common screening questions with answer structure.',
          ),
        ],
        links: const <CommunityLinkItem>[
          CommunityLinkItem(
            label: 'Job tracker',
            url: 'https://airtable.com/career-lift-jobs',
            kind: 'Tracker',
          ),
          CommunityLinkItem(
            label: 'Portfolio references',
            url: 'https://behance.net/zerde-career-lift',
            kind: 'Reference',
          ),
        ],
        tags: const <String>['Career', 'CV', 'Interview'],
      ),
    ];
  }

  CommunityGroup? groupById(String groupId) {
    for (final group in state) {
      if (group.id == groupId) {
        return group;
      }
    }
    return null;
  }

  void createGroup({
    required String name,
    required String summary,
    required CommunityGroupCategory category,
    required String topic,
    required bool isPrivate,
  }) {
    final slug = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    state = <CommunityGroup>[
      CommunityGroup(
        id: slug.isEmpty ? 'group_$timestamp' : '${slug}_$timestamp',
        title: LocalizedText(ru: name, en: name, kk: name),
        summary: LocalizedText(ru: summary, en: summary, kk: summary),
        topic: LocalizedText(ru: topic, en: topic, kk: topic),
        visibility: isPrivate
            ? communityText(
                ru: 'Частная группа',
                en: 'Private group',
                kk: 'Жабық топ',
              )
            : communityText(
                ru: 'Открытая группа',
                en: 'Open group',
                kk: 'Ашық топ',
              ),
        category: category,
        isJoined: true,
        memberCount: 1,
        mediaCount: 0,
        linkCount: 0,
        members: const <CommunityMember>[
          CommunityMember(name: 'You', role: 'Owner', accent: 'Group creator'),
        ],
        media: const <CommunityMediaItem>[],
        links: const <CommunityLinkItem>[],
        tags: <String>[topic, _categoryCode(category)],
      ),
      ...state,
    ];
  }

  void leaveGroup(String groupId) {
    state = state
        .map(
          (group) => group.id == groupId
              ? group.copyWith(
                  isJoined: false,
                  memberCount: group.memberCount > 0
                      ? group.memberCount - 1
                      : 0,
                )
              : group,
        )
        .toList(growable: false);
  }

  void reportGroup(String groupId) {
    state = state
        .map(
          (group) => group.id == groupId
              ? group.copyWith(reportsCount: group.reportsCount + 1)
              : group,
        )
        .toList(growable: false);
  }
}

class CommunityGroup {
  const CommunityGroup({
    required this.id,
    required this.title,
    required this.summary,
    required this.topic,
    required this.visibility,
    required this.category,
    required this.isJoined,
    required this.memberCount,
    required this.mediaCount,
    required this.linkCount,
    required this.members,
    required this.media,
    required this.links,
    required this.tags,
    this.reportsCount = 0,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText summary;
  final LocalizedText topic;
  final LocalizedText visibility;
  final CommunityGroupCategory category;
  final bool isJoined;
  final int memberCount;
  final int mediaCount;
  final int linkCount;
  final List<CommunityMember> members;
  final List<CommunityMediaItem> media;
  final List<CommunityLinkItem> links;
  final List<String> tags;
  final int reportsCount;

  CommunityGroup copyWith({
    bool? isJoined,
    int? memberCount,
    int? reportsCount,
  }) {
    return CommunityGroup(
      id: id,
      title: title,
      summary: summary,
      topic: topic,
      visibility: visibility,
      category: category,
      isJoined: isJoined ?? this.isJoined,
      memberCount: memberCount ?? this.memberCount,
      mediaCount: mediaCount,
      linkCount: linkCount,
      members: members,
      media: media,
      links: links,
      tags: tags,
      reportsCount: reportsCount ?? this.reportsCount,
    );
  }
}

enum CommunityGroupCategory { study, project, mentorship, career }

class CommunityMember {
  const CommunityMember({
    required this.name,
    required this.role,
    required this.accent,
  });

  final String name;
  final String role;
  final String accent;
}

class CommunityMediaItem {
  const CommunityMediaItem({
    required this.title,
    required this.kind,
    required this.description,
  });

  final String title;
  final String kind;
  final String description;
}

class CommunityLinkItem {
  const CommunityLinkItem({
    required this.label,
    required this.url,
    required this.kind,
  });

  final String label;
  final String url;
  final String kind;
}

String _categoryCode(CommunityGroupCategory category) {
  return switch (category) {
    CommunityGroupCategory.study => 'study',
    CommunityGroupCategory.project => 'project',
    CommunityGroupCategory.mentorship => 'mentorship',
    CommunityGroupCategory.career => 'career',
  };
}
