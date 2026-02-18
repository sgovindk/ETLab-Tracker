# ETLab Attendance Tracker

A Flutter app for tracking attendance from **sctce.etlab.in**. Fetches your attendance data directly and displays it with useful stats like bunkable classes, projected percentages, and more.

## Features

- **Dashboard** — Overall attendance %, subjects below 75%, quick stats
- **Subjects** — Filter by all / low / safe, tap for detailed view
- **Calculator** — Target % → classes needed, or skip count → projected %
- **Timetable** — Editable weekly schedule
- **Secure login** — Credentials stored on-device with encryption
- **Pull-to-refresh** — Fetch latest data with a swipe

## Setup

```bash
cd app
flutter pub get
flutter run
```

## Build APK

```bash
cd app
flutter build apk --release
```

Output: `app/build/app/outputs/flutter-apk/app-release.apk`

## Project Structure

```
app/
├── lib/
│   ├── main.dart
│   ├── models/          — Data models
│   ├── providers/       — State management (Provider)
│   ├── screens/         — All screens
│   ├── services/        — ETLab scraper, storage, haptics
│   ├── theme/           — App theme
│   └── widgets/         — Reusable components
├── android/
├── pubspec.yaml
└── ...
```

## Troubleshooting

- **Invalid credentials** — Double-check your ETLab username and password
- **No data** — ETLab may have changed its page structure
- **Connection issues** — Check your internet connection
