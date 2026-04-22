# ZerdeStudy Frontend

`frontend_flutter` - это Flutter frontend для **ZerdeStudy**, MVP образовательной платформы в рамках дипломного проекта. Репозиторий содержит многоплатформенное клиентское приложение с учебными сценариями для студентов, каталогом курсов, AI-ассистентом, community-разделом и отдельными интерфейсами для преподавателя и модератора.

Проект сочетает demo-контент и реальные интеграции:

- email/password авторизация работает через backend gateway;
- каталог курсов может дополняться живыми курсами из backend;
- AI mentor работает через отдельный AI service;
- часть учебного контента и прогресса пользователя пока хранится локально для demo и презентационных сценариев.

## Что Есть В Проекте

Основные разделы приложения:

- welcome и auth flow;
- knowledge tree и learning tracks;
- уроки, практика и assessments;
- каталог курсов, страница курса и course player;
- AI mentor;
- community и учебные группы;
- профиль, достижения, статистика и leaderboard;
- teacher workspace;
- moderator workspace.

Дополнительно:

- локализация: `RU`, `EN`, `KK`;
- адаптивный UI для web и desktop;
- локальное хранение части состояния через `SharedPreferences`;
- стандартные Flutter-платформы: `web`, `windows`, `macos`, `linux`, `android`, `ios`.

## Технологии

- `Flutter`
- `Dart 3.9+`
- `flutter_riverpod`
- `go_router`
- `http`
- `shared_preferences`
- `window_manager`
- `flutter_local_notifications`
- `file_picker`
- `image`

## Структура Репозитория

- `lib/app` - инициализация приложения, роутинг, глобальное состояние.
- `lib/core` - общая инфраструктура: тема, локализация, общие виджеты, network helpers, platform utilities.
- `lib/features` - продуктовые модули по фичам и экранам.
- `test` - widget-тесты и integration-style проверки основных сценариев.
- `tooling` - вспомогательные скрипты для mockups и скриншотов.
- `output` - сгенерированные скриншоты и артефакты визуальных проверок.
- `android`, `ios`, `web`, `windows`, `linux`, `macos` - платформенные runner'ы Flutter.

Если нужно быстро войти в проект, начните с этих точек:

1. `lib/main.dart`
2. `lib/app/routing/router.dart`
3. `lib/features/*`

## Требования

Перед запуском убедитесь, что у вас есть:

- Flutter SDK с Dart `3.9` или новее;
- настроенная целевая платформа, например `Chrome`, `Windows` или Android emulator;
- корректный результат `flutter doctor` для нужной платформы.

Для полного runtime-сценария также нужны внешние сервисы:

- gateway backend для auth и backend course endpoints;
- AI service для ответов ментора.

## Быстрый Старт

Установить зависимости:

```bash
flutter pub get
```

Проверить проект:

```bash
flutter analyze
flutter test
```

Запустить в браузере:

```bash
flutter run -d chrome
```

Запустить на Windows:

```bash
flutter run -d windows
```

Собрать production artifacts:

```bash
flutter build web
flutter build windows
```

## Конфигурация Окружения

Приложение можно поднять и без явных переменных окружения, но функции, завязанные на API, будут полноценно работать только при доступных внешних сервисах.

Поддерживаемые `dart-define`:

- `GATEWAY_BASE_URL`
- `AI_SERVICE_BASE_URL`
- `AI_SERVICE_AUTH_TOKEN`

Значения по умолчанию:

- `GATEWAY_BASE_URL`: `http://localhost:8090`
- `AI_SERVICE_BASE_URL`: `http://localhost:8088`
- special case для Android emulator gateway: `http://10.0.2.2:8090`
- `AI_SERVICE_AUTH_TOKEN`: опционально

Пример запуска с явной конфигурацией:

```bash
flutter run -d chrome --dart-define=GATEWAY_BASE_URL=http://localhost:8090 --dart-define=AI_SERVICE_BASE_URL=http://localhost:8088
```

## Как Проект Ведет Себя В Разработке

- Email/password login, registration, session restore, password reset и `me` используют backend gateway.
- Social login-кнопки на экране входа создают mock session и удобны для быстрого прохода по UI.
- Часть каталога - это локальный demo-контент, а backend-курсы подмешиваются сверху при наличии авторизованного пользователя и доступного API.
- Demo state и часть пользовательского прогресса сохраняются локально через `SharedPreferences`.
- Если backend недоступен, интерфейс приложения все равно может открываться, но API-dependent сценарии могут не работать или показывать пустые состояния.

## Полезные Команды

```bash
flutter pub get
flutter analyze
flutter test
flutter test test/widget_test.dart
flutter test test/backend_courses_test.dart
flutter run -d chrome
flutter run -d windows
flutter build web
flutter build windows
```

## Тестирование

Текущий набор тестов покрывает основные пользовательские сценарии:

- auth и навигацию;
- learning screens и assessments;
- профиль и локальное сохранение прогресса;
- границы интеграции AI mentor;
- community и moderator screens;
- адаптацию backend courses и фильтрацию каталога.

## Что Важно Понимать

- Репозиторий содержит и продуктовый код, и demo/presentation-поддержку.
- Teacher и moderator части уже представлены во frontend и имеют отдельные маршруты.
- Admin experience пока не оформлен как полноценный отдельный workspace.
- Папка `output/` содержит не исходный код, а скриншоты и результаты визуальных проверок.

## Зачем Этот README

Этот README специально сфокусирован на developer onboarding:

- что это за проект;
- как его установить и запустить;
- где искать основные части кода;
- какие разделы зависят от внешних сервисов.

Подробную бизнес-логику и разбор экранов лучше держать в коде и технических заметках, а не в README.
