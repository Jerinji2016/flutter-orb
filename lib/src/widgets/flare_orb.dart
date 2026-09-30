import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/flare_orb_style.dart';
import '../painters/flare_orb_painter.dart';
import '../shader/orb_shader_loader.dart';
import 'internal/shader_orb.dart';

/// Pure visualizer widget that renders the Quantum Flare 3D holographic sphere
/// with an orbital plasma ring, incandescent white-hot flare head, and sonic ripples.
class FlareOrb extends StatelessWidget {
  /// The audio energy level [0.0 - 1.0].
  ///
  /// If provided, this value overrides [energyListenable].
  final double? audioEnergy;

  /// A listenable producing audio energy levels [0.0 - 1.0] (e.g. [VoiceOrbController]).
  final ValueListenable<double>? energyListenable;

  /// Visual styling configuration including orbital speed, ring thickness, and flare colors.
  final FlareOrbStyle style;

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
  final Widget Function(BuildContext context, Object error, StackTrace? stackTrace)? errorBuilder;

  const FlareOrb({
    super.key,
    this.audioEnergy,
    this.energyListenable,
    this.style = const FlareOrbStyle(),
    this.shader,
    this.customShaderAsset,
    this.width,
    this.height,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderOrb<FlareOrbStyle>(
      audioEnergy: audioEnergy,
      energyListenable: energyListenable,
      style: style,
      shaderAsset: OrbShaderLoader.flareShaderPath,
      shader: shader,
      customShaderAsset: customShaderAsset,
      width: width,
      height: height,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      painterBuilder: (shader, time, energy, style) => FlareOrbPainter(
        shader: shader,
        time: time,
        audioEnergy: energy,
        style: style,
      ),
    );
  }
}
