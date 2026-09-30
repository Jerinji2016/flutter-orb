import 'dart:ui';
import 'base_orb_style.dart';

/// Configuration style specifically for the 3D particle sphere orb visualizer.
class ParticleOrbStyle extends BaseOrbStyle {
  /// Altitude turbulence and height randomness of particles in silent/idle state.
  ///
  /// - `0.0`: Geometrically perfect, smooth 3D particle sphere surface.
  /// - `0.15` - `0.3`: Subtle, gentle surface shimmer and micro-breathing.
  /// - `1.0`: Full randomized particle altitude dispersion.
  final double idleTurbulence;

  /// Number of 3D pinpoint particles rendered on the sphere surface (default: 5500).
  final int particleCount;

  /// Diameter of each individual pinpoint particle in pixels (default: 1.8).
  final double particleSize;

  /// Spatial frequency of procedural 3D surface wave undulations (default: 1.6).
  final double waveFrequency;

  /// Amplitude multiplier for 3D surface wave undulations (default: 0.12).
  final double waveAmplitude;

  const ParticleOrbStyle({
    super.silentColor = const Color(0xFF0D2566),
    super.activeColor = const Color(0xFF00E5FF),
    super.baseRadius = 0.24,
    super.glowIntensity = 1.0,
    super.speedMultiplier = 1.0,
    this.idleTurbulence = 0.0,
    this.particleCount = 5500,
    this.particleSize = 1.8,
    this.waveFrequency = 1.6,
    this.waveAmplitude = 0.12,
  });

  /// Deep Electric Blue / Neon Cyan Wave Particle Sphere (Matches reference).
  factory ParticleOrbStyle.gemini() => const ParticleOrbStyle(
        silentColor: Color(0xFF0A2266),
        activeColor: Color(0xFF00E5FF),
        baseRadius: 0.24,
        glowIntensity: 1.0,
        speedMultiplier: 1.0,
        particleCount: 5500,
        particleSize: 1.8,
        waveFrequency: 1.6,
        waveAmplitude: 0.12,
      );

  /// Cyberpunk Neon Magenta & Electric Teal.
  factory ParticleOrbStyle.cyberpunk() => const ParticleOrbStyle(
        silentColor: Color(0xFF990066),
        activeColor: Color(0xFF00FFCC),
        baseRadius: 0.24,
        glowIntensity: 1.1,
        speedMultiplier: 1.1,
        particleCount: 5500,
        particleSize: 1.8,
        waveFrequency: 1.8,
        waveAmplitude: 0.14,
      );

  /// Solar Flare Crimson & Radiant Gold.
  factory ParticleOrbStyle.solar() => const ParticleOrbStyle(
        silentColor: Color(0xFFC62828),
        activeColor: Color(0xFFFFD54F),
        baseRadius: 0.23,
        glowIntensity: 1.1,
        speedMultiplier: 0.95,
        particleCount: 5500,
        particleSize: 1.8,
        waveFrequency: 1.5,
        waveAmplitude: 0.13,
      );

  /// Emerald Deep Teal & Vivid Mint.
  factory ParticleOrbStyle.emerald() => const ParticleOrbStyle(
        silentColor: Color(0xFF00382B),
        activeColor: Color(0xFF00E676),
        baseRadius: 0.24,
        glowIntensity: 1.0,
        speedMultiplier: 1.0,
        particleCount: 5500,
        particleSize: 1.8,
        waveFrequency: 1.6,
        waveAmplitude: 0.12,
      );

  /// Neon Rose Royal Purple & Hot Pink.
  factory ParticleOrbStyle.neonRose() => const ParticleOrbStyle(
        silentColor: Color(0xFF3B096C),
        activeColor: Color(0xFFFF1493),
        baseRadius: 0.24,
        glowIntensity: 1.1,
        speedMultiplier: 1.05,
        particleCount: 5500,
        particleSize: 1.8,
        waveFrequency: 1.7,
        waveAmplitude: 0.13,
      );

  /// Sleek Monochrome Slate & Radiant White.
  factory ParticleOrbStyle.monochrome() => const ParticleOrbStyle(
        silentColor: Color(0xFF263238),
        activeColor: Color(0xFFFFFFFF),
        baseRadius: 0.24,
        glowIntensity: 0.9,
        speedMultiplier: 0.85,
        particleCount: 5500,
        particleSize: 1.8,
        waveFrequency: 1.6,
        waveAmplitude: 0.11,
      );

  ParticleOrbStyle copyWith({
    Color? silentColor,
    Color? activeColor,
    double? baseRadius,
    double? glowIntensity,
    double? speedMultiplier,
    double? idleTurbulence,
    int? particleCount,
    double? particleSize,
    double? waveFrequency,
    double? waveAmplitude,
  }) {
    return ParticleOrbStyle(
      silentColor: silentColor ?? this.silentColor,
      activeColor: activeColor ?? this.activeColor,
      baseRadius: baseRadius ?? this.baseRadius,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      idleTurbulence: idleTurbulence ?? this.idleTurbulence,
      particleCount: particleCount ?? this.particleCount,
      particleSize: particleSize ?? this.particleSize,
      waveFrequency: waveFrequency ?? this.waveFrequency,
      waveAmplitude: waveAmplitude ?? this.waveAmplitude,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ParticleOrbStyle &&
          runtimeType == other.runtimeType &&
          idleTurbulence == other.idleTurbulence &&
          particleCount == other.particleCount &&
          particleSize == other.particleSize &&
          waveFrequency == other.waveFrequency &&
          waveAmplitude == other.waveAmplitude;

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        idleTurbulence,
        particleCount,
        particleSize,
        waveFrequency,
        waveAmplitude,
      );
}

/// Backwards-compatible type alias for [ParticleOrbStyle].
typedef OrbStyle = ParticleOrbStyle;
