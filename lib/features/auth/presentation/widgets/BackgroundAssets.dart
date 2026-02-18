import 'package:flutter/material.dart';

class BackgroundAssets {
  static const List<String> symbols = [
    // базовые код-символы
    "[]", "<>", "::", "&&", "||", "==", "!=", ">=", "<=", "/* */", "//", "??", "?:", "->", "<-",
    "@", "*", "&", "|", "^", "~", "%", "!", "?", ":", ";", "++", "< />", "{ }", "()", "#", "λ",

    // привычные штуки из dev-мира
    "HTTP", "HTTPS", "REST", "gRPC", "WS", "TCP", "UDP", "IP", "DNS", "JWT", "OAuth",
    "CI", "CD", "TDD", "OOP", "SOLID", "DRY", "KISS",

    // языки/техи
    "JS", "TS", "HTML", "CSS", "C#", "C++", "Rust", "Kotlin", "Swift", "Go", "Dart", "Flutter", "Python", "Java",
    "Linux", "Bash", "Docker", "K8s", "AWS", "GCP", "Azure", "Git", "API", "db"

    // данные/хранилища/форматы
        "NoSQL", "SQL", "Redis", "Postgres", "Mongo", "Kafka", "S3", "ETL", "CSV", "XML", "YAML", "JSON"

    // мат/алго
        "O(n)", "O(log n)", "BFS", "DFS", "APIv1", "v2",

    // UI/мобилка
    "UX", "UI/UX", "iOS", "Android",
  ];

  static const List<IconData> icons = [
    // сеть / инфраструктура
    Icons.router,
    Icons.code,
    Icons.terminal,
    Icons.wifi,
    Icons.public,
    Icons.cloud_outlined,
    Icons.dns,
    Icons.cable,
    Icons.usb,
    Icons.settings_ethernet,


    // данные / базы / аналитика
    Icons.storage,
    Icons.memory,
    Icons.table_chart_outlined,
    Icons.schema_outlined,
    Icons.insights_outlined,
    Icons.bug_report_outlined,

    // разработка / git / контроль
    Icons.merge_type,
    Icons.commit,
    Icons.rule,
    Icons.manage_search,
    Icons.code_off,

    // безопасность
    Icons.vpn_key_outlined,
    Icons.lock_outline,
    Icons.security,
    Icons.shield_outlined,

    // API / интеграции
    Icons.api_outlined,
    Icons.integration_instructions_outlined,

    // UI/компоненты
    Icons.widgets_outlined,
    Icons.devices_outlined,
    Icons.phone_android,
  ];
}