# Sport Assistant Flutter

Это Flutter-версия приложения SportAssistant для планирования и отслеживания тренировок.

## Описание

Sport Assistant Flutter - это мобильное приложение для планирования и отслеживания тренировок. Оно позволяет пользователям создавать расписание тренировок на каждый день недели, добавлять упражнения с различными параметрами и отслеживать их выполнение.

## Функциональность

- Планирование тренировок на каждый день недели
- Добавление упражнений с различными параметрами (время, повторения, вес и т.д.)
- Отслеживание выполнения упражнений
- Настройка темы приложения (светлая, темная, системная)
- Сохранение данных между сеансами

## Архитектура

Приложение построено по архитектуре MVVM (Model-View-ViewModel):
- **Models**: Содержат структуры данных (Exercise, Day)
- **Views**: Пользовательский интерфейс (HomeView, ScheduleView, SettingsView и др.)
- **ViewModels**: Бизнес-логика (HomeViewModel, ScheduleViewModel и др.)
- **Utilities**: Вспомогательные классы (DataManager)

## Зависимости

- provider: ^6.0.5 - для управления состоянием
- shared_preferences: ^2.2.0 - для хранения данных
- uuid: ^3.0.7 - для генерации уникальных идентификаторов
- intl: ^0.18.1 - для работы с датами и форматированием
- cupertino_icons: ^1.0.5 - для иконок в стиле iOS

## Установка и запуск

1. Убедитесь, что у вас установлен Flutter SDK
2. Клонируйте репозиторий
3. Выполните команду `flutter pub get` для установки зависимостей
4. Запустите приложение командой `flutter run`

## Скриншоты

(Здесь будут скриншоты приложения после его запуска) 