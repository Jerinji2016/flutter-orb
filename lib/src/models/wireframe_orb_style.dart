import 'dart:ui';
import 'base_orb_style.dart';

/// Configuration style specifically for the holographic geodesic grid wireframe orb visualizer.
class WireframeOrbStyle extends BaseOrbStyle {
  /// Density / frequency of the geodesic lattice divisions (default: 18.0).
  final double gridDensity;

  /// Stroke thickness of the projected 3D wireframe grid lines (default: 1.0).
  final double lineThickness;

  /// Size and halo intensity of glowing vertex nodes at grid intersections (default: 1.0).
  final double vertexGlowSize;

  /// Opacity and depth of the horizontal CRT holographic scanline interference (default: 0.4).
  final double scanlineIntensity;

  /// Sensitivity of chromatic aberration jitter on loud audio transients (default: 0.5).
  final double glitchIntensity;

  const WireframeOrbStyle({
    super.silentColor = const Color(0xFFD900FF),
    super.activeColor = const Color(0xFF00E5FF),
    super.baseRadius = 0.24,
    super.glowIntensity = 1.1,
    super.speedMultiplier = 1.0,
    this.gridDensity = 18.0,
    this.lineThickness = 1.0,
    this.vertexGlowSize = 1.0,
    this.scanlineIntensity = 0.35,
    this.glitchIntensity = 0.5,
  });

  /// Hologram: Iconic dual-tone cyan & magenta undulating 3D wireframe mesh with vertex nodes.
  factory WireframeOrbStyle.hologram() => const WireframeOrbStyle(
        silentColor: Color(0xFFD900FF),
        activeColor: Color(0xFF00E5FF),
        baseRadius: 0.24,
        glowIntensity: 1.15,
        speedMultiplier: 1.0,
        gridDensity: 18.0,
        lineThickness: 1.0,
        vertexGlowSize: 1.1,
        scanlineIntensity: 0.35,
      );

  /// Matrix: Terminal black with luminous green phosphor nodes.
  factory WireframeOrbStyle.matrix() => const WireframeOrbStyle(
        silentColor: Color(0xFF022C22),
        activeColor: Color(0xFF22C55E),
        baseRadius: 0.24,
        glowIntensity: 1.15,
        speedMultiplier: 1.05,
        gridDensity: 20.0,
        lineThickness: 0.9,
        vertexGlowSize: 1.3,
        scanlineIntensity: 0.5,
      );

  /// Cyber Lattice: Synthwave neon magenta with electric cyan vertices.
  factory WireframeOrbStyle.cyberLattice() => const WireframeOrbStyle(
        silentColor: Color(0xFF581C87),
        activeColor: Color(0xFFF43F5E),
        baseRadius: 0.24,
        glowIntensity: 1.2,
        speedMultiplier: 1.1,
        gridDensity: 16.0,
        lineThickness: 1.2,
        vertexGlowSize: 1.2,
        scanlineIntensity: 0.35,
      );

  /// Golden Cortex: Warm amber neural network lattice in radiant 24k gold.
  factory WireframeOrbStyle.goldenCortex() => const WireframeOrbStyle(
        silentColor: Color(0xFF451A03),
        activeColor: Color(0xFFFBBF24),
        baseRadius: 0.24,
        glowIntensity: 1.1,
        speedMultiplier: 0.9,
        gridDensity: 18.0,
        lineThickness: 1.0,
        vertexGlowSize: 1.0,
        scanlineIntensity: 0.3,
      );

  /// Stealth Red: Dark carbon charcoal with sharp laser crimson grid lines.
  factory WireframeOrbStyle.stealthRed() => const WireframeOrbStyle(
        silentColor: Color(0xFF18181B),
        activeColor: Color(0xFFEF4444),
        baseRadius: 0.24,
        glowIntensity: 1.2,
        speedMultiplier: 1.0,
        gridDensity: 22.0,
        lineThickness: 0.85,
        vertexGlowSize: 1.2,
        scanlineIntensity: 0.45,
      );

  WireframeOrbStyle copyWith({
    Color? silentColor,
    Color? activeColor,
    double? baseRadius,
    double? glowIntensity,
    double? speedMultiplier,
    double? gridDensity,
    double? lineThickness,
    double? vertexGlowSize,
    double? scanlineIntensity,
    double? glitchIntensity,
  }) {
    return WireframeOrbStyle(
      silentColor: silentColor ?? this.silentColor,
      activeColor: activeColor ?? this.activeColor,
      baseRadius: baseRadius ?? this.baseRadius,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      gridDensity: gridDensity ?? this.gridDensity,
      lineThickness: lineThickness ?? this.lineThickness,
      vertexGlowSize: vertexGlowSize ?? this.vertexGlowSize,
      scanlineIntensity: scanlineIntensity ?? this.scanlineIntensity,
      glitchIntensity: glitchIntensity ?? this.glitchIntensity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is WireframeOrbStyle &&
          runtimeType == other.runtimeType &&
          gridDensity == other.gridDensity &&
          lineThickness == other.lineThickness &&
          vertexGlowSize == other.vertexGlowSize &&
          scanlineIntensity == other.scanlineIntensity &&
          glitchIntensity == other.glitchIntensity;

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        gridDensity,
        lineThickness,
        vertexGlowSize,
        scanlineIntensity,
        glitchIntensity,
      );
}
