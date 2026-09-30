import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/siri_orb_style.dart';

/// CustomPainter that renders the Apple Siri iridescent chromatic fluid glow visualizer.
class SiriOrbPainter extends CustomPainter {
  final FragmentShader? shader;
  final double time;
  final double audioEnergy;
  final SiriOrbStyle style;

  SiriOrbPainter({
    this.shader,
    required this.time,
    required this.audioEnergy,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    if (shader != null) {
      _paintWithShader(canvas, size, shader!);
    } else {
      _paintWithCanvasFallback(canvas, size);
    }
  }

  void _paintWithShader(Canvas canvas, Size size, FragmentShader s) {
    final double audio = audioEnergy.clamp(0.0, 1.0);

    // 0, 1: uResolution (vec2)
    s.setFloat(0, size.width);
    s.setFloat(1, size.height);

    // 2: uTime (float)
    s.setFloat(2, time);

    // 3: uAudio (float)
    s.setFloat(3, audio);

    // 4, 5, 6: uSilentColor (vec3 normalized RGB)
    s.setFloat(4, style.silentColor.r);
    s.setFloat(5, style.silentColor.g);
    s.setFloat(6, style.silentColor.b);

    // 7, 8, 9: uActiveColor (vec3 normalized RGB)
    s.setFloat(7, style.activeColor.r);
    s.setFloat(8, style.activeColor.g);
    s.setFloat(9, style.activeColor.b);

    // 10, 11, 12: uTertiaryColor (vec3 normalized RGB)
    s.setFloat(10, style.tertiaryColor.r);
    s.setFloat(11, style.tertiaryColor.g);
    s.setFloat(12, style.tertiaryColor.b);

    // 13, 14, 15: uQuaternaryColor (vec3 normalized RGB)
    s.setFloat(13, style.quaternaryColor.r);
    s.setFloat(14, style.quaternaryColor.g);
    s.setFloat(15, style.quaternaryColor.b);

    // 16: uBaseRadius (float)
    s.setFloat(16, style.baseRadius);

    // 17: uGlowIntensity (float)
    s.setFloat(17, style.glowIntensity);

    // 18: uSpeedMultiplier (float)
    s.setFloat(18, style.speedMultiplier);

    // 19: uChromaticIntensity (float)
    s.setFloat(19, style.chromaticIntensity);

    // 20: uFluidSwirlSpeed (float)
    s.setFloat(20, style.fluidSwirlSpeed);

    // 21: uEdgeBlur (float)
    s.setFloat(21, style.edgeBlur);

    // 22: uWaveDeformation (float)
    s.setFloat(22, style.waveDeformation);

    final paint = Paint()..shader = s;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _paintWithCanvasFallback(Canvas canvas, Size size) {
    final double cx = size.width * 0.5;
    final double cy = size.height * 0.5;
    final double baseR = min(size.width, size.height) * (style.baseRadius * 1.5);
    final double audio = audioEnergy.clamp(0.0, 1.0);
    final double t = time * style.speedMultiplier * style.fluidSwirlSpeed;

    // --- 1. Outer Ambient Radiant Diffuse Bloom ---
    final haloR = baseR * (1.5 + audio * 0.5);
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          style.activeColor.withValues(alpha: 0.35 + audio * 0.25),
          style.tertiaryColor.withValues(alpha: 0.15 + audio * 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: haloR));
    canvas.drawCircle(Offset(cx, cy), haloR, haloPaint);

    // --- 2. Rotating Chromatic Gradient Vortices ---
    final vortexOffsets = [
      Offset(cos(t * 1.1) * (baseR * 0.5), sin(t * 1.1) * (baseR * 0.5)),
      Offset(cos(-t * 1.3 + 2.1) * (baseR * 0.55), sin(-t * 1.3 + 2.1) * (baseR * 0.55)),
      Offset(cos(t * 1.5 + 4.2) * (baseR * 0.45), sin(t * 1.5 + 4.2) * (baseR * 0.45)),
      Offset(cos(-t * 0.8 + 1.0) * (baseR * 0.35), sin(-t * 0.8 + 1.0) * (baseR * 0.35)),
    ];

    final vortexColors = [
      style.activeColor,
      style.tertiaryColor,
      style.quaternaryColor,
      style.silentColor,
    ];

    for (int i = 0; i < 4; i++) {
      final vCenter = Offset(cx, cy) + vortexOffsets[i];
      final vRadius = baseR * (0.85 + sin(t * 2.0 + i) * 0.15 + audio * 0.2);
      final vPaint = Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            vortexColors[i].withValues(alpha: 0.75 + audio * 0.25),
            vortexColors[i].withValues(alpha: 0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: vCenter, radius: vRadius));
      canvas.drawCircle(vCenter, vRadius, vPaint);
    }

    // --- 3. Fluid Caustic Interference Rings ---
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 + audio * 1.5
      ..shader = SweepGradient(
        colors: [
          style.activeColor.withValues(alpha: 0.7),
          style.tertiaryColor.withValues(alpha: 0.8),
          style.quaternaryColor.withValues(alpha: 0.7),
          style.activeColor.withValues(alpha: 0.7),
        ],
        transform: GradientRotation(t * 2.0),
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: baseR * 0.9));
    canvas.drawCircle(Offset(cx, cy), baseR * (0.9 + sin(t * 3.0) * 0.05), ringPaint);

    // --- 4. Central Luminous White-Hot Energy Core ---
    final coreR = baseR * (0.35 + audio * 0.2);
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: (0.9 + audio * 0.1).clamp(0.0, 1.0)),
          style.activeColor.withValues(alpha: 0.45),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: coreR));
    canvas.drawCircle(Offset(cx, cy), coreR, corePaint);
  }

  @override
  bool shouldRepaint(covariant SiriOrbPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.audioEnergy != audioEnergy ||
        oldDelegate.style != style ||
        oldDelegate.shader != shader;
  }
}
