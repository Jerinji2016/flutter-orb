import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../models/base_orb_style.dart';
import '../../shader/orb_shader_loader.dart';

/// Internal reusable base widget that encapsulates ticker timing, async shader
/// compilation, error handling, and uniform painter binding across all shader orbs.
class ShaderOrb<T extends BaseOrbStyle> extends StatefulWidget {
  /// Direct audio energy level [0.0 - 1.0].
  final double? audioEnergy;

  /// Reactive audio energy listenable (e.g. from a controller).
  final ValueListenable<double>? energyListenable;

  /// Visual styling configuration.
  final T style;

  /// Default asset path for this visualizer's fragment shader.
  final String shaderAsset;

  /// Preloaded [FragmentShader] instance (optional).
  final FragmentShader? shader;

  /// Custom asset path to override the default shader asset.
  final String? customShaderAsset;

  /// Explicit widget width.
  final double? width;

  /// Explicit widget height.
  final double? height;

  /// Builder displayed while the fragment shader compiles.
  final WidgetBuilder? loadingBuilder;

  /// Builder displayed if fragment shader compilation fails.
  final Widget Function(
      BuildContext context, Object error, StackTrace? stackTrace)? errorBuilder;

  /// Factory function that creates the tailored [CustomPainter] for this shader and style.
  final CustomPainter Function(
    FragmentShader shader,
    double time,
    double audioEnergy,
    T style,
  ) painterBuilder;

  const ShaderOrb({
    super.key,
    required this.style,
    required this.shaderAsset,
    required this.painterBuilder,
    this.audioEnergy,
    this.energyListenable,
    this.shader,
    this.customShaderAsset,
    this.width,
    this.height,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  State<ShaderOrb<T>> createState() => _ShaderOrbState<T>();
}

class _ShaderOrbState<T extends BaseOrbStyle> extends State<ShaderOrb<T>>
    with SingleTickerProviderStateMixin {
  FragmentShader? _shader;
  Object? _loadError;
  StackTrace? _loadStackTrace;
  late final Ticker _ticker;
  double _elapsedSeconds = 0.0;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.shader != null) {
      _shader = widget.shader;
    } else {
      _initShader();
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
      final assetPath = widget.customShaderAsset ?? widget.shaderAsset;
      final program = await OrbShaderLoader.loadPath(assetPath);
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
  void didUpdateWidget(covariant ShaderOrb<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shader != null && widget.shader != _shader) {
      _shader = widget.shader;
    } else if (widget.customShaderAsset != oldWidget.customShaderAsset ||
        widget.shaderAsset != oldWidget.shaderAsset) {
      _initShader();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    return CustomPaint(
      size: Size.infinite,
      painter: widget.painterBuilder(
        _shader!,
        _elapsedSeconds,
        audioEnergy,
        widget.style,
      ),
    );
  }
}
