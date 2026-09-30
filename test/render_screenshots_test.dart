import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_orb/flutter_orb.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> renderPainterToFile(
    String filename,
    CustomPainter painter, {
    double width = 300,
    double height = 300,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, width, height),
    );

    // Dark backdrop matching example app
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = const Color(0xFF08090C),
    );

    painter.paint(canvas, Size(width, height));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      final file = File('example/doc/screenshots/$filename.png');
      await file.parent.create(recursive: true);
      file.writeAsBytesSync(byteData.buffer.asUint8List());
      // ignore: avoid_print
      print('📸 Rendered: ${file.path} (${file.lengthSync()} bytes)');
    }
  }

  group('Screenshot Direct Painter Renderer', () {
    late ui.FragmentProgram liquidProgram;
    late ui.FragmentProgram galaxyProgram;
    late ui.FragmentProgram wireframeProgram;
    late ui.FragmentProgram spectrumProgram;

    setUpAll(() async {
      // Load real system TrueType font for crystal-clear text in test snapshots
      final fontCandidates = [
        '/System/Library/Fonts/Supplemental/Arial.ttf',
        '/System/Library/Fonts/Geneva.ttf',
        '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
      ];

      for (final candidate in fontCandidates) {
        final f = File(candidate);
        if (f.existsSync()) {
          final fontBytes = f.readAsBytesSync();
          for (final fontName in ['Roboto', 'Arial', 'sans-serif']) {
            final loader = FontLoader(fontName)
              ..addFont(Future.value(ByteData.view(fontBytes.buffer)));
            await loader.load();
          }
          break;
        }
      }

      liquidProgram =
          await OrbShaderLoader.loadPath(OrbShaderLoader.liquidShaderPath);
      galaxyProgram =
          await OrbShaderLoader.loadPath(OrbShaderLoader.galaxyShaderPath);
      wireframeProgram =
          await OrbShaderLoader.loadPath(OrbShaderLoader.wireframeShaderPath);
      spectrumProgram =
          await OrbShaderLoader.loadPath(OrbShaderLoader.spectrumShaderPath);
    });

    test('01_particle_gemini', () async {
      await renderPainterToFile(
        '01_particle_gemini',
        ParticleSpherePainter(
          time: 1.5,
          audioEnergy: 0.65,
          style: ParticleOrbStyle.gemini(),
          particleCount: 2500,
        ),
      );
    });

    test('02_liquid_mercury', () async {
      await renderPainterToFile(
        '02_liquid_mercury',
        LiquidOrbPainter(
          shader: liquidProgram.fragmentShader(),
          time: 2.0,
          audioEnergy: 0.6,
          style: LiquidOrbStyle.mercury(),
        ),
      );
    });

    test('03_liquid_lava', () async {
      await renderPainterToFile(
        '03_liquid_lava',
        LiquidOrbPainter(
          shader: liquidProgram.fragmentShader(),
          time: 2.5,
          audioEnergy: 0.75,
          style: LiquidOrbStyle.lava(),
        ),
      );
    });

    test('04_galaxy_andromeda', () async {
      await renderPainterToFile(
        '04_galaxy_andromeda',
        GalaxyOrbPainter(
          shader: galaxyProgram.fragmentShader(),
          time: 3.0,
          audioEnergy: 0.65,
          style: GalaxyOrbStyle.andromeda(),
        ),
      );
    });

    test('05_galaxy_supernova', () async {
      await renderPainterToFile(
        '05_galaxy_supernova',
        GalaxyOrbPainter(
          shader: galaxyProgram.fragmentShader(),
          time: 3.5,
          audioEnergy: 0.85,
          style: GalaxyOrbStyle.supernova(),
        ),
      );
    });

    test('06_wireframe_hologram', () async {
      await renderPainterToFile(
        '06_wireframe_hologram',
        WireframeOrbPainter(
          shader: wireframeProgram.fragmentShader(),
          time: 2.2,
          audioEnergy: 0.55,
          style: WireframeOrbStyle.hologram(),
        ),
      );
    });

    test('07_wireframe_matrix', () async {
      await renderPainterToFile(
        '07_wireframe_matrix',
        WireframeOrbPainter(
          shader: wireframeProgram.fragmentShader(),
          time: 2.8,
          audioEnergy: 0.65,
          style: WireframeOrbStyle.matrix(),
        ),
      );
    });

    test('08_spectrum_neon', () async {
      await renderPainterToFile(
        '08_spectrum_neon',
        SpectrumOrbPainter(
          shader: spectrumProgram.fragmentShader(),
          time: 2.0,
          audioEnergy: 0.7,
          style: SpectrumOrbStyle.neonEqualizer(),
        ),
      );
    });

    test('09_spectrum_sunset', () async {
      await renderPainterToFile(
        '09_spectrum_sunset',
        SpectrumOrbPainter(
          shader: spectrumProgram.fragmentShader(),
          time: 2.5,
          audioEnergy: 0.6,
          style: SpectrumOrbStyle.sunsetEcho(),
        ),
      );
    });

    test('10_tuning_panel', () async {
      await renderPainterToFile(
        '10_tuning_panel',
        _TuningPanelPainter(),
        width: 300,
        height: 300,
      );
    });
  });
}

class _TuningPanelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Outer Container
    final panelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
      const Radius.circular(16),
    );

    // Card background
    final bgPaint = Paint()..color = const Color(0xFF10131B);
    canvas.drawRRect(panelRect, bgPaint);

    // Card border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(panelRect, borderPaint);

    double y = 18;

    // Header badge
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(18, y, size.width - 36, 22),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      badgeRect,
      Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      badgeRect,
      Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Draw small cyan slider icon in badge
    final iconPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(28, y + 6), Offset(28, y + 16), iconPaint);
    canvas.drawCircle(Offset(28, y + 9), 2.5, Paint()..color = const Color(0xFF00E5FF));
    canvas.drawLine(Offset(34, y + 6), Offset(34, y + 16), iconPaint);
    canvas.drawCircle(Offset(34, y + 13), 2.5, Paint()..color = const Color(0xFF00E5FF));

    _drawText(
      canvas,
      'LIVE PARAMETER TUNING DRAWER',
      Offset(42, y + 5),
      const TextStyle(
        fontFamily: 'Arial',
        color: Color(0xFF00E5FF),
        fontSize: 9.5,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
    y += 28;

    // Mode title
    _drawText(
      canvas,
      'Spiral Galaxy (Andromeda)',
      Offset(18, y),
      const TextStyle(
        fontFamily: 'Arial',
        color: Colors.white,
        fontSize: 12.5,
        fontWeight: FontWeight.bold,
      ),
    );
    y += 18;

    // Slider builder helper
    void drawSlider(String label, String valStr, double ratio, Color accent) {
      _drawText(
        canvas,
        label,
        Offset(18, y),
        const TextStyle(
          fontFamily: 'Arial',
          color: Colors.white70,
          fontSize: 10,
        ),
      );
      _drawText(
        canvas,
        valStr,
        Offset(size.width - 64, y),
        TextStyle(
          fontFamily: 'Arial',
          color: accent,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      y += 14;

      // Track bg
      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(18, y, size.width - 36, 4),
        const Radius.circular(2),
      );
      canvas.drawRRect(
        trackRect,
        Paint()..color = Colors.white.withValues(alpha: 0.08),
      );

      // Active fill
      final activeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(18, y, (size.width - 36) * ratio, 4),
        const Radius.circular(2),
      );
      canvas.drawRRect(activeRect, Paint()..color = accent);

      // Thumb
      canvas.drawCircle(
        Offset(18 + (size.width - 36) * ratio, y + 2),
        4.5,
        Paint()..color = Colors.white,
      );

      y += 11;
    }

    // Shader parameters
    drawSlider('Arm Count', '2.00', 0.25, const Color(0xFF00E5FF));
    drawSlider('Spiral Tightness', '1.20', 0.38, const Color(0xFF00E5FF));
    drawSlider('Core Bulge Size', '1.00', 0.32, const Color(0xFF00E5FF));
    drawSlider('Stardust Density', '0.80', 0.53, const Color(0xFF00E5FF));

    // Divider
    final divPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(18, y + 2), Offset(size.width - 18, y + 2), divPaint);
    y += 8;

    // Audio sensitivity section
    _drawText(
      canvas,
      'AUDIO SENSITIVITY & MIC DYNAMICS',
      Offset(18, y),
      const TextStyle(
        fontFamily: 'Arial',
        color: Colors.white38,
        fontSize: 8.5,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.6,
      ),
    );
    y += 13;

    drawSlider('Decibel Floor', '-55 dB', 0.45, const Color(0xFF10B981));
    drawSlider('EMA Smoothing', '0.18', 0.35, const Color(0xFF10B981));
    drawSlider('Power Boost', '1.50x', 0.33, const Color(0xFF10B981));

    // Bottom mic status pill
    final micPill = RRect.fromRectAndRadius(
      Rect.fromLTWH(18, size.height - 28, size.width - 36, 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      micPill,
      Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.12),
    );

    canvas.drawCircle(
      Offset(26, size.height - 20),
      3.0,
      Paint()..color = const Color(0xFF10B981),
    );

    _drawText(
      canvas,
      'LIVE MICROPHONE ACTIVE: -42.5 dBFS  |  65%',
      Offset(34, size.height - 25),
      const TextStyle(
        fontFamily: 'Arial',
        color: Color(0xFF10B981),
        fontSize: 8,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.4,
      ),
    );
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
