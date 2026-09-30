import 'dart:ui';
import 'package:flutter/rendering.dart';
import '../models/spectrum_orb_style.dart';

/// CustomPainter that binds shader uniforms and paints the radial audio spectrum equalizer orb.
class SpectrumOrbPainter extends CustomPainter {
  final FragmentShader shader;
  final double time;
  final double audioEnergy;
  final SpectrumOrbStyle style;

  SpectrumOrbPainter({
    required this.shader,
    required this.time,
    required this.audioEnergy,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // 0, 1: uResolution (vec2)
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // 2: uTime (float)
    shader.setFloat(2, time);

    // 3: uAudio (float)
    shader.setFloat(3, audioEnergy.clamp(0.0, 1.0));

    // 4, 5, 6: uSilentColor (vec3 normalized RGB)
    shader.setFloat(4, style.silentColor.r);
    shader.setFloat(5, style.silentColor.g);
    shader.setFloat(6, style.silentColor.b);

    // 7, 8, 9: uActiveColor (vec3 normalized RGB)
    shader.setFloat(7, style.activeColor.r);
    shader.setFloat(8, style.activeColor.g);
    shader.setFloat(9, style.activeColor.b);

    // 10: uBaseRadius (float)
    shader.setFloat(10, style.baseRadius);

    // 11: uGlowIntensity (float)
    shader.setFloat(11, style.glowIntensity);

    // 12: uSpeedMultiplier (float)
    shader.setFloat(12, style.speedMultiplier);

    // 13: uBarCount (float)
    shader.setFloat(13, style.barCount.toDouble());

    // 14: uBarHeightScale (float)
    shader.setFloat(14, style.barHeightScale);

    // 15: uBarWidth (float)
    shader.setFloat(15, style.barWidth);

    // 16: uRibbonThickness (float)
    shader.setFloat(16, style.ribbonThickness);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant SpectrumOrbPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.audioEnergy != audioEnergy ||
        oldDelegate.style != style ||
        oldDelegate.shader != shader;
  }
}
