# Flutter Orb Example (`voice_orb_example`)

Interactive demo application showcasing the `flutter_orb` 3D audio-reactive wave particle sphere visualizer.

---

## 🚀 Running the Example

```bash
flutter run
```

---

## 📸 Automated Screenshot Generator

To generate the showcase screenshots in `doc/screenshots/` using Flutter's native integration test framework:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshot_test.dart
```

This runs the in-app automated tour, captures each 3D particle sphere preset & feature state at 60 FPS in real-time, and saves crisp PNG screenshots directly into `doc/screenshots/`.
