# Setup Guide

This project requires both Python and Flutter to be installed on your system.

## Prerequisites

### Python 3.8+
- Download from [python.org](https://www.python.org/)
- Ensure `python` is in your PATH

### Flutter SDK
- Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
- Ensure `flutter` is in your PATH
- Run `flutter doctor` to verify setup

### Google Chrome
- Required on the backend machine for Selenium scraping
- Download from [google.com/chrome](https://www.google.com/chrome/)

## Installation

### 1. Clone and Setup Backend

```bash
# Create Python virtual environment
python -m venv venv

# Activate it
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
cd backend
pip install -r requirements.txt

# Run the server
python main.py
```

Server will start at `http://127.0.0.1:8000`

### 2. Setup Flutter App

```bash
cd app
flutter pub get
flutter run
```

## Running on Android Device

1. **Connect to Backend**:
   - Find your PC's IP: `ipconfig` (look for IPv4 Address)
   - In app Settings, enter: `http://YOUR_PC_IP:8000`

2. **Build APK** (for distribution):
   ```bash
   cd app
   flutter build apk --release
   ```
   APK will be at: `app/build/app/outputs/flutter-apk/app-release.apk`

3. **Install on Device**:
   ```bash
   adb install app/build/app/outputs/flutter-apk/app-release.apk
   ```

## Architecture

- **Frontend**: Flutter (Dart) with Provider state management
- **Backend**: FastAPI (Python) with Selenium web scraping
- **Features**: Auto-login, attendance calculation, timetable management, haptic feedback

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Chrome not found | Install Google Chrome on backend machine |
| Connection refused | Ensure backend is running, check firewall, verify IP address |
| ETLab page changed | Update CSS selectors in `backend/scraper.py` |
| venv activation fails | Delete venv/ folder and recreate: `python -m venv venv` |

## For Developers

Key files to modify:

- `backend/scraper.py` - ETLab scraping logic
- `backend/main.py` - FastAPI endpoints
- `app/lib/main.dart` - App entry point
- `app/lib/services/api_service.dart` - Backend communication
- `app/lib/screens/` - All screen implementations

