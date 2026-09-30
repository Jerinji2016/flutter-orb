import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voice_orb_example/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('Multi-Shader Visualizer Screenshot Generator', () {
    testWidgets('Capture all 5 visualizer widgets and presets',
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

      // Wait 2.0 seconds for initial compilation and simulation start
      await tester.pump(const Duration(milliseconds: 2000));

      // Convert Android surface to image reader for takeScreenshot support
      await binding.convertFlutterSurfaceToImage();
      await tester.pump(const Duration(milliseconds: 500));

      // Helper to select visualizer mode
      Future<void> selectMode(String modeTitle) async {
        final modeFinder = find.text(modeTitle);
        expect(modeFinder, findsOneWidget);
        await tester.tap(modeFinder);
        await tester.pump(const Duration(milliseconds: 1000));
      }

      // Helper function to reliably find and scroll to any preset chip horizontally
      Future<void> selectPreset(String name) async {
        final chipKey = ValueKey('preset_$name');
        final chipFinder = find.byKey(chipKey);

        // If not immediately visible, scroll horizontal list
        if (chipFinder.evaluate().isEmpty) {
          final listFinders = find.byType(ListView);
          if (listFinders.evaluate().isNotEmpty) {
            final listFinder = listFinders.last;
            for (int step = 0; step < 6; step++) {
              if (chipFinder.evaluate().isNotEmpty) break;
              await tester.drag(listFinder, const Offset(-120, 0));
              await tester.pump(const Duration(milliseconds: 200));
            }
          }
        }

        expect(chipFinder, findsOneWidget);
        await tester.tap(chipFinder);
        await tester.pump(const Duration(milliseconds: 1200));
      }

      // --- 1. PARTICLE SPHERE (Gemini) ---
      await selectMode('Particle Sphere');
      await selectPreset('Gemini');
      await binding.takeScreenshot('01_particle_gemini');

      // --- 2. LIQUID METABALLS (Mercury & Lava) ---
      await selectMode('Liquid Blob');
      await selectPreset('Mercury');
      await binding.takeScreenshot('02_liquid_mercury');

      await selectPreset('Lava');
      await binding.takeScreenshot('03_liquid_lava');

      // --- 3. SPIRAL GALAXY (Andromeda & Supernova) ---
      await selectMode('Spiral Galaxy');
      await selectPreset('Andromeda');
      await binding.takeScreenshot('04_galaxy_andromeda');

      await selectPreset('Supernova');
      await binding.takeScreenshot('05_galaxy_supernova');

      // --- 4. HOLOGRAPHIC WIREFRAME (Hologram & Matrix) ---
      await selectMode('Wireframe Holo');
      await selectPreset('Hologram');
      await binding.takeScreenshot('06_wireframe_hologram');

      await selectPreset('Matrix');
      await binding.takeScreenshot('07_wireframe_matrix');

      // --- 5. AUDIO SPECTRUM EQUALIZER (Neon & Sunset) ---
      await selectMode('Audio Spectrum');
      await selectPreset('Neon Equalizer');
      await binding.takeScreenshot('08_spectrum_neon');

      await selectPreset('Sunset Echo');
      await binding.takeScreenshot('09_spectrum_sunset');

      // --- 6. LIVE SHADER & AUDIO TUNING PANEL ---
      await selectMode('Wireframe Holo');
      await selectPreset('Hologram');
      final settingsBtn = find.byKey(const ValueKey('btn_settings'));
      expect(settingsBtn, findsOneWidget);
      await tester.tap(settingsBtn);
      await tester.pump(const Duration(milliseconds: 1200));
      await binding.takeScreenshot('10_tuning_panel');

      // Close settings sheet/drawer
      await tester.tap(settingsBtn);
      await tester.pump(const Duration(milliseconds: 600));

      // --- 7. 2.5D WAVE MESH (Oceanic Blue) ---
      await selectMode('Wave Mesh 2.5D');
      await selectPreset('Oceanic Blue');
      await binding.takeScreenshot('11_wave_mesh_oceanic');

      // --- 8. 2D DYNAMIC CONSTELLATION (Neural Synapse) ---
      await selectMode('Constellation 2D');
      await selectPreset('Neural Synapse');
      await binding.takeScreenshot('12_constellation_neural');

      // --- 9. APPLE SIRI CHROMATIC GLOW (Apple Classic) ---
      await selectMode('Siri Glow');
      await selectPreset('Apple Classic');
      await binding.takeScreenshot('13_siri_glow_apple');

      // --- 10. QUANTUM FLARE 3D ORB (Quantum Blue) ---
      await selectMode('Quantum Flare');
      await selectPreset('Quantum Blue');
      await binding.takeScreenshot('14_flare_quantum_blue');

      FlutterError.onError = originalOnError;
    });
  });
}
