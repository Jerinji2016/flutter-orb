import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

/// Simulation modes when microphone input is disabled or unavailable.
enum SimulationMode {
  /// Simulates natural conversational speaking cadence with pauses and burst energy.
  speech,

  /// Continuous rhythmic pulsing.
  pulse,

  /// Smooth sinusoidal breathing wave.
  sine,

  /// Subtle idle resting state.
  idle,
}

/// Controller responsible for audio capture, amplitude polling, decibel normalization,
/// exponential smoothing (EMA), and synthetic audio simulation.
class VoiceOrbController extends ChangeNotifier
    implements ValueListenable<double> {
  AudioRecorder? _audioRecorder;
  AudioRecorder get _recorder => _audioRecorder ??= AudioRecorder();
  StreamSubscription<Amplitude>? _amplitudeSub;

  /// Minimum noise floor threshold in dBFS (default: -55.0 dB).
  double minDb;

  /// Maximum peak ceiling threshold in dBFS (default: -5.0 dB).
  double maxDb;

  /// Exponential moving average smoothing factor [0.0 - 1.0] (default: 0.18).
  /// Higher values react faster, lower values produce smoother, liquid transitions.
  double smoothingFactor;

  /// Exponential power curve applied to normalized amplitude for dynamic punch (default: 1.5).
  double powerBoost;

  /// Polling interval for microphone amplitude updates.
  final Duration pollingInterval;

  bool _isListening = false;
  bool _hasPermission = false;
  bool _isSimulated = false;
  SimulationMode _simulationMode = SimulationMode.speech;

  double _currentDb = -160.0;
  double _targetEnergy = 0.0;
  double _smoothedEnergy = 0.0;
  double _simulatedTime = 0.0;

  VoiceOrbController({
    AudioRecorder? audioRecorder,
    this.minDb = -55.0,
    this.maxDb = -5.0,
    this.smoothingFactor = 0.18,
    this.powerBoost = 1.5,
    this.pollingInterval = const Duration(milliseconds: 16),
    bool autoStart = false,
  }) : _audioRecorder = audioRecorder {
    if (autoStart) {
      start();
    }
  }

  /// The current smoothed audio energy in the range [0.0, 1.0].
  @override
  double get value => _smoothedEnergy;

  /// The current smoothed audio energy in the range [0.0, 1.0].
  double get energy => _smoothedEnergy;

  /// The un-smoothed target energy [0.0, 1.0].
  double get targetEnergy => _targetEnergy;

  /// The latest raw microphone decibels (dBFS).
  double get currentDb => _currentDb;

  /// Whether the controller is actively capturing microphone input or simulating.
  bool get isListening => _isListening;

  /// Whether microphone permission has been granted.
  bool get hasPermission => _hasPermission;

  /// Whether simulation mode is enabled.
  bool get isSimulated => _isSimulated;

  /// The active simulation mode.
  SimulationMode get simulationMode => _simulationMode;

  set simulationMode(SimulationMode mode) {
    _simulationMode = mode;
    notifyListeners();
  }

  /// Request permission and begin capturing microphone input.
  Future<bool> start() async {
    if (_isSimulated) {
      _isListening = true;
      notifyListeners();
      return true;
    }

    try {
      _hasPermission = await _recorder.hasPermission();
      if (!_hasPermission) {
        notifyListeners();
        return false;
      }

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.pcm16bits),
        path: '',
      );

      _amplitudeSub?.cancel();
      _amplitudeSub = _recorder
          .onAmplitudeChanged(pollingInterval)
          .listen(_onAmplitudeData);

      _isListening = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[VoiceOrbController] Failed to start audio recorder: $e');
      _isListening = false;
      notifyListeners();
      return false;
    }
  }

  /// Stop capturing microphone input.
  Future<void> stop() async {
    _amplitudeSub?.cancel();
    _amplitudeSub = null;
    try {
      if (_audioRecorder != null && await _audioRecorder!.isRecording()) {
        await _audioRecorder!.stop();
      }
    } catch (_) {}
    _isListening = false;
    _targetEnergy = 0.0;
    notifyListeners();
  }

  /// Toggles simulation mode on or off.
  void setSimulated(bool enabled,
      {SimulationMode mode = SimulationMode.speech}) {
    _isSimulated = enabled;
    _simulationMode = mode;
    if (enabled) {
      if (_amplitudeSub != null) {
        _amplitudeSub?.cancel();
        _amplitudeSub = null;
      }
      if (_audioRecorder != null) {
        try {
          _audioRecorder!.stop();
        } catch (_) {}
      }
      _isListening = true;
    } else {
      _isListening = false;
    }
    notifyListeners();
  }

  void _onAmplitudeData(Amplitude amp) {
    _currentDb = amp.current;
    _targetEnergy = normalizeDb(amp.current, minDb, maxDb, powerBoost);
  }

  /// Advances the smoothing animation and simulation time step.
  /// Call this per animation frame (e.g. from ticker).
  void tick(double dt) {
    if (_isSimulated && _isListening) {
      _simulatedTime += dt;
      _targetEnergy =
          _calculateSimulatedEnergy(_simulatedTime, _simulationMode);
      _currentDb = minDb + _targetEnergy * (maxDb - minDb);
    }

    // Exponential Moving Average (EMA)
    _smoothedEnergy +=
        (_targetEnergy - _smoothedEnergy) * smoothingFactor.clamp(0.01, 1.0);

    // Minor threshold cutoff for absolute silence
    if (_smoothedEnergy < 0.0001) {
      _smoothedEnergy = 0.0;
    }

    notifyListeners();
  }

  /// Directly feed an external audio energy value [0.0 - 1.0] (useful for custom audio pipelines or TTS).
  void setManualEnergy(double target) {
    _targetEnergy = target.clamp(0.0, 1.0);
  }

  /// Utility to normalize a decibel value into [0.0, 1.0] with exponential curve.
  static double normalizeDb(
      double db, double minDb, double maxDb, double power) {
    final clamped = db.clamp(minDb, maxDb);
    final normalized = (clamped - minDb) / (maxDb - minDb);
    return pow(normalized, power).toDouble().clamp(0.0, 1.0);
  }

  double _calculateSimulatedEnergy(double t, SimulationMode mode) {
    switch (mode) {
      case SimulationMode.speech:
        // Cadence with syllables, voice stress bursts, and natural conversational gaps
        final burst1 = max(0.0, sin(t * 3.5));
        final burst2 = max(0.0, sin(t * 7.2 + 1.2));
        final envelope = max(0.0, sin(t * 0.9)); // phrasing pause
        final energy = (burst1 * 0.7 + burst2 * 0.5) * envelope;
        return pow(energy.clamp(0.0, 1.0), 1.2).toDouble();

      case SimulationMode.pulse:
        return (sin(t * 5.0) * 0.5 + 0.5);

      case SimulationMode.sine:
        return (sin(t * 2.0) * 0.5 + 0.5) * 0.6;

      case SimulationMode.idle:
        return (sin(t * 1.2) * 0.1 + 0.15);
    }
  }

  @override
  void dispose() {
    _amplitudeSub?.cancel();
    _audioRecorder?.dispose();
    super.dispose();
  }
}
