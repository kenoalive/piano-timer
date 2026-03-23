# Piano Timer 🎹

A Flutter application for tracking piano practice time, with video recording, cloud sync, and statistics.

## Features

- ⏱️ Practice timer with start/pause/stop
- 📹 Video recording and upload (up to 9 videos per session)
- ☁️ Cloud sync (Tencent CloudBase)
- 📊 Practice statistics (weekly/monthly/yearly charts)
- 🔥 Practice heatmap
- 🎯 Daily goal tracking

## Screenshots

| Home | Timer | Videos | Statistics |
|------|-------|--------|------------|
| ![Home](screenshots/home.png) | ![Timer](screenshots/timer.png) | ![Videos](screenshots/videos.png) | ![Stats](screenshots/stats.png) |

## Tech Stack

- **Framework**: Flutter 3.4+
- **Language**: Dart
- **State Management**: flutter_bloc
- **Local Database**: sqflite + shared_preferences
- **Cloud**: Tencent CloudBase
- **Video**: video_player + chewie
- **Charts**: fl_chart

## Getting Started

### Prerequisites

- Flutter 3.4+
- Android SDK / Xcode (for iOS)
- Tencent CloudBase account

### Installation

```bash
# Clone the repository
git clone https://github.com/kenoalive/piano-timer.git
cd piano-timer

# Get dependencies
flutter pub get

# Run
flutter run
```

### Configuration

1. Create a Tencent CloudBase environment
2. Update `lib/services/cloud_service.dart` with your configuration:
   ```dart
   static const String _envId = 'your-env-id';
   ```

## Project Structure

```
lib/
├── blocs/          # BLoC state management
├── models/         # Data models
├── screens/        # UI screens
├── services/       # Cloud & database services
├── utils/          # Utilities
└── widgets/        # Reusable widgets
```

## License

MIT License
