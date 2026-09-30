import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/wave_mesh_orb_style.dart';

/// High-performance 2.5D Perspective Undulating Wave Mesh Painter.
///
/// Renders a dynamic 3D undulating network grid with depth-of-field focal blur,
/// soft circular bokeh discs on distant crests, and crisp foreground lattice nodes.
class WaveMeshPainter extends CustomPainter {
  final double time;
  final double audioEnergy;
  final WaveMeshOrbStyle style;

  // Reusable Float32 coordinate cache for grid points: [screenX, screenY, depth, waveHeight]
  Float32List? _pointCache;
  int _pointCacheCapacity = 0;

  WaveMeshPainter({
    required this.time,
    required this.audioEnergy,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rows = style.gridRows;
    final cols = style.gridColumns;
    final totalPoints = rows * cols;
    final requiredFloats = totalPoints * 4;

    if (_pointCache == null || _pointCacheCapacity < requiredFloats) {
      _pointCache = Float32List(requiredFloats);
      _pointCacheCapacity = requiredFloats;
    }

    final double audio = audioEnergy.clamp(0.0, 1.0);
    final double t = time * style.speedMultiplier;
    final double cx = size.width * 0.5;
    final double cy = size.height * 0.54;
    final double baseDimension = min(size.width, size.height);

    // --- 1. Background Atmosphere / Deep Glow Backdrop ---
    final bgGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          style.activeColor.withValues(alpha: 0.22 + audio * 0.18),
          style.silentColor.withValues(alpha: 0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(cx, cy * 0.85),
        radius: baseDimension * (style.baseRadius * 3.0),
      ));
    canvas.drawCircle(
      Offset(cx, cy * 0.85),
      baseDimension * (style.baseRadius * 3.0),
      bgGlowPaint,
    );

    // --- 2. Calculate 3D Wave Displacements and Perspective Projections ---
    final double freq = style.waveFrequency;
    final double amp = style.waveAmplitude *
        (size.height * 0.24) *
        (1.0 + audio * 2.2 * style.glowIntensity);
    final double pitch = style.perspectivePitch;
    final double cosPitch = cos(pitch);
    final double sinPitch = sin(pitch);

    final double gridSpanX = size.width * 0.66;
    const double gridSpanZ = 2.8;

    for (int r = 0; r < rows; r++) {
      final double v = r / (rows - 1); // 0.0 near -> 1.0 far
      final double zDepth = 1.0 + v * gridSpanZ;

      for (int c = 0; c < cols; c++) {
        final double u = ((c / (cols - 1)) - 0.5) * 2.0; // -1.0 left -> 1.0 right
        final int index = (r * cols + c) * 4;

        // Compound undulating wave harmonics
        final double w1 = sin(u * 2.6 * freq + t * 1.5) *
            cos(v * 2.2 * freq - t * 1.1);
        final double w2 = sin((u * 1.8 + v * 2.4) * freq - t * 1.7) * 0.55;
        final double w3 = cos(u * 4.2 * freq - t * 2.1) *
            sin(v * 3.6 * freq + t * 1.3) *
            0.32;

        // Lateral mountain ridge crests at the flanks (matching reference aesthetic)
        final double flankElevation =
            (u * u) * 0.45 * sin(v * 3.2 * freq + t * 0.9);
        final double waveVal = (w1 + w2 + w3 + flankElevation);
        final double yWave = -waveVal * amp;

        // 3D Perspective Rotation
        final double x3d = u * gridSpanX * (1.0 + v * 0.45);
        final double yRot = yWave * cosPitch - (v - 0.45) * (size.height * 0.52) * sinPitch;
        final double zRot = zDepth + (v - 0.45) * cosPitch * 0.45;

        final double perspective = 1.85 / max(0.2, zRot);
        final double sx = cx + x3d * perspective;
        final double sy = cy + yRot * perspective;

        _pointCache![index] = sx;
        _pointCache![index + 1] = sy;
        _pointCache![index + 2] = v; // Normalized depth
        _pointCache![index + 3] = waveVal; // Wave height normalized
      }
    }

    // --- 3. Render Background Focal Bokeh Discs (Depth of Field) ---
    if (style.showBokehCircles && style.depthOfField > 0.05) {
      final bokehColor = Color.lerp(
        style.silentColor,
        style.activeColor,
        0.55 + audio * 0.45,
      )!;

      for (int r = rows - 1; r >= 0; r--) {
        final double v = r / (rows - 1);
        if (v < style.focalDistance) continue; // Only far-field bokeh

        final double focalDelta =
            (v - style.focalDistance) / (1.0 - style.focalDistance);
        if (focalDelta <= 0.1) continue;

        for (int c = 0; c < cols; c += 2) {
          final int index = (r * cols + c) * 4;
          final double sx = _pointCache![index];
          final double sy = _pointCache![index + 1];
          final double waveVal = _pointCache![index + 3];

          // Render bokeh discs on wave crests and elevated terrain
          if (waveVal > 0.12 || (v > 0.7 && c % 3 == 0)) {
            final double bokehRadius = focalDelta *
                (16.0 * style.depthOfField) *
                (1.0 + waveVal * 0.4 + audio * 0.3);

            final double alpha = (focalDelta * 0.35 + waveVal * 0.25)
                .clamp(0.04, 0.48) *
                style.glowIntensity;

            final bokehPaint = Paint()
              ..shader = RadialGradient(
                colors: [
                  bokehColor.withValues(alpha: alpha),
                  bokehColor.withValues(alpha: alpha * 0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6, 1.0],
              ).createShader(Rect.fromCircle(
                center: Offset(sx, sy),
                radius: bokehRadius,
              ));

            canvas.drawCircle(Offset(sx, sy), bokehRadius, bokehPaint);
          }
        }
      }
    }

    // --- 4. Render Interconnecting Mesh Lattice Lines ---
    final Color baseLineColor = Color.lerp(
      style.silentColor,
      style.activeColor,
      0.65 + audio * 0.35,
    )!;

    final linePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (int r = 0; r < rows; r++) {
      final double v = r / (rows - 1);
      final double depthFade = (1.0 - v * 0.55).clamp(0.2, 1.0);
      final double alpha = (style.lineOpacity * depthFade * (0.75 + audio * 0.35))
          .clamp(0.05, 1.0);

      linePaint.color = baseLineColor.withValues(alpha: alpha);
      linePaint.strokeWidth = max(
        0.5,
        style.lineThickness * (1.3 - v * 0.7) * (1.0 + audio * 0.2),
      );

      for (int c = 0; c < cols; c++) {
        final int idx = (r * cols + c) * 4;
        final double x1 = _pointCache![idx];
        final double y1 = _pointCache![idx + 1];

        // Horizontal connecting line (c -> c + 1)
        if (c < cols - 1) {
          final int nextIdx = (r * cols + (c + 1)) * 4;
          final double x2 = _pointCache![nextIdx];
          final double y2 = _pointCache![nextIdx + 1];
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
        }

        // Depth connecting line (r -> r + 1)
        if (r < rows - 1) {
          final int depthIdx = ((r + 1) * cols + c) * 4;
          final double x2 = _pointCache![depthIdx];
          final double y2 = _pointCache![depthIdx + 1];
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);

          // Diagonal cross line for triangular lattice mesh
          if (c < cols - 1) {
            final int diagIdx = ((r + 1) * cols + (c + 1)) * 4;
            final double xd = _pointCache![diagIdx];
            final double yd = _pointCache![diagIdx + 1];
            final double diagAlpha = alpha * 0.55;
            linePaint.color = baseLineColor.withValues(alpha: diagAlpha);
            canvas.drawLine(Offset(x1, y1), Offset(xd, yd), linePaint);
            linePaint.color = baseLineColor.withValues(alpha: alpha);
          }
        }
      }
    }

    // --- 5. Render Crisp Foreground / Midground Node Junctions & Peak Sparkles ---
    final Color nodeColor = Color.lerp(
      style.silentColor,
      style.activeColor,
      0.85 + audio * 0.15,
    )!;

    final nodePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    for (int r = 0; r < rows; r++) {
      final double v = r / (rows - 1);
      final double depthScale = (1.25 - v * 0.75).clamp(0.35, 1.25);
      final double nodeAlpha = ((1.0 - v * 0.45) * (0.8 + audio * 0.2))
          .clamp(0.2, 1.0);

      nodePaint.color = nodeColor.withValues(alpha: nodeAlpha);

      for (int c = 0; c < cols; c++) {
        final int idx = (r * cols + c) * 4;
        final double sx = _pointCache![idx];
        final double sy = _pointCache![idx + 1];
        final double waveVal = _pointCache![idx + 3];

        final double radius = max(
          0.8,
          style.nodeGlowSize * depthScale * (1.0 + waveVal * 0.3 + audio * 0.25),
        );

        canvas.drawCircle(Offset(sx, sy), radius, nodePaint);

        // Bright white-hot sparkle highlights on wave peaks
        if (waveVal > 0.45 || (audio > 0.4 && waveVal > 0.25)) {
          final sparklePaint = Paint()
            ..color = Colors.white.withValues(alpha: (0.75 + audio * 0.25).clamp(0.0, 1.0))
            ..isAntiAlias = true;
          canvas.drawCircle(
            Offset(sx, sy),
            max(0.6, radius * 0.6),
            sparklePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant WaveMeshPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.audioEnergy != audioEnergy ||
        oldDelegate.style != style;
  }
}
