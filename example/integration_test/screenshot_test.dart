import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voice_orb_example/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Set the frame policy to fullyLive to run particle and shader animations smoothly at 60fps
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('Particle Orb In-App Flutter Screenshot Generator', () {
    testWidgets('Capture all 3D particle orb preset & feature screen states',
        (WidgetTester tester) async {
      // 1. Ignore benign layout overflow errors during screenshot runs
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exceptionAsString().contains('overflowed')) {
          debugPrint(
              'Ignored layout overflow error: ${details.exceptionAsString()}');
          return;
        }
        originalOnError?.call(details);
      };

      // 2. Start the example application
      app.main();

      // Wait 2.0 seconds for initial particle mesh compilation, shader uniforms, and simulation to start
      await tester.pump(const Duration(milliseconds: 2000));

      // Convert Android surface to image reader for takeScreenshot support
      await binding.convertFlutterSurfaceToImage();
      await tester.pump(const Duration(milliseconds: 500));

      // Helper function to reliably find and scroll to any preset chip horizontally
      Future<void> selectPreset(String name) async {
        final chipKey = ValueKey('preset_$name');
        final chipFinder = find.byKey(chipKey);
        final listFinder = find.byType(Scrollable).first;

        // Try scrolling right to find chip
        for (int step = 0; step < 8; step++) {
          if (chipFinder.evaluate().isNotEmpty) break;
          await tester.drag(listFinder, const Offset(-150, 0));
          await tester.pump(const Duration(milliseconds: 250));
        }

        // If not found, try scrolling back left
        if (chipFinder.evaluate().isEmpty) {
          for (int step = 0; step < 8; step++) {
            if (chipFinder.evaluate().isNotEmpty) break;
            await tester.drag(listFinder, const Offset(150, 0));
            await tester.pump(const Duration(milliseconds: 250));
          }
        }

        expect(chipFinder, findsOneWidget);
        await tester.tap(chipFinder);
        await tester.pump(const Duration(milliseconds: 1500));
      }

      // --- SCREEN 1: GEMINI NEON AURA ---
      await selectPreset('Gemini');
      await binding.takeScreenshot('01_gemini_neon');

      // --- SCREEN 2: CYBERPUNK ELECTRIC PULSE ---
      await selectPreset('Cyberpunk');
      await binding.takeScreenshot('02_cyberpunk_pulse');

      // --- SCREEN 3: SOLAR FLARE DYNAMICS ---
      await selectPreset('Solar Flare');
      await binding.takeScreenshot('03_solar_flare');

      // --- SCREEN 4: EMERALD DEEP MINT ---
      await selectPreset('Emerald');
      await binding.takeScreenshot('04_emerald_deep');
      await binding.takeScreenshot('04_emerald_compact');

      // --- SCREEN 5: NEON ROSE HOT PINK ---
      await selectPreset('Neon Rose');
      await binding.takeScreenshot('05_neon_rose');
      await binding.takeScreenshot('05_tuning_settings');

      // --- SCREEN 6: MONOCHROME MINIMALIST ---
      await selectPreset('Monochrome');
      await binding.takeScreenshot('06_monochrome');

      // --- SCREEN 7: COMPACT ASSISTANT BUBBLE ---
      await selectPreset('Emerald');
      final compactBtn = find.byKey(const ValueKey('btn_compact'));
      expect(compactBtn, findsOneWidget);
      await tester.tap(compactBtn);
      await tester.pump(const Duration(milliseconds: 1500));
      await binding.takeScreenshot('07_compact_bubble');

      // Toggle back from compact to fullscreen
      await tester.tap(compactBtn);
      await tester.pump(const Duration(milliseconds: 800));

      // --- SCREEN 8: LIVE SHADER & AUDIO TUNING SHEET ---
      await selectPreset('Neon Rose');
      final settingsBtn = find.byKey(const ValueKey('btn_settings'));
      expect(settingsBtn, findsOneWidget);
      await tester.tap(settingsBtn);
      await tester.pump(const Duration(milliseconds: 1500));
      await binding.takeScreenshot('08_tuning_sheet');

      // Close settings sheet
      await tester.tap(settingsBtn);
      await tester.pump(const Duration(milliseconds: 800));

      // Restore error handler
      FlutterError.onError = originalOnError;
    });
  });
}
