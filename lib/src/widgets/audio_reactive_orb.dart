import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../controllers/voice_orb_controller.dart';
import '../models/base_orb_style.dart';
import '../models/constellation_orb_style.dart';
import '../models/flare_orb_style.dart';
import '../models/galaxy_orb_style.dart';
import '../models/liquid_orb_style.dart';
import '../models/particle_orb_style.dart';
import '../models/siri_orb_style.dart';
import '../models/spectrum_orb_style.dart';
import '../models/wave_mesh_orb_style.dart';
import '../models/wireframe_orb_style.dart';
import 'constellation_orb.dart';
import 'flare_orb.dart';
import 'galaxy_orb.dart';
import 'liquid_orb.dart';
import 'particle_orb.dart';
import 'siri_orb.dart';
import 'spectrum_orb.dart';
import 'wave_mesh_orb.dart';
import 'wireframe_orb.dart';

enum _OrbVisualizerType {
  particle,
  liquid,
  galaxy,
  wireframe,
  spectrum,
  waveMesh,
  constellation,
  siri,
  flare,
}

/// Drop-in, all-in-one audio-reactive voice orb visualizer.
///
/// Automatically captures microphone input (with permission handling),
/// applies exponential smoothing, and renders the desired GPU orb visualizer.
class AudioReactiveOrb extends StatefulWidget {
  /// Custom controller. If not provided, an internal [VoiceOrbController] is created.
  final VoiceOrbController? controller;

  /// Visual styling configuration.
  final BaseOrbStyle style;

  /// Whether to automatically start capturing audio upon mounting (default: true).
  final bool autoStart;

  /// Whether to run in simulated speech mode if microphone permission is not granted.
  final bool fallbackToSimulation;

  /// Width of the widget.
  final double? width;

  /// Height of the widget.
  final double? height;

  /// Custom builder when microphone permission is denied and fallback is disabled.
  final Widget Function(BuildContext context, VoidCallback requestPermission)? permissionDeniedBuilder;

  /// Loading widget while the shader or mic initializes.
  final WidgetBuilder? loadingBuilder;

  final _OrbVisualizerType _type;

  /// Default particle sphere audio-reactive visualizer.
  const AudioReactiveOrb({
    super.key,
    this.controller,
    this.style = const ParticleOrbStyle(),
    this.autoStart = true,
    this.fallbackToSimulation = true,
    this.width,
    this.height,
    this.permissionDeniedBuilder,
    this.loadingBuilder,
  }) : _type = _OrbVisualizerType.particle;

  /// 3D wave particle sphere audio-reactive visualizer.
  const AudioReactiveOrb.particle({
    super.key,
    this.controller,
    this.style = const ParticleOrbStyle(),
    this.autoStart = true,
    this.fallbackToSimulation = true,
    this.width,
    this.height,
    this.permissionDeniedBuilder,
    this.loadingBuilder,
  }) : _type = _OrbVisualizerType.particle;

  /// Raymarched SDF metaballs and gooey fluid blob audio-reactive visualizer.
  const AudioReactiveOrb.liquid({
    super.key,
    this.controller,
    this.style = const LiquidOrbStyle(),
    this.autoStart = true,
    this.fallbackToSimulation = true,
    this.width,
    this.height,
    this.permissionDeniedBuilder,
    this.loadingBuilder,
  }) : _type = _OrbVisualizerType.liquid;

  /// Spiral disk particle system and galactic core audio-reactive visualizer.
  const AudioReactiveOrb.galaxy({
    super.key,
    this.controller,
    this.style = const GalaxyOrbStyle(),
    this.autoStart = true,
    this.fallbackToSimulation = true,
    this.width,
    this.height,
    this.permissionDeniedBuilder,
    this.loadingBuilder,
  }) : _type = _OrbVisualizerType.galaxy;

  /// Holographic rotating geodesic grid wireframe audio-reactive visualizer.
  const AudioReactiveOrb.wireframe({
    super.key,
    this.controller,
    this.style = const WireframeOrbStyle(),
    this.autoStart = true,
    this.fallbackToSimulation = true,
    this.width,
    this.height,
    this.permissionDeniedBuilder,
    this.loadingBuilder,
  }) : _type = _OrbVisualizerType.wireframe;

  /// Radial frequency bars and circular waveform ribbons audio-reactive visualizer.
  const AudioReactiveOrb.spectrum({
    super.key,
    this.controller,
    this.style = const SpectrumOrbStyle(),
    this.autoStart = true,
    this.fallbackToSimulation = true,
    this.width,
    this.height,
    this.permissionDeniedBuilder,
    this.loadingBuilder,
  }) : _type = _OrbVisualizerType.spectrum;

  /// 2.5D perspective undulating wave mesh with focal bokeh blur audio-reactive visualizer.
  const AudioReactiveOrb.waveMesh({
    super.key,
    this.controller,
    this.style = const WaveMeshOrbStyle(),
    this.autoStart = true,
    this.fallbackToSimulation = true,
    this.width,
    this.height,
    this.permissionDeniedBuilder,
    this.loadingBuilder,
  }) : _type = _OrbVisualizerType.waveMesh;

  /// 2D dynamic proximity-connecting constellation network mesh audio-reactive visualizer.
  const AudioReactiveOrb.constellation({
    super.key,
    this.controller,
    this.style = const ConstellationOrbStyle(),
    this.autoStart = true,
    this.fallbackToSimulation = true,
    this.width,
    this.height,
    this.permissionDeniedBuilder,
    this.loadingBuilder,
  }) : _type = _OrbVisualizerType.constellation;

  /// Apple Siri iridescent chromatic fluid glow audio-reactive visualizer.
  const AudioReactiveOrb.siri({
    super.key,
    this.controller,
    this.style = const SiriOrbStyle(),
    this.autoStart = true,
    this.fallbackToSimulation = true,
    this.width,
    this.height,
    this.permissionDeniedBuilder,
    this.loadingBuilder,
  }) : _type = _OrbVisualizerType.siri;

  /// Quantum Flare 3D holographic sphere with sweeping orbital plasma ring audio-reactive visualizer.
  const AudioReactiveOrb.flare({
    super.key,
    this.controller,
    this.style = const FlareOrbStyle(),
    this.autoStart = true,
    this.fallbackToSimulation = true,
    this.width,
    this.height,
    this.permissionDeniedBuilder,
    this.loadingBuilder,
  }) : _type = _OrbVisualizerType.flare;

  @override
  State<AudioReactiveOrb> createState() => _AudioReactiveOrbState();
}

class _AudioReactiveOrbState extends State<AudioReactiveOrb> with SingleTickerProviderStateMixin {
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
        if (!_controller.hasPermission && !_controller.isSimulated && widget.permissionDeniedBuilder != null) {
          return widget.permissionDeniedBuilder!(context, () => _controller.start());
        }

        return _buildVisualizer();
      },
    );
  }

  Widget _buildVisualizer() {
    switch (widget._type) {
      case _OrbVisualizerType.liquid:
        return LiquidOrb(
          energyListenable: _controller,
          style: widget.style as LiquidOrbStyle,
          width: widget.width,
          height: widget.height,
          loadingBuilder: widget.loadingBuilder,
        );
      case _OrbVisualizerType.galaxy:
        return GalaxyOrb(
          energyListenable: _controller,
          style: widget.style as GalaxyOrbStyle,
          width: widget.width,
          height: widget.height,
          loadingBuilder: widget.loadingBuilder,
        );
      case _OrbVisualizerType.wireframe:
        return WireframeOrb(
          energyListenable: _controller,
          style: widget.style as WireframeOrbStyle,
          width: widget.width,
          height: widget.height,
          loadingBuilder: widget.loadingBuilder,
        );
      case _OrbVisualizerType.spectrum:
        return SpectrumOrb(
          energyListenable: _controller,
          style: widget.style as SpectrumOrbStyle,
          width: widget.width,
          height: widget.height,
          loadingBuilder: widget.loadingBuilder,
        );
      case _OrbVisualizerType.waveMesh:
        return WaveMeshOrb(
          energyListenable: _controller,
          style: widget.style as WaveMeshOrbStyle,
          width: widget.width,
          height: widget.height,
        );
      case _OrbVisualizerType.constellation:
        return ConstellationOrb(
          energyListenable: _controller,
          style: widget.style as ConstellationOrbStyle,
          width: widget.width,
          height: widget.height,
        );
      case _OrbVisualizerType.siri:
        return SiriOrb(
          energyListenable: _controller,
          style: widget.style as SiriOrbStyle,
          width: widget.width,
          height: widget.height,
          loadingBuilder: widget.loadingBuilder,
        );
      case _OrbVisualizerType.flare:
        return FlareOrb(
          energyListenable: _controller,
          style: widget.style as FlareOrbStyle,
          width: widget.width,
          height: widget.height,
          loadingBuilder: widget.loadingBuilder,
        );
      case _OrbVisualizerType.particle:
        return ParticleOrb(
          energyListenable: _controller,
          style: widget.style as ParticleOrbStyle,
          width: widget.width,
          height: widget.height,
          loadingBuilder: widget.loadingBuilder,
        );
    }
  }
}
