import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/flare_orb_style.dart';

/// CustomPainter that renders the Quantum Flare 3D particle sphere visualizer
/// with an orbital plasma ring and white-hot flare head.
class FlareOrbPainter extends CustomPainter {
  final FragmentShader? shader;
  final double time;
  final double audioEnergy;
  final FlareOrbStyle style;

  FlareOrbPainter({
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

    // 10, 11, 12: uFlareColor (vec3 normalized RGB)
    s.setFloat(10, style.flareColor.r);
    s.setFloat(11, style.flareColor.g);
    s.setFloat(12, style.flareColor.b);

    // 13, 14, 15: uCoreHighlightColor (vec3 normalized RGB)
    s.setFloat(13, style.coreHighlightColor.r);
    s.setFloat(14, style.coreHighlightColor.g);
    s.setFloat(15, style.coreHighlightColor.b);

    // 16: uBaseRadius (float)
    s.setFloat(16, style.baseRadius);

    // 17: uGlowIntensity (float)
    s.setFloat(17, style.glowIntensity);

    // 18: uSpeedMultiplier (float)
    s.setFloat(18, style.speedMultiplier);

    // 19: uRingThickness (float)
    s.setFloat(19, style.ringThickness);

    // 20: uOrbitalSpeed (float)
    s.setFloat(20, style.orbitalSpeed);

    // 21: uParticleDensity (float)
    s.setFloat(21, style.particleDensity);

    // 22: uDispersionAmount (float)
    s.setFloat(22, style.dispersionAmount);

    // 23: uSonicRippleIntensity (float)
    s.setFloat(23, style.sonicRippleIntensity);

    final paint = Paint()..shader = s;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _paintWithCanvasFallback(Canvas canvas, Size size) {
    final double cx = size.width * 0.5;
    final double cy = size.height * 0.5;
    final double baseR = min(size.width, size.height) * (style.baseRadius * 1.65);
    final double audio = audioEnergy.clamp(0.0, 1.0);
    final double t = time * style.speedMultiplier;

    // --- 1. Background Sonic Ripples ---
    if (style.sonicRippleIntensity > 0.05) {
      for (int i = 1; i <= 3; i++) {
        final rippleR = baseR * (1.1 + (i * 0.35) + sin(t * 2.0 - i) * 0.08);
        final rippleAlpha = (0.25 - i * 0.06 + audio * 0.15) * style.sonicRippleIntensity;
        final ripplePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = style.flareColor.withValues(alpha: rippleAlpha.clamp(0.0, 1.0));
        canvas.drawCircle(Offset(cx, cy), rippleR, ripplePaint);
      }
    }

    // --- 2. Ambient Holographic Sphere Halo ---
    final haloR = baseR * (1.3 + audio * 0.4);
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          style.activeColor.withValues(alpha: 0.35 * style.glowIntensity),
          style.silentColor.withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: haloR));
    canvas.drawCircle(Offset(cx, cy), haloR, haloPaint);

    // --- 3. Holographic Sphere Shell ---
    final spherePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          style.silentColor.withValues(alpha: 0.85),
          style.activeColor.withValues(alpha: 0.45 + audio * 0.25),
        ],
        stops: const [0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: baseR));
    canvas.drawCircle(Offset(cx, cy), baseR, spherePaint);

    // --- 4. 3D Inclined Elliptical Plasma Ring ---
    final orbitAngle = t * style.orbitalSpeed * 1.4 + audio * 0.4;
    final ringRx = baseR * 1.05;
    final ringRy = baseR * 0.42;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-0.55); // ~32 degree orbital plane slant

    final ringPath = Path()..addOval(Rect.fromCenter(center: Offset.zero, width: ringRx * 2, height: ringRy * 2));
    final ringStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * style.ringThickness * (1.0 + audio * 0.3)
      ..shader = SweepGradient(
        colors: [
          style.flareColor.withValues(alpha: 0.2),
          style.flareColor.withValues(alpha: 0.9),
          style.coreHighlightColor.withValues(alpha: 0.95),
          style.flareColor.withValues(alpha: 0.3),
        ],
        stops: const [0.0, 0.4, 0.5, 1.0],
        transform: GradientRotation(orbitAngle),
      ).createShader(Rect.fromCenter(center: Offset.zero, width: ringRx * 2, height: ringRy * 2));
    canvas.drawPath(ringPath, ringStroke);

    // --- 5. Flare Head Particle Nucleus ---
    final flareX = ringRx * cos(orbitAngle);
    final flareY = ringRy * sin(orbitAngle);
    final flarePos = Offset(flareX, flareY);

    final flareBloomPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          style.coreHighlightColor.withValues(alpha: 0.95),
          style.flareColor.withValues(alpha: 0.75),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: flarePos, radius: baseR * 0.35));
    canvas.drawCircle(flarePos, baseR * 0.35, flareBloomPaint);

    final flareCorePaint = Paint()..color = style.coreHighlightColor;
    canvas.drawCircle(flarePos, 4.0 + audio * 2.0, flareCorePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FlareOrbPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.audioEnergy != audioEnergy ||
        oldDelegate.style != style ||
        oldDelegate.shader != shader;
  }
}
