import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/constellation_orb_style.dart';
import '../painters/constellation_painter.dart';

/// Pure visualizer widget that renders the 2D dynamic constellation network mesh with distance fadeout.
class ConstellationOrb extends StatefulWidget {
  /// The audio energy level [0.0 - 1.0].
  ///
  /// If provided, this value overrides [energyListenable].
  final double? audioEnergy;

  /// A listenable producing audio energy levels [0.0 - 1.0] (e.g. [VoiceOrbController]).
  final ValueListenable<double>? energyListenable;

  /// Visual styling configuration including particle count, connection distance, speed, and impulse response.
  final ConstellationOrbStyle style;

  /// Optional explicit width.
  final double? width;

  /// Optional explicit height.
  final double? height;

  const ConstellationOrb({
    super.key,
    this.audioEnergy,
    this.energyListenable,
    this.style = const ConstellationOrbStyle(),
    this.width,
    this.height,
  });

  @override
  State<ConstellationOrb> createState() => _ConstellationOrbState();
}

class _ConstellationOrbState extends State<ConstellationOrb> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _elapsedSeconds = 0.0;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;

      setState(() {
        _elapsedSeconds += dt;
      });
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      painter: ConstellationPainter(
        time: _elapsedSeconds,
        audioEnergy: audioEnergy,
        style: widget.style,
      ),
    );
  }
}
