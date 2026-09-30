import 'dart:ui';
import 'base_orb_style.dart';

/// Configuration style specifically for the Quantum Flare visualizer with
/// 3D holographic particle sphere, sweeping orbital ring, and white-hot flare head.
class FlareOrbStyle extends BaseOrbStyle {
  /// Color of the sweeping plasma orbital ring and flare corona (default: cyan).
  final Color flareColor;

  /// High-intensity incandescent highlight color of the flare head nucleus (default: white).
  final Color coreHighlightColor;

  /// Relative thickness multiplier for the 3D orbital plasma ring (default: 1.0).
  final double ringThickness;

  /// Angular velocity multiplier for the orbital flare head revolution (default: 1.0).
  final double orbitalSpeed;

  /// Spatial density frequency of the holographic quantum dot lattice (default: 26.0).
  final double particleDensity;

  /// Dispersion and scattering intensity of the trailing particle wake (default: 1.0).
  final double dispersionAmount;

  /// Amplitude of background concentric acoustic soundwaves/ripples (default: 0.85).
  final double sonicRippleIntensity;

  const FlareOrbStyle({
    super.silentColor = const Color(0xFF061126),
    super.activeColor = const Color(0xFF00D4FF),
    super.baseRadius = 0.22,
    super.glowIntensity = 1.25,
    super.speedMultiplier = 1.0,
    this.flareColor = const Color(0xFF00FFFF),
    this.coreHighlightColor = const Color(0xFFFFFFFF),
    this.ringThickness = 1.0,
    this.orbitalSpeed = 1.0,
    this.particleDensity = 26.0,
    this.dispersionAmount = 1.0,
    this.sonicRippleIntensity = 0.85,
  });

  /// Quantum Blue: Electric cyan and celestial blue with incandescent white flare (matches reference).
  factory FlareOrbStyle.quantumBlue() => const FlareOrbStyle(
        silentColor: Color(0xFF061126),
        activeColor: Color(0xFF00D4FF),
        flareColor: Color(0xFF00FFFF),
        coreHighlightColor: Color(0xFFFFFFFF),
        baseRadius: 0.22,
        glowIntensity: 1.25,
        speedMultiplier: 1.0,
        ringThickness: 1.0,
        orbitalSpeed: 1.0,
        particleDensity: 26.0,
        dispersionAmount: 1.0,
        sonicRippleIntensity: 0.85,
      );

  /// Solar Corona: Fiery molten amber, solar gold, and incandescent yellow flare head.
  factory FlareOrbStyle.solarCorona() => const FlareOrbStyle(
        silentColor: Color(0xFF1E0802),
        activeColor: Color(0xFFFF5500),
        flareColor: Color(0xFFFFD000),
        coreHighlightColor: Color(0xFFFFFFEE),
        baseRadius: 0.22,
        glowIntensity: 1.3,
        speedMultiplier: 1.0,
        ringThickness: 1.1,
        orbitalSpeed: 1.05,
        particleDensity: 28.0,
        dispersionAmount: 1.1,
        sonicRippleIntensity: 0.9,
      );

  /// Neon Cyber: Cyberpunk synthwave palette with magenta particle sphere and neon cyan flare ring.
  factory FlareOrbStyle.neonCyber() => const FlareOrbStyle(
        silentColor: Color(0xFF160029),
        activeColor: Color(0xFFFF007F),
        flareColor: Color(0xFF00F0FF),
        coreHighlightColor: Color(0xFFFFFFFF),
        baseRadius: 0.22,
        glowIntensity: 1.35,
        speedMultiplier: 1.1,
        ringThickness: 1.05,
        orbitalSpeed: 1.15,
        particleDensity: 26.0,
        dispersionAmount: 1.2,
        sonicRippleIntensity: 0.8,
      );

  /// Emerald Pulse: Bio-luminescent matrix jade, emerald aurora, and aqua flare.
  factory FlareOrbStyle.emeraldPulse() => const FlareOrbStyle(
        silentColor: Color(0xFF021B14),
        activeColor: Color(0xFF00F5A0),
        flareColor: Color(0xFF00D9F5),
        coreHighlightColor: Color(0xFFFFFFFF),
        baseRadius: 0.22,
        glowIntensity: 1.25,
        speedMultiplier: 0.95,
        ringThickness: 0.95,
        orbitalSpeed: 0.95,
        particleDensity: 24.0,
        dispersionAmount: 0.95,
        sonicRippleIntensity: 0.85,
      );

  /// Supernova: Deep ultraviolet nebula with high-energy magenta flare and golden starlight nucleus.
  factory FlareOrbStyle.supernova() => const FlareOrbStyle(
        silentColor: Color(0xFF1B032A),
        activeColor: Color(0xFFBF00FF),
        flareColor: Color(0xFFFF0077),
        coreHighlightColor: Color(0xFFFFF0AA),
        baseRadius: 0.22,
        glowIntensity: 1.35,
        speedMultiplier: 1.05,
        ringThickness: 1.15,
        orbitalSpeed: 1.1,
        particleDensity: 30.0,
        dispersionAmount: 1.25,
        sonicRippleIntensity: 0.95,
      );

  FlareOrbStyle copyWith({
    Color? silentColor,
    Color? activeColor,
    Color? flareColor,
    Color? coreHighlightColor,
    double? baseRadius,
    double? glowIntensity,
    double? speedMultiplier,
    double? ringThickness,
    double? orbitalSpeed,
    double? particleDensity,
    double? dispersionAmount,
    double? sonicRippleIntensity,
  }) {
    return FlareOrbStyle(
      silentColor: silentColor ?? this.silentColor,
      activeColor: activeColor ?? this.activeColor,
      flareColor: flareColor ?? this.flareColor,
      coreHighlightColor: coreHighlightColor ?? this.coreHighlightColor,
      baseRadius: baseRadius ?? this.baseRadius,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      ringThickness: ringThickness ?? this.ringThickness,
      orbitalSpeed: orbitalSpeed ?? this.orbitalSpeed,
      particleDensity: particleDensity ?? this.particleDensity,
      dispersionAmount: dispersionAmount ?? this.dispersionAmount,
      sonicRippleIntensity: sonicRippleIntensity ?? this.sonicRippleIntensity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is FlareOrbStyle &&
          runtimeType == other.runtimeType &&
          flareColor == other.flareColor &&
          coreHighlightColor == other.coreHighlightColor &&
          ringThickness == other.ringThickness &&
          orbitalSpeed == other.orbitalSpeed &&
          particleDensity == other.particleDensity &&
          dispersionAmount == other.dispersionAmount &&
          sonicRippleIntensity == other.sonicRippleIntensity;

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        flareColor,
        coreHighlightColor,
        ringThickness,
        orbitalSpeed,
        particleDensity,
        dispersionAmount,
        sonicRippleIntensity,
      );
}
