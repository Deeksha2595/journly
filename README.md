# Journly

Journly is a Flutter journaling app that gives users a personal space to write journal entries, track their mood, keep notes about events, save favourite quotes, and use a simple drawing board for reflection.

## Features

* Email/password sign up, login, logout, and password reset
* Journal entries with editable titles, descriptions, and selectable colour gradients
* Mood tracking with history charts for 7 days, 30 days, or all time
* Calendar-based events with tags and filtering
* Favourite quotes
* Profile details and app settings
* Light and dark themes, with the selected theme saved locally
* Drawing board with pen, eraser, straight-line, colour selection, undo, redo, clear, and save-to-gallery actions
* Responsive Flutter UI with splash and onboarding screens

## Built With

| Category                 | Technologies                                                                                                           |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------- |
| Framework & Language     | [Flutter](https://flutter.dev/), Dart                                                                                  |
| Backend & Authentication | Firebase Core, Firebase Authentication, Cloud Firestore                                                                |
| Local Storage            | Shared Preferences                                                                                                     |
| Charts & Calendar        | Syncfusion Flutter Charts, Table Calendar                                                                              |
| UI & Animation           | Carousel Slider, Flutter Colorpicker, Animated Text Kit, Flutter Animate, Avatar Glow, Auto Size Text, Typewriter Text |
| Media & Gallery          | Saver Gallery                                                                                                          |


## Project Structure

```text
lib/
├── main.dart
├── models/          # Firestore data models
├── controllers/     # App-level state such as theme settings
├── pages/           # Authentication, dashboard, journal, mood, event, and utility screens
├── services/        # Firebase authentication service
└── widgets/         # Reusable UI components

assets/              # Images and other bundled app assets
android/, ios/, ...  # Flutter platform runners
```

## Requirements

* Flutter SDK with Dart 3.5.4 or newer
* A Firebase project
* Platform tooling for the target platform:

  * Android Studio and an Android SDK for Android
  * Xcode for iOS or macOS
  * The relevant Flutter desktop tooling for Windows or Linux

Check the local Flutter installation with:

```bash
flutter doctor
```

## Getting Started

1. Clone the repository and enter the project directory.

2. Install the Flutter dependencies:

```bash
flutter pub get
```

3. Configure Firebase as described below.

4. Start an emulator or connect a device.

5. Run the application:

```bash
flutter run
```

To choose a specific target:

```bash
flutter devices
flutter run -d <device-id>
```

## Firebase Configuration

Journly uses Firebase Authentication and Cloud Firestore for user authentication and data storage.

The Firebase configuration file is generated locally using the FlutterFire CLI and is not included in source control.

For a different Firebase project:

1. Create a Firebase project.
2. Register the platforms you intend to run.
3. Enable Email/Password sign-in under Firebase Authentication.
4. Create a Cloud Firestore database and configure appropriate security rules.
5. Install the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup).
6. Run `flutterfire configure` to generate the Firebase configuration for your project.

The app stores user-scoped data in Firestore for users, journals, mood entries, calendar events, and favourite quotes.

The Linux target is present in the Flutter project, but its current Firebase configuration does not support Linux. Additional Firebase configuration is required before running the application on Linux.

## Building

```bash
# Web
flutter build web

# Android APK
flutter build apk

# Windows
flutter build windows

# macOS
flutter build macos

# iOS (run on macOS with Xcode configured)
flutter build ios
```

The Android release configuration currently uses the debug signing configuration. Set up a proper release keystore and signing configuration before distributing an Android release build.

## Notes

* Authentication and user data features require an internet connection and a correctly configured Firebase project.
* Firestore security rules are not included in this repository; review and configure them before deploying the application.
* No license file is currently included.
