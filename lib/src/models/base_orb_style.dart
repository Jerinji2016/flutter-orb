import 'dart:ui';

/// Abstract base configuration style for all visualizer orb types.
abstract class BaseOrbStyle {
  /// The base color of the orb when silent or idle (low audio energy).
  final Color silentColor;

  /// The active color of the orb when loud or active (high audio energy).
  final Color activeColor;

  /// The base normalized radius of the central visualizer core.
  final double baseRadius;

  /// Multiplier for bloom, emission, and atmospheric glow.
  final double glowIntensity;

  /// Multiplier for animation, rotation, and wave frequency speed.
  final double speedMultiplier;

  const BaseOrbStyle({
    required this.silentColor,
    required this.activeColor,
    this.baseRadius = 0.24,
    this.glowIntensity = 1.0,
    this.speedMultiplier = 1.0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseOrbStyle &&
          runtimeType == other.runtimeType &&
          silentColor == other.silentColor &&
          activeColor == other.activeColor &&
          baseRadius == other.baseRadius &&
          glowIntensity == other.glowIntensity &&
          speedMultiplier == other.speedMultiplier;

  @override
  int get hashCode => Object.hash(
        silentColor,
        activeColor,
        baseRadius,
        glowIntensity,
        speedMultiplier,
      );
}
