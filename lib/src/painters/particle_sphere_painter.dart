import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../math/fast_noise_3d.dart';
import '../models/orb_style.dart';

/// Base spherical point data containing un-deformed unit sphere coordinates.
class _SpherePoint {
  final double x;
  final double y;
  final double z;
  final double phi;
  final double theta;

  const _SpherePoint({
    required this.x,
    required this.y,
    required this.z,
    required this.phi,
    required this.theta,
  });
}

/// High-performance 3D Wave Particle Sphere Painter.
///
/// Renders thousands of crisp, pinpoint particles arranged in undulating
/// 3D spherical wave ripples with zero motion blur.
class ParticleSpherePainter extends CustomPainter {
  final double time;
  final double audioEnergy;
  final OrbStyle style;
  final int particleCount;
  final double waveFrequency;
  final double waveAmplitude;
  final double particleSize;

  // Cached geometry grid
  static List<_SpherePoint>? _cachedPoints;
  static int _cachedCount = 0;

  // Buffers for drawRawPoints
  Float32List? _frontPointsBuffer;
  Float32List? _backPointsBuffer;
  Float32List? _peakPointsBuffer;

  ParticleSpherePainter({
    required this.time,
    required this.audioEnergy,
    required this.style,
    this.particleCount = 5500,
    this.waveFrequency = 1.6,
    this.waveAmplitude = 0.12,
    this.particleSize = 1.8,
  }) {
    _ensurePointsGenerated(particleCount);
  }

  static void _ensurePointsGenerated(int count) {
    if (_cachedPoints != null && _cachedCount == count) return;

    final points = <_SpherePoint>[];

    // Generate uniform latitude rings and longitude points
    final int numLatitudeRings = (sqrt(count) * 0.9).round();

    for (int i = 0; i < numLatitudeRings; i++) {
      final double phi = -pi / 2.0 + (i + 0.5) * (pi / numLatitudeRings);
      final double cosPhi = cos(phi);
      final double sinPhi = sin(phi);

      final int numLongPoints =
          max(1, (numLatitudeRings * 2.0 * cosPhi).round());
      for (int j = 0; j < numLongPoints; j++) {
        final double theta = (j / numLongPoints) * 2.0 * pi;
        final double x = cos(theta) * cosPhi;
        final double y = sinPhi;
        final double z = sin(theta) * cosPhi;

        points.add(_SpherePoint(
          x: x,
          y: y,
          z: z,
          phi: phi,
          theta: theta,
        ));
      }
    }

    _cachedPoints = points;
    _cachedCount = points.length;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || _cachedPoints == null) return;

    final points = _cachedPoints!;
    final total = points.length;

    final double centerX = size.width / 2.0;
    final double centerY = size.height / 2.0;
    final double baseRadius =
        min(size.width, size.height) * (style.baseRadius * 1.55);

    final double audio = audioEnergy.clamp(0.0, 1.0);
    final double t = time * style.speedMultiplier * 0.65;

    // --- 1. Background Core Radial Glow Backdrop ---
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          style.silentColor.withValues(alpha: 0.35 + audio * 0.25),
          style.silentColor.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: baseRadius * 1.4,
      ));
    canvas.drawCircle(Offset(centerX, centerY), baseRadius * 1.4, glowPaint);

    // --- 2. 3D Rotation Angles ---
    final double rotY = t * 0.4 + audio * 0.15;
    final double rotX = 0.35 + sin(t * 0.3) * 0.15;
    final double rotZ = sin(t * 0.2) * 0.1;

    final double cosY = cos(rotY), sinY = sin(rotY);
    final double cosX = cos(rotX), sinX = sin(rotX);
    final double cosZ = cos(rotZ), sinZ = sin(rotZ);

    // Allocate / reuse point coordinate arrays
    final maxPoints = total * 2;
    if (_frontPointsBuffer == null || _frontPointsBuffer!.length < maxPoints) {
      _frontPointsBuffer = Float32List(maxPoints);
      _backPointsBuffer = Float32List(maxPoints);
      _peakPointsBuffer = Float32List(maxPoints);
    }

    int frontCount = 0;
    int backCount = 0;
    int peakCount = 0;

    const double cameraZ = 2.8;
    final double dynamicWaveAmp =
        waveAmplitude * (style.idleTurbulence * (1.0 - audio) + audio * 2.0);
    final double waveSpeed = t * 1.2;

    for (int i = 0; i < total; i++) {
      final p = points[i];

      // Procedural 3D Simplex Wave Displacement
      final double n1 = FastNoise3D.noise(
        p.x * waveFrequency + waveSpeed,
        p.y * waveFrequency,
        p.z * waveFrequency - waveSpeed * 0.5,
      );
      final double n2 = FastNoise3D.noise(
            p.x * waveFrequency * 2.2 - waveSpeed * 0.7,
            p.y * waveFrequency * 2.2 + waveSpeed * 0.4,
            p.z * waveFrequency * 2.2,
          ) *
          0.45;

      final double displacement = (n1 + n2) * dynamicWaveAmp;
      final double r = baseRadius * (1.0 + displacement);

      // Local 3D Coordinates
      double px = p.x * r;
      double py = p.y * r;
      double pz = p.z * r;

      // 3D Rotation (Y -> X -> Z)
      // Rot Y
      double x1 = px * cosY + pz * sinY;
      double y1 = py;
      double z1 = -px * sinY + pz * cosY;

      // Rot X
      double x2 = x1;
      double y2 = y1 * cosX - z1 * sinX;
      double z2 = y1 * sinX + z1 * cosX;

      // Rot Z
      double x3 = x2 * cosZ - y2 * sinZ;
      double y3 = x2 * sinZ + y2 * cosZ;
      double z3 = z2;

      // Perspective Projection
      final double depth = (z3 / baseRadius);
      final double perspective = cameraZ / (cameraZ - depth * 0.65);
      final double sx = centerX + x3 * perspective;
      final double sy = centerY + y3 * perspective;

      if (depth < 0.0) {
        // Back hemisphere (seen through transparent orb)
        _backPointsBuffer![backCount * 2] = sx;
        _backPointsBuffer![backCount * 2 + 1] = sy;
        backCount++;
      } else {
        // Front hemisphere (crisp bright dots)
        _frontPointsBuffer![frontCount * 2] = sx;
        _frontPointsBuffer![frontCount * 2 + 1] = sy;
        frontCount++;

        // Peak highlights on wave crests
        if (displacement > 0.06 || (audio > 0.3 && displacement > 0.02)) {
          _peakPointsBuffer![peakCount * 2] = sx;
          _peakPointsBuffer![peakCount * 2 + 1] = sy;
          peakCount++;
        }
      }
    }

    // --- 3. Draw Back Hemisphere Particles (Deeper tone, zero blur) ---
    if (backCount > 0) {
      final backPaint = Paint()
        ..color = style.silentColor.withValues(alpha: 0.38)
        ..strokeWidth = max(1.0, particleSize * 0.75)
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      canvas.drawRawPoints(
        PointMode.points,
        _backPointsBuffer!.sublist(0, backCount * 2),
        backPaint,
      );
    }

    // --- 4. Draw Front Hemisphere Particles (Crisp Vibrant Cyan, zero blur) ---
    if (frontCount > 0) {
      final frontColor = Color.lerp(
        style.silentColor,
        style.activeColor,
        0.75 + audio * 0.25,
      )!;

      final frontPaint = Paint()
        ..color = frontColor.withValues(alpha: 0.90)
        ..strokeWidth = max(1.2, particleSize * (1.0 + audio * 0.2))
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      canvas.drawRawPoints(
        PointMode.points,
        _frontPointsBuffer!.sublist(0, frontCount * 2),
        frontPaint,
      );
    }

    // --- 5. Draw Peak Wave Crest Highlights (White-hot sparkle tips) ---
    if (peakCount > 0) {
      final peakColor = Color.lerp(
        style.activeColor,
        Colors.white,
        0.65 + audio * 0.35,
      )!;

      final peakPaint = Paint()
        ..color = peakColor.withValues(alpha: 0.95)
        ..strokeWidth = max(1.4, particleSize * (1.2 + audio * 0.3))
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      canvas.drawRawPoints(
        PointMode.points,
        _peakPointsBuffer!.sublist(0, peakCount * 2),
        peakPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticleSpherePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.audioEnergy != audioEnergy ||
        oldDelegate.style != style ||
        oldDelegate.particleSize != particleSize ||
        oldDelegate.waveAmplitude != waveAmplitude ||
        oldDelegate.waveFrequency != waveFrequency;
  }
}
