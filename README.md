# Voxy — Smart Proxy & Mixed VPN Client

**Voxy** — современный кроссплатформенный клиент для Android и iOS, объединяющий гибкость современных прокси-протоколов (VLESS, VMess, Shadowsocks, Reality) и надёжность VPN-туннелирования (TUN/WireGuard).

## Стек технологий
* **UI & Core Framework:** Flutter (Dart, без Expo)
* **Платформы:** Android & iOS (единая дизайн-система, Dark UI, адаптивность)
* **Архитектура:** Нативный TUN/Proxy провайдер с общими правилами маршрутизации

## GitHub Actions CI/CD (Manual Triggers Only)

Все воркфлоу настроены со строгим триггером `workflow_dispatch` (ручной запуск по кнопке **Run workflow**, без автоматического срабатывания на push/PR, по аналогии со сборками AyuGram-iOS):

1. **[Check & Test](.github/workflows/test_and_check.yml)**:
   * Проверка форматирования кода (`dart format`).
   * Статический анализ и линтинг (`flutter analyze`).
   * Запуск юнит- и виджет-тестов с покрытием (`flutter test`).
2. **[Build Android](.github/workflows/build_android.yml)**:
   * Ручной выбор: `apk`, `appbundle` (AAB) или оба сразу.
   * Выбор режима: `release` / `debug`.
   * Сохранение артефактов в GitHub Actions Artifacts.
3. **[Build iOS](.github/workflows/build_ios.yml)**:
   * Сборка на macOS-раннерах (`--no-codesign`).
   * Упаковка приложения в `.ipa` (unsigned Payload zip), готовый к установке через AltStore, SideStore, Sideloadly, TrollStore, LiveContainer или ESign.
4. **[Build All (Parallel)](.github/workflows/build_all.yml)**:
   * Параллельный одновременный запуск сборки для Android и iOS.

## Как запустить сборку в GitHub:
1. Перейдите во вкладку **Actions** в репозитории `voxy`.
2. В левой панели выберите нужный воркфлоу (например, *Build Android*, *Build iOS* или *Build All*).
3. Нажмите кнопку **Run workflow**, выберите параметры сборки и нажмите зеленую кнопку запуска.
4. После завершения скачайте готовые `.apk` или `.ipa` из блока **Artifacts**.
