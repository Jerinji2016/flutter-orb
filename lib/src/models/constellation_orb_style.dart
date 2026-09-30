import 'dart:ui';
import 'base_orb_style.dart';

/// Configuration style specifically for the 2D dynamic constellation network mesh visualizer.
class ConstellationOrbStyle extends BaseOrbStyle {
  /// Number of autonomous dynamic particle nodes wandering in the field (default: 60).
  final int particleCount;

  /// Maximum pixel distance below which nodes connect with a proximity line (default: 85.0).
  final double maxConnectionDistance;

  /// Movement velocity multiplier for drifting particles (default: 1.0).
  final double particleSpeed;

  /// Base visual radius of individual particle nodes (default: 2.8).
  final double particleRadius;

  /// Stroke width of proximity connecting lines (default: 1.0).
  final double lineThickness;

  /// Multiplier for the glow and brightness of proximity connecting lines (default: 1.0).
  final double lineGlowIntensity;

  /// Dynamic impulse force scaling particle speed, pulse size, and ripple aura on loud audio (default: 1.5).
  final double audioImpulseForce;

  /// Whether to render a soft ambient backdrop halo (default: true).
  final bool showBoundaryGlow;

  /// Normalized bounds radius within the widget canvas [0.1 - 0.5] (default: 0.44).
  final double interactionRadius;

  const ConstellationOrbStyle({
    super.silentColor = const Color(0xFF0F172A),
    super.activeColor = const Color(0xFF38BDF8),
    super.baseRadius = 0.28,
    super.glowIntensity = 1.2,
    super.speedMultiplier = 1.0,
    this.particleCount = 60,
    this.maxConnectionDistance = 85.0,
    this.particleSpeed = 1.0,
    this.particleRadius = 2.8,
    this.lineThickness = 1.0,
    this.lineGlowIntensity = 1.0,
    this.audioImpulseForce = 1.5,
    this.showBoundaryGlow = true,
    this.interactionRadius = 0.44,
  });

  /// Deep Space: Midnight navy backdrop with celestial cyan nodes and star charts.
  factory ConstellationOrbStyle.deepSpace() => const ConstellationOrbStyle(
        silentColor: Color(0xFF0B132B),
        activeColor: Color(0xFF4CC9F0),
        baseRadius: 0.28,
        glowIntensity: 1.25,
        speedMultiplier: 1.0,
        particleCount: 65,
        maxConnectionDistance: 90.0,
        particleSpeed: 1.0,
        particleRadius: 2.8,
        lineThickness: 1.0,
        lineGlowIntensity: 1.1,
        audioImpulseForce: 1.5,
        showBoundaryGlow: true,
      );

  /// Neural Synapse: Deep purple cortex with electric magenta synaptic spikes.
  factory ConstellationOrbStyle.neuralSynapse() => const ConstellationOrbStyle(
        silentColor: Color(0xFF2E0854),
        activeColor: Color(0xFFF72585),
        baseRadius: 0.28,
        glowIntensity: 1.3,
        speedMultiplier: 1.1,
        particleCount: 70,
        maxConnectionDistance: 82.0,
        particleSpeed: 1.15,
        particleRadius: 3.0,
        lineThickness: 1.15,
        lineGlowIntensity: 1.2,
        audioImpulseForce: 1.6,
        showBoundaryGlow: true,
      );

  /// Matrix Nodes: Terminal slate black with glowing emerald data packets.
  factory ConstellationOrbStyle.matrixNodes() => const ConstellationOrbStyle(
        silentColor: Color(0xFF022C22),
        activeColor: Color(0xFF10B981),
        baseRadius: 0.28,
        glowIntensity: 1.2,
        speedMultiplier: 0.95,
        particleCount: 60,
        maxConnectionDistance: 85.0,
        particleSpeed: 0.95,
        particleRadius: 2.6,
        lineThickness: 0.95,
        lineGlowIntensity: 1.1,
        audioImpulseForce: 1.4,
        showBoundaryGlow: true,
      );

  /// Quantum Amber: Warm bronze obsidian with radiant gold energy linkages.
  factory ConstellationOrbStyle.quantumAmber() => const ConstellationOrbStyle(
        silentColor: Color(0xFF261501),
        activeColor: Color(0xFFF59E0B),
        baseRadius: 0.28,
        glowIntensity: 1.25,
        speedMultiplier: 1.0,
        particleCount: 65,
        maxConnectionDistance: 88.0,
        particleSpeed: 1.0,
        particleRadius: 2.9,
        lineThickness: 1.05,
        lineGlowIntensity: 1.15,
        audioImpulseForce: 1.5,
        showBoundaryGlow: true,
      );

  ConstellationOrbStyle copyWith({
    Color? silentColor,
    Color? activeColor,
    double? baseRadius,
    double? glowIntensity,
    double? speedMultiplier,
    int? particleCount,
    double? maxConnectionDistance,
    double? particleSpeed,
    double? particleRadius,
    double? lineThickness,
    double? lineGlowIntensity,
    double? audioImpulseForce,
    bool? showBoundaryGlow,
    double? interactionRadius,
  }) {
    return ConstellationOrbStyle(
      silentColor: silentColor ?? this.silentColor,
      activeColor: activeColor ?? this.activeColor,
      baseRadius: baseRadius ?? this.baseRadius,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      particleCount: particleCount ?? this.particleCount,
      maxConnectionDistance: maxConnectionDistance ?? this.maxConnectionDistance,
      particleSpeed: particleSpeed ?? this.particleSpeed,
      particleRadius: particleRadius ?? this.particleRadius,
      lineThickness: lineThickness ?? this.lineThickness,
      lineGlowIntensity: lineGlowIntensity ?? this.lineGlowIntensity,
      audioImpulseForce: audioImpulseForce ?? this.audioImpulseForce,
      showBoundaryGlow: showBoundaryGlow ?? this.showBoundaryGlow,
      interactionRadius: interactionRadius ?? this.interactionRadius,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ConstellationOrbStyle &&
          runtimeType == other.runtimeType &&
          particleCount == other.particleCount &&
          maxConnectionDistance == other.maxConnectionDistance &&
          particleSpeed == other.particleSpeed &&
          particleRadius == other.particleRadius &&
          lineThickness == other.lineThickness &&
          lineGlowIntensity == other.lineGlowIntensity &&
          audioImpulseForce == other.audioImpulseForce &&
          showBoundaryGlow == other.showBoundaryGlow &&
          interactionRadius == other.interactionRadius;

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        particleCount,
        maxConnectionDistance,
        particleSpeed,
        particleRadius,
        lineThickness,
        lineGlowIntensity,
        audioImpulseForce,
        showBoundaryGlow,
        interactionRadius,
      );
}
