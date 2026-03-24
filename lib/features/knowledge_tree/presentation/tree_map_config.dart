import 'package:flutter/material.dart';

import '../../../app/state/demo_models.dart';

const Size knowledgeTreeCanvasSize = Size(1600, 2820);

const List<KnowledgeTreeNodeSpec> knowledgeTreeNodes = <KnowledgeTreeNodeSpec>[
  // ── Layer 1: Root Hub ──
  KnowledgeTreeNodeSpec(
    id: 'root',
    title: LocalizedText(
      ru: 'Computer Science',
      en: 'Computer Science',
      kk: 'Computer Science',
    ),
    subtitle: LocalizedText(
      ru: 'Foundation',
      en: 'Foundation',
      kk: 'Foundation',
    ),
    position: Offset(800, 150),
    radius: 110,
    isHub: true,
  ),

  // ── Layer 2: Main branches ──
  KnowledgeTreeNodeSpec(
    id: 'mathematics',
    trackId: 'mathematics',
    title: LocalizedText(
      ru: 'Mathematics',
      en: 'Mathematics',
      kk: 'Mathematics',
    ),
    position: Offset(340, 450),
    radius: 96,
  ),
  KnowledgeTreeNodeSpec(
    id: 'databases',
    trackId: 'databases',
    title: LocalizedText(ru: 'Databases', en: 'Databases', kk: 'Databases'),
    position: Offset(1020, 420),
    radius: 84,
  ),
  KnowledgeTreeNodeSpec(
    id: 'algorithms_data_structures',
    trackId: 'algorithms_data_structures',
    title: LocalizedText(
      ru: 'Algorithms & Data Structures',
      en: 'Algorithms & Data Structures',
      kk: 'Algorithms & Data Structures',
    ),
    position: Offset(1340, 640),
    radius: 88,
  ),

  // ── Layer 3: Math sub-branches (top pair) ──
  KnowledgeTreeNodeSpec(
    id: 'mathematical_analysis',
    trackId: 'mathematical_analysis',
    title: LocalizedText(
      ru: 'Mathematical Analysis',
      en: 'Mathematical Analysis',
      kk: 'Mathematical Analysis',
    ),
    position: Offset(140, 740),
    radius: 76,
  ),
  KnowledgeTreeNodeSpec(
    id: 'linear_algebra_calculus',
    trackId: 'linear_algebra_calculus',
    title: LocalizedText(
      ru: 'Linear Algebra',
      en: 'Linear Algebra',
      kk: 'Linear Algebra',
    ),
    position: Offset(520, 740),
    radius: 76,
  ),

  // ── Layer 4: Math sub-branches (bottom pair) + CS right branch ──
  KnowledgeTreeNodeSpec(
    id: 'discrete_math',
    trackId: 'discrete_math',
    title: LocalizedText(
      ru: 'Discrete Math',
      en: 'Discrete Math',
      kk: 'Discrete Math',
    ),
    position: Offset(140, 1020),
    radius: 76,
  ),
  KnowledgeTreeNodeSpec(
    id: 'probability_statistics_analytics',
    trackId: 'probability_statistics_analytics',
    title: LocalizedText(
      ru: 'Probability & Statistics',
      en: 'Probability & Statistics',
      kk: 'Probability & Statistics',
    ),
    position: Offset(520, 1020),
    radius: 78,
  ),
  KnowledgeTreeNodeSpec(
    id: 'networking_protocols',
    trackId: 'networking_protocols',
    title: LocalizedText(
      ru: 'Information Networks',
      en: 'Information Networks',
      kk: 'Information Networks',
    ),
    position: Offset(1140, 900),
    radius: 80,
  ),
  KnowledgeTreeNodeSpec(
    id: 'ai_theory',
    trackId: 'ai_theory',
    title: LocalizedText(ru: 'AI Theory', en: 'AI Theory', kk: 'AI Theory'),
    position: Offset(1360, 1130),
    radius: 78,
  ),

  // ── Layer 5: Mid-tree CS branches ──
  KnowledgeTreeNodeSpec(
    id: 'computer_architecture',
    trackId: 'computer_architecture',
    title: LocalizedText(
      ru: 'Computer Architecture',
      en: 'Computer Architecture',
      kk: 'Computer Architecture',
    ),
    position: Offset(1020, 1340),
    radius: 82,
  ),
  KnowledgeTreeNodeSpec(
    id: 'information_security_foundations',
    trackId: 'information_security_foundations',
    title: LocalizedText(
      ru: 'Information Security',
      en: 'Information Security',
      kk: 'Information Security',
    ),
    position: Offset(1300, 1540),
    radius: 78,
  ),

  // ── Layer 6: Operating Systems (bridge) ──
  KnowledgeTreeNodeSpec(
    id: 'operating_systems',
    trackId: 'operating_systems',
    title: LocalizedText(
      ru: 'Operating Systems',
      en: 'Operating Systems',
      kk: 'Operating Systems',
    ),
    position: Offset(800, 1720),
    radius: 106,
  ),

  // ── Layer 7: Applied IT Hub ──
  KnowledgeTreeNodeSpec(
    id: 'applied_hub',
    title: LocalizedText(
      ru: 'Applied IT Spheres',
      en: 'Applied IT Spheres',
      kk: 'Applied IT Spheres',
    ),
    subtitle: LocalizedText(
      ru: 'Specializations',
      en: 'Specializations',
      kk: 'Specializations',
    ),
    position: Offset(800, 1980),
    radius: 96,
    isHub: true,
  ),

  // ── Layer 8: Applied specializations ──
  KnowledgeTreeNodeSpec(
    id: 'frontend',
    trackId: 'frontend',
    title: LocalizedText(ru: 'Frontend', en: 'Frontend', kk: 'Frontend'),
    position: Offset(230, 2200),
    radius: 78,
  ),
  KnowledgeTreeNodeSpec(
    id: 'backend',
    trackId: 'backend',
    title: LocalizedText(ru: 'Backend', en: 'Backend', kk: 'Backend'),
    position: Offset(480, 2360),
    radius: 78,
  ),
  KnowledgeTreeNodeSpec(
    id: 'mobile',
    trackId: 'mobile',
    title: LocalizedText(ru: 'Mobile', en: 'Mobile', kk: 'Mobile'),
    position: Offset(800, 2350),
    radius: 88,
  ),
  KnowledgeTreeNodeSpec(
    id: 'sre_devops',
    trackId: 'sre_devops',
    title: LocalizedText(
      ru: 'DevOps / SRE',
      en: 'DevOps / SRE',
      kk: 'DevOps / SRE',
    ),
    position: Offset(1180, 2200),
    radius: 78,
  ),

  // ── Layer 9: Deep specializations ──
  KnowledgeTreeNodeSpec(
    id: 'machine_learning',
    trackId: 'machine_learning',
    title: LocalizedText(
      ru: 'ML Engineer',
      en: 'ML Engineer',
      kk: 'ML Engineer',
    ),
    position: Offset(200, 2520),
    radius: 74,
  ),
  KnowledgeTreeNodeSpec(
    id: 'qa_engineering',
    trackId: 'qa_engineering',
    title: LocalizedText(
      ru: 'QA Engineer',
      en: 'QA Engineer',
      kk: 'QA Engineer',
    ),
    position: Offset(440, 2650),
    radius: 70,
  ),
  KnowledgeTreeNodeSpec(
    id: 'system_administration',
    trackId: 'system_administration',
    title: LocalizedText(
      ru: 'System Admin',
      en: 'System Admin',
      kk: 'System Admin',
    ),
    position: Offset(1260, 2520),
    radius: 74,
  ),
  KnowledgeTreeNodeSpec(
    id: 'cybersecurity',
    trackId: 'cybersecurity',
    title: LocalizedText(
      ru: 'Cybersecurity',
      en: 'Cybersecurity',
      kk: 'Cybersecurity',
    ),
    position: Offset(1120, 2650),
    radius: 74,
  ),

  // ── Layer 10: Mobile sub-nodes ──
  KnowledgeTreeNodeSpec(
    id: 'android_development',
    trackId: 'android_development',
    title: LocalizedText(ru: 'Android', en: 'Android', kk: 'Android'),
    position: Offset(660, 2580),
    radius: 64,
  ),
  KnowledgeTreeNodeSpec(
    id: 'ios_development',
    trackId: 'ios_development',
    title: LocalizedText(ru: 'iOS', en: 'iOS', kk: 'iOS'),
    position: Offset(940, 2580),
    radius: 64,
  ),
  KnowledgeTreeNodeSpec(
    id: 'crossplatform_development',
    trackId: 'crossplatform_development',
    title: LocalizedText(
      ru: 'Crossplatform',
      en: 'Crossplatform',
      kk: 'Crossplatform',
    ),
    position: Offset(800, 2730),
    radius: 66,
  ),
];

const List<KnowledgeTreeEdgeSpec> knowledgeTreeEdges = <KnowledgeTreeEdgeSpec>[
  // Root → main branches
  KnowledgeTreeEdgeSpec(fromNodeId: 'root', toNodeId: 'mathematics'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'root', toNodeId: 'databases'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'root', toNodeId: 'algorithms_data_structures'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'root', toNodeId: 'networking_protocols'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'root', toNodeId: 'ai_theory'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'root', toNodeId: 'computer_architecture'),
  KnowledgeTreeEdgeSpec(
      fromNodeId: 'root', toNodeId: 'information_security_foundations'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'root', toNodeId: 'operating_systems'),

  // Mathematics → sub-branches
  KnowledgeTreeEdgeSpec(
      fromNodeId: 'mathematics', toNodeId: 'mathematical_analysis'),
  KnowledgeTreeEdgeSpec(
      fromNodeId: 'mathematics', toNodeId: 'linear_algebra_calculus'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'mathematics', toNodeId: 'discrete_math'),
  KnowledgeTreeEdgeSpec(
      fromNodeId: 'mathematics',
      toNodeId: 'probability_statistics_analytics'),

  // OS → Applied Hub → specializations
  KnowledgeTreeEdgeSpec(
      fromNodeId: 'operating_systems', toNodeId: 'applied_hub'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'applied_hub', toNodeId: 'frontend'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'applied_hub', toNodeId: 'backend'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'applied_hub', toNodeId: 'mobile'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'applied_hub', toNodeId: 'sre_devops'),
  KnowledgeTreeEdgeSpec(
      fromNodeId: 'applied_hub', toNodeId: 'machine_learning'),
  KnowledgeTreeEdgeSpec(
      fromNodeId: 'applied_hub', toNodeId: 'qa_engineering'),
  KnowledgeTreeEdgeSpec(
      fromNodeId: 'applied_hub', toNodeId: 'system_administration'),
  KnowledgeTreeEdgeSpec(
      fromNodeId: 'applied_hub', toNodeId: 'cybersecurity'),

  // Mobile → sub-platforms
  KnowledgeTreeEdgeSpec(
      fromNodeId: 'mobile', toNodeId: 'android_development'),
  KnowledgeTreeEdgeSpec(fromNodeId: 'mobile', toNodeId: 'ios_development'),
  KnowledgeTreeEdgeSpec(
      fromNodeId: 'mobile', toNodeId: 'crossplatform_development'),
];
