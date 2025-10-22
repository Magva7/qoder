# Alarm App

A Flutter application for managing tasks with alarm reminders that integrate with the Android system alarm clock.

## Features

- Two-column task management ("Дома" and "На улице")
- Add tasks with optional alarm reminders
- Date/time picker for setting reminders
- Integration with Android's native alarm system
- Clean, responsive UI

## Getting Started

This project is a Flutter application that demonstrates how to set alarms using Android's native alarm system.

### Prerequisites

- Flutter 3.32.8 or higher
- Android SDK
- Android NDK version 27.0.12077973 (required for android_intent_plus)

### Dependencies

All dependencies are listed in [project_dependencies.txt](project_dependencies.txt) and defined in [pubspec.yaml](pubspec.yaml).

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Connect an Android device or start an Android emulator
4. Run `flutter run` to start the application

### Building APK

To build an APK for distribution:
```bash
flutter build apk
```

The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## Usage

1. Tap the "+" button to add a new task
2. Enter the task name
3. Select the location ("Дома" or "На улице")
4. Optionally set a reminder by tapping the edit icon and selecting date/time
5. Tasks will appear in their respective columns
6. Tap the delete icon to remove tasks

## Integration with Android Alarms

This app uses the `android_intent_plus` package to integrate with Android's native alarm system. When you set a reminder:
- The task name becomes the alarm name
- The selected date/time becomes the alarm time
- The alarm is added to the system's Clock app
- Alarms persist even when the app is closed

## Project Structure

- `lib/main.dart` - Main application code
- `android/` - Android-specific configuration
- `pubspec.yaml` - Project dependencies
- `project_dependencies.txt` - Detailed dependency information
- `.gitignore` - Files and directories to ignore in version control