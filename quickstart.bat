@echo off
REM Quick Start Script for ETLab Attendance Tracker (Windows)

echo.
echo ==================================================
echo   ETLab Attendance Tracker - Quick Start
echo ==================================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found. Install from https://www.python.org/
    exit /b 1
)
echo [OK] Python found: %python_version%

REM Check Flutter
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter not found. Install from https://flutter.dev/
    exit /b 1
)
echo [OK] Flutter found

REM Check Chrome
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe" >nul 2>&1
if errorlevel 1 (
    echo WARNING: Chrome not detected. Required for backend scraper.
)
echo [OK] Chrome check skipped (can install later)

echo.
echo ==================================================
echo Setting up Backend...
echo ==================================================

if not exist venv (
    echo Creating Python virtual environment...
    python -m venv venv
)

echo Activating venv...
call venv\Scripts\activate.bat

echo Installing dependencies...
cd backend
pip install -r requirements.txt -q
cd ..

echo.
echo ==================================================
echo Setting up Frontend...
echo ==================================================

cd app
echo Getting Flutter packages...
flutter pub get -q
cd ..

echo.
echo ==================================================
echo Setup Complete! Next Steps:
echo ==================================================
echo.
echo 1. Start Backend Server:
echo    venv\Scripts\activate.bat
echo    cd backend
echo    python main.py
echo.
echo 2. In a new terminal, start Flutter:
echo    cd app
echo    flutter run
echo.
echo 3. For Android Device:
echo    - Find your PC IP: ipconfig
echo    - Enter in app settings: http://YOUR_IP:8000
echo.
echo See SETUP.md for detailed instructions.
echo.
pause
