import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/orb_style.dart';
import '../painters/orb_painter.dart';
import '../painters/particle_sphere_painter.dart';
import '../shader/orb_shader_loader.dart';

/// Pure visualizer widget that renders the 3D wave particle sphere visualizer.
class ParticleOrb extends StatefulWidget {
  /// The audio energy level [0.0 - 1.0].
  ///
  /// If provided, this value overrides [energyListenable].
  final double? audioEnergy;

  /// A listenable producing audio energy levels [0.0 - 1.0] (e.g. [VoiceOrbController]).
  final ValueListenable<double>? energyListenable;

  /// Visual styling configuration including colors, glow, radius, and particle params.
  final OrbStyle style;

  /// Optional preloaded [FragmentShader]. If provided, renders via GPU shader.
  final FragmentShader? shader;

  /// Custom asset path to load the shader from if using shader mode.
  final String? customShaderAsset;

  /// Whether to force using GPU fragment shader instead of 3D point cloud mesh (default: false).
  final bool useShaderRenderer;

  /// Optional explicit width.
  final double? width;

  /// Optional explicit height.
  final double? height;

  /// Widget displayed while the shader is loading (if [useShaderRenderer] is true).
  final WidgetBuilder? loadingBuilder;

  /// Widget displayed if shader loading fails.
  final Widget Function(BuildContext context, Object error, StackTrace? stackTrace)? errorBuilder;

  const ParticleOrb({
    super.key,
    this.audioEnergy,
    this.energyListenable,
    this.style = const OrbStyle(),
    this.shader,
    this.customShaderAsset,
    this.useShaderRenderer = false,
    this.width,
    this.height,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  State<ParticleOrb> createState() => _ParticleOrbState();
}

class _ParticleOrbState extends State<ParticleOrb> with SingleTickerProviderStateMixin {
  FragmentShader? _shader;
  Object? _loadError;
  StackTrace? _loadStackTrace;
  late final Ticker _ticker;
  double _elapsedSeconds = 0.0;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.useShaderRenderer || widget.shader != null) {
      if (widget.shader != null) {
        _shader = widget.shader;
      } else {
        _initShader();
      }
    }

    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;

      setState(() {
        _elapsedSeconds += dt;
      });
    })
      ..start();
  }

  Future<void> _initShader() async {
    try {
      final program = await OrbShaderLoader.load(
        customAssetPath: widget.customShaderAsset,
      );
      if (mounted) {
        setState(() {
          _shader = program.fragmentShader();
        });
      }
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _loadError = e;
          _loadStackTrace = st;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant ParticleOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shader != null && widget.shader != _shader) {
      _shader = widget.shader;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useShaderRenderer) {
      if (_loadError != null) {
        if (widget.errorBuilder != null) {
          return widget.errorBuilder!(context, _loadError!, _loadStackTrace);
        }
        return Center(
          child: Text(
            'Failed to load shader: $_loadError',
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        );
      }

      if (_shader == null) {
        if (widget.loadingBuilder != null) {
          return widget.loadingBuilder!(context);
        }
        return const Center(
          child: CircularProgressIndicator.adaptive(
            strokeWidth: 2.0,
          ),
        );
      }
    }

    final child = widget.energyListenable != null
        ? ValueListenableBuilder<double>(
            valueListenable: widget.energyListenable!,
            builder: (context, energy, _) {
              return _buildPainter(widget.audioEnergy ?? energy);
            },
          )
        : _buildPainter(widget.audioEnergy ?? 0.0);

    if (widget.width != null || widget.height != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: child,
      );
    }

    return child;
  }

  Widget _buildPainter(double audioEnergy) {
    if (widget.useShaderRenderer && _shader != null) {
      return CustomPaint(
        size: Size.infinite,
        painter: OrbPainter(
          shader: _shader!,
          time: _elapsedSeconds,
          audioEnergy: audioEnergy,
          style: widget.style,
        ),
      );
    }

    return CustomPaint(
      size: Size.infinite,
      painter: ParticleSpherePainter(
        time: _elapsedSeconds,
        audioEnergy: audioEnergy,
        style: widget.style,
        particleCount: widget.style.particleCount,
        particleSize: widget.style.particleSize,
        waveAmplitude: widget.style.waveAmplitude,
        waveFrequency: widget.style.waveFrequency,
      ),
    );
  }
}
