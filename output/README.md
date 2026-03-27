# UX/UI Mockups

Готовые материалы для дипломного проекта лежат в двух папках:

- `raw/` — исходные скриншоты приложения в desktop и mobile viewport.
- `final/` — готовые mockup-композиции для вставки в диплом.

Основные файлы в `final/`:

- `responsive-home-showcase.png` — общий адаптивный mockup для компьютера и телефона.
- `desktop-home-mockup.png` — домашний экран в mockup ноутбука.
- `desktop-tree-mockup.png` — экран дерева знаний в mockup ноутбука.
- `desktop-learn-mockup.png` — каталог обучения в mockup ноутбука.
- `desktop-ai-mockup.png` — AI mentor в mockup ноутбука.
- `desktop-profile-mockup.png` — профиль пользователя в mockup ноутбука.
- `mobile-home-mockup.png` — домашний экран в mockup телефона.
- `mobile-tree-mockup.png` — дерево знаний в mockup телефона.
- `mobile-learn-mockup.png` — каталог обучения в mockup телефона.
- `mobile-ai-mockup.png` — AI mentor в mockup телефона.
- `mobile-profile-mockup.png` — профиль пользователя в mockup телефона.

Если нужно пересобрать материалы заново:

1. `flutter build web --release`
2. Поднять локальный сервер на `build/web`
3. Запустить `python tooling/mockups/capture_web_mockups.py`
4. Запустить `python tooling/mockups/compose_mockups.py`
