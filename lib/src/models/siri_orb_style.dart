import 'dart:ui';
import 'base_orb_style.dart';

/// Configuration style specifically for the Apple Siri iridescent chromatic fluid glow visualizer.
class SiriOrbStyle extends BaseOrbStyle {
  /// Third accent color in the chromatic spectral rotation (default: neon magenta/pink).
  final Color tertiaryColor;

  /// Fourth accent color in the chromatic spectral rotation (default: solar amber/gold).
  final Color quaternaryColor;

  /// Multiplier for chromatic aberration and RGB spectral dispersion (default: 1.2).
  final double chromaticIntensity;

  /// Angular velocity and vortex swirl multiplier of internal fluid streams (default: 1.0).
  final double fluidSwirlSpeed;

  /// Softness and diffuse bloom radius of the outer glowing fluid boundary (default: 0.35).
  final double edgeBlur;

  /// Amplitude of audio-reactive organic surface displacement and wave ripples (default: 0.45).
  final double waveDeformation;

  const SiriOrbStyle({
    super.silentColor = const Color(0xFF0F081D),
    super.activeColor = const Color(0xFF007AFF),
    super.baseRadius = 0.24,
    super.glowIntensity = 1.25,
    super.speedMultiplier = 1.0,
    this.tertiaryColor = const Color(0xFFFF2D55),
    this.quaternaryColor = const Color(0xFF30D158),
    this.chromaticIntensity = 1.0,
    this.fluidSwirlSpeed = 1.0,
    this.edgeBlur = 0.35,
    this.waveDeformation = 1.0,
  });

  /// Apple Classic: Iconic Apple Siri 3D undulating silk ribbon waves (Electric Blue, Crimson, Emerald, Obsidian).
  factory SiriOrbStyle.appleClassic() => const SiriOrbStyle(
        silentColor: Color(0xFF0F081D),
        activeColor: Color(0xFF007AFF),
        tertiaryColor: Color(0xFFFF2D55),
        quaternaryColor: Color(0xFF30D158),
        baseRadius: 0.24,
        glowIntensity: 1.25,
        speedMultiplier: 1.0,
        chromaticIntensity: 1.0,
        fluidSwirlSpeed: 1.0,
        edgeBlur: 0.35,
        waveDeformation: 1.0,
      );

  /// Cosmic Aurora: Boreal emerald and jade with electric blue and deep violet vortices.
  factory SiriOrbStyle.cosmicAurora() => const SiriOrbStyle(
        silentColor: Color(0xFF031B28),
        activeColor: Color(0xFF00F5D4),
        tertiaryColor: Color(0xFF7B2CBF),
        quaternaryColor: Color(0xFF3A86FF),
        baseRadius: 0.24,
        glowIntensity: 1.2,
        speedMultiplier: 0.95,
        chromaticIntensity: 1.15,
        fluidSwirlSpeed: 0.95,
        edgeBlur: 0.38,
        waveDeformation: 0.42,
      );

  /// Electric Prism: Hyper-vibrant rainbow chromatic dispersion and neon laser flares.
  factory SiriOrbStyle.electricPrism() => const SiriOrbStyle(
        silentColor: Color(0xFF160029),
        activeColor: Color(0xFF00E5FF),
        tertiaryColor: Color(0xFFFF007F),
        quaternaryColor: Color(0xFFFFE600),
        baseRadius: 0.24,
        glowIntensity: 1.35,
        speedMultiplier: 1.1,
        chromaticIntensity: 1.45,
        fluidSwirlSpeed: 1.15,
        edgeBlur: 0.32,
        waveDeformation: 0.50,
      );

  /// Sunset Glow: Warm velvet wine with radiating sunset orange, rose magenta, and solar gold.
  factory SiriOrbStyle.sunsetGlow() => const SiriOrbStyle(
        silentColor: Color(0xFF2E0219),
        activeColor: Color(0xFFFF5E36),
        tertiaryColor: Color(0xFFFF007F),
        quaternaryColor: Color(0xFFFFAA00),
        baseRadius: 0.24,
        glowIntensity: 1.25,
        speedMultiplier: 1.0,
        chromaticIntensity: 1.1,
        fluidSwirlSpeed: 1.0,
        edgeBlur: 0.36,
        waveDeformation: 0.45,
      );

  SiriOrbStyle copyWith({
    Color? silentColor,
    Color? activeColor,
    Color? tertiaryColor,
    Color? quaternaryColor,
    double? baseRadius,
    double? glowIntensity,
    double? speedMultiplier,
    double? chromaticIntensity,
    double? fluidSwirlSpeed,
    double? edgeBlur,
    double? waveDeformation,
  }) {
    return SiriOrbStyle(
      silentColor: silentColor ?? this.silentColor,
      activeColor: activeColor ?? this.activeColor,
      tertiaryColor: tertiaryColor ?? this.tertiaryColor,
      quaternaryColor: quaternaryColor ?? this.quaternaryColor,
      baseRadius: baseRadius ?? this.baseRadius,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      chromaticIntensity: chromaticIntensity ?? this.chromaticIntensity,
      fluidSwirlSpeed: fluidSwirlSpeed ?? this.fluidSwirlSpeed,
      edgeBlur: edgeBlur ?? this.edgeBlur,
      waveDeformation: waveDeformation ?? this.waveDeformation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is SiriOrbStyle &&
          runtimeType == other.runtimeType &&
          tertiaryColor == other.tertiaryColor &&
          quaternaryColor == other.quaternaryColor &&
          chromaticIntensity == other.chromaticIntensity &&
          fluidSwirlSpeed == other.fluidSwirlSpeed &&
          edgeBlur == other.edgeBlur &&
          waveDeformation == other.waveDeformation;

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        tertiaryColor,
        quaternaryColor,
        chromaticIntensity,
        fluidSwirlSpeed,
        edgeBlur,
        waveDeformation,
      );
}
