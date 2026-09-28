import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_orb/flutter_orb.dart';
import 'package:flutter/material.dart';

void main() {
  group('VoiceOrbController', () {
    test('normalizeDb scales decibels correctly to [0.0, 1.0]', () {
      const minDb = -55.0;
      const maxDb = -5.0;
      const power = 1.0;

      // At minDb (silence floor)
      expect(VoiceOrbController.normalizeDb(-60.0, minDb, maxDb, power), 0.0);
      expect(VoiceOrbController.normalizeDb(-55.0, minDb, maxDb, power), 0.0);

      // At maxDb (peak ceiling)
      expect(VoiceOrbController.normalizeDb(-5.0, minDb, maxDb, power), 1.0);
      expect(VoiceOrbController.normalizeDb(0.0, minDb, maxDb, power), 1.0);

      // Midpoint: (-55 + -5) / 2 = -30.0
      expect(VoiceOrbController.normalizeDb(-30.0, minDb, maxDb, power),
          closeTo(0.5, 0.001));
    });

    test('EMA smoothing smoothly interpolates towards target energy', () {
      final controller = VoiceOrbController(
        smoothingFactor: 0.2,
      );

      expect(controller.energy, 0.0);

      // Set manual target energy
      controller.setManualEnergy(1.0);
      expect(controller.targetEnergy, 1.0);

      // Tick 1
      controller.tick(0.016);
      expect(controller.energy, closeTo(0.2, 0.001));

      // Tick 2
      controller.tick(0.016);
      expect(controller.energy, closeTo(0.36, 0.001));

      controller.dispose();
    });

    test('Simulation mode updates energy over time', () {
      final controller = VoiceOrbController();
      controller.setSimulated(true, mode: SimulationMode.pulse);

      expect(controller.isSimulated, true);
      expect(controller.isListening, true);

      controller.tick(0.1);
      expect(controller.energy, greaterThan(0.0));

      controller.dispose();
    });
  });

  group('OrbStyle', () {
    test('presets have valid non-null properties including idleTurbulence', () {
      final gemini = OrbStyle.gemini();
      expect(gemini.silentColor, isNotNull);
      expect(gemini.activeColor, isNotNull);
      expect(gemini.baseRadius, greaterThan(0.0));
      expect(gemini.glowIntensity, greaterThan(0.0));
      expect(gemini.idleTurbulence, 0.0); // Default pristine sphere

      final cyberpunk = OrbStyle.cyberpunk();
      expect(cyberpunk.silentColor, const Color(0xFF990066));
      expect(cyberpunk.activeColor, const Color(0xFF00FFCC));

      final solar = OrbStyle.solar();
      expect(solar.silentColor, const Color(0xFFC62828));

      const custom = OrbStyle(idleTurbulence: 0.25);
      expect(custom.idleTurbulence, 0.25);

      final copy = gemini.copyWith(glowIntensity: 2.5, idleTurbulence: 0.3);
      expect(copy.glowIntensity, 2.5);
      expect(copy.idleTurbulence, 0.3);
      expect(copy.silentColor, gemini.silentColor);

      expect(gemini == gemini.copyWith(), isTrue);
      expect(gemini == copy, isFalse);
    });
  });
}
