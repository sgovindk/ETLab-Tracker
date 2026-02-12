# ETLab Attendance Tracker

Industrial-grade Flutter + Python attendance tracking app for **sctce.etlab.in**.

## Architecture

```
attendance/
├── backend/               ← Python FastAPI server (Selenium scraper)
│   ├── main.py            ← API entry-point (run this)
│   ├── scraper.py         ← Headless Chrome ETLab scraper
│   └── requirements.txt
├── app/                   ← Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── theme/         ← Dark industrial theme
│   │   ├── models/        ← Data models
│   │   ├── services/      ← API, storage, haptics, timetable
│   │   ├── providers/     ← State management (Provider)
│   │   ├── screens/       ← All app screens
│   │   └── widgets/       ← Reusable UI components
│   ├── pubspec.yaml
│   └── android/
└── venv/                  ← Python virtual environment
```

## Quick Start

### 1. Start the Python Backend

```bash
cd backend
# Activate your venv first, then:
python main.py
```

The server starts on `http://0.0.0.0:8000`. It uses headless Chrome + Selenium to scrape ETLab.

> **Requires**: Google Chrome installed on the machine running the backend.

### 2. Run the Flutter App

```bash
cd app
flutter pub get
flutter run
```

### 3. Connect App → Backend

- On **Android Emulator**: The default URL `http://10.0.2.2:8000` should work (it maps to host's localhost).
- On **Physical Device**: Find your PC's local IP (e.g. `192.168.1.x`) and enter `http://192.168.1.x:8000` in the login screen's "Server settings".

## Features

| Feature | Description |
|---------|-------------|
| **Dashboard** | Overall attendance %, next class, subjects below 75% |
| **Subjects** | Filter by all / low / safe; tap for details |
| **Calculator** | Target % → classes needed, or classes → projected % |
| **Timetable** | Weekly schedule with day tabs; fully editable |
| **Auto-login** | Credentials stored securely on-device (AES-encrypted) |
| **Haptic feedback** | Light/medium/heavy taps on every interaction |
| **Pull-to-refresh** | Re-scrape from ETLab with a swipe down |

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/fetch` | Login + scrape + close (one-shot) |
| `POST` | `/api/login` | Login and keep session alive |
| `GET`  | `/api/attendance` | Scrape from active session |
| `GET`  | `/health` | Health check |

## Troubleshooting

- **"Connection failed"**: Make sure the Python backend is running and reachable from the device.
- **Scraping fails**: ETLab may have changed its HTML structure. Check `scraper.py` and update CSS selectors.
- **Chrome not found**: Install Google Chrome on the backend machine. The `webdriver-manager` package auto-downloads ChromeDriver.
