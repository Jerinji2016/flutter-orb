import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/galaxy_orb_style.dart';
import '../painters/galaxy_orb_painter.dart';
import '../shader/orb_shader_loader.dart';
import 'internal/shader_orb.dart';

/// Spiral disk particle system with a galactic core and stellar dust visualizer.
class GalaxyOrb extends StatelessWidget {
  /// The audio energy level [0.0 - 1.0].
  ///
  /// If provided, this value overrides [energyListenable].
  final double? audioEnergy;

  /// A listenable producing audio energy levels [0.0 - 1.0] (e.g. [VoiceOrbController]).
  final ValueListenable<double>? energyListenable;

  /// Visual styling configuration including arm count, spiral curvature, and dust density.
  final GalaxyOrbStyle style;

  /// Optional preloaded [FragmentShader].
  final FragmentShader? shader;

  /// Custom asset path to load the shader from.
  final String? customShaderAsset;

  /// Optional explicit width.
  final double? width;

  /// Optional explicit height.
  final double? height;

  /// Widget displayed while the shader is compiling.
  final WidgetBuilder? loadingBuilder;

  /// Widget displayed if shader loading fails.
  final Widget Function(
      BuildContext context, Object error, StackTrace? stackTrace)? errorBuilder;

  const GalaxyOrb({
    super.key,
    this.audioEnergy,
    this.energyListenable,
    this.style = const GalaxyOrbStyle(),
    this.shader,
    this.customShaderAsset,
    this.width,
    this.height,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderOrb<GalaxyOrbStyle>(
      audioEnergy: audioEnergy,
      energyListenable: energyListenable,
      style: style,
      shaderAsset: OrbShaderLoader.galaxyShaderPath,
      shader: shader,
      customShaderAsset: customShaderAsset,
      width: width,
      height: height,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      painterBuilder: (shader, time, energy, style) => GalaxyOrbPainter(
        shader: shader,
        time: time,
        audioEnergy: energy,
        style: style,
      ),
    );
  }
}
