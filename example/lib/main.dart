import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_orb/flutter_orb.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VoiceOrbExampleApp());
}

class VoiceOrbExampleApp extends StatelessWidget {
  final bool autoStartTour;

  const VoiceOrbExampleApp({
    super.key,
    this.autoStartTour = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Orb Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF08090C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4318FF),
          brightness: Brightness.dark,
          surface: const Color(0xFF10131B),
        ),
      ),
      home: VoiceOrbHomePage(autoStartTour: autoStartTour),
    );
  }
}

class VoiceOrbHomePage extends StatefulWidget {
  final bool autoStartTour;

  const VoiceOrbHomePage({
    super.key,
    this.autoStartTour = false,
  });

  @override
  State<VoiceOrbHomePage> createState() => _VoiceOrbHomePageState();
}

class _VoiceOrbHomePageState extends State<VoiceOrbHomePage>
    with SingleTickerProviderStateMixin {
  late final VoiceOrbController _controller;
  late final AnimationController _tickerController;

  // Visual Customization State
  OrbStyle _currentStyle = OrbStyle.gemini();
  String _selectedPresetName = 'Gemini';
  final ScrollController _presetScrollController = ScrollController();

  bool _isCompactView = false;
  bool _showSettings = false;

  // Auto UI Tour Navigation State
  bool _isAutoTourActive = false;
  int _tourStep = 0;
  Timer? _tourTimer;
  String _tourDescription = '';

  final Map<String, OrbStyle> _presets = {
    'Gemini': OrbStyle.gemini(),
    'Cyberpunk': OrbStyle.cyberpunk(),
    'Solar Flare': OrbStyle.solar(),
    'Emerald': OrbStyle.emerald(),
    'Neon Rose': OrbStyle.neonRose(),
    'Monochrome': OrbStyle.monochrome(),
  };

  @override
  void initState() {
    super.initState();
    _controller = VoiceOrbController(
      smoothingFactor: 0.18,
      minDb: -55.0,
      maxDb: -5.0,
      powerBoost: 1.5,
    );

    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..addListener(() {
        _controller.tick(0.016);
      })
      ..repeat();

    // Attempt start microphone; fallback to simulated speech if not granted
    _initVoiceCapture();

    // Listen for direct adb/intent test control commands
    const MethodChannel('com.example.voice_orb/control')
        .setMethodCallHandler((call) async {
      stopAutoTour();
      switch (call.method) {
        case 'setTourStep':
          final step = call.arguments as int;
          setState(() {
            _tourStep = step;
            _executeTourStep(step);
          });
          break;
        case 'setPreset':
          final rawName = (call.arguments as String).trim();
          final matchedKey = _presets.keys.firstWhere(
            (k) =>
                k.toLowerCase().replaceAll(' ', '') ==
                rawName.toLowerCase().replaceAll(' ', ''),
            orElse: () => _presets.containsKey(rawName) ? rawName : '',
          );
          if (matchedKey.isNotEmpty && _presets.containsKey(matchedKey)) {
            final idx = _presets.keys.toList().indexOf(matchedKey);
            setState(() {
              _selectedPresetName = matchedKey;
              _currentStyle = _presets[matchedKey]!;
              _isCompactView = false;
              _showSettings = false;
            });
            if (idx >= 0) _scrollToPreset(idx);
          }
          break;
        case 'setCompact':
          final compact = call.arguments as bool;
          setState(() {
            _isCompactView = compact;
          });
          break;
        case 'setSettings':
          final show = call.arguments as bool;
          setState(() {
            _showSettings = show;
          });
          break;
      }
    });

    if (widget.autoStartTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startAutoTour();
      });
    }
  }

  Future<void> _initVoiceCapture() async {
    final granted = await _controller.start();
    if (!granted && mounted) {
      _controller.setSimulated(true, mode: SimulationMode.speech);
    }
  }

  void _scrollToPreset(int index) {
    if (!_presetScrollController.hasClients) return;
    final double targetOffset = (index * 130.0).clamp(
      0.0,
      _presetScrollController.position.maxScrollExtent,
    );
    _presetScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  /// Starts the automatic UI tour navigation sequence.
  void startAutoTour() {
    setState(() {
      _isAutoTourActive = true;
      _tourStep = 0;
    });
    _executeTourStep(_tourStep);

    _tourTimer?.cancel();
    _tourTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (!mounted || !_isAutoTourActive) {
        timer.cancel();
        return;
      }
      setState(() {
        _tourStep = (_tourStep + 1) % 8;
      });
      _executeTourStep(_tourStep);
    });
  }

  /// Stop or pause the automatic UI tour.
  void stopAutoTour() {
    _tourTimer?.cancel();
    _tourTimer = null;
    setState(() {
      _isAutoTourActive = false;
      _tourDescription = '';
    });
  }

  void _executeTourStep(int step) {
    _controller.setSimulated(true);

    switch (step) {
      case 0:
        setState(() {
          _selectedPresetName = 'Gemini';
          _currentStyle = _presets['Gemini']!;
          _isCompactView = false;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.speech;
          _tourDescription = '1/6: Google Gemini Aura';
        });
        _scrollToPreset(0);
        break;
      case 1:
        setState(() {
          _selectedPresetName = 'Cyberpunk';
          _currentStyle = _presets['Cyberpunk']!;
          _isCompactView = false;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.pulse;
          _tourDescription = '2/6: Cyberpunk Pulse';
        });
        _scrollToPreset(1);
        break;
      case 2:
        setState(() {
          _selectedPresetName = 'Solar Flare';
          _currentStyle = _presets['Solar Flare']!;
          _isCompactView = false;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.sine;
          _tourDescription = '3/6: Solar Flare Dynamics';
        });
        _scrollToPreset(2);
        break;
      case 3:
        setState(() {
          _selectedPresetName = 'Emerald';
          _currentStyle = _presets['Emerald']!;
          _isCompactView = false;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.speech;
          _tourDescription = '4/6: Emerald Deep Mint';
        });
        _scrollToPreset(3);
        break;
      case 4:
        setState(() {
          _selectedPresetName = 'Neon Rose';
          _currentStyle = _presets['Neon Rose']!;
          _isCompactView = false;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.pulse;
          _tourDescription = '5/6: Neon Rose Hot Pink';
        });
        _scrollToPreset(4);
        break;
      case 5:
        setState(() {
          _selectedPresetName = 'Monochrome';
          _currentStyle = _presets['Monochrome']!;
          _isCompactView = false;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.speech;
          _tourDescription = '6/6: Monochrome Minimalist';
        });
        _scrollToPreset(5);
        break;
      case 6:
        setState(() {
          _selectedPresetName = 'Emerald';
          _currentStyle = _presets['Emerald']!;
          _isCompactView = true;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.speech;
          _tourDescription = 'Feature: Compact Assistant Bubble';
        });
        _scrollToPreset(3);
        break;
      case 7:
        setState(() {
          _selectedPresetName = 'Neon Rose';
          _currentStyle = _presets['Neon Rose']!;
          _isCompactView = false;
          _showSettings = true;
          _controller.simulationMode = SimulationMode.pulse;
          _tourDescription = 'Feature: Live Shader & Audio Tuning';
        });
        _scrollToPreset(4);
        break;
    }
  }

  @override
  void dispose() {
    _presetScrollController.dispose();
    _tourTimer?.cancel();
    _tickerController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    _currentStyle.silentColor.withValues(alpha: 0.18),
                    const Color(0xFF07080B),
                  ],
                ),
              ),
            ),
          ),

          // Main Interactive Layout
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                if (_isAutoTourActive) _buildTourBanner(),
                Expanded(
                  child: Center(
                    child: _buildOrbStage(),
                  ),
                ),
                _buildMetricsBar(),
                _buildPresetSelector(),
                _buildControlBar(),
              ],
            ),
          ),

          // Tweak Settings Bottom Sheet
          if (_showSettings)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildSettingsSheet(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _controller.isListening
                      ? (_controller.isSimulated
                          ? Colors.amberAccent
                          : Colors.greenAccent)
                      : Colors.redAccent,
                  boxShadow: [
                    BoxShadow(
                      color: (_controller.isSimulated
                              ? Colors.amberAccent
                              : Colors.greenAccent)
                          .withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'FLUTTER ORB',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton.filledTonal(
                key: const ValueKey('btn_auto_tour'),
                icon: Icon(_isAutoTourActive
                    ? Icons.pause_circle_filled
                    : Icons.auto_awesome),
                tooltip: _isAutoTourActive
                    ? 'Pause Auto Tour'
                    : 'Start Auto UI Tour',
                onPressed: () {
                  if (_isAutoTourActive) {
                    stopAutoTour();
                  } else {
                    startAutoTour();
                  }
                },
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                key: const ValueKey('btn_compact'),
                icon: Icon(
                    _isCompactView ? Icons.fullscreen : Icons.fullscreen_exit),
                tooltip: _isCompactView
                    ? 'Fullscreen Stage'
                    : 'Compact Assistant Bubble',
                onPressed: () {
                  setState(() {
                    _isCompactView = !_isCompactView;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTourBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _currentStyle.activeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: _currentStyle.activeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle_fill,
                  size: 16, color: _currentStyle.activeColor),
              const SizedBox(width: 8),
              Text(
                _tourDescription,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _currentStyle.activeColor,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: stopAutoTour,
            child: const Icon(Icons.close, size: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbStage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double fullWidth = constraints.maxWidth;
        final double fullHeight = constraints.maxHeight;
        final double width = _isCompactView ? 200.0 : fullWidth;
        final double height = _isCompactView ? 200.0 : fullHeight;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          width: width,
          height: height,
          decoration: _isCompactView
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.6),
                  border: Border.all(
                    color: _currentStyle.activeColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _currentStyle.silentColor.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                )
              : const BoxDecoration(
                  color: Colors.transparent,
                ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_isCompactView ? 100 : 0),
            child: ParticleOrb(
              energyListenable: _controller,
              style: _currentStyle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricsBar() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final db = _controller.currentDb;
        final energy = _controller.energy;
        final modeLabel = _controller.isSimulated
            ? 'Simulation (${_controller.simulationMode.name.toUpperCase()})'
            : (_controller.isListening ? 'LIVE MICROPHONE' : 'STANDBY');

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF141722).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      modeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: _controller.isSimulated
                            ? Colors.amberAccent
                            : Colors.cyanAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${db.toStringAsFixed(1)} dBFS  |  ${(energy * 100).toInt()}%',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: energy.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_currentStyle.activeColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPresetSelector() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView(
        controller: _presetScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _presets.keys.map((name) {
          final isSelected = _selectedPresetName == name;
          final preset = _presets[name]!;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              key: ValueKey('preset_$name'),
              avatar: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [preset.silentColor, preset.activeColor],
                  ),
                ),
              ),
              label: Text(name),
              selected: isSelected,
              selectedColor: _currentStyle.activeColor.withValues(alpha: 0.2),
              side: BorderSide(
                color: isSelected
                    ? _currentStyle.activeColor
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 1.5 : 1.0,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPresetName = name;
                    _currentStyle = preset;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              key: const ValueKey('btn_mode_toggle'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                side: BorderSide(
                  color: _controller.isSimulated
                      ? Colors.amberAccent
                      : Colors.cyanAccent,
                ),
              ),
              icon: Icon(
                _controller.isSimulated ? Icons.graphic_eq : Icons.mic,
                color: _controller.isSimulated
                    ? Colors.amberAccent
                    : Colors.cyanAccent,
              ),
              label: Text(
                _controller.isSimulated ? 'Mode: Simulated' : 'Mode: Live Mic',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() {
                  if (_controller.isSimulated) {
                    // Switch to live mic
                    _controller.setSimulated(false);
                    _controller.start();
                  } else {
                    // Switch to simulation
                    _controller.setSimulated(true, mode: SimulationMode.speech);
                  }
                });
              },
            ),
          ),
          if (_controller.isSimulated) ...[
            const SizedBox(width: 8),
            PopupMenuButton<SimulationMode>(
              key: const ValueKey('btn_sim_menu'),
              initialValue: _controller.simulationMode,
              icon: const Icon(Icons.tune),
              tooltip: 'Simulation Pattern',
              onSelected: (mode) {
                setState(() {
                  _controller.simulationMode = mode;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: SimulationMode.speech,
                  child: Text('Conversational Speech'),
                ),
                const PopupMenuItem(
                  value: SimulationMode.pulse,
                  child: Text('Rhythmic Pulse'),
                ),
                const PopupMenuItem(
                  value: SimulationMode.sine,
                  child: Text('Sinusoidal Wave'),
                ),
                const PopupMenuItem(
                  value: SimulationMode.idle,
                  child: Text('Idle Beat'),
                ),
              ],
            ),
          ],
          const SizedBox(width: 8),
          IconButton.filledTonal(
            key: const ValueKey('btn_settings'),
            icon: Icon(_showSettings ? Icons.close : Icons.tune_rounded),
            tooltip: 'Fine-tune Visuals & Sensitivity',
            onPressed: () {
              setState(() {
                _showSettings = !_showSettings;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSheet() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 380),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131620),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shader & Audio Tuning',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() => _showSettings = false),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildSlider(
              label: 'Base Core Radius',
              value: _currentStyle.baseRadius,
              min: 0.10,
              max: 0.35,
              onChanged: (v) => setState(() {
                _currentStyle = _currentStyle.copyWith(baseRadius: v);
              }),
            ),
            _buildSlider(
              label: 'Plasma Glow Intensity',
              value: _currentStyle.glowIntensity,
              min: 0.3,
              max: 2.5,
              onChanged: (v) => setState(() {
                _currentStyle = _currentStyle.copyWith(glowIntensity: v);
              }),
            ),
            _buildSlider(
              label: 'Turbulence Speed Multiplier',
              value: _currentStyle.speedMultiplier,
              min: 0.2,
              max: 2.5,
              onChanged: (v) => setState(() {
                _currentStyle = _currentStyle.copyWith(speedMultiplier: v);
              }),
            ),
            _buildSlider(
              label: 'Idle Turbulence (0 = Perfect Sphere)',
              value: _currentStyle.idleTurbulence,
              min: 0.0,
              max: 1.0,
              onChanged: (v) => setState(() {
                _currentStyle = _currentStyle.copyWith(idleTurbulence: v);
              }),
            ),
            _buildSlider(
              label: 'Particle Dot Size',
              value: _currentStyle.particleSize,
              min: 0.8,
              max: 3.5,
              onChanged: (v) => setState(() {
                _currentStyle = _currentStyle.copyWith(particleSize: v);
              }),
            ),
            _buildSlider(
              label: '3D Wave Amplitude',
              value: _currentStyle.waveAmplitude,
              min: 0.04,
              max: 0.30,
              onChanged: (v) => setState(() {
                _currentStyle = _currentStyle.copyWith(waveAmplitude: v);
              }),
            ),
            _buildSlider(
              label: 'Decibel Floor (minDb)',
              value: _controller.minDb,
              min: -80.0,
              max: -25.0,
              onChanged: (v) => setState(() {
                _controller.minDb = v;
              }),
            ),
            _buildSlider(
              label: 'Smoothing Factor (EMA)',
              value: _controller.smoothingFactor,
              min: 0.05,
              max: 0.50,
              onChanged: (v) => setState(() {
                _controller.smoothingFactor = v;
              }),
            ),
            _buildSlider(
              label: 'Audio Power Boost Curve',
              value: _controller.powerBoost,
              min: 1.0,
              max: 2.5,
              onChanged: (v) => setState(() {
                _controller.powerBoost = v;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),
          Expanded(
            flex: 5,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 42,
            child: Text(
              value.toStringAsFixed(2),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 11, fontFamily: 'Courier'),
            ),
          ),
        ],
      ),
    );
  }
}
