import 'dart:ui';
import 'base_orb_style.dart';

/// Configuration style specifically for the radial frequency equalizer and audio spectrum ribbons visualizer.
class SpectrumOrbStyle extends BaseOrbStyle {
  /// Number of radial frequency bars distributed evenly around the circumference (default: 48).
  final int barCount;

  /// Multiplier scale for radial equalizer bar height at peak audio volume (default: 1.0).
  final double barHeightScale;

  /// Relative angular width and spacing factor of individual frequency bars (default: 1.0).
  final double barWidth;

  /// Stroke width and glow thickness of the concentric oscillating waveform ribbons (default: 1.0).
  final double ribbonThickness;

  /// Decay rate and gravity falloff for floating neon peak dots (default: 1.0).
  final double peakDecayRate;

  const SpectrumOrbStyle({
    super.silentColor = const Color(0xFF0F172A),
    super.activeColor = const Color(0xFF00E5FF),
    super.baseRadius = 0.22,
    super.glowIntensity = 1.0,
    super.speedMultiplier = 1.0,
    this.barCount = 48,
    this.barHeightScale = 1.0,
    this.barWidth = 1.0,
    this.ribbonThickness = 1.0,
    this.peakDecayRate = 1.0,
  });

  /// Neon Equalizer: High-energy electric cyan and vibrant cobalt blue equalizer.
  factory SpectrumOrbStyle.neonEqualizer() => const SpectrumOrbStyle(
        silentColor: Color(0xFF032B44),
        activeColor: Color(0xFF00F0FF),
        baseRadius: 0.22,
        glowIntensity: 1.15,
        speedMultiplier: 1.05,
        barCount: 48,
        barHeightScale: 1.1,
        barWidth: 1.0,
        ribbonThickness: 1.1,
      );

  /// Sunset Echo: Deep royal purple to radiant sunset amber ribbons and bars.
  factory SpectrumOrbStyle.sunsetEcho() => const SpectrumOrbStyle(
        silentColor: Color(0xFF4C0519),
        activeColor: Color(0xFFFB923C),
        baseRadius: 0.23,
        glowIntensity: 1.2,
        speedMultiplier: 1.0,
        barCount: 40,
        barHeightScale: 1.2,
        barWidth: 1.1,
        ribbonThickness: 1.2,
      );

  /// Vaporwave: Retro pastel violet to electric mint turquoise wave visualizer.
  factory SpectrumOrbStyle.vaporwave() => const SpectrumOrbStyle(
        silentColor: Color(0xFF4A044E),
        activeColor: Color(0xFF2DD4BF),
        baseRadius: 0.22,
        glowIntensity: 1.1,
        speedMultiplier: 0.95,
        barCount: 56,
        barHeightScale: 1.0,
        barWidth: 0.9,
        ribbonThickness: 1.0,
      );

  /// Radiant Green: Deep emerald core with intense radioactive lime frequency bars.
  factory SpectrumOrbStyle.radiantGreen() => const SpectrumOrbStyle(
        silentColor: Color(0xFF052E16),
        activeColor: Color(0xFF4ADE80),
        baseRadius: 0.22,
        glowIntensity: 1.1,
        speedMultiplier: 1.0,
        barCount: 48,
        barHeightScale: 1.15,
        barWidth: 1.0,
        ribbonThickness: 1.0,
      );

  /// Minimal Monochrome: Crisp dark slate with pure white illuminated peak caps.
  factory SpectrumOrbStyle.monochrome() => const SpectrumOrbStyle(
        silentColor: Color(0xFF1E293B),
        activeColor: Color(0xFFFFFFFF),
        baseRadius: 0.22,
        glowIntensity: 0.9,
        speedMultiplier: 0.85,
        barCount: 36,
        barHeightScale: 0.95,
        barWidth: 1.2,
        ribbonThickness: 0.9,
      );

  SpectrumOrbStyle copyWith({
    Color? silentColor,
    Color? activeColor,
    double? baseRadius,
    double? glowIntensity,
    double? speedMultiplier,
    int? barCount,
    double? barHeightScale,
    double? barWidth,
    double? ribbonThickness,
    double? peakDecayRate,
  }) {
    return SpectrumOrbStyle(
      silentColor: silentColor ?? this.silentColor,
      activeColor: activeColor ?? this.activeColor,
      baseRadius: baseRadius ?? this.baseRadius,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      barCount: barCount ?? this.barCount,
      barHeightScale: barHeightScale ?? this.barHeightScale,
      barWidth: barWidth ?? this.barWidth,
      ribbonThickness: ribbonThickness ?? this.ribbonThickness,
      peakDecayRate: peakDecayRate ?? this.peakDecayRate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is SpectrumOrbStyle &&
          runtimeType == other.runtimeType &&
          barCount == other.barCount &&
          barHeightScale == other.barHeightScale &&
          barWidth == other.barWidth &&
          ribbonThickness == other.ribbonThickness &&
          peakDecayRate == other.peakDecayRate;

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        barCount,
        barHeightScale,
        barWidth,
        ribbonThickness,
        peakDecayRate,
      );
}
