import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/constellation_orb_style.dart';

/// Precomputed seed traits for deterministic, continuous particle drifting.
class _ParticleSeed {
  final double baseRadiusNorm;
  final double baseAngle;
  final double freqX1;
  final double freqX2;
  final double freqY1;
  final double freqY2;
  final double phaseX1;
  final double phaseX2;
  final double phaseY1;
  final double phaseY2;
  final double ampX;
  final double ampY;
  final double sizeScale;

  const _ParticleSeed({
    required this.baseRadiusNorm,
    required this.baseAngle,
    required this.freqX1,
    required this.freqX2,
    required this.freqY1,
    required this.freqY2,
    required this.phaseX1,
    required this.phaseX2,
    required this.phaseY1,
    required this.phaseY2,
    required this.ampX,
    required this.ampY,
    required this.sizeScale,
  });
}

/// High-performance 2D Dynamic Constellation Network Mesh Painter.
///
/// Renders dynamic wandering nodes whose proximity connections smoothly fade
/// in as they approach and fade out as they separate, pulsating to audio transients.
class ConstellationPainter extends CustomPainter {
  final double time;
  final double audioEnergy;
  final ConstellationOrbStyle style;

  // Cached seeds for deterministic particle flight paths
  static List<_ParticleSeed>? _cachedSeeds;
  static int _cachedCount = 0;

  // Coordinate buffer for frame: [x, y, pulsePhase]
  Float32List? _coordBuffer;

  ConstellationPainter({
    required this.time,
    required this.audioEnergy,
    required this.style,
  }) {
    _ensureSeeds(style.particleCount);
  }

  static void _ensureSeeds(int count) {
    if (_cachedSeeds != null && _cachedCount == count) return;

    final seeds = <_ParticleSeed>[];
    final random = Random(42); // Deterministic seed

    for (int i = 0; i < count; i++) {
      // Golden spiral distribution for uniform 2D coverage
      final double rNorm = sqrt((i + 0.5) / count);
      final double angle = i * 2.399963229728653; // Golden angle

      seeds.add(_ParticleSeed(
        baseRadiusNorm: rNorm,
        baseAngle: angle,
        freqX1: 0.4 + random.nextDouble() * 0.7,
        freqX2: 0.6 + random.nextDouble() * 0.8,
        freqY1: 0.4 + random.nextDouble() * 0.7,
        freqY2: 0.6 + random.nextDouble() * 0.8,
        phaseX1: random.nextDouble() * 2.0 * pi,
        phaseX2: random.nextDouble() * 2.0 * pi,
        phaseY1: random.nextDouble() * 2.0 * pi,
        phaseY2: random.nextDouble() * 2.0 * pi,
        ampX: 0.12 + random.nextDouble() * 0.16,
        ampY: 0.12 + random.nextDouble() * 0.16,
        sizeScale: 0.75 + random.nextDouble() * 0.55,
      ));
    }

    _cachedSeeds = seeds;
    _cachedCount = count;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || _cachedSeeds == null) return;

    final count = min(style.particleCount, _cachedSeeds!.length);
    if (_coordBuffer == null || _coordBuffer!.length < count * 2) {
      _coordBuffer = Float32List(count * 2);
    }

    final double audio = audioEnergy.clamp(0.0, 1.0);
    final double t = time * style.particleSpeed * style.speedMultiplier;
    final double cx = size.width * 0.5;
    final double cy = size.height * 0.5;
    final double maxDimension = min(size.width, size.height);
    final double fieldRadius = maxDimension * style.interactionRadius;

    // --- 1. Ambient Backdrop Glow ---
    if (style.showBoundaryGlow) {
      final bgPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            style.activeColor.withValues(alpha: 0.18 + audio * 0.16),
            style.silentColor.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(cx, cy),
          radius: fieldRadius * 1.25,
        ));
      canvas.drawCircle(Offset(cx, cy), fieldRadius * 1.25, bgPaint);
    }

    // --- 2. Calculate Dynamic 2D Particle Positions ---
    for (int i = 0; i < count; i++) {
      final seed = _cachedSeeds![i];

      // Base polar anchor
      final double baseDist = seed.baseRadiusNorm * fieldRadius;
      final double baseX = cx + cos(seed.baseAngle) * baseDist;
      final double baseY = cy + sin(seed.baseAngle) * baseDist;

      // Harmonic Lissajous wandering offset
      final double driftX = (sin(seed.freqX1 * t + seed.phaseX1) +
              cos(seed.freqX2 * t * 1.3 + seed.phaseX2) * 0.6) *
          (fieldRadius * seed.ampX) *
          (1.0 + audio * 0.4 * style.audioImpulseForce);

      final double driftY = (cos(seed.freqY1 * t + seed.phaseY1) +
              sin(seed.freqY2 * t * 1.2 + seed.phaseY2) * 0.6) *
          (fieldRadius * seed.ampY) *
          (1.0 + audio * 0.4 * style.audioImpulseForce);

      final double px = baseX + driftX;
      final double py = baseY + driftY;

      _coordBuffer![i * 2] = px;
      _coordBuffer![i * 2 + 1] = py;
    }

    // --- 3. Compute Proximity Connections with Quadratic Distance Fadeout ---
    final double scaleFactor = (maxDimension / 300.0).clamp(0.5, 2.5);
    final double maxDist = style.maxConnectionDistance *
        scaleFactor *
        (1.0 + audio * 0.35 * style.audioImpulseForce);
    final double maxDistSq = maxDist * maxDist;

    final Color lineColor = Color.lerp(
      style.silentColor,
      style.activeColor,
      0.60 + audio * 0.40,
    )!;

    final linePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (int i = 0; i < count; i++) {
      final double x1 = _coordBuffer![i * 2];
      final double y1 = _coordBuffer![i * 2 + 1];

      for (int j = i + 1; j < count; j++) {
        final double x2 = _coordBuffer![j * 2];
        final double y2 = _coordBuffer![j * 2 + 1];

        final double dx = x1 - x2;
        final double dy = y1 - y2;
        final double distSq = dx * dx + dy * dy;

        if (distSq < maxDistSq) {
          final double dist = sqrt(distSq);
          final double proximity = (1.0 - dist / maxDist);
          // Smooth quadratic falloff for natural connection fading
          final double alpha = (proximity * proximity * 0.85 * (0.65 + audio * 0.35) * style.lineGlowIntensity)
              .clamp(0.0, 1.0);

          linePaint.color = lineColor.withValues(alpha: alpha);
          linePaint.strokeWidth = max(
            0.5,
            style.lineThickness * (0.7 + proximity * 0.7) * (1.0 + audio * 0.25),
          );

          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
        }
      }
    }

    // --- 4. Render Particle Nodes and Synaptic Spark Highlights ---
    final Color nodeColor = Color.lerp(
      style.silentColor,
      style.activeColor,
      0.80 + audio * 0.20,
    )!;

    final nodePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final auraPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final double px = _coordBuffer![i * 2];
      final double py = _coordBuffer![i * 2 + 1];
      final seed = _cachedSeeds![i];

      final double nodeRadius = style.particleRadius *
          seed.sizeScale *
          (1.0 + audio * 0.45 * style.audioImpulseForce);

      // Outer soft aura halo
      auraPaint.color = style.activeColor.withValues(
        alpha: (0.20 + audio * 0.25).clamp(0.0, 0.6),
      );
      canvas.drawCircle(Offset(px, py), nodeRadius * 2.2, auraPaint);

      // Solid central core node
      nodePaint.color = nodeColor.withValues(
        alpha: (0.85 + audio * 0.15).clamp(0.0, 1.0),
      );
      canvas.drawCircle(Offset(px, py), nodeRadius, nodePaint);

      // White-hot center spark on active audio pulses
      if (audio > 0.35 && (i % 4 == 0 || audio > 0.7)) {
        final sparkPaint = Paint()
          ..color = Colors.white.withValues(alpha: (0.75 + audio * 0.25).clamp(0.0, 1.0))
          ..isAntiAlias = true;
        canvas.drawCircle(Offset(px, py), max(0.8, nodeRadius * 0.5), sparkPaint);

        // Synaptic expanding ripple ring on loud beats
        if (audio > 0.6 && i % 8 == 0) {
          final rippleRadius = nodeRadius * (2.5 + sin(t * 3.0 + i) * 1.5);
          final ringPaint = Paint()
            ..color = style.activeColor.withValues(alpha: (0.35 * (1.0 - rippleRadius / (nodeRadius * 4.5))).clamp(0.0, 0.4))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..isAntiAlias = true;
          canvas.drawCircle(Offset(px, py), rippleRadius, ringPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConstellationPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.audioEnergy != audioEnergy ||
        oldDelegate.style != style;
  }
}
