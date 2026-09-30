import 'package:flutter/material.dart';
import 'package:flutter_orb/flutter_orb.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  group('ParticleOrbStyle & OrbStyle Compatibility', () {
    test('presets have valid non-null properties including idleTurbulence', () {
      final gemini = OrbStyle.gemini();
      expect(gemini.silentColor, isNotNull);
      expect(gemini.activeColor, isNotNull);
      expect(gemini.baseRadius, greaterThan(0.0));
      expect(gemini.glowIntensity, greaterThan(0.0));
      expect(gemini.idleTurbulence, 0.0);

      final cyberpunk = ParticleOrbStyle.cyberpunk();
      expect(cyberpunk.silentColor, const Color(0xFF990066));
      expect(cyberpunk.activeColor, const Color(0xFF00FFCC));

      final solar = ParticleOrbStyle.solar();
      expect(solar.silentColor, const Color(0xFFC62828));

      const custom = ParticleOrbStyle(idleTurbulence: 0.25);
      expect(custom.idleTurbulence, 0.25);

      final copy = gemini.copyWith(glowIntensity: 2.5, idleTurbulence: 0.3);
      expect(copy.glowIntensity, 2.5);
      expect(copy.idleTurbulence, 0.3);
      expect(copy.silentColor, gemini.silentColor);

      expect(gemini == gemini.copyWith(), isTrue);
      expect(gemini == copy, isFalse);
    });
  });

  group('LiquidOrbStyle', () {
    test('presets and properties are valid and copyable', () {
      final mercury = LiquidOrbStyle.mercury();
      expect(mercury.viscosity, 0.9);
      expect(mercury.blobScale, 0.48);
      expect(mercury.specularShininess, 1.4);
      expect(mercury.refractiveGlow, 0.7);

      final lava = LiquidOrbStyle.lava();
      expect(lava.silentColor, const Color(0xFF450A0A));
      expect(lava.activeColor, const Color(0xFFF97316));

      final plasma = LiquidOrbStyle.plasma();
      expect(plasma.viscosity, 0.8);

      final slime = LiquidOrbStyle.toxicSlime();
      expect(slime.activeColor, const Color(0xFF22C55E));

      final amethyst = LiquidOrbStyle.amethyst();
      expect(amethyst.activeColor, const Color(0xFFA855F7));

      final copy = mercury.copyWith(viscosity: 1.2, blobScale: 0.55);
      expect(copy.viscosity, 1.2);
      expect(copy.blobScale, 0.55);
      expect(copy == mercury, isFalse);
      expect(mercury == mercury.copyWith(), isTrue);
    });
  });

  group('GalaxyOrbStyle', () {
    test('presets and properties are valid and copyable', () {
      final andromeda = GalaxyOrbStyle.andromeda();
      expect(andromeda.armCount, 2);
      expect(andromeda.spiralTightness, 1.2);
      expect(andromeda.coreBulgeSize, 1.0);

      final supernova = GalaxyOrbStyle.supernova();
      expect(supernova.armCount, 3);
      expect(supernova.polarJetIntensity, 1.4);

      final milkyWay = GalaxyOrbStyle.milkyWay();
      expect(milkyWay.armCount, 2);

      final blackHole = GalaxyOrbStyle.blackHole();
      expect(blackHole.armCount, 4);

      final nebula = GalaxyOrbStyle.nebula();
      expect(nebula.activeColor, const Color(0xFF2DD4BF));

      final copy = andromeda.copyWith(armCount: 4, spiralTightness: 1.8);
      expect(copy.armCount, 4);
      expect(copy.spiralTightness, 1.8);
      expect(copy == andromeda, isFalse);
      expect(andromeda == andromeda.copyWith(), isTrue);
    });
  });

  group('WireframeOrbStyle', () {
    test('presets and properties are valid and copyable', () {
      final holo = WireframeOrbStyle.hologram();
      expect(holo.gridDensity, 18.0);
      expect(holo.lineThickness, 1.0);
      expect(holo.vertexGlowSize, 1.1);
      expect(holo.scanlineIntensity, 0.4);

      final matrix = WireframeOrbStyle.matrix();
      expect(matrix.gridDensity, 20.0);
      expect(matrix.activeColor, const Color(0xFF22C55E));

      final cyber = WireframeOrbStyle.cyberLattice();
      expect(cyber.activeColor, const Color(0xFFF43F5E));

      final golden = WireframeOrbStyle.goldenCortex();
      expect(golden.activeColor, const Color(0xFFFBBF24));

      final red = WireframeOrbStyle.stealthRed();
      expect(red.activeColor, const Color(0xFFEF4444));

      final copy = holo.copyWith(gridDensity: 24.0, lineThickness: 1.5);
      expect(copy.gridDensity, 24.0);
      expect(copy.lineThickness, 1.5);
      expect(copy == holo, isFalse);
      expect(holo == holo.copyWith(), isTrue);
    });
  });

  group('SpectrumOrbStyle', () {
    test('presets and properties are valid and copyable', () {
      final neon = SpectrumOrbStyle.neonEqualizer();
      expect(neon.barCount, 48);
      expect(neon.barHeightScale, 1.1);
      expect(neon.ribbonThickness, 1.1);

      final sunset = SpectrumOrbStyle.sunsetEcho();
      expect(sunset.barCount, 40);
      expect(sunset.activeColor, const Color(0xFFFB923C));

      final vapor = SpectrumOrbStyle.vaporwave();
      expect(vapor.barCount, 56);

      final green = SpectrumOrbStyle.radiantGreen();
      expect(green.activeColor, const Color(0xFF4ADE80));

      final mono = SpectrumOrbStyle.monochrome();
      expect(mono.activeColor, const Color(0xFFFFFFFF));

      final copy = neon.copyWith(barCount: 64, barWidth: 1.4);
      expect(copy.barCount, 64);
      expect(copy.barWidth, 1.4);
      expect(copy == neon, isFalse);
      expect(neon == neon.copyWith(), isTrue);
    });
  });

  group('Widget Instantiation Tests', () {
    testWidgets('Instantiates ParticleOrb without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleOrb(audioEnergy: 0.5),
          ),
        ),
      );

      expect(find.byType(ParticleOrb), findsOneWidget);
    });

    testWidgets('Instantiates LiquidOrb without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidOrb(
              audioEnergy: 0.5,
              style: LiquidOrbStyle.mercury(),
            ),
          ),
        ),
      );

      expect(find.byType(LiquidOrb), findsOneWidget);
    });

    testWidgets('Instantiates GalaxyOrb without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalaxyOrb(
              audioEnergy: 0.5,
              style: GalaxyOrbStyle.andromeda(),
            ),
          ),
        ),
      );

      expect(find.byType(GalaxyOrb), findsOneWidget);
    });

    testWidgets('Instantiates WireframeOrb without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WireframeOrb(
              audioEnergy: 0.5,
              style: WireframeOrbStyle.hologram(),
            ),
          ),
        ),
      );

      expect(find.byType(WireframeOrb), findsOneWidget);
    });

    testWidgets('Instantiates SpectrumOrb without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpectrumOrb(
              audioEnergy: 0.5,
              style: SpectrumOrbStyle.neonEqualizer(),
            ),
          ),
        ),
      );

      expect(find.byType(SpectrumOrb), findsOneWidget);
    });

    testWidgets('Instantiates AudioReactiveOrb constructors without crashing',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AudioReactiveOrb.particle(autoStart: false, width: 100, height: 100),
                AudioReactiveOrb.liquid(autoStart: false, width: 100, height: 100),
                AudioReactiveOrb.galaxy(autoStart: false, width: 100, height: 100),
                AudioReactiveOrb.wireframe(autoStart: false, width: 100, height: 100),
                AudioReactiveOrb.spectrum(autoStart: false, width: 100, height: 100),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AudioReactiveOrb), findsNWidgets(5));
    });
  });
}
