import 'dart:ui';
import 'base_orb_style.dart';

/// Configuration style specifically for the volumetric spiral galaxy particle orb visualizer.
class GalaxyOrbStyle extends BaseOrbStyle {
  /// Number of logarithmic spiral arms rotating through the accretion disk (default: 2).
  final int armCount;

  /// Tightness and curvature rate of logarithmic spiral arms (default: 1.2).
  final double spiralTightness;

  /// Relative radius of the dense, superheated stellar core bulge (default: 1.0).
  final double coreBulgeSize;

  /// Density and opacity multiplier for interstellar dust and star clusters (default: 1.0).
  final double starDustDensity;

  /// Intensity of relativistic polar plasma jet flares along the rotation axis (default: 1.0).
  final double polarJetIntensity;

  const GalaxyOrbStyle({
    super.silentColor = const Color(0xFF0B192C),
    super.activeColor = const Color(0xFF00E5FF),
    super.baseRadius = 0.24,
    super.glowIntensity = 1.0,
    super.speedMultiplier = 1.0,
    this.armCount = 2,
    this.spiralTightness = 1.2,
    this.coreBulgeSize = 1.0,
    this.starDustDensity = 1.0,
    this.polarJetIntensity = 1.0,
  });

  /// Andromeda: Deep cosmic navy with starlight cyan spiral arms.
  factory GalaxyOrbStyle.andromeda() => const GalaxyOrbStyle(
        silentColor: Color(0xFF06142E),
        activeColor: Color(0xFF38BDF8),
        baseRadius: 0.24,
        glowIntensity: 1.1,
        speedMultiplier: 1.0,
        armCount: 2,
        spiralTightness: 1.2,
        coreBulgeSize: 1.0,
        starDustDensity: 1.1,
      );

  /// Supernova: Crimson galactic core with incandescent golden ejecta.
  factory GalaxyOrbStyle.supernova() => const GalaxyOrbStyle(
        silentColor: Color(0xFF4C0519),
        activeColor: Color(0xFFFBBF24),
        baseRadius: 0.23,
        glowIntensity: 1.25,
        speedMultiplier: 1.15,
        armCount: 3,
        spiralTightness: 1.4,
        coreBulgeSize: 1.2,
        starDustDensity: 1.2,
        polarJetIntensity: 1.4,
      );

  /// Milky Way: Warm interstellar amber core with soft violet spiral lanes.
  factory GalaxyOrbStyle.milkyWay() => const GalaxyOrbStyle(
        silentColor: Color(0xFF2E1065),
        activeColor: Color(0xFFF59E0B),
        baseRadius: 0.24,
        glowIntensity: 1.0,
        speedMultiplier: 0.95,
        armCount: 2,
        spiralTightness: 1.1,
        coreBulgeSize: 0.9,
        starDustDensity: 1.0,
      );

  /// Black Hole: Dark singularity core surrounded by an ultra-bright accretion disk.
  factory GalaxyOrbStyle.blackHole() => const GalaxyOrbStyle(
        silentColor: Color(0xFF09090B),
        activeColor: Color(0xFFA855F7),
        baseRadius: 0.25,
        glowIntensity: 1.3,
        speedMultiplier: 1.2,
        armCount: 4,
        spiralTightness: 1.6,
        coreBulgeSize: 0.6,
        starDustDensity: 1.3,
        polarJetIntensity: 1.5,
      );

  /// Cosmic Nebula: Deep oceanic teal with emerald stellar dust lanes.
  factory GalaxyOrbStyle.nebula() => const GalaxyOrbStyle(
        silentColor: Color(0xFF022C22),
        activeColor: Color(0xFF2DD4BF),
        baseRadius: 0.24,
        glowIntensity: 1.05,
        speedMultiplier: 0.9,
        armCount: 2,
        spiralTightness: 1.0,
        coreBulgeSize: 1.0,
        starDustDensity: 1.25,
      );

  GalaxyOrbStyle copyWith({
    Color? silentColor,
    Color? activeColor,
    double? baseRadius,
    double? glowIntensity,
    double? speedMultiplier,
    int? armCount,
    double? spiralTightness,
    double? coreBulgeSize,
    double? starDustDensity,
    double? polarJetIntensity,
  }) {
    return GalaxyOrbStyle(
      silentColor: silentColor ?? this.silentColor,
      activeColor: activeColor ?? this.activeColor,
      baseRadius: baseRadius ?? this.baseRadius,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      armCount: armCount ?? this.armCount,
      spiralTightness: spiralTightness ?? this.spiralTightness,
      coreBulgeSize: coreBulgeSize ?? this.coreBulgeSize,
      starDustDensity: starDustDensity ?? this.starDustDensity,
      polarJetIntensity: polarJetIntensity ?? this.polarJetIntensity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is GalaxyOrbStyle &&
          runtimeType == other.runtimeType &&
          armCount == other.armCount &&
          spiralTightness == other.spiralTightness &&
          coreBulgeSize == other.coreBulgeSize &&
          starDustDensity == other.starDustDensity &&
          polarJetIntensity == other.polarJetIntensity;

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        armCount,
        spiralTightness,
        coreBulgeSize,
        starDustDensity,
        polarJetIntensity,
      );
}
