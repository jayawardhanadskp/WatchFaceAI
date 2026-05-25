# WatchFace AI

An AI-powered Wear OS watch face builder. Describe a watch face in plain English on your phone — Gemini 1.5 Flash generates a live design that renders on your Wear OS watch.

## Features

- **AI generation** — Gemini 1.5 Flash turns any text prompt into a complete watch face design
- **3 variants** — Each generation produces 3 variants to choose from
- **Live preview** — Real-time CustomPainter preview on both phone and watch
- **Style chips** — Minimal, Bold, Neon, Classic presets to guide the AI
- **Wear OS rendering** — Steps arc, battery indicator, date, configurable border and font weight
- **Ambient mode** — Simplified rendering in Wear OS ambient mode to save battery

---

## Setup

### 1. Prerequisites

- Flutter 3.x with Dart 3+
- Android Studio with Wear OS emulator support
- A Gemini API key from [Google AI Studio](https://aistudio.google.com)

### 2. Clone & install dependencies

```bash
git clone <repo-url>
cd watchface_ai
flutter pub get
```

### 3. Add your Gemini API key

Open `lib/services/gemini_service.dart` and replace the placeholder:

```dart
// Replace with your Gemini API key from https://aistudio.google.com
const _apiKey = 'YOUR_GEMINI_API_KEY';
```

---

## Running the apps

### Phone app

```bash
flutter run -t lib/main.dart
```

### Wear OS watch face

First, find your Wear OS emulator device ID:

```bash
flutter devices
```

Then run the watch app on it:

```bash
flutter run -t lib/main_watch.dart -d <wear_os_device_id>
```
 
Example:
```bash
flutter run -t lib/main_watch.dart -d emulator-5556
```

---

## How to get a Gemini API key

1. Go to [https://aistudio.google.com](https://aistudio.google.com)
2. Sign in with your Google account
3. Click **Get API key** → **Create API key**
4. Copy the key and paste it into `lib/services/gemini_service.dart`

The app uses **Gemini 1.5 Flash** which is fast and available on the free tier.

---

## Creating a Wear OS emulator in Android Studio

1. Open **Android Studio** → **Device Manager** (`Tools > Device Manager`)
2. Click **Create Device**
3. Select the **Wear OS** category
4. Choose a hardware profile (e.g., **Wear OS Round**)
5. Click **Next** → select a system image:
   - **API Level 30** — Wear OS 3.0 ✓
   - Download it if not already present
6. Click **Next** → name it (e.g., `Wear_API30`) → **Finish**
7. Start the emulator and note the device ID shown in `flutter devices`

---

## Project structure

```
lib/
├── main.dart                    # Phone app entry point
├── main_watch.dart              # Wear OS watch face entry point
├── models/
│   └── watch_face_config.dart   # Data model + SharedPreferences persistence
├── services/
│   └── gemini_service.dart      # Gemini 1.5 Flash API client
├── providers/
│   └── watch_face_provider.dart # Riverpod state management
├── widgets/
│   ├── watch_face_painter.dart  # CustomPainter (shared phone + watch)
│   └── watch_preview_widget.dart # Animated preview widget
└── screens/
    ├── home_screen.dart          # Prompt input + live preview
    ├── generating_screen.dart    # Animated loading screen
    └── result_screen.dart        # Variant picker + apply button
```

---

## How phone → watch sync works

When you tap **Apply to Watch**, the selected `WatchFaceConfig` is serialised to JSON and saved to `SharedPreferences` under the key `watchface_config`.

The Wear OS app polls `SharedPreferences` every **2 seconds** and repaints when the config changes. In a production app you would replace this with the [Wearable Data Layer API](https://developer.android.com/training/wearables/data/data-items) for reliable, push-based syncing between paired devices.

---

## Tech stack

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.0.0 | State management |
| `flutter_animate` | ^4.0.0 | UI animations |
| `wear` | ^1.0.0 | Wear OS `WatchShape` & `AmbientMode` |
| `http` | ^1.0.0 | Gemini REST API calls |
| `shared_preferences` | ^2.0.0 | Phone ↔ watch config sync |
