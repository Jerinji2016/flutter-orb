import 'dart:ui';
import 'base_orb_style.dart';

/// Configuration style specifically for the 2.5D perspective undulating wave mesh visualizer.
class WaveMeshOrbStyle extends BaseOrbStyle {
  /// Number of grid rows along the depth / Z axis (default: 28).
  final int gridRows;

  /// Number of grid columns along the width / X axis (default: 44).
  final int gridColumns;

  /// Vertical wave crest amplitude displacement multiplier (default: 0.28).
  final double waveAmplitude;

  /// Spatial frequency of wave ripples and undulating harmonics (default: 1.8).
  final double waveFrequency;

  /// Camera perspective pitch tilt in radians (default: 0.68, ~39 degrees).
  final double perspectivePitch;

  /// Strength and diameter of the out-of-focus background bokeh discs (default: 0.8).
  final double depthOfField;

  /// Normalized Z depth where the mesh is in sharpest focal clarity [0.0 - 1.0] (default: 0.45).
  final double focalDistance;

  /// Base dot radius of glowing lattice junction vertices (default: 2.2).
  final double nodeGlowSize;

  /// Stroke thickness of the interconnecting wire lines (default: 1.0).
  final double lineThickness;

  /// Opacity multiplier for the mesh interconnecting lines (default: 0.65).
  final double lineOpacity;

  /// Whether to render soft glowing bokeh circles on background wave crests (default: true).
  final bool showBokehCircles;

  const WaveMeshOrbStyle({
    super.silentColor = const Color(0xFF0B1E3F),
    super.activeColor = const Color(0xFF38BDF8),
    super.baseRadius = 0.28,
    super.glowIntensity = 1.2,
    super.speedMultiplier = 1.0,
    this.gridRows = 28,
    this.gridColumns = 44,
    this.waveAmplitude = 0.28,
    this.waveFrequency = 1.8,
    this.perspectivePitch = 0.68,
    this.depthOfField = 0.8,
    this.focalDistance = 0.45,
    this.nodeGlowSize = 2.2,
    this.lineThickness = 1.0,
    this.lineOpacity = 0.65,
    this.showBokehCircles = true,
  });

  /// Oceanic Blue: Deep midnight sea with radiant sky azure waves and glowing bokeh orbs.
  factory WaveMeshOrbStyle.oceanicBlue() => const WaveMeshOrbStyle(
        silentColor: Color(0xFF0A192F),
        activeColor: Color(0xFF38BDF8),
        baseRadius: 0.28,
        glowIntensity: 1.25,
        speedMultiplier: 1.0,
        gridRows: 28,
        gridColumns: 44,
        waveAmplitude: 0.30,
        waveFrequency: 1.8,
        perspectivePitch: 0.68,
        depthOfField: 0.85,
        focalDistance: 0.42,
        nodeGlowSize: 2.2,
        lineThickness: 1.0,
        lineOpacity: 0.70,
        showBokehCircles: true,
      );

  /// Cyber Grid: Synthwave twilight with electric magenta ridges and neon teal bokeh.
  factory WaveMeshOrbStyle.cyberGrid() => const WaveMeshOrbStyle(
        silentColor: Color(0xFF3B0764),
        activeColor: Color(0xFFF43F5E),
        baseRadius: 0.28,
        glowIntensity: 1.3,
        speedMultiplier: 1.1,
        gridRows: 26,
        gridColumns: 42,
        waveAmplitude: 0.34,
        waveFrequency: 2.0,
        perspectivePitch: 0.72,
        depthOfField: 0.90,
        focalDistance: 0.40,
        nodeGlowSize: 2.4,
        lineThickness: 1.1,
        lineOpacity: 0.75,
        showBokehCircles: true,
      );

  /// Aurora Green: Deep boreal emerald with luminous mint ripples and jade horizon nodes.
  factory WaveMeshOrbStyle.auroraGreen() => const WaveMeshOrbStyle(
        silentColor: Color(0xFF022C22),
        activeColor: Color(0xFF34D399),
        baseRadius: 0.28,
        glowIntensity: 1.2,
        speedMultiplier: 0.95,
        gridRows: 30,
        gridColumns: 46,
        waveAmplitude: 0.26,
        waveFrequency: 1.7,
        perspectivePitch: 0.65,
        depthOfField: 0.75,
        focalDistance: 0.48,
        nodeGlowSize: 2.0,
        lineThickness: 0.95,
        lineOpacity: 0.65,
        showBokehCircles: true,
      );

  /// Solar Gold: Warm obsidian amber with radiant 24k gold wave surges and sunlit bokeh.
  factory WaveMeshOrbStyle.solarGold() => const WaveMeshOrbStyle(
        silentColor: Color(0xFF451A03),
        activeColor: Color(0xFFFBBF24),
        baseRadius: 0.28,
        glowIntensity: 1.25,
        speedMultiplier: 1.0,
        gridRows: 28,
        gridColumns: 44,
        waveAmplitude: 0.32,
        waveFrequency: 1.8,
        perspectivePitch: 0.68,
        depthOfField: 0.85,
        focalDistance: 0.45,
        nodeGlowSize: 2.3,
        lineThickness: 1.05,
        lineOpacity: 0.70,
        showBokehCircles: true,
      );

  WaveMeshOrbStyle copyWith({
    Color? silentColor,
    Color? activeColor,
    double? baseRadius,
    double? glowIntensity,
    double? speedMultiplier,
    int? gridRows,
    int? gridColumns,
    double? waveAmplitude,
    double? waveFrequency,
    double? perspectivePitch,
    double? depthOfField,
    double? focalDistance,
    double? nodeGlowSize,
    double? lineThickness,
    double? lineOpacity,
    bool? showBokehCircles,
  }) {
    return WaveMeshOrbStyle(
      silentColor: silentColor ?? this.silentColor,
      activeColor: activeColor ?? this.activeColor,
      baseRadius: baseRadius ?? this.baseRadius,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      gridRows: gridRows ?? this.gridRows,
      gridColumns: gridColumns ?? this.gridColumns,
      waveAmplitude: waveAmplitude ?? this.waveAmplitude,
      waveFrequency: waveFrequency ?? this.waveFrequency,
      perspectivePitch: perspectivePitch ?? this.perspectivePitch,
      depthOfField: depthOfField ?? this.depthOfField,
      focalDistance: focalDistance ?? this.focalDistance,
      nodeGlowSize: nodeGlowSize ?? this.nodeGlowSize,
      lineThickness: lineThickness ?? this.lineThickness,
      lineOpacity: lineOpacity ?? this.lineOpacity,
      showBokehCircles: showBokehCircles ?? this.showBokehCircles,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is WaveMeshOrbStyle &&
          runtimeType == other.runtimeType &&
          gridRows == other.gridRows &&
          gridColumns == other.gridColumns &&
          waveAmplitude == other.waveAmplitude &&
          waveFrequency == other.waveFrequency &&
          perspectivePitch == other.perspectivePitch &&
          depthOfField == other.depthOfField &&
          focalDistance == other.focalDistance &&
          nodeGlowSize == other.nodeGlowSize &&
          lineThickness == other.lineThickness &&
          lineOpacity == other.lineOpacity &&
          showBokehCircles == other.showBokehCircles;

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        gridRows,
        gridColumns,
        waveAmplitude,
        waveFrequency,
        perspectivePitch,
        depthOfField,
        focalDistance,
        nodeGlowSize,
        lineThickness,
        lineOpacity,
        showBokehCircles,
      );
}
