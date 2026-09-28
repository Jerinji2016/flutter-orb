import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../controllers/voice_orb_controller.dart';
import '../models/orb_style.dart';
import 'particle_orb.dart';

/// Drop-in, all-in-one audio-reactive voice orb widget.
///
/// Automatically captures microphone input (with permission handling),
/// applies exponential smoothing, and renders the GPU particle orb visualizer.
class AudioReactiveOrb extends StatefulWidget {
  /// Custom controller. If not provided, an internal [VoiceOrbController] is created.
  final VoiceOrbController? controller;

  /// Visual styling configuration.
  final OrbStyle style;

  /// Whether to automatically start capturing audio upon mounting (default: true).
  final bool autoStart;

  /// Whether to run in simulated speech mode if microphone permission is not granted.
  final bool fallbackToSimulation;

  /// Width of the widget.
  final double? width;

  /// Height of the widget.
  final double? height;

  /// Custom builder when microphone permission is denied and fallback is disabled.
  final Widget Function(BuildContext context, VoidCallback requestPermission)?
      permissionDeniedBuilder;

  /// Loading widget while the shader or mic initializes.
  final WidgetBuilder? loadingBuilder;

  const AudioReactiveOrb({
    super.key,
    this.controller,
    this.style = const OrbStyle(),
    this.autoStart = true,
    this.fallbackToSimulation = true,
    this.width,
    this.height,
    this.permissionDeniedBuilder,
    this.loadingBuilder,
  });

  @override
  State<AudioReactiveOrb> createState() => _AudioReactiveOrbState();
}

class _AudioReactiveOrbState extends State<AudioReactiveOrb>
    with SingleTickerProviderStateMixin {
  late VoiceOrbController _controller;
  bool _isInternalController = false;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = VoiceOrbController();
      _isInternalController = true;
    }

    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;
      _controller.tick(dt);
    })
      ..start();

    if (widget.autoStart) {
      _startCapture();
    }
  }

  Future<void> _startCapture() async {
    final granted = await _controller.start();
    if (!granted && widget.fallbackToSimulation) {
      _controller.setSimulated(true, mode: SimulationMode.speech);
    }
  }

  @override
  void didUpdateWidget(covariant AudioReactiveOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _controller) {
      if (_isInternalController) {
        _controller.dispose();
      }
      _controller = widget.controller!;
      _isInternalController = false;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (!_controller.hasPermission &&
            !_controller.isSimulated &&
            widget.permissionDeniedBuilder != null) {
          return widget.permissionDeniedBuilder!(
              context, () => _controller.start());
        }

        return ParticleOrb(
          energyListenable: _controller,
          style: widget.style,
          width: widget.width,
          height: widget.height,
          loadingBuilder: widget.loadingBuilder,
        );
      },
    );
  }
}
