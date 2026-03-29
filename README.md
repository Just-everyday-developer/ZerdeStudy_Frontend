# ZerdeStudy Frontend

Полноценный Flutter frontend MVP для дипломного проекта и презентации. Проект работает без backend: все данные, прогресс, курсы, рейтинги, сертификаты, история и настройки живут локально через `SharedPreferences`.

README ниже написан как практическая карта кодовой базы: что лежит в каждой папке, за что отвечает каждый файл, где именно править дерево знаний, курсы, профиль, фильтры, роуты, локализацию и состояние приложения.

## 1. Что это за приложение

ZerdeStudy состоит из нескольких крупных блоков:

- `Welcome / Auth` — вход, регистрация, social login-моки.
- `Tree` — единое дерево знаний с ветками computer science и прикладных направлений.
- `Learn` — витрина курсов и каталог.
- `Course Detail / Course Player` — детальная страница курса и mini-course player.
- `AI` — локальный AI mentor.
- `Profile` — прогресс, достижения, сертификаты, избранное, история.
- `Analytics` — статистика и лидерборд.

## 2. Как запустить проект

### Основные команды

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
flutter run -d windows
flutter build web
flutter build windows
```

### Где хранится локальное состояние

Все demo-данные пользователя сохраняются в `SharedPreferences`.

Ключ storage:

```text
zerdestudy_demo_state_v4
```

Этот ключ объявлен в:

- `lib/app/state/demo_app_controller.dart`

## 3. Архитектура по слоям

### `lib/main.dart`

Точка входа приложения.

Что делает:

- инициализирует Flutter binding;
- конфигурирует desktop window через `core/window`;
- получает `SharedPreferences`;
- поднимает `ProviderScope`;
- запускает `MaterialApp.router`;
- подключает тему, локализацию и роутер.

Если нужно:

- поменять стартовую обвязку приложения — править здесь;
- поменять подключение window frame — править здесь и в `core/window/*`.

### `lib/app`

Здесь находится "application shell":

- роутинг;
- глобальное состояние;
- seed-данные;
- доменные модели.

### `lib/core`

Переиспользуемая инфраструктура:

- общие виджеты;
- тема;
- локализация;
- responsive/breakpoints;
- window frame;
- служебные providers;
- utility-анимации и расширения.

### `lib/features`

Фичи приложения, разложенные по экранам:

- `auth`
- `home`
- `knowledge_tree`
- `learning`
- `ai`
- `profile`
- `analytics`
- `faq`

## 4. Поток данных в приложении

Главный поток такой:

1. `DemoCatalog` поставляет контент, seed-курсы, tree-ноды, assessments и derived-логику.
2. `DemoAppController` хранит mutable demo-state пользователя.
3. Экраны читают:
   - состояние через `demoAppControllerProvider`
   - каталог через `demoCatalogProvider`
4. Любое действие пользователя идёт в controller:
   - completion урока
   - оценка курса
   - enrollment
   - AI message
   - смена темы / языка
5. После изменения controller пересчитывает derived-state и пишет всё в `SharedPreferences`.

Главные файлы этого потока:

- `lib/app/state/demo_models.dart`
- `lib/app/state/demo_app_state.dart`
- `lib/app/state/demo_app_controller.dart`
- `lib/app/state/demo_catalog.dart`

## 5. Роутинг

### Главные route-константы

Файл:

- `lib/app/routing/app_routes.dart`

Здесь лежат:

- пути экранов;
- helpers для динамических роутов;
- генерация query string для каталога и course player.

### Основной роутер

Файл:

- `lib/app/routing/router.dart`

Что здесь:

- `GoRouter`;
- redirect-логика между auth и shell;
- shell-навигация по 5 вкладкам;
- detail routes:
  - `track`
  - `lesson`
  - `practice`
  - `assessment`
  - `stats`
  - `leaderboard`
  - `faq`
  - `courses`
  - `course-player`

### Устаревший маршрутный файл

Файл:

- `lib/app/routing/routes.dart`

Это старый/переходный файл с ранними route-описаниями. Сейчас главным является `router.dart`. Если нужен реальный маршрут приложения — смотреть нужно именно `router.dart`.

## 6. Состояние и модели

### `lib/app/state/app_locale.dart`

Enum локалей приложения.

Используется для:

- текущего языка;
- преобразования в `Locale`;
- подписи языка в UI.

### `lib/app/state/app_theme_mode.dart`

Enum тем приложения.

Используется в:

- настройках;
- `MaterialApp.themeMode`;
- локальном сохранении выбора темы.

### `lib/app/state/demo_models.dart`

Главный файл моделей.

Что здесь лежит:

- `LocalizedText`
- `DemoUser`
- `AiMessage`
- `Achievement`
- `LeaderboardEntry`
- `LessonQuiz`
- `CodeTrainer`
- `LessonItem`
- `PracticeTask`
- `LearningModule`
- `LearningTrack`
- `KnowledgeTreeNodeSpec`
- `KnowledgeTreeEdgeSpec`
- `TrackAssessment*`
- `CommunityCourse*`
- `CoursePlayer*`
- `CourseCertificate`
- `CourseDurationBucket`

Если нужно поменять структуру контента, добавить новое поле в курс, урок, упражнение или сертификат — правки начинаются отсюда.

### `lib/app/state/demo_app_state.dart`

Хранит весь сериализуемый state пользователя.

Сюда входят:

- auth status;
- current locale/theme;
- текущий track/focus;
- completed lessons/practices;
- quiz/trainer completion;
- assessment results;
- learning history;
- просмотренные/сохранённые курсы;
- user ratings курсов;
- enrollment и progress course player;
- XP, streak, weekly activity;
- AI message history;
- unlocked achievements.

Если нужно понять, что именно реально сохраняется на устройстве — смотреть этот файл.

### `lib/app/state/demo_app_controller.dart`

Главный state controller.

Что делает:

- читает и восстанавливает state из `SharedPreferences`;
- логинит пользователя;
- меняет язык и тему;
- завершает уроки, практики, quizzes, trainers;
- сохраняет/оценивает курсы;
- открывает и продвигает course player;
- сохраняет AI сообщения;
- выдаёт историю действий;
- ресетит demo-state.

Если надо изменить бизнес-логику:

- начисление XP;
- условия выдачи сертификатов;
- правила сохранения прогресса;
- историю результатов;
- onboarding/enrollment flow

то править нужно именно здесь.

### `lib/app/state/demo_catalog.dart`

Главный "content index" приложения.

Что делает:

- собирает все треки и курсы;
- индексирует уроки, практики, quizzes, exercises;
- считает progress по track/course;
- выдаёт leaderboard;
- фильтрует каталог;
- считает рейтинг курса;
- создаёт сертификаты;
- выдаёт incorrect questions/exercises;
- строит AI-ответы для части локальных сценариев.

Если нужно поменять derived-логику интерфейса — очень вероятно, что правка здесь.

### `lib/app/state/demo_catalog_support.dart`

Helper-строитель seed-данных.

Что лежит здесь:

- builders для `LearningTrack`, `LearningModule`, `LessonItem`, `PracticeTask`;
- builders для `CommunityCourse`;
- default lesson previews;
- default course player modules;
- default course comments/reviews/updates/facts/offer.

Если вы хотите быстро поменять шаблон, по которому генерируются demo-курсы или lesson flow — правьте этот файл.

### `lib/app/state/demo_catalog_cs_data.dart`

Seed-данные для веток `Computer Science Core`.

Примеры:

- mathematics
- databases
- operating systems
- networks
- algorithms
- architecture

Если нужно поменять контент веток фундаментального дерева — править здесь.

### `lib/app/state/demo_catalog_it_data.dart`

Seed-данные для прикладных IT-сфер.

Примеры:

- frontend
- backend
- mobile
- sre/devops
- ml
- cybersecurity

Если нужно менять практические треки дерева — править здесь.

### `lib/app/state/demo_catalog_course_data.dart`

Seed-данные discovery-курсов для `Learn` и `Catalog`.

Что здесь:

- авторы курсов;
- список mock courses;
- topic keys;
- flagship course ids;
- basic course metadata для discovery UI.

Если нужно:

- добавить новый курс в каталог;
- отметить курс как `supportsCoursePlayer`;
- поменять автора;
- перераспределить курс по секциям `Learn`

править нужно здесь.

## 7. Core-инфраструктура

### `lib/core/common_widgets/adaptive_panel.dart`

Универсальная adaptive-панель.

Используется для:

- bottom sheets на телефоне;
- dialog/panel presentation на wide-экранах.

Через этот файл открываются:

- filters;
- settings;
- inline AI;
- enrollment modal;
- achievements panel.

### `lib/core/common_widgets/app_button.dart`

Главные кнопки приложения.

Если нужно поменять:

- форму CTA;
- paddings;
- размеры;
- общую кнопку secondary/primary

это место для правок.

### `lib/core/common_widgets/app_notice.dart`

Система внутренних уведомлений.

Сейчас:

- уведомления появляются справа сверху;
- умеют стекаться;
- используют overlay;
- поддерживают `info/success/error`.

Если хотите поменять поведение toast/notice — править здесь.

### `lib/core/common_widgets/app_page_scaffold.dart`

Базовый scaffold для отдельных страниц.

Что даёт:

- фон;
- верхний back button;
- max content width;
- safe area;
- общий backdrop.

Практически все detail-экраны проходят через него.

### `lib/core/common_widgets/app_settings_panel.dart`

Контент панели настроек.

Сюда вынесены:

- переключение языка;
- переключение темы.

Если нужно менять settings UI — править сюда.

### `lib/core/common_widgets/app_shell_scaffold.dart`

Один из важнейших файлов проекта.

Что делает:

- строит shell для вкладок;
- на телефоне показывает bottom navigation;
- на desktop показывает top navigation;
- обрабатывает back-навигацию;
- даёт hotkeys;
- держит FAQ/settings/profile actions в top bar.

Если нужно менять:

- shell-навигацию;
- desktop header;
- кнопку профиля;
- FAQ/settings расположение;
- hotkeys

то начинать отсюда.

### `lib/core/common_widgets/glow_card.dart`

Базовая декоративная карточка проекта.

Используется почти везде:

- home
- profile
- analytics
- learn
- tree
- detail pages

### `lib/core/common_widgets/locale_selector.dart`

Selector языка для auth и других компактных мест.

### `lib/core/common_widgets/tech_text_field.dart`

Общий стиль text input для auth-экранов.

### `lib/core/constants/app_colors.dart`

Базовые цветовые константы.

### `lib/core/extensions/context_size.dart`

Мини-расширения для размеров из `BuildContext`.

Сейчас скорее вспомогательный/legacy файл.

### `lib/core/layout/app_breakpoints.dart`

Responsive слой.

Здесь определены breakpoint-хелперы вида:

- compact
- medium
- wide
- page max width
- horizontal paddings

Если desktop/mobile адаптивность выглядит не так, как нужно — править здесь.

### `lib/core/localization/app_localizations.dart`

Локализация приложения.

Что делает:

- хранит все UI-строки;
- отдает `text(key)` и `format(key, values)`;
- умеет преобразовывать topic/level labels.

Если в интерфейсе появился новый текст — его надо добавить сюда.

### `lib/core/providers/background_controller.dart`

Контроллер фоновых анимаций/визуальных слоёв.

Поднимается в `main.dart`.

### `lib/core/providers/course_search_focus_provider.dart`

Небольшой provider для фокуса поисковой строки курсов.

Используется с hotkey `Ctrl+K`.

### `lib/core/theme/app_theme.dart`

Главный ThemeData-файл.

Здесь:

- light theme;
- dark theme;
- базовые компоненты Material.

### `lib/core/theme/app_theme_colors.dart`

Расширение темы с проектными цветами.

Используется для:

- `context.appColors`
- page gradients
- accent colors
- card colors

### `lib/core/utils/cyber_transition.dart`

Переходы страниц для `GoRouter`.

### `lib/core/window/app_window.dart`

Публичная обёртка над desktop window layer.

### `lib/core/window/app_window_io.dart`

Windows-реализация кастомного frame.

Что делает:

- скрывает нативный title bar;
- конфигурирует размер окна;
- рисует кастомную верхнюю полосу;
- добавляет drag/minimize/maximize/close.

Если нужно править desktop frame — это главный файл.

### `lib/core/window/app_window_stub.dart`

Stub-реализация для платформ, где custom frame не нужен.

## 8. Feature-папки

### `lib/features/auth`

#### `application/usecases`

- `validate_email.dart` — use case валидации email.
- `validate_name.dart` — use case валидации имени.
- `validate_password.dart` — use case валидации пароля.

#### `domain/validators`

- `email_validator.dart` — контракт validator.
- `name_validator.dart` — контракт validator.
- `password_validator.dart` — контракт validator.

#### `data/validators`

- `email_validator_impl.dart` — реализация email validator.
- `name_validator_impl.dart` — реализация name validator.
- `password_validator_impl.dart` — реализация password validator.

#### `presentation/providers`

- `email_providers.dart` — Riverpod provider для email validation.
- `name_providers.dart` — Riverpod provider для name validation.
- `password_providers.dart` — Riverpod provider для password validation.

#### `presentation/pages`

- `welcome_page.dart` — стартовый экран, social login, вход/регистрация, ссылка `Forgot password?`.
- `login_page.dart` — вход по email и быстрый переход в mock reset-password flow.
- `sign_up_page.dart` — регистрация.
- `forgot_password_page.dart` — экран запроса сброса пароля по email.
- `forgot_password_code_page.dart` — экран ввода 6-значного кода подтверждения. Сейчас для демо принимает любой полностью заполненный 6-значный код и пускает пользователя в `Home`.

#### `presentation/widgets`

- `animated_welcome_text.dart` — animated branding text.
- `auth_background_wrapper.dart` — общий фон auth-экранов.
- `background_assets.dart` — вспомогательные background assets/config.
- `infinite_tech_painter.dart` — кастомный painter фона.
- `tech_action_button.dart` — стиль кнопок auth.
- `tech_particle.dart` — декоративные частицы.

### `lib/features/home`

#### `presentation/pages/home_page.dart`

Главная dashboard-страница.

Здесь:

- `continue learning`;
- daily mission;
- repeat incorrect questions;
- recommended tracks;
- leaderboard preview.

Если нужно менять главную страницу — править здесь.

#### `presentation/pages/community_courses_page.dart`

Главная страница каталога курсов.

Здесь:

- поиск;
- filters;
- results chips;
- адаптивный list/grid;
- authors rail.

#### `presentation/pages/community_course_detail_page.dart`

Детальная страница курса.

Adaptive:

- mobile tab layout;
- desktop hero + sidebar.

Здесь же:

- рейтинг курса 1–5;
- save course;
- enroll/start course;
- desktop onboarding modal.

#### `presentation/pages/community_course_player_page.dart`

Mini-course player.

Здесь:

- compact intro;
- desktop sidebar layout;
- lesson content;
- media block;
- code example;
- comments;
- exercises:
  - single choice
  - multiple choice
  - matching
  - drag/drop
  - fill blank
  - code input
- inline AI.

Если нужно править lesson flow flagship-курсов — это главный файл.

#### `presentation/widgets/course_card.dart`

Карточка для рекомендованных track-веток на home.

### `lib/features/knowledge_tree`

#### `presentation/pages/knowledge_tree.dart`

Главный экран дерева знаний.

Здесь:

- summary;
- legend;
- interactive tree viewport;
- zoom controls;
- wheel/pinch behavior;
- routing по tap на node.

Если нужно менять поведение зума, панорамирование или весь tree screen — править здесь.

#### `presentation/tree_map_config.dart`

Ключевой файл геометрии дерева.

Здесь лежит:

- `knowledgeTreeCanvasSize`
- `knowledgeTreeNodes`
- `knowledgeTreeEdges`

Если нужно переставить ноды, разнести ветки, поменять связи или размеры дерева — правки начинаются отсюда.

#### `presentation/widgets/skill_node.dart`

Дополнительный tree-node widget/helper.

#### `presentation/widgets/tree_painter.dart`

Legacy/helper painter для дерева.

### `lib/features/learning`

#### `presentation/pages/learn_page.dart`

Экран `Learn`.

Сейчас здесь:

- поисковая строка;
- открытие filters;
- горизонтальные rails по секциям;
- `10 course cards + View all`;
- popular authors rail;
- frequent searches block.

Если нужно менять layout раздела `Learn` — это главный файл.

#### `presentation/pages/track_page.dart`

Обзор учебного трека из дерева.

#### `presentation/pages/lesson_page.dart`

Экран обычного lesson flow для tree-треков.

#### `presentation/pages/practice_page.dart`

Практика для tree-треков.

#### `presentation/pages/track_assessment_page.dart`

Итоговый assessment по track.

#### `presentation/widgets/course_discovery_widgets.dart`

Общий UI-kit для discovery-курсов:

- search bar;
- filter cards;
- filter chip groups;
- toggle tiles;
- section header;
- course cards;
- author cards;
- view-all card.

Если нужно править дизайн `Learn`/`Catalog` карточек и фильтров — редактировать нужно здесь.

### `lib/features/ai`

#### `presentation/pages/ai_mentor_page.dart`

Основной экран AI mentor.

Здесь:

- подготовленные prompt-ы;
- чат;
- локальные canned replies.

### `lib/features/profile`

#### `presentation/pages/profile_page.dart`

Профиль пользователя.

Здесь:

- profile header;
- achievements carousel;
- certificates carousel;
- favorites;
- completed;
- result history;
- переходы в stats/leaderboard;
- reset/logout.

Если нужно менять профиль — почти всё сосредоточено здесь.

### `lib/features/analytics`

#### `presentation/pages/stats_page.dart`

Статистика:

- weekly activity;
- aggregated progress;
- quiz accuracy;
- completion metrics.

#### `presentation/pages/leaderboard_page.dart`

Лидерборд:

- podium для top 3;
- список остальных участников.

### `lib/features/faq`

#### `presentation/pages/faq_page.dart`

FAQ-экран с быстрыми ответами о платформе.

## 9. Где править конкретные вещи

### Изменить дерево знаний

Править:

- `lib/features/knowledge_tree/presentation/tree_map_config.dart`
- `lib/features/knowledge_tree/presentation/pages/knowledge_tree.dart`

### Изменить зум дерева

Править:

- `lib/features/knowledge_tree/presentation/pages/knowledge_tree.dart`

### Добавить новый трек в дерево

Править:

- `lib/app/state/demo_models.dart`
- `lib/app/state/demo_catalog_cs_data.dart` или `lib/app/state/demo_catalog_it_data.dart`
- `lib/features/knowledge_tree/presentation/tree_map_config.dart`

### Добавить новый discovery-курс в Learn/Catalog

Править:

- `lib/app/state/demo_catalog_course_data.dart`
- при необходимости `lib/app/state/demo_catalog_support.dart`

### Добавить полный playable flagship course

Править:

- `lib/app/state/demo_catalog_course_data.dart` — отметить `supportsCoursePlayer`
- `lib/app/state/demo_catalog_support.dart` — шаблон player lessons/exercises
- `lib/features/home/presentation/pages/community_course_player_page.dart` — сам UI прохождения

### Поменять фильтры каталога

Править:

- `lib/features/learning/presentation/pages/learn_page.dart`
- `lib/features/home/presentation/pages/community_courses_page.dart`
- `lib/features/learning/presentation/widgets/course_discovery_widgets.dart`
- `lib/app/state/demo_catalog.dart`

### Поменять профиль

Править:

- `lib/features/profile/presentation/pages/profile_page.dart`

### Поменять топбар/desktop shell

Править:

- `lib/core/common_widgets/app_shell_scaffold.dart`
- `lib/core/window/app_window_io.dart`

### Поменять настройки темы и языка

Править:

- `lib/core/common_widgets/app_settings_panel.dart`
- `lib/app/state/demo_app_controller.dart`
- `lib/app/state/app_theme_mode.dart`
- `lib/app/state/app_locale.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/localization/app_localizations.dart`

### Поменять локальные AI-ответы

Править:

- `lib/app/state/demo_catalog.dart`
- `lib/app/state/demo_app_controller.dart`
- `lib/features/ai/presentation/pages/ai_mentor_page.dart`
- `lib/features/home/presentation/pages/community_course_player_page.dart`

### Поменять сертификаты

Править:

- `lib/app/state/demo_catalog.dart`
- `lib/app/state/demo_models.dart`
- `lib/app/state/demo_app_controller.dart`
- `lib/features/profile/presentation/pages/profile_page.dart`

## 10. Тесты

Файл:

- `test/widget_test.dart`

Здесь лежат widget smoke tests для:

- social login;
- knowledge tree;
- learn page;
- catalog filtering;
- lesson flow;
- assessments;
- profile;
- AI.

Если вы меняете тексты, layout или route flow, этот файл нужно обновить.

## 11. Web и Windows

### `web`

- `web/index.html` — html-обвязка web build.
- `web/manifest.json` — web manifest и метаданные.
- `web/favicon.png` — favicon.
- `web/icons/*` — PWA иконки.

### `windows`

#### Важные редактируемые файлы

- `windows/CMakeLists.txt` — сборка windows-приложения.
- `windows/runner/CMakeLists.txt` — конфиг runner target.
- `windows/runner/main.cpp` — вход в Windows runner.
- `windows/runner/flutter_window.cpp`
- `windows/runner/flutter_window.h`
- `windows/runner/win32_window.cpp`
- `windows/runner/win32_window.h`
- `windows/runner/utils.cpp`
- `windows/runner/utils.h`
- `windows/runner/Runner.rc`
- `windows/runner/resource.h`
- `windows/runner/resources/app_icon.ico`
- `windows/runner/runner.exe.manifest`

#### Generated windows files

Обычно не редактируются вручную:

- `windows/flutter/generated_plugin_registrant.cc`
- `windows/flutter/generated_plugin_registrant.h`
- `windows/flutter/generated_plugins.cmake`
- `windows/flutter/CMakeLists.txt`

## 12. Android

### Важные файлы

- `android/build.gradle.kts`
- `android/settings.gradle.kts`
- `android/gradle.properties`
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/com/example/frontend_flutter/MainActivity.kt`
- `android/app/src/main/res/values/styles.xml`
- `android/app/src/main/res/values-night/styles.xml`
- `android/app/src/main/res/drawable/launch_background.xml`
- `android/app/src/main/res/drawable-v21/launch_background.xml`
- `android/app/src/main/res/mipmap-*/*`

### Вспомогательные manifest-файлы

- `android/app/src/debug/AndroidManifest.xml`
- `android/app/src/profile/AndroidManifest.xml`

## 13. Правила безопасного редактирования

Когда меняете проект, лучше держать такую последовательность:

1. Меняете модели, если нужен новый data shape.
2. Меняете seed-данные в `demo_catalog_*`.
3. Меняете derived-логику в `demo_catalog.dart`.
4. Меняете mutable flow в `demo_app_controller.dart`.
5. Меняете UI-страницы.
6. Добавляете строки в `app_localizations.dart`.
7. Проверяете:

```bash
flutter analyze
flutter test
flutter build web
flutter build windows
```

## 14. Короткая шпаргалка

### Хочу поменять...

- дерево знаний — `knowledge_tree.dart` + `tree_map_config.dart`
- карточки курсов — `course_discovery_widgets.dart`
- секции Learn — `learn_page.dart`
- каталог — `community_courses_page.dart`
- страницу курса — `community_course_detail_page.dart`
- плеер курса — `community_course_player_page.dart`
- профиль — `profile_page.dart`
- статистику — `stats_page.dart`
- лидерборд — `leaderboard_page.dart`
- shell/topbar — `app_shell_scaffold.dart`
- тему — `app_theme.dart`
- тексты — `app_localizations.dart`
- локальное состояние — `demo_app_state.dart`
- бизнес-логику — `demo_app_controller.dart`
- derived-логику и поиски — `demo_catalog.dart`

## 15. Текущее состояние проекта

На момент этого README приложение уже поддерживает:

- dark и light theme;
- RU / EN / KK localization layer;
- desktop adaptive shell;
- custom Windows frame;
- knowledge tree c zoom controls;
- discovery Learn;
- adaptive catalog;
- rating 1–5;
- mini-course player;
- inline AI;
- achievements;
- certificates;
- saved courses;
- history;
- tests;
- web/windows builds.

Если вам нужно быстро войти в проект и понять, где исправлять конкретный экран, сначала смотрите:

1. `router.dart`
2. нужный `features/.../pages/...`
3. `demo_catalog.dart`
4. `demo_app_controller.dart`
5. `app_localizations.dart`

## 16. Debug Notes: 2026-03-20

Recent UI/debugging updates:

- `lib/features/learning/presentation/widgets/course_discovery_widgets.dart`
  Fixed the `Search courses` field so the text caret stays inside the border.
- `lib/core/window/app_window_io.dart`
  Reworked the Windows window-frame buttons. The center button now toggles
  maximize and restore based on the real current window state.
- `lib/features/learning/presentation/pages/learn_page.dart`
  Filters are now rendered inside a scrollable panel to avoid bottom overflow
  on compact screens.
- `lib/features/home/presentation/pages/community_courses_page.dart`
  Catalog filters use the same scrollable panel approach as `Learn`.
- `lib/features/knowledge_tree/presentation/pages/knowledge_tree.dart`
  Tree screen now runs in a viewport-only mode: the outer summary/legend cards
  were removed, the legend lives inside the tree at the top-right, and the page
  itself no longer scrolls. Mouse wheel on desktop now directly controls tree
  zoom, so scaling no longer depends on `Ctrl + wheel`.
- `lib/core/common_widgets/app_settings_panel.dart`
  FAQ entry moved inside Settings.
- `lib/core/common_widgets/app_shell_scaffold.dart`
  Profile action is now the last topbar action, and avatar navigation uses a
  dedicated profile preview route for hero-style transition flow.
- `lib/app/routing/app_routes.dart`
  Added `profilePreview`.
- `lib/app/routing/router.dart`
  Registered the root-level profile preview route.
- `lib/main.dart`
  Added global mouse-drag scrolling support through a custom scroll behavior.

Debugging tip:

- If a horizontal rail stops dragging with the mouse, first check
  `lib/core/common_widgets/app_scroll_behavior.dart` and then the target
  `ListView` in `Learn` or `Profile`.

## 17. Debug Notes: 2026-03-20 Mobile Repair Pass

Latest compact/mobile UI repairs:

- `lib/core/common_widgets/app_page_scaffold.dart`
  Added `horizontalPadding` and `expandContent` so screens like `Tree` can run
  edge-to-edge without the default centered content constraint. App bar titles
  now clamp to a single line with ellipsis.
- `lib/core/common_widgets/glow_card.dart`
  Added `showBorder` for cases where a card should keep the surface styling
  without the visible border line.
- `lib/features/knowledge_tree/presentation/pages/knowledge_tree.dart`
  The tree now renders as the only viewport on the page. The outer card wrapper
  and zoom buttons were removed, and the legend is now pinned as a permanent
  panel on the top-right side of the tree viewport instead of a toggle button.
  Pinch zoom remains enabled, and mouse-wheel zoom is handled directly inside
  the tree listener. Compact mode uses tighter bounds and no page-level
  scrolling.
  Native Windows now uses a fixed tree scale and disables zoom interaction:
  the map starts in one stable desktop resolution and can only be moved by
  dragging with the mouse cursor.
  The desktop tree viewport is also width-limited now, so the map window is
  no longer stretched edge-to-edge; its height was increased to visually reach
  the bottom of the available page area.
  The outer tree background now stretches across the full available page
  width, while the actual interactive map area stays narrower inside it.
- `lib/features/home/presentation/pages/home_page.dart`
  Compact layout now uses full-width page content, the first `continue learning`
  card has no border on phone, and `daily mission` is hidden in compact mode.
- `lib/features/profile/presentation/pages/profile_page.dart`
  Reworked the compact profile header into a true mobile layout: larger avatar,
  name/email to the right, and the XP/Level/Streak metrics in an even row below
  instead of a narrow centered stack.
  The shell avatar hero transition is now enabled only for the dedicated
  `profile-preview` route. The profile page that lives inside the persistent
  shell keeps the same visual avatar but does not register the shared hero tag,
  which prevents duplicate-hero conflicts and restores the animated transition
  from the desktop shell avatar into the profile header.
- `lib/features/analytics/presentation/pages/leaderboard_page.dart`
  Added a dedicated compact podium layout to remove the phone overflow. Names,
  XP labels, and bar content are now clamped and sized specifically for small
  screens.
  The branch/focus subtitles like `Database` or `Frontend` were removed from
  both the podium and the participant list, so leaderboard entries now show a
  cleaner name/role presentation without the extra focus tag under each user.
- `lib/features/learning/presentation/pages/learn_page.dart`
  Discovery rails in `Learn` now use wider spacing between cards and slightly
  larger gaps between sections so the course rows no longer feel visually
  compressed.
- `lib/features/ai/presentation/pages/ai_mentor_page.dart`
  Replaced the old `TextField + full-width button` composer with a compact
  inline message bar for phone and desktop. The prepared-questions section now
  uses localization keys instead of hardcoded fallback strings.
- `lib/core/common_widgets/app_scroll_behavior.dart`
  Native Windows builds no longer show the Material desktop scrollbar on the
  right edge. The scrollbar is hidden only for the Windows app; web and mobile
  platforms keep their default behavior.
- `lib/core/layout/app_breakpoints.dart`
  Native Windows now uses roomier page widths and slightly tighter outer
  paddings so content spreads more evenly across the window instead of sitting
  in a narrow centered column.
- `lib/core/common_widgets/app_page_scaffold.dart`
  Desktop content alignment on the native Windows app now starts from the left
  edge of the content area instead of being centered by default.
- `lib/core/common_widgets/app_shell_scaffold.dart`
  Desktop shell now supports richer keyboard navigation: `Alt + 1..5`,
  `Left / Right`, `Ctrl + Tab`, `Ctrl + Shift + Tab`, `Alt + Z`, plus the
  existing focused-search shortcut flow. Shortcut handling now runs through a
  direct shell-level `HardwareKeyboard` handler instead of depending only on a
  focused widget subtree, so combinations like `Ctrl + K` still work even after
  the user clicks through different desktop controls. The shell locale selector
  was also restyled into a bordered pill control with a clearer dropdown
  affordance.
- `lib/features/learning/presentation/pages/learn_page.dart`
  `Ctrl + K` and the shell search action now animate the `Learn` page back to
  the top before focusing the search field, so the cursor lands directly in the
  visible search bar instead of focusing an off-screen input.
- `lib/core/common_widgets/app_settings_panel.dart`
  Settings now includes a `Help` section with FAQ access and a hotkeys list so
  desktop navigation shortcuts are discoverable from the UI.
- `lib/core/localization/app_localizations.dart`
  Added localized labels and descriptions for the new `Help` and `Hotkeys`
  settings content. The auth layer now also includes localized strings for the
  mock `Forgot password` email step and the 6-digit verification-code screen.
- `lib/features/auth/presentation/pages/forgot_password_page.dart`
  Added a dedicated mock reset-password step with email validation before the
  verification-code screen.
- `lib/features/auth/presentation/pages/forgot_password_code_page.dart`
  Added the 6-box confirmation code UI. For the current demo build, any fully
  filled 6-digit code is accepted and immediately routes the user into `Home`.
- `test/widget_test.dart`
  Added coverage for the forgot-password flow from `Welcome` through email
  submission, 6-digit code entry, and the redirect into `Home`, along with the
  earlier widget expectations for the dashboard, legend, AI composer, and the
  desktop `Ctrl + K` shortcut that should jump into `Learn` and reveal the
  search bar.

Debugging tips for this pass:

- If the tree stops zooming, inspect `onPointerSignal` and `InteractiveViewer`
  in `knowledge_tree.dart` first. The tree no longer depends on page scroll,
  so gesture conflicts usually mean the viewport listener changed.
- If a compact card looks too centered or too narrow, check the page's own
  internal `ListView` padding before changing `AppPageScaffold`.

## 18. Work Log: 2026-03-29

Latest implementation pass for the auth experience split and teacher workspace:

- `lib/features/auth/presentation/pages/login_page.dart`
  Added the `Sign in as` role selector with `Student`, `Teacher`,
  `Moderator`, and `Admin` paths. Student keeps the current app flow, teacher
  opens the new teacher workspace, moderator opens the existing moderation
  panel, and admin currently shows an availability notice.
- `lib/features/auth/presentation/widgets/auth_experience_selector.dart`
  Added role cards for the 4 entry models with localized labels and helper
  descriptions.
- `lib/features/auth/presentation/widgets/social_auth_button.dart`
  Added `Log in with` actions for Google and GitHub and aligned them with the
  current auth design system.
- `lib/features/auth/presentation/pages/sign_up_page.dart`
  Fixed the return path so navigating back from account creation no longer
  breaks the login layout.
- `lib/features/auth/presentation/pages/forgot_password_page.dart`
- `lib/features/auth/presentation/pages/forgot_password_code_page.dart`
- `lib/features/auth/presentation/pages/reset_password_page.dart`
  Split the password recovery flow into dedicated email, code verification,
  and new-password screens. The final step now includes password confirmation
  and mismatch validation.
- `lib/app/routing/router.dart`
  Stabilized routing with a router refresh listenable so changing the selected
  role no longer recreates `GoRouter` and unexpectedly resets the current auth
  page.
- `lib/features/teacher/presentation/pages/teacher_shell_page.dart`
- `lib/features/teacher/presentation/pages/teacher_dashboard_page.dart`
- `lib/features/teacher/presentation/pages/teacher_ai_generator_page.dart`
- `lib/features/teacher/presentation/pages/teacher_course_builder_page.dart`
- `lib/features/teacher/presentation/pages/teacher_assessment_builder_page.dart`
- `lib/features/teacher/presentation/pages/teacher_publishing_page.dart`
- `lib/features/teacher/presentation/pages/teacher_qna_page.dart`
- `lib/features/teacher/presentation/pages/teacher_analytics_page.dart`
- `lib/features/teacher/presentation/pages/teacher_profile_page.dart`
  Added the first teacher UI pass with localized screens for dashboard,
  AI course generation, course builder, assessment builder, publishing /
  preview, Q&A, analytics, and teacher profile. The workspace supports both
  light and dark themes through the shared app settings panel.
- `lib/core/localization/app_localizations.dart`
  Added localization keys required by the new auth flow and teacher entry
  points.
- `lib/features/auth/presentation/widgets/auth_experience_selector.dart`
- `lib/features/auth/presentation/widgets/auth_panel.dart`
- `lib/features/auth/presentation/pages/login_page.dart`
  Rebalanced the 4 auth role cards into an even responsive grid and kept the
  email / password / login cluster centered on desktop so the auth form stays
  focused instead of stretching edge-to-edge.
- `lib/features/teacher/presentation/providers/teacher_question_bank_provider.dart`
- `lib/features/teacher/presentation/pages/teacher_assessment_builder_page.dart`
  Added CSV and JSON question-bank import / export through a local exchange
  dialog, plus live parsing so the teacher assessment screen immediately shows
  the imported bank content.
- `lib/features/community/presentation/pages/community_page.dart`
- `lib/features/community/presentation/pages/community_group_page.dart`
- `lib/features/community/presentation/providers/community_groups_provider.dart`
- `lib/core/common_widgets/app_shell_scaffold.dart`
- `lib/app/routing/app_routes.dart`
- `lib/app/routing/router.dart`
  Added a new localized student `Community` section with group creation,
  group list filtering, detailed group pages, member search, media and links,
  and red `Leave group` / `Report` actions. The report flow includes common
  moderation reasons, an `Other` reason with free-text details, attachment
  chips, and a send action.
- `test/widget_test.dart`
  Updated widget coverage for the split password recovery flow and the
  teacher sign-in route, and added a smoke test for the new Community flow.
- `lib/features/knowledge_tree/presentation/tree_map_config.dart`
- `lib/app/state/demo_catalog_cs_data.dart`
  Added a new `OOP` branch under the Computer Science hub, seeded it with
  temporary object-oriented modules, and introduced a dedicated `Midterm`
  module with its own OOP checkpoint task.
- `lib/app/state/demo_models.dart`
- `lib/app/state/demo_catalog_support.dart`
- `lib/features/learning/presentation/pages/practice_page.dart`
  Extended practice tasks with an optional interactive code sandbox and
  comments thread, then used that new model to build an OOP midterm page with
  a scrollable code editor, draft run button, final submission check, and a
  bottom comments section.
- `lib/app/state/demo_moderator_controller.dart`
- `lib/features/faq/presentation/pages/faq_page.dart`
- `lib/features/moderator/presentation/pages/moderator_faq_page.dart`
- `lib/features/moderator/presentation/pages/moderator_dashboard_page.dart`
  Added a shared demo FAQ inbox so students can write a question inside the
  FAQ screen and send it to moderators. The new question form is localized,
  uses in-app notices for validation and success, and the moderator FAQ queue
  plus dashboard counter now react to newly submitted questions.
- `lib/core/localization/app_localizations.dart`
  Added localization keys for the FAQ contact form and moderator submission
  states.
- `lib/features/auth/presentation/pages/sign_up_page.dart`
  Centered the sign-up form cluster on desktop so the email field, password
  field, primary action, and back-to-login action stay visually grouped in
  the middle of the auth panel.
- `lib/app/state/demo_moderator_data.dart`
- `lib/app/state/demo_moderator_controller.dart`
- `lib/features/moderator/presentation/pages/moderator_shell_page.dart`
- `lib/features/moderator/presentation/pages/moderator_dashboard_page.dart`
- `lib/features/moderator/presentation/pages/moderator_comments_page.dart`
- `lib/features/moderator/presentation/pages/moderator_community_page.dart`
- `lib/app/routing/app_routes.dart`
- `lib/app/routing/router.dart`
  Expanded the moderator workspace to better match the UML scope. Added
  dedicated `Moderate Comments` and `Manage Community Content` review screens,
  shared demo state for those moderation queues, live sidebar badges, new
  moderator routes, and a dashboard that now surfaces comments and community
  content alongside courses, reports, and FAQ.
- `lib/core/common_widgets/inline_markdown_text.dart`
- `lib/features/ai/presentation/pages/ai_mentor_page.dart`
- `lib/features/home/presentation/pages/community_course_player_page.dart`
- `lib/features/ai/data/datasources/ai_chat_remote_data_source.dart`
  Added shared inline markdown rendering for mentor replies so `**bold**`
  becomes emphasized text and `` `code` `` is shown with a code-style look.
  Updated the legacy frontend mentor prompt to encourage direct, human,
  no-greeting answers with clearer structure.
- `pubspec.yaml`
- `android/app/build.gradle.kts`
- `lib/core/notifications/local_notification_service.dart`
- `lib/core/common_widgets/app_settings_panel.dart`
- `lib/core/localization/app_localizations.dart`
- `lib/main.dart`
  Connected local device notifications through `flutter_local_notifications`,
  initialized the service at app startup, enabled Android desugaring for the
  plugin, and added a localized `Send test notification` action inside the
  settings panel. The test flow requests permissions when needed and shows a
  clear in-app result state for success, denied permission, unsupported
  platforms, or send failures.
- `test/widget_test.dart`
  Added smoke coverage for the new OOP node on the knowledge tree and the OOP
  midterm flow, including draft execution, submission, and comment posting.
  Also added coverage for sending a FAQ question into the moderator queue.
  Added smoke coverage for the new moderator comments and community sections.
  Added a formatting test for inline mentor markdown spans.

Verification for this pass:

- `flutter analyze`
- `flutter test`
