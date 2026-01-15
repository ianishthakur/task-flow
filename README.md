# TaskFlow Premium 🚀

A beautiful, modern Flutter task management app built with **Clean Architecture**, **BLoC** state management, **sqflite** for local database storage, and **SharedPreferences** for settings persistence.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- 📝 **Task Management** - Create, update, delete, and toggle tasks
- 🏷️ **Categories** - Organize tasks by Personal, Work, Health, Shopping
- ⚡ **Priority Levels** - Low, Medium, High priority support
- 📅 **Due Dates** - Set and track task deadlines
- 🌙 **Dark Mode** - Beautiful light and dark themes
- 📊 **Progress Stats** - Visual completion statistics
- 🔔 **Notifications** - Toggle notification preferences
- 💾 **Offline First** - All data stored locally

## 🏗️ Architecture

This project follows **Clean Architecture** principles with a clear separation of concerns:

```
lib/
├── core/
│   ├── database/       # SQLite database helper
│   ├── di/             # Dependency injection (GetIt)
│   ├── error/          # Failures and exceptions
│   ├── theme/          # App theming
│   └── usecases/       # Base use case interface
│
├── features/
│   ├── tasks/
│   │   ├── data/
│   │   │   ├── datasources/    # Local data sources
│   │   │   ├── models/         # Data models
│   │   │   └── repositories/   # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/       # Business entities
│   │   │   ├── repositories/   # Repository interfaces
│   │   │   └── usecases/       # Use cases
│   │   └── presentation/
│   │       ├── bloc/           # BLoC state management
│   │       ├── pages/          # Screen widgets
│   │       └── widgets/        # Reusable UI components
│   │
│   └── settings/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
```

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management |
| `equatable` | Value equality |
| `sqflite` | SQLite local database |
| `shared_preferences` | Key-value storage |
| `get_it` | Dependency injection |
| `dartz` | Functional programming (Either) |
| `flutter_animate` | Smooth animations |
| `google_fonts` | Custom typography |
| `iconsax` | Beautiful icons |
| `uuid` | Unique ID generation |
| `intl` | Date formatting |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK >= 3.2.0
- Dart >= 3.2.0

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/taskflow_premium.git
cd taskflow_premium
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 🎨 Design System

### Colors

The app uses a carefully crafted color palette:

- **Primary**: Indigo (#6366F1)
- **Accent**: Pink (#EC4899)
- **Success**: Emerald (#34D399)
- **Warning**: Amber (#FBBF24)
- **Error**: Coral (#FF6B6B)

### Typography

Using **Plus Jakarta Sans** font family for a modern, premium feel.

### Components

- Glassmorphism cards
- Gradient buttons
- Smooth micro-interactions
- Custom animated switches
- Dismissible task cards

## 📱 Screenshots

| Home (Light) | Home (Dark) | Add Task | Settings |
|--------------|-------------|----------|----------|
| [Screenshot] | [Screenshot]| [Screenshot] | [Screenshot] |

## 🔧 Configuration

### Database Schema

```sql
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  priority INTEGER NOT NULL DEFAULT 0,
  is_completed INTEGER NOT NULL DEFAULT 0,
  due_date TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  color TEXT NOT NULL,
  icon TEXT,
  created_at TEXT NOT NULL
);
```

### SharedPreferences Keys

- `is_dark_mode` - Dark mode toggle
- `notifications_enabled` - Notifications toggle
- `default_category` - Default task category
- `show_completed_tasks` - Show/hide completed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📧 Contact

Your Name - [@yourtwitter](https://twitter.com/yourtwitter)

Project Link: [https://github.com/yourusername/taskflow_premium](https://github.com/yourusername/taskflow_premium)

---

Made with ❤️ and Flutter
