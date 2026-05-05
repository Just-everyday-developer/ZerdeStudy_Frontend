import 'package:flutter/material.dart';

import '../../../app/state/demo_models.dart';

const Size knowledgeTreeCanvasSize = Size(1600, 2520);

const List<KnowledgeTreeNodeSpec> knowledgeTreeNodes = <KnowledgeTreeNodeSpec>[
  // Root
  KnowledgeTreeNodeSpec(
    id: 'root',
    title: LocalizedText(
      ru: 'Computer Science',
      en: 'Computer Science',
      kk: 'Computer Science',
    ),
    subtitle: LocalizedText(
      ru: 'Foundations',
      en: 'Foundations',
      kk: 'Foundations',
    ),
    position: Offset(800, 180),
    radius: 120,
    isHub: true,
  ),

  // Primary foundation branches
  KnowledgeTreeNodeSpec(
    id: 'mathematics',
    trackId: 'mathematics',
    title: LocalizedText(
      ru: 'Mathematics',
      en: 'Mathematics',
      kk: 'Mathematics',
    ),
    position: Offset(220, 520),
    radius: 92,
  ),
  KnowledgeTreeNodeSpec(
    id: 'oop',
    trackId: 'oop',
    title: LocalizedText(ru: 'OOP', en: 'OOP', kk: 'OOP'),
    position: Offset(500, 500),
    radius: 80,
  ),
  KnowledgeTreeNodeSpec(
    id: 'algorithms_data_structures',
    trackId: 'algorithms_data_structures',
    title: LocalizedText(
      ru: 'Algorithms & Data Structures',
      en: 'Algorithms & Data Structures',
      kk: 'Algorithms & Data Structures',
    ),
    position: Offset(800, 540),
    radius: 102,
  ),
  KnowledgeTreeNodeSpec(
    id: 'databases',
    trackId: 'databases',
    title: LocalizedText(ru: 'Databases', en: 'Databases', kk: 'Databases'),
    position: Offset(1100, 500),
    radius: 82,
  ),
  KnowledgeTreeNodeSpec(
    id: 'operating_systems',
    trackId: 'operating_systems',
    title: LocalizedText(
      ru: 'Operating Systems',
      en: 'Operating Systems',
      kk: 'Operating Systems',
    ),
    position: Offset(1380, 520),
    radius: 94,
  ),

  // Mathematics branches
  KnowledgeTreeNodeSpec(
    id: 'mathematical_analysis',
    trackId: 'mathematical_analysis',
    title: LocalizedText(
      ru: 'Math Analysis',
      en: 'Math Analysis',
      kk: 'Math Analysis',
    ),
    position: Offset(110, 840),
    radius: 68,
  ),
  KnowledgeTreeNodeSpec(
    id: 'linear_algebra_calculus',
    trackId: 'linear_algebra_calculus',
    title: LocalizedText(
      ru: 'Linear Algebra',
      en: 'Linear Algebra',
      kk: 'Linear Algebra',
    ),
    position: Offset(330, 840),
    radius: 68,
  ),
  KnowledgeTreeNodeSpec(
    id: 'discrete_math',
    trackId: 'discrete_math',
    title: LocalizedText(
      ru: 'Discrete Math',
      en: 'Discrete Math',
      kk: 'Discrete Math',
    ),
    position: Offset(110, 1100),
    radius: 72,
  ),
  KnowledgeTreeNodeSpec(
    id: 'probability_statistics_analytics',
    trackId: 'probability_statistics_analytics',
    title: LocalizedText(
      ru: 'Probability & Statistics',
      en: 'Probability & Statistics',
      kk: 'Probability & Statistics',
    ),
    position: Offset(330, 1100),
    radius: 74,
  ),

  // Supporting foundation branches
  KnowledgeTreeNodeSpec(
    id: 'ai_theory',
    trackId: 'ai_theory',
    title: LocalizedText(ru: 'AI Theory', en: 'AI Theory', kk: 'AI Theory'),
    position: Offset(700, 900),
    radius: 74,
  ),
  KnowledgeTreeNodeSpec(
    id: 'networking_protocols',
    trackId: 'networking_protocols',
    title: LocalizedText(ru: 'Networks', en: 'Networks', kk: 'Networks'),
    position: Offset(980, 860),
    radius: 76,
  ),
  KnowledgeTreeNodeSpec(
    id: 'computer_architecture',
    trackId: 'computer_architecture',
    title: LocalizedText(
      ru: 'Computer Architecture',
      en: 'Computer Architecture',
      kk: 'Computer Architecture',
    ),
    position: Offset(1280, 860),
    radius: 76,
  ),
  KnowledgeTreeNodeSpec(
    id: 'information_security_foundations',
    trackId: 'information_security_foundations',
    title: LocalizedText(
      ru: 'Info Security',
      en: 'Info Security',
      kk: 'Info Security',
    ),
    position: Offset(1120, 1120),
    radius: 72,
  ),

  // Applied bridge
  KnowledgeTreeNodeSpec(
    id: 'applied_hub',
    title: LocalizedText(
      ru: 'Applied Paths',
      en: 'Applied Paths',
      kk: 'Applied Paths',
    ),
    subtitle: LocalizedText(
      ru: 'Product + Systems',
      en: 'Product + Systems',
      kk: 'Product + Systems',
    ),
    position: Offset(800, 1500),
    radius: 110,
    isHub: true,
  ),

  // Applied branches
  KnowledgeTreeNodeSpec(
    id: 'frontend',
    trackId: 'frontend',
    title: LocalizedText(ru: 'Frontend', en: 'Frontend', kk: 'Frontend'),
    position: Offset(180, 1840),
    radius: 80,
  ),
  KnowledgeTreeNodeSpec(
    id: 'backend',
    trackId: 'backend',
    title: LocalizedText(ru: 'Backend', en: 'Backend', kk: 'Backend'),
    position: Offset(430, 1840),
    radius: 80,
  ),
  KnowledgeTreeNodeSpec(
    id: 'machine_learning',
    trackId: 'machine_learning',
    title: LocalizedText(
      ru: 'ML Engineer',
      en: 'ML Engineer',
      kk: 'ML Engineer',
    ),
    position: Offset(640, 1840),
    radius: 76,
  ),
  KnowledgeTreeNodeSpec(
    id: 'mobile',
    trackId: 'mobile',
    title: LocalizedText(ru: 'Mobile', en: 'Mobile', kk: 'Mobile'),
    position: Offset(840, 1840),
    radius: 90,
  ),
  KnowledgeTreeNodeSpec(
    id: 'sre_devops',
    trackId: 'sre_devops',
    title: LocalizedText(
      ru: 'DevOps / SRE',
      en: 'DevOps / SRE',
      kk: 'DevOps / SRE',
    ),
    position: Offset(1090, 1840),
    radius: 80,
  ),
  KnowledgeTreeNodeSpec(
    id: 'cybersecurity',
    trackId: 'cybersecurity',
    title: LocalizedText(
      ru: 'Cybersecurity',
      en: 'Cybersecurity',
      kk: 'Cybersecurity',
    ),
    position: Offset(1330, 1840),
    radius: 80,
  ),

  // Applied depth
  KnowledgeTreeNodeSpec(
    id: 'qa_engineering',
    trackId: 'qa_engineering',
    title: LocalizedText(
      ru: 'QA Engineer',
      en: 'QA Engineer',
      kk: 'QA Engineer',
    ),
    position: Offset(300, 2140),
    radius: 72,
  ),
  KnowledgeTreeNodeSpec(
    id: 'android_development',
    trackId: 'android_development',
    title: LocalizedText(ru: 'Android', en: 'Android', kk: 'Android'),
    position: Offset(740, 2140),
    radius: 64,
  ),
  KnowledgeTreeNodeSpec(
    id: 'ios_development',
    trackId: 'ios_development',
    title: LocalizedText(ru: 'iOS', en: 'iOS', kk: 'iOS'),
    position: Offset(930, 2140),
    radius: 64,
  ),
  KnowledgeTreeNodeSpec(
    id: 'system_administration',
    trackId: 'system_administration',
    title: LocalizedText(
      ru: 'System Admin',
      en: 'System Admin',
      kk: 'System Admin',
    ),
    position: Offset(1170, 2140),
    radius: 74,
  ),
  KnowledgeTreeNodeSpec(
    id: 'crossplatform_development',
    trackId: 'crossplatform_development',
    title: LocalizedText(
      ru: 'Crossplatform',
      en: 'Crossplatform',
      kk: 'Crossplatform',
    ),
    position: Offset(835, 2360),
    radius: 66,
  ),
];

const List<KnowledgeTreeEdgeSpec> knowledgeTreeEdges = <KnowledgeTreeEdgeSpec>[
  // Root to primary foundations
  KnowledgeTreeEdgeSpec(fromNodeId: 'root', toNodeId: 'mathematics'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'root', toNodeId: 'oop'),
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'root',
    toNodeId: 'algorithms_data_structures',
  ),
  KnowledgeTreeEdgeSpec(fromNodeId: 'root', toNodeId: 'databases'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'root', toNodeId: 'operating_systems'),

  // Mathematics cluster
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'mathematics',
    toNodeId: 'mathematical_analysis',
  ),
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'mathematics',
    toNodeId: 'linear_algebra_calculus',
  ),
  KnowledgeTreeEdgeSpec(fromNodeId: 'mathematics', toNodeId: 'discrete_math'),
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'mathematics',
    toNodeId: 'probability_statistics_analytics',
  ),

  // Supporting foundations
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'algorithms_data_structures',
    toNodeId: 'ai_theory',
  ),
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'databases',
    toNodeId: 'networking_protocols',
  ),
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'operating_systems',
    toNodeId: 'computer_architecture',
  ),
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'networking_protocols',
    toNodeId: 'information_security_foundations',
  ),
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'operating_systems',
    toNodeId: 'information_security_foundations',
  ),

  // Foundation convergence into applied paths
  KnowledgeTreeEdgeSpec(fromNodeId: 'mathematics', toNodeId: 'applied_hub'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'oop', toNodeId: 'applied_hub'),
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'algorithms_data_structures',
    toNodeId: 'applied_hub',
  ),
  KnowledgeTreeEdgeSpec(fromNodeId: 'databases', toNodeId: 'applied_hub'),
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'operating_systems',
    toNodeId: 'applied_hub',
  ),

  // Applied branches
  KnowledgeTreeEdgeSpec(fromNodeId: 'applied_hub', toNodeId: 'frontend'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'applied_hub', toNodeId: 'backend'),
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'applied_hub',
    toNodeId: 'machine_learning',
  ),
  KnowledgeTreeEdgeSpec(fromNodeId: 'applied_hub', toNodeId: 'mobile'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'applied_hub', toNodeId: 'sre_devops'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'applied_hub', toNodeId: 'cybersecurity'),

  // Applied depth
  KnowledgeTreeEdgeSpec(fromNodeId: 'ai_theory', toNodeId: 'applied_hub'),
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'information_security_foundations',
    toNodeId: 'applied_hub',
  ),
  KnowledgeTreeEdgeSpec(fromNodeId: 'frontend', toNodeId: 'qa_engineering'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'backend', toNodeId: 'qa_engineering'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'mobile', toNodeId: 'android_development'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'mobile', toNodeId: 'ios_development'),
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'mobile',
    toNodeId: 'crossplatform_development',
  ),
  KnowledgeTreeEdgeSpec(
    fromNodeId: 'sre_devops',
    toNodeId: 'system_administration',
  ),
];
