import 'dart:ui';
import 'base_orb_style.dart';

/// Configuration style specifically for the raymarched liquid metaball orb visualizer.
class LiquidOrbStyle extends BaseOrbStyle {
  /// Viscosity / smooth minimum blending factor `k` determining how fluidly droplets merge.
  /// Higher values result in thicker, stickier fluid coalescence (default: 0.85).
  final double viscosity;

  /// Relative scale of the orbiting satellite droplets compared to the central core (default: 0.45).
  final double blobScale;

  /// Sharpness and intensity of the metallic / wet specular highlights (default: 1.0).
  final double specularShininess;

  /// Subsurface scattering radiance diffusing through the translucent liquid body (default: 0.8).
  final double refractiveGlow;

  /// Harmonic frequency and speed of procedural surface wobbles and ripples (default: 1.0).
  final double wobbleFrequency;

  const LiquidOrbStyle({
    super.silentColor = const Color(0xFF0F1B3B),
    super.activeColor = const Color(0xFF00E5FF),
    super.baseRadius = 0.22,
    super.glowIntensity = 1.0,
    super.speedMultiplier = 1.0,
    this.viscosity = 0.85,
    this.blobScale = 0.45,
    this.specularShininess = 1.0,
    this.refractiveGlow = 0.8,
    this.wobbleFrequency = 1.0,
  });

  /// Liquid Mercury: Molten chrome/silver with electric blue rim glow.
  factory LiquidOrbStyle.mercury() => const LiquidOrbStyle(
        silentColor: Color(0xFF1E293B),
        activeColor: Color(0xFF38BDF8),
        baseRadius: 0.22,
        glowIntensity: 1.1,
        speedMultiplier: 1.0,
        viscosity: 0.9,
        blobScale: 0.48,
        specularShininess: 1.4,
        refractiveGlow: 0.7,
      );

  /// Molten Lava: Obsidian core with glowing magma orange crests.
  factory LiquidOrbStyle.lava() => const LiquidOrbStyle(
        silentColor: Color(0xFF450A0A),
        activeColor: Color(0xFFF97316),
        baseRadius: 0.23,
        glowIntensity: 1.2,
        speedMultiplier: 0.9,
        viscosity: 0.95,
        blobScale: 0.42,
        specularShininess: 0.8,
        refractiveGlow: 1.2,
      );

  /// Cosmic Plasma: Deep violet core to hot neon pink fluid.
  factory LiquidOrbStyle.plasma() => const LiquidOrbStyle(
        silentColor: Color(0xFF3B0764),
        activeColor: Color(0xFFEC4899),
        baseRadius: 0.22,
        glowIntensity: 1.15,
        speedMultiplier: 1.1,
        viscosity: 0.8,
        blobScale: 0.46,
        specularShininess: 1.1,
        refractiveGlow: 0.9,
      );

  /// Toxic Slime: Radioactive dark emerald with vivid lime green luminescence.
  factory LiquidOrbStyle.toxicSlime() => const LiquidOrbStyle(
        silentColor: Color(0xFF052E16),
        activeColor: Color(0xFF22C55E),
        baseRadius: 0.24,
        glowIntensity: 1.05,
        speedMultiplier: 0.95,
        viscosity: 1.1,
        blobScale: 0.5,
        specularShininess: 1.2,
        refractiveGlow: 1.0,
      );

  /// Royal Amethyst: Deep midnight indigo with ethereal violet glow.
  factory LiquidOrbStyle.amethyst() => const LiquidOrbStyle(
        silentColor: Color(0xFF1E1B4B),
        activeColor: Color(0xFFA855F7),
        baseRadius: 0.22,
        glowIntensity: 1.0,
        speedMultiplier: 1.0,
        viscosity: 0.85,
        blobScale: 0.44,
        specularShininess: 1.0,
        refractiveGlow: 0.85,
      );

  LiquidOrbStyle copyWith({
    Color? silentColor,
    Color? activeColor,
    double? baseRadius,
    double? glowIntensity,
    double? speedMultiplier,
    double? viscosity,
    double? blobScale,
    double? specularShininess,
    double? refractiveGlow,
    double? wobbleFrequency,
  }) {
    return LiquidOrbStyle(
      silentColor: silentColor ?? this.silentColor,
      activeColor: activeColor ?? this.activeColor,
      baseRadius: baseRadius ?? this.baseRadius,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      viscosity: viscosity ?? this.viscosity,
      blobScale: blobScale ?? this.blobScale,
      specularShininess: specularShininess ?? this.specularShininess,
      refractiveGlow: refractiveGlow ?? this.refractiveGlow,
      wobbleFrequency: wobbleFrequency ?? this.wobbleFrequency,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is LiquidOrbStyle &&
          runtimeType == other.runtimeType &&
          viscosity == other.viscosity &&
          blobScale == other.blobScale &&
          specularShininess == other.specularShininess &&
          refractiveGlow == other.refractiveGlow &&
          wobbleFrequency == other.wobbleFrequency;

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        viscosity,
        blobScale,
        specularShininess,
        refractiveGlow,
        wobbleFrequency,
      );
}
