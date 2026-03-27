# Backend Logic Journal

Этот файл ведется как журнал всех задач, связанных с интеграцией Flutter frontend с backend.

Правило ведения:
- Каждая новая backend-задача добавляется отдельным блоком `Task N`.
- Внутри блока фиксируются: цель, что изучено на backend, что сделано во frontend, схема потока, затронутые файлы и результат проверки.
- Если есть blocker на стороне backend, он тоже записывается сюда, чтобы не терять контекст.

---

## Task 1. Real Auth Through Gateway

### Goal

Подключить во Flutter только реальные backend-сценарии:
- `register`
- `login`
- `me`
- `refresh`
- `logout`

И при этом:
- убрать моки из auth-страниц;
- перевести `GoRouter` на реальный auth state;
- оставить demo-состояние только как витрину локального UI и учебного прогресса.

### Backend studied

Изученные backend-файлы:
- `C:\Users\User\Desktop\zerde-study\docker-compose.yaml`
- `C:\Users\User\Desktop\zerde-study\auth-service\internal\http\router\router.go`
- `C:\Users\User\Desktop\zerde-study\auth-service\internal\http\dto\auth.go`
- `C:\Users\User\Desktop\zerde-study\auth-service\internal\http\handlers\auth.go`
- `C:\Users\User\Desktop\zerde-study\auth-service\internal\usecase\auth.go`
- `C:\Users\User\Desktop\zerde-study\auth-service\internal\service\jwt\manager.go`
- `C:\Users\User\Desktop\zerde-study\auth-service\internal\domain\validation.go`
- `C:\Users\User\Desktop\zerde-study\auth-service\internal\repo\postgres\user_repo.go`
- `C:\Users\User\Desktop\zerde-study\auth-service\internal\repo\postgres\refresh_repo.go`
- `C:\Users\User\Desktop\zerde-study\gateway\internal\usecase\gateway\service.go`
- `C:\Users\User\Desktop\zerde-study\gateway\internal\transport\http\router\router.go`
- `C:\Users\User\Desktop\zerde-study\gateway\internal\transport\http\middleware\auth.go`
- `C:\Users\User\Desktop\zerde-study\gateway\internal\infrastructure\proxy\reverse_proxy.go`

### Backend contract summary

Flutter должен ходить в gateway по префиксу:
- `/api/v1/auth/register`
- `/api/v1/auth/login`
- `/api/v1/auth/me`
- `/api/v1/auth/refresh`
- `/api/v1/auth/logout`

Формат запросов:
- `register/login`: `{ "email": "...", "password": "..." }`
- `refresh/logout`: `{ "refresh_token": "..." }`

Формат успешных auth-ответов:
- `register/login/refresh` возвращают `{ "accessToken": "...", "refreshToken": "..." }`
- `me` возвращает пользователя с `roles`, `is_active`, `created_at`

Важные backend-детали:
- `register/login` не возвращают профиль, поэтому после них нужно отдельно дергать `me`
- роли в backend: `student`, `teacher`, `manager`, `admin`
- `student` выдается по умолчанию при регистрации
- пароль валиден только при длине `8..72`
- ошибки приходят в формате `error.code` + `error.message`

### Frontend architecture introduced

Новая auth-цепочка во Flutter:

```text
LoginPage / SignUpPage
        |
        v
AuthController (Riverpod Notifier)
        |
        v
UseCases
        |
        v
AuthRepository (domain contract)
        |
        +--> AuthRemoteDataSource --> Gateway /api/v1/auth/*
        |
        +--> AuthLocalDataSource --> SharedPreferences
```

Отдельно добавлен bridge:

```text
AuthController state
        |
        v
authDemoBridgeProvider
        |
        v
DemoAppController.syncExternalAuth(...)
```

Зачем bridge нужен:
- реальный auth state теперь живет отдельно;
- старый demo-state не управляет аутентификацией;
- но demo-экраны все еще могут показывать email/role/display name пользователя, не переписывая весь проект целиком.

### Auth flow after this task

```text
App start
  -> AuthController.restoreSession()
     -> read local session
     -> try /api/v1/auth/me with access token
     -> if 401, try /api/v1/auth/refresh
     -> then /api/v1/auth/me
     -> update AuthState
     -> bridge syncs demo profile
     -> GoRouter redirects by real auth state
```

```text
Login / Register
  -> screen validates email/password
  -> AuthController.login/register
  -> backend returns tokens
  -> frontend calls /me
  -> session is stored locally
  -> router sees authenticated state
  -> redirect to /home or /moderator
```

```text
Logout
  -> AuthController.logout
  -> POST /api/v1/auth/logout with refresh_token
  -> local session cleared
  -> bridge clears demo profile
  -> router redirects to /welcome
```

### What was changed in Flutter

#### 1. Core config + network
- Добавлен `http` в `pubspec.yaml`
- Создан `lib/core/config/app_environment.dart`
- Создан `lib/core/network/api_exception.dart`
- Создан `lib/core/network/json_http_client.dart`

#### 2. Auth domain
- Создан `lib/features/auth/domain/entities/auth_role.dart`
- Создан `lib/features/auth/domain/entities/auth_user.dart`
- Создан `lib/features/auth/domain/entities/auth_session.dart`
- Создан `lib/features/auth/domain/repositories/auth_repository.dart`

#### 3. Auth data layer
- Создан `lib/features/auth/data/models/auth_tokens_dto.dart`
- Создан `lib/features/auth/data/models/auth_role_dto.dart`
- Создан `lib/features/auth/data/models/auth_user_dto.dart`
- Создан `lib/features/auth/data/models/stored_auth_session_dto.dart`
- Создан `lib/features/auth/data/datasources/auth_local_data_source.dart`
- Создан `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- Создан `lib/features/auth/data/repositories/auth_repository_impl.dart`

#### 4. Auth application layer
- Создан `lib/features/auth/application/usecases/login_with_email.dart`
- Создан `lib/features/auth/application/usecases/register_with_email.dart`
- Создан `lib/features/auth/application/usecases/restore_auth_session.dart`
- Создан `lib/features/auth/application/usecases/refresh_auth_session.dart`
- Создан `lib/features/auth/application/usecases/logout_current_session.dart`

#### 5. Auth presentation/state layer
- Создан `lib/features/auth/presentation/providers/auth_state.dart`
- Создан `lib/features/auth/presentation/providers/auth_controller.dart`

#### 6. App integration
- Создан `lib/app/state/auth_demo_bridge.dart`
- Обновлен `lib/app/state/demo_app_controller.dart`
- Обновлен `lib/main.dart`
- Обновлен `lib/app/routing/router.dart`

#### 7. UI screens without auth mocks
- Обновлен `lib/features/auth/presentation/pages/login_page.dart`
- Обновлен `lib/features/auth/presentation/pages/sign_up_page.dart`
- Обновлен `lib/features/auth/presentation/pages/welcome_page.dart`
- Обновлен `lib/features/auth/presentation/pages/forgot_password_page.dart`
- Обновлен `lib/features/auth/presentation/pages/forgot_password_code_page.dart`
- Обновлен `lib/features/profile/presentation/pages/profile_page.dart`
- Обновлен `lib/features/moderator/presentation/pages/moderator_shell_page.dart`

### Important decisions

1. Source of truth for auth
- Источник истины теперь `AuthController`, а не `demoAppController.isAuthenticated`

2. Local storage
- Сессия хранится в `SharedPreferences`, потому что этот проект уже использует его и он был доступен без дополнительной платформенной настройки
- При желании позже можно заменить local storage на `flutter_secure_storage`

3. Environment config
- По умолчанию frontend ожидает gateway на `http://localhost:8090`
- Для Android emulator default: `http://10.0.2.2:8090`
- Можно переопределить через `--dart-define=GATEWAY_BASE_URL=...`

4. Removed mocks
- Убраны mock social login действия
- Убран mock moderator login из welcome screen
- Mock auto-login из reset-code screen удален
- Forgot/reset экраны пока оставлены как честные заглушки до следующей backend-задачи

### Verification

Что проверено:
- `flutter pub get` — успешно
- `flutter analyze` — успешно, без issues

### Runtime verification blocker

Попытка проверить auth именно через gateway уперлась в backend blocker:

`gateway` контейнер не держится в `Up`, потому что ему не передаются обязательные JWT env vars.

Сводка из логов контейнера:
- `JWT_SECRET` not set
- `JWT_ISSUER` not set
- `JWT_AUDIENCE` not set
- `JWT_ACCESS_TTL` not set
- `JWT_REFRESH_TTL` not set

Что это значит practically:
- Flutter-код под gateway уже готов;
- но живой smoke-test через `http://localhost:8090` сейчас невозможен, пока backend gateway не получит эти переменные окружения.

### Post-integration fix

После первого запуска на Windows проявился Riverpod edge-case:
- bridge `auth -> demo` сначала был реализован как provider, который во время собственного build менял `demoAppController`
- Riverpod это запрещает: provider не должен модифицировать другой provider во время инициализации

Что было исправлено:
- синхронизация вынесена из provider-build
- теперь она запускается через `ref.listenManual(...)` в `MyApp` после первого кадра
- helper логика осталась в `lib/app/state/auth_demo_bridge.dart`, но как функция, а не как provider

Затронутые файлы hotfix:
- `lib/app/state/auth_demo_bridge.dart`
- `lib/main.dart`

Результат hotfix:
- ошибка инициализации Riverpod устранена
- `flutter analyze` снова проходит без issues

### What to do next

Следующая backend-задача может идти в одном из направлений:
- починить запуск gateway и сделать живой end-to-end auth smoke-test;
- подключить `forgot-password` и `reset-password`;
- начать подключать защищенные curriculum endpoints через bearer token;
- заменить `SharedPreferences` на защищенное хранилище токенов.

---

## Template For Next Tasks

Использовать такой шаблон ниже при следующих backend-работах:

```text
## Task N. Название задачи

### Goal
...

### Backend studied
...

### Frontend changes
...

### Flow / Scheme
...

### Files touched
...

### Verification
...

### Blockers / Notes
...
```
