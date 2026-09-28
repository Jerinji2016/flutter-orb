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

      // --- SCREEN 1: GEMINI NEON AURA ---
      final geminiChip = find.byKey(const ValueKey('preset_Gemini'));
      expect(geminiChip, findsOneWidget);
      await tester.tap(geminiChip);
      await tester.pump(const Duration(milliseconds: 1500));
      await binding.takeScreenshot('01_gemini_neon');

      // --- SCREEN 2: CYBERPUNK ELECTRIC PULSE ---
      final cyberpunkChip = find.byKey(const ValueKey('preset_Cyberpunk'));
      expect(cyberpunkChip, findsOneWidget);
      await tester.tap(cyberpunkChip);
      await tester.pump(const Duration(milliseconds: 1500));
      await binding.takeScreenshot('02_cyberpunk_pulse');

      // --- SCREEN 3: SOLAR FLARE DYNAMICS ---
      final solarChip = find.byKey(const ValueKey('preset_Solar Flare'));
      expect(solarChip, findsOneWidget);
      await tester.tap(solarChip);
      await tester.pump(const Duration(milliseconds: 1500));
      await binding.takeScreenshot('03_solar_flare');

      // --- SCREEN 4: EMERALD DEEP MINT ---
      final emeraldChip = find.byKey(const ValueKey('preset_Emerald'));
      expect(emeraldChip, findsOneWidget);
      await tester.tap(emeraldChip);
      await tester.pump(const Duration(milliseconds: 1500));
      await binding.takeScreenshot('04_emerald_deep');
      await binding.takeScreenshot('04_emerald_compact');

      // --- SCREEN 5: NEON ROSE HOT PINK ---
      final neonRoseChip = find.byKey(const ValueKey('preset_Neon Rose'));
      expect(neonRoseChip, findsOneWidget);
      await tester.tap(neonRoseChip);
      await tester.pump(const Duration(milliseconds: 1500));
      await binding.takeScreenshot('05_neon_rose');
      await binding.takeScreenshot('05_tuning_settings');

      // --- SCREEN 6: MONOCHROME MINIMALIST ---
      // Ensure Monochrome is in view by dragging ListView slightly if needed
      final monoChip = find.byKey(const ValueKey('preset_Monochrome'));
      if (monoChip.evaluate().isEmpty) {
        await tester.drag(find.byType(ListView), const Offset(-300, 0));
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(find.byKey(const ValueKey('preset_Monochrome')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('preset_Monochrome')));
      await tester.pump(const Duration(milliseconds: 1500));
      await binding.takeScreenshot('06_monochrome');

      // --- SCREEN 7: COMPACT ASSISTANT BUBBLE ---
      // Return to Emerald preset and toggle compact bubble view
      // Drag ListView back to start
      await tester.drag(find.byType(ListView), const Offset(300, 0));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byKey(const ValueKey('preset_Emerald')));
      await tester.pump(const Duration(milliseconds: 500));

      final compactBtn = find.byKey(const ValueKey('btn_compact'));
      expect(compactBtn, findsOneWidget);
      await tester.tap(compactBtn);
      await tester.pump(const Duration(milliseconds: 1500));
      await binding.takeScreenshot('07_compact_bubble');

      // Toggle back from compact to fullscreen
      await tester.tap(compactBtn);
      await tester.pump(const Duration(milliseconds: 800));

      // --- SCREEN 8: LIVE SHADER & AUDIO TUNING SHEET ---
      // Switch to Neon Rose and open the tuning sheet
      await tester.tap(find.byKey(const ValueKey('preset_Neon Rose')));
      await tester.pump(const Duration(milliseconds: 500));
      final settingsBtn = find.byKey(const ValueKey('btn_settings'));
      expect(settingsBtn, findsOneWidget);
      await tester.tap(settingsBtn);
      await tester.pump(const Duration(milliseconds: 1500));
      await binding.takeScreenshot('08_tuning_sheet');

      // Close settings sheet using its top close icon
      final closeBtn = find.byIcon(Icons.close);
      if (closeBtn.evaluate().isNotEmpty) {
        await tester.tap(closeBtn);
      }
      await tester.pump(const Duration(milliseconds: 800));

      // Restore error handler
      FlutterError.onError = originalOnError;
    });
  });
}
