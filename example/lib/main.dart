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

enum VisualizerMode {
  particle('Particle Sphere', Icons.grain),
  liquid('Liquid Blob', Icons.water_drop),
  galaxy('Spiral Galaxy', Icons.cyclone),
  wireframe('Wireframe Holo', Icons.grid_4x4),
  spectrum('Audio Spectrum', Icons.graphic_eq),
  waveMesh('Wave Mesh 2.5D', Icons.waves),
  constellation('Constellation 2D', Icons.hub),
  siri('Siri Glow', Icons.blur_on),
  flare('Quantum Flare', Icons.flare);

  final String title;
  final IconData icon;
  const VisualizerMode(this.title, this.icon);
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

  // Selected Visualizer Mode
  VisualizerMode _selectedMode = VisualizerMode.particle;

  // Styles per mode
  ParticleOrbStyle _particleStyle = ParticleOrbStyle.gemini();
  LiquidOrbStyle _liquidStyle = LiquidOrbStyle.mercury();
  GalaxyOrbStyle _galaxyStyle = GalaxyOrbStyle.andromeda();
  WireframeOrbStyle _wireframeStyle = WireframeOrbStyle.hologram();
  SpectrumOrbStyle _spectrumStyle = SpectrumOrbStyle.neonEqualizer();
  WaveMeshOrbStyle _waveMeshStyle = WaveMeshOrbStyle.oceanicBlue();
  ConstellationOrbStyle _constellationStyle = ConstellationOrbStyle.deepSpace();
  SiriOrbStyle _siriStyle = SiriOrbStyle.appleClassic();
  FlareOrbStyle _flareStyle = FlareOrbStyle.quantumBlue();

  String _selectedPresetName = 'Gemini';
  final ScrollController _presetScrollController = ScrollController();

  bool _showSettings = false;

  // Auto UI Tour Navigation State
  bool _isAutoTourActive = false;
  int _tourStep = 0;
  Timer? _tourTimer;
  String _tourDescription = '';

  // Preset Palettes per Mode
  final Map<String, ParticleOrbStyle> _particlePresets = {
    'Gemini': ParticleOrbStyle.gemini(),
    'Cyberpunk': ParticleOrbStyle.cyberpunk(),
    'Solar Flare': ParticleOrbStyle.solar(),
    'Emerald': ParticleOrbStyle.emerald(),
    'Neon Rose': ParticleOrbStyle.neonRose(),
    'Monochrome': ParticleOrbStyle.monochrome(),
  };

  final Map<String, LiquidOrbStyle> _liquidPresets = {
    'Mercury': LiquidOrbStyle.mercury(),
    'Lava': LiquidOrbStyle.lava(),
    'Plasma': LiquidOrbStyle.plasma(),
    'Toxic Slime': LiquidOrbStyle.toxicSlime(),
    'Amethyst': LiquidOrbStyle.amethyst(),
  };

  final Map<String, GalaxyOrbStyle> _galaxyPresets = {
    'Andromeda': GalaxyOrbStyle.andromeda(),
    'Supernova': GalaxyOrbStyle.supernova(),
    'Milky Way': GalaxyOrbStyle.milkyWay(),
    'Black Hole': GalaxyOrbStyle.blackHole(),
    'Nebula': GalaxyOrbStyle.nebula(),
  };

  final Map<String, WireframeOrbStyle> _wireframePresets = {
    'Hologram': WireframeOrbStyle.hologram(),
    'Matrix': WireframeOrbStyle.matrix(),
    'Cyber Lattice': WireframeOrbStyle.cyberLattice(),
    'Golden Cortex': WireframeOrbStyle.goldenCortex(),
    'Stealth Red': WireframeOrbStyle.stealthRed(),
  };

  final Map<String, SpectrumOrbStyle> _spectrumPresets = {
    'Neon Equalizer': SpectrumOrbStyle.neonEqualizer(),
    'Sunset Echo': SpectrumOrbStyle.sunsetEcho(),
    'Vaporwave': SpectrumOrbStyle.vaporwave(),
    'Radiant Green': SpectrumOrbStyle.radiantGreen(),
    'Monochrome': SpectrumOrbStyle.monochrome(),
  };

  final Map<String, WaveMeshOrbStyle> _waveMeshPresets = {
    'Oceanic Blue': WaveMeshOrbStyle.oceanicBlue(),
    'Cyber Grid': WaveMeshOrbStyle.cyberGrid(),
    'Aurora Green': WaveMeshOrbStyle.auroraGreen(),
    'Solar Gold': WaveMeshOrbStyle.solarGold(),
  };

  final Map<String, ConstellationOrbStyle> _constellationPresets = {
    'Deep Space': ConstellationOrbStyle.deepSpace(),
    'Neural Synapse': ConstellationOrbStyle.neuralSynapse(),
    'Matrix Nodes': ConstellationOrbStyle.matrixNodes(),
    'Quantum Amber': ConstellationOrbStyle.quantumAmber(),
  };

  final Map<String, SiriOrbStyle> _siriPresets = {
    'Apple Classic': SiriOrbStyle.appleClassic(),
    'Cosmic Aurora': SiriOrbStyle.cosmicAurora(),
    'Electric Prism': SiriOrbStyle.electricPrism(),
    'Sunset Glow': SiriOrbStyle.sunsetGlow(),
  };

  final Map<String, FlareOrbStyle> _flarePresets = {
    'Quantum Blue': FlareOrbStyle.quantumBlue(),
    'Solar Corona': FlareOrbStyle.solarCorona(),
    'Neon Cyber': FlareOrbStyle.neonCyber(),
    'Emerald Pulse': FlareOrbStyle.emeraldPulse(),
    'Supernova': FlareOrbStyle.supernova(),
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

    // Preload all shader programs asynchronously
    OrbShaderLoader.preloadAll();

    // Attempt microphone capture; fallback to simulated speech
    _initVoiceCapture();

    // Listen for direct adb/intent test control commands
    const MethodChannel('com.halooid.orbView/control')
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
        case 'setMode':
          final modeStr = (call.arguments as String).trim().toLowerCase();
          final mode = VisualizerMode.values.firstWhere(
            (m) => m.name.toLowerCase() == modeStr,
            orElse: () => VisualizerMode.particle,
          );
          _switchMode(mode);
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

  void _switchMode(VisualizerMode mode) {
    setState(() {
      _selectedMode = mode;
      switch (mode) {
        case VisualizerMode.particle:
          _selectedPresetName = _particlePresets.keys.first;
          _particleStyle = _particlePresets.values.first;
          break;
        case VisualizerMode.liquid:
          _selectedPresetName = _liquidPresets.keys.first;
          _liquidStyle = _liquidPresets.values.first;
          break;
        case VisualizerMode.galaxy:
          _selectedPresetName = _galaxyPresets.keys.first;
          _galaxyStyle = _galaxyPresets.values.first;
          break;
        case VisualizerMode.wireframe:
          _selectedPresetName = _wireframePresets.keys.first;
          _wireframeStyle = _wireframePresets.values.first;
          break;
        case VisualizerMode.spectrum:
          _selectedPresetName = _spectrumPresets.keys.first;
          _spectrumStyle = _spectrumPresets.values.first;
          break;
        case VisualizerMode.waveMesh:
          _selectedPresetName = _waveMeshPresets.keys.first;
          _waveMeshStyle = _waveMeshPresets.values.first;
          break;
        case VisualizerMode.constellation:
          _selectedPresetName = _constellationPresets.keys.first;
          _constellationStyle = _constellationPresets.values.first;
          break;
        case VisualizerMode.siri:
          _selectedPresetName = _siriPresets.keys.first;
          _siriStyle = _siriPresets.values.first;
          break;
        case VisualizerMode.flare:
          _selectedPresetName = _flarePresets.keys.first;
          _flareStyle = _flarePresets.values.first;
          break;
      }
    });
    _scrollToPreset(0);
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

  /// Starts the automatic UI tour navigation sequence across all visualizer widgets.
  void startAutoTour() {
    setState(() {
      _isAutoTourActive = true;
      _tourStep = 0;
    });
    _executeTourStep(_tourStep);

    _tourTimer?.cancel();
    _tourTimer = Timer.periodic(const Duration(milliseconds: 3800), (timer) {
      if (!mounted || !_isAutoTourActive) {
        timer.cancel();
        return;
      }
      setState(() {
        _tourStep = (_tourStep + 1) % 11;
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
          _selectedMode = VisualizerMode.particle;
          _selectedPresetName = 'Gemini';
          _particleStyle = _particlePresets['Gemini']!;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.speech;
          _tourDescription = '1/11: Particle Orb (Gemini Aura)';
        });
        _scrollToPreset(0);
        break;
      case 1:
        setState(() {
          _selectedMode = VisualizerMode.liquid;
          _selectedPresetName = 'Mercury';
          _liquidStyle = _liquidPresets['Mercury']!;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.pulse;
          _tourDescription = '2/11: Liquid Metaballs (Molten Chrome)';
        });
        _scrollToPreset(0);
        break;
      case 2:
        setState(() {
          _selectedMode = VisualizerMode.galaxy;
          _selectedPresetName = 'Andromeda';
          _galaxyStyle = _galaxyPresets['Andromeda']!;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.sine;
          _tourDescription = '3/11: Spiral Galaxy (Keplerian Disk)';
        });
        _scrollToPreset(0);
        break;
      case 3:
        setState(() {
          _selectedMode = VisualizerMode.wireframe;
          _selectedPresetName = 'Matrix';
          _wireframeStyle = _wireframePresets['Matrix']!;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.speech;
          _tourDescription = '4/11: Holographic Wireframe (Matrix Nodes)';
        });
        _scrollToPreset(1);
        break;
      case 4:
        setState(() {
          _selectedMode = VisualizerMode.spectrum;
          _selectedPresetName = 'Neon Equalizer';
          _spectrumStyle = _spectrumPresets['Neon Equalizer']!;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.pulse;
          _tourDescription = '5/11: Radial Audio Spectrum (Equalizer Ribbons)';
        });
        _scrollToPreset(0);
        break;
      case 5:
        setState(() {
          _selectedMode = VisualizerMode.waveMesh;
          _selectedPresetName = 'Oceanic Blue';
          _waveMeshStyle = _waveMeshPresets['Oceanic Blue']!;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.speech;
          _tourDescription = '6/11: 2.5D Wave Mesh (Oceanic Blue Waves)';
        });
        _scrollToPreset(0);
        break;
      case 6:
        setState(() {
          _selectedMode = VisualizerMode.constellation;
          _selectedPresetName = 'Neural Synapse';
          _constellationStyle = _constellationPresets['Neural Synapse']!;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.pulse;
          _tourDescription = '7/11: 2D Constellation (Neural Synapse)';
        });
        _scrollToPreset(1);
        break;
      case 7:
        setState(() {
          _selectedMode = VisualizerMode.siri;
          _selectedPresetName = 'Apple Classic';
          _siriStyle = _siriPresets['Apple Classic']!;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.speech;
          _tourDescription = '8/11: Apple Siri Chromatic Fluid Glow';
        });
        _scrollToPreset(0);
        break;
      case 8:
        setState(() {
          _selectedMode = VisualizerMode.flare;
          _selectedPresetName = 'Quantum Blue';
          _flareStyle = _flarePresets['Quantum Blue']!;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.pulse;
          _tourDescription = '9/11: Quantum Flare (3D Orbital Arc)';
        });
        _scrollToPreset(0);
        break;
      case 9:
        setState(() {
          _selectedMode = VisualizerMode.liquid;
          _selectedPresetName = 'Lava';
          _liquidStyle = _liquidPresets['Lava']!;
          _showSettings = false;
          _controller.simulationMode = SimulationMode.speech;
          _tourDescription = '10/11: Liquid Lava (Magma Audio Dynamics)';
        });
        _scrollToPreset(1);
        break;
      case 10:
        setState(() {
          _selectedMode = VisualizerMode.siri;
          _selectedPresetName = 'Apple Classic';
          _siriStyle = _siriPresets['Apple Classic']!;
          _showSettings = true;
          _controller.simulationMode = SimulationMode.pulse;
          _tourDescription = '11/11: Live Parameter & Audio Tuning';
        });
        _scrollToPreset(0);
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

  Color get _currentSilentColor {
    switch (_selectedMode) {
      case VisualizerMode.particle:
        return _particleStyle.silentColor;
      case VisualizerMode.liquid:
        return _liquidStyle.silentColor;
      case VisualizerMode.galaxy:
        return _galaxyStyle.silentColor;
      case VisualizerMode.wireframe:
        return _wireframeStyle.silentColor;
      case VisualizerMode.spectrum:
        return _spectrumStyle.silentColor;
      case VisualizerMode.waveMesh:
        return _waveMeshStyle.silentColor;
      case VisualizerMode.constellation:
        return _constellationStyle.silentColor;
      case VisualizerMode.siri:
        return _siriStyle.silentColor;
      case VisualizerMode.flare:
        return _flareStyle.silentColor;
    }
  }

  Color get _currentActiveColor {
    switch (_selectedMode) {
      case VisualizerMode.particle:
        return _particleStyle.activeColor;
      case VisualizerMode.liquid:
        return _liquidStyle.activeColor;
      case VisualizerMode.galaxy:
        return _galaxyStyle.activeColor;
      case VisualizerMode.wireframe:
        return _wireframeStyle.activeColor;
      case VisualizerMode.spectrum:
        return _spectrumStyle.activeColor;
      case VisualizerMode.waveMesh:
        return _waveMeshStyle.activeColor;
      case VisualizerMode.constellation:
        return _constellationStyle.activeColor;
      case VisualizerMode.siri:
        return _siriStyle.activeColor;
      case VisualizerMode.flare:
        return _flareStyle.activeColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.sizeOf(context).width >= 850;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: isWideScreen && _showSettings
                      ? const Alignment(-0.25, 0.0)
                      : Alignment.center,
                  radius: 1.2,
                  colors: [
                    _currentSilentColor.withValues(alpha: 0.22),
                    const Color(0xFF07080B),
                  ],
                ),
              ),
            ),
          ),

          // Main Responsive Interactive Layout
          SafeArea(
            child: Row(
              children: [
                // Primary Visualizer Canvas & Controls
                Expanded(
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildModeSelector(),
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

                // Widescreen Right Side Drawer Panel
                if (isWideScreen && _showSettings)
                  _buildWideSettingsDrawer(),
              ],
            ),
          ),

          // Mobile / Small Screen Sliding Bottom Sheet Overlay
          if (!isWideScreen && _showSettings)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildMobileSettingsSheet(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          IconButton.filledTonal(
            key: const ValueKey('btn_auto_tour'),
            icon: Icon(_isAutoTourActive
                ? Icons.pause_circle_filled
                : Icons.auto_awesome),
            tooltip: _isAutoTourActive
                ? 'Pause Auto Tour'
                : 'Start Multi-Shader Tour',
            onPressed: () {
              if (_isAutoTourActive) {
                stopAutoTour();
              } else {
                startAutoTour();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: VisualizerMode.values.map((mode) {
          final isSelected = _selectedMode == mode;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              avatar: Icon(
                mode.icon,
                size: 16,
                color: isSelected ? _currentActiveColor : Colors.white70,
              ),
              label: Text(
                mode.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: _currentActiveColor.withValues(alpha: 0.2),
              side: BorderSide(
                color: isSelected
                    ? _currentActiveColor
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 1.5 : 1.0,
              ),
              onSelected: (selected) {
                if (selected) {
                  _switchMode(mode);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTourBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _currentActiveColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: _currentActiveColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle_fill,
                  size: 16, color: _currentActiveColor),
              const SizedBox(width: 8),
              Text(
                _tourDescription,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _currentActiveColor,
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
    Widget visualizerWidget;
    switch (_selectedMode) {
      case VisualizerMode.particle:
        visualizerWidget = ParticleOrb(
          energyListenable: _controller,
          style: _particleStyle,
        );
        break;
      case VisualizerMode.liquid:
        visualizerWidget = LiquidOrb(
          energyListenable: _controller,
          style: _liquidStyle,
        );
        break;
      case VisualizerMode.galaxy:
        visualizerWidget = GalaxyOrb(
          energyListenable: _controller,
          style: _galaxyStyle,
        );
        break;
      case VisualizerMode.wireframe:
        visualizerWidget = WireframeOrb(
          energyListenable: _controller,
          style: _wireframeStyle,
        );
        break;
      case VisualizerMode.spectrum:
        visualizerWidget = SpectrumOrb(
          energyListenable: _controller,
          style: _spectrumStyle,
        );
        break;
      case VisualizerMode.waveMesh:
        visualizerWidget = WaveMeshOrb(
          energyListenable: _controller,
          style: _waveMeshStyle,
        );
        break;
      case VisualizerMode.constellation:
        visualizerWidget = ConstellationOrb(
          energyListenable: _controller,
          style: _constellationStyle,
        );
        break;
      case VisualizerMode.siri:
        visualizerWidget = SiriOrb(
          energyListenable: _controller,
          style: _siriStyle,
        );
        break;
      case VisualizerMode.flare:
        visualizerWidget = FlareOrb(
          energyListenable: _controller,
          style: _flareStyle,
        );
        break;
    }

    return Center(
      child: visualizerWidget,
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
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: energy.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_currentActiveColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPresetSelector() {
    Map<String, BaseOrbStyle> currentPresets;
    switch (_selectedMode) {
      case VisualizerMode.particle:
        currentPresets = _particlePresets;
        break;
      case VisualizerMode.liquid:
        currentPresets = _liquidPresets;
        break;
      case VisualizerMode.galaxy:
        currentPresets = _galaxyPresets;
        break;
      case VisualizerMode.wireframe:
        currentPresets = _wireframePresets;
        break;
      case VisualizerMode.spectrum:
        currentPresets = _spectrumPresets;
        break;
      case VisualizerMode.waveMesh:
        currentPresets = _waveMeshPresets;
        break;
      case VisualizerMode.constellation:
        currentPresets = _constellationPresets;
        break;
      case VisualizerMode.siri:
        currentPresets = _siriPresets;
        break;
      case VisualizerMode.flare:
        currentPresets = _flarePresets;
        break;
    }

    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        controller: _presetScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: currentPresets.keys.map((name) {
          final isSelected = _selectedPresetName == name;
          final preset = currentPresets[name]!;
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
              selectedColor: _currentActiveColor.withValues(alpha: 0.2),
              side: BorderSide(
                color: isSelected
                    ? _currentActiveColor
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 1.5 : 1.0,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPresetName = name;
                    switch (_selectedMode) {
                      case VisualizerMode.particle:
                        _particleStyle = _particlePresets[name]!;
                        break;
                      case VisualizerMode.liquid:
                        _liquidStyle = _liquidPresets[name]!;
                        break;
                      case VisualizerMode.galaxy:
                        _galaxyStyle = _galaxyPresets[name]!;
                        break;
                      case VisualizerMode.wireframe:
                        _wireframeStyle = _wireframePresets[name]!;
                        break;
                      case VisualizerMode.spectrum:
                        _spectrumStyle = _spectrumPresets[name]!;
                        break;
                      case VisualizerMode.waveMesh:
                        _waveMeshStyle = _waveMeshPresets[name]!;
                        break;
                      case VisualizerMode.constellation:
                        _constellationStyle = _constellationPresets[name]!;
                        break;
                      case VisualizerMode.siri:
                        _siriStyle = _siriPresets[name]!;
                        break;
                      case VisualizerMode.flare:
                        _flareStyle = _flarePresets[name]!;
                        break;
                    }
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
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
                    _controller.setSimulated(false);
                    _controller.start();
                  } else {
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

  Widget _buildWideSettingsDrawer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: 380,
      decoration: BoxDecoration(
        color: const Color(0xFF10131B).withValues(alpha: 0.96),
        border: Border(
          left: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: _buildSettingsContent(),
    );
  }

  Widget _buildMobileSettingsSheet() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 420),
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
      child: _buildSettingsContent(),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedMode.title} Tuning',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _showSettings = false),
              ),
            ],
          ),
          const Divider(height: 16),
          ..._buildModeSpecificSliders(),
          const Divider(height: 16),
          const Text(
            'Audio Sensitivity',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
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
            label: 'Audio Power Boost',
            value: _controller.powerBoost,
            min: 1.0,
            max: 2.5,
            onChanged: (v) => setState(() {
              _controller.powerBoost = v;
            }),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildModeSpecificSliders() {
    switch (_selectedMode) {
      case VisualizerMode.particle:
        return [
          _buildSlider(
            label: 'Base Core Radius',
            value: _particleStyle.baseRadius,
            min: 0.10,
            max: 0.35,
            onChanged: (v) => setState(() {
              _particleStyle = _particleStyle.copyWith(baseRadius: v);
            }),
          ),
          _buildSlider(
            label: 'Plasma Glow Intensity',
            value: _particleStyle.glowIntensity,
            min: 0.3,
            max: 2.5,
            onChanged: (v) => setState(() {
              _particleStyle = _particleStyle.copyWith(glowIntensity: v);
            }),
          ),
          _buildSlider(
            label: 'Speed Multiplier',
            value: _particleStyle.speedMultiplier,
            min: 0.2,
            max: 2.5,
            onChanged: (v) => setState(() {
              _particleStyle = _particleStyle.copyWith(speedMultiplier: v);
            }),
          ),
          _buildSlider(
            label: 'Idle Turbulence',
            value: _particleStyle.idleTurbulence,
            min: 0.0,
            max: 1.0,
            onChanged: (v) => setState(() {
              _particleStyle = _particleStyle.copyWith(idleTurbulence: v);
            }),
          ),
          _buildSlider(
            label: 'Particle Dot Size',
            value: _particleStyle.particleSize,
            min: 0.8,
            max: 3.5,
            onChanged: (v) => setState(() {
              _particleStyle = _particleStyle.copyWith(particleSize: v);
            }),
          ),
        ];

      case VisualizerMode.liquid:
        return [
          _buildSlider(
            label: 'Base Core Radius',
            value: _liquidStyle.baseRadius,
            min: 0.10,
            max: 0.35,
            onChanged: (v) => setState(() {
              _liquidStyle = _liquidStyle.copyWith(baseRadius: v);
            }),
          ),
          _buildSlider(
            label: 'Fluid Viscosity (smin blend)',
            value: _liquidStyle.viscosity,
            min: 0.3,
            max: 1.8,
            onChanged: (v) => setState(() {
              _liquidStyle = _liquidStyle.copyWith(viscosity: v);
            }),
          ),
          _buildSlider(
            label: 'Satellite Blob Scale',
            value: _liquidStyle.blobScale,
            min: 0.2,
            max: 0.8,
            onChanged: (v) => setState(() {
              _liquidStyle = _liquidStyle.copyWith(blobScale: v);
            }),
          ),
          _buildSlider(
            label: 'Specular Shininess',
            value: _liquidStyle.specularShininess,
            min: 0.3,
            max: 2.5,
            onChanged: (v) => setState(() {
              _liquidStyle = _liquidStyle.copyWith(specularShininess: v);
            }),
          ),
          _buildSlider(
            label: 'Subsurface Scattering Glow',
            value: _liquidStyle.refractiveGlow,
            min: 0.2,
            max: 2.0,
            onChanged: (v) => setState(() {
              _liquidStyle = _liquidStyle.copyWith(refractiveGlow: v);
            }),
          ),
        ];

      case VisualizerMode.galaxy:
        return [
          _buildSlider(
            label: 'Base Core Radius',
            value: _galaxyStyle.baseRadius,
            min: 0.10,
            max: 0.35,
            onChanged: (v) => setState(() {
              _galaxyStyle = _galaxyStyle.copyWith(baseRadius: v);
            }),
          ),
          _buildSlider(
            label: 'Spiral Arm Count',
            value: _galaxyStyle.armCount.toDouble(),
            min: 2.0,
            max: 4.0,
            onChanged: (v) => setState(() {
              _galaxyStyle = _galaxyStyle.copyWith(armCount: v.round());
            }),
          ),
          _buildSlider(
            label: 'Spiral Tightness',
            value: _galaxyStyle.spiralTightness,
            min: 0.5,
            max: 2.5,
            onChanged: (v) => setState(() {
              _galaxyStyle = _galaxyStyle.copyWith(spiralTightness: v);
            }),
          ),
          _buildSlider(
            label: 'Core Bulge Size',
            value: _galaxyStyle.coreBulgeSize,
            min: 0.4,
            max: 2.0,
            onChanged: (v) => setState(() {
              _galaxyStyle = _galaxyStyle.copyWith(coreBulgeSize: v);
            }),
          ),
          _buildSlider(
            label: 'Interstellar Dust Density',
            value: _galaxyStyle.starDustDensity,
            min: 0.2,
            max: 2.0,
            onChanged: (v) => setState(() {
              _galaxyStyle = _galaxyStyle.copyWith(starDustDensity: v);
            }),
          ),
        ];

      case VisualizerMode.wireframe:
        return [
          _buildSlider(
            label: 'Base Core Radius',
            value: _wireframeStyle.baseRadius,
            min: 0.10,
            max: 0.35,
            onChanged: (v) => setState(() {
              _wireframeStyle = _wireframeStyle.copyWith(baseRadius: v);
            }),
          ),
          _buildSlider(
            label: 'Grid Density',
            value: _wireframeStyle.gridDensity,
            min: 8.0,
            max: 32.0,
            onChanged: (v) => setState(() {
              _wireframeStyle = _wireframeStyle.copyWith(gridDensity: v);
            }),
          ),
          _buildSlider(
            label: 'Wireframe Line Thickness',
            value: _wireframeStyle.lineThickness,
            min: 0.4,
            max: 2.5,
            onChanged: (v) => setState(() {
              _wireframeStyle = _wireframeStyle.copyWith(lineThickness: v);
            }),
          ),
          _buildSlider(
            label: 'Vertex Node Glow Size',
            value: _wireframeStyle.vertexGlowSize,
            min: 0.4,
            max: 2.5,
            onChanged: (v) => setState(() {
              _wireframeStyle = _wireframeStyle.copyWith(vertexGlowSize: v);
            }),
          ),
          _buildSlider(
            label: 'CRT Scanline Intensity',
            value: _wireframeStyle.scanlineIntensity,
            min: 0.0,
            max: 1.0,
            onChanged: (v) => setState(() {
              _wireframeStyle = _wireframeStyle.copyWith(scanlineIntensity: v);
            }),
          ),
        ];

      case VisualizerMode.spectrum:
        return [
          _buildSlider(
            label: 'Base Core Radius',
            value: _spectrumStyle.baseRadius,
            min: 0.10,
            max: 0.35,
            onChanged: (v) => setState(() {
              _spectrumStyle = _spectrumStyle.copyWith(baseRadius: v);
            }),
          ),
          _buildSlider(
            label: 'Frequency Bar Count',
            value: _spectrumStyle.barCount.toDouble(),
            min: 16.0,
            max: 96.0,
            onChanged: (v) => setState(() {
              _spectrumStyle = _spectrumStyle.copyWith(barCount: v.round());
            }),
          ),
          _buildSlider(
            label: 'Bar Height Scale',
            value: _spectrumStyle.barHeightScale,
            min: 0.4,
            max: 2.5,
            onChanged: (v) => setState(() {
              _spectrumStyle = _spectrumStyle.copyWith(barHeightScale: v);
            }),
          ),
          _buildSlider(
            label: 'Bar Width',
            value: _spectrumStyle.barWidth,
            min: 0.4,
            max: 2.0,
            onChanged: (v) => setState(() {
              _spectrumStyle = _spectrumStyle.copyWith(barWidth: v);
            }),
          ),
          _buildSlider(
            label: 'Concentric Ribbon Thickness',
            value: _spectrumStyle.ribbonThickness,
            min: 0.4,
            max: 2.5,
            onChanged: (v) => setState(() {
              _spectrumStyle = _spectrumStyle.copyWith(ribbonThickness: v);
            }),
          ),
        ];

      case VisualizerMode.waveMesh:
        return [
          _buildSlider(
            label: 'Wave Amplitude',
            value: _waveMeshStyle.waveAmplitude,
            min: 0.10,
            max: 0.60,
            onChanged: (v) => setState(() {
              _waveMeshStyle = _waveMeshStyle.copyWith(waveAmplitude: v);
            }),
          ),
          _buildSlider(
            label: 'Wave Frequency',
            value: _waveMeshStyle.waveFrequency,
            min: 0.8,
            max: 3.5,
            onChanged: (v) => setState(() {
              _waveMeshStyle = _waveMeshStyle.copyWith(waveFrequency: v);
            }),
          ),
          _buildSlider(
            label: 'Perspective Pitch Tilt',
            value: _waveMeshStyle.perspectivePitch,
            min: 0.3,
            max: 1.2,
            onChanged: (v) => setState(() {
              _waveMeshStyle = _waveMeshStyle.copyWith(perspectivePitch: v);
            }),
          ),
          _buildSlider(
            label: 'Focal Bokeh Blur (DoF)',
            value: _waveMeshStyle.depthOfField,
            min: 0.0,
            max: 1.5,
            onChanged: (v) => setState(() {
              _waveMeshStyle = _waveMeshStyle.copyWith(depthOfField: v);
            }),
          ),
          _buildSlider(
            label: 'Focal Distance Plane',
            value: _waveMeshStyle.focalDistance,
            min: 0.1,
            max: 0.9,
            onChanged: (v) => setState(() {
              _waveMeshStyle = _waveMeshStyle.copyWith(focalDistance: v);
            }),
          ),
          _buildSlider(
            label: 'Vertex Node Glow Size',
            value: _waveMeshStyle.nodeGlowSize,
            min: 0.8,
            max: 4.0,
            onChanged: (v) => setState(() {
              _waveMeshStyle = _waveMeshStyle.copyWith(nodeGlowSize: v);
            }),
          ),
          _buildSlider(
            label: 'Mesh Line Thickness',
            value: _waveMeshStyle.lineThickness,
            min: 0.4,
            max: 2.5,
            onChanged: (v) => setState(() {
              _waveMeshStyle = _waveMeshStyle.copyWith(lineThickness: v);
            }),
          ),
          _buildSlider(
            label: 'Line Opacity',
            value: _waveMeshStyle.lineOpacity,
            min: 0.2,
            max: 1.0,
            onChanged: (v) => setState(() {
              _waveMeshStyle = _waveMeshStyle.copyWith(lineOpacity: v);
            }),
          ),
        ];

      case VisualizerMode.constellation:
        return [
          _buildSlider(
            label: 'Field Interaction Radius',
            value: _constellationStyle.interactionRadius,
            min: 0.20,
            max: 0.50,
            onChanged: (v) => setState(() {
              _constellationStyle =
                  _constellationStyle.copyWith(interactionRadius: v);
            }),
          ),
          _buildSlider(
            label: 'Particle Node Count',
            value: _constellationStyle.particleCount.toDouble(),
            min: 20.0,
            max: 120.0,
            onChanged: (v) => setState(() {
              _constellationStyle =
                  _constellationStyle.copyWith(particleCount: v.round());
            }),
          ),
          _buildSlider(
            label: 'Max Connection Distance',
            value: _constellationStyle.maxConnectionDistance,
            min: 40.0,
            max: 150.0,
            onChanged: (v) => setState(() {
              _constellationStyle =
                  _constellationStyle.copyWith(maxConnectionDistance: v);
            }),
          ),
          _buildSlider(
            label: 'Particle Drift Speed',
            value: _constellationStyle.particleSpeed,
            min: 0.3,
            max: 2.5,
            onChanged: (v) => setState(() {
              _constellationStyle =
                  _constellationStyle.copyWith(particleSpeed: v);
            }),
          ),
          _buildSlider(
            label: 'Particle Node Radius',
            value: _constellationStyle.particleRadius,
            min: 1.2,
            max: 5.0,
            onChanged: (v) => setState(() {
              _constellationStyle =
                  _constellationStyle.copyWith(particleRadius: v);
            }),
          ),
          _buildSlider(
            label: 'Connection Line Thickness',
            value: _constellationStyle.lineThickness,
            min: 0.4,
            max: 2.5,
            onChanged: (v) => setState(() {
              _constellationStyle =
                  _constellationStyle.copyWith(lineThickness: v);
            }),
          ),
          _buildSlider(
            label: 'Connection Glow Intensity',
            value: _constellationStyle.lineGlowIntensity,
            min: 0.3,
            max: 2.5,
            onChanged: (v) => setState(() {
              _constellationStyle =
                  _constellationStyle.copyWith(lineGlowIntensity: v);
            }),
          ),
          _buildSlider(
            label: 'Audio Impulse Force',
            value: _constellationStyle.audioImpulseForce,
            min: 0.5,
            max: 3.0,
            onChanged: (v) => setState(() {
              _constellationStyle =
                  _constellationStyle.copyWith(audioImpulseForce: v);
            }),
          ),
        ];

      case VisualizerMode.siri:
        return [
          _buildSlider(
            label: 'Base Core Radius',
            value: _siriStyle.baseRadius,
            min: 0.10,
            max: 0.35,
            onChanged: (v) => setState(() {
              _siriStyle = _siriStyle.copyWith(baseRadius: v);
            }),
          ),
          _buildSlider(
            label: 'Chromatic Dispersion',
            value: _siriStyle.chromaticIntensity,
            min: 0.3,
            max: 2.5,
            onChanged: (v) => setState(() {
              _siriStyle = _siriStyle.copyWith(chromaticIntensity: v);
            }),
          ),
          _buildSlider(
            label: 'Fluid Swirl Velocity',
            value: _siriStyle.fluidSwirlSpeed,
            min: 0.3,
            max: 2.5,
            onChanged: (v) => setState(() {
              _siriStyle = _siriStyle.copyWith(fluidSwirlSpeed: v);
            }),
          ),
          _buildSlider(
            label: 'Glow Bloom Softness',
            value: _siriStyle.edgeBlur,
            min: 0.1,
            max: 0.8,
            onChanged: (v) => setState(() {
              _siriStyle = _siriStyle.copyWith(edgeBlur: v);
            }),
          ),
          _buildSlider(
            label: 'Fluid Ripple Deformation',
            value: _siriStyle.waveDeformation,
            min: 0.1,
            max: 1.0,
            onChanged: (v) => setState(() {
              _siriStyle = _siriStyle.copyWith(waveDeformation: v);
            }),
          ),
          _buildSlider(
            label: 'Glow Bloom Intensity',
            value: _siriStyle.glowIntensity,
            min: 0.4,
            max: 2.5,
            onChanged: (v) => setState(() {
              _siriStyle = _siriStyle.copyWith(glowIntensity: v);
            }),
          ),
        ];

      case VisualizerMode.flare:
        return [
          _buildSlider(
            label: 'Base Core Radius',
            value: _flareStyle.baseRadius,
            min: 0.10,
            max: 0.35,
            onChanged: (v) => setState(() {
              _flareStyle = _flareStyle.copyWith(baseRadius: v);
            }),
          ),
          _buildSlider(
            label: 'Orbital Ring Speed',
            value: _flareStyle.orbitalSpeed,
            min: 0.3,
            max: 2.5,
            onChanged: (v) => setState(() {
              _flareStyle = _flareStyle.copyWith(orbitalSpeed: v);
            }),
          ),
          _buildSlider(
            label: 'Orbital Ring Thickness',
            value: _flareStyle.ringThickness,
            min: 0.4,
            max: 2.5,
            onChanged: (v) => setState(() {
              _flareStyle = _flareStyle.copyWith(ringThickness: v);
            }),
          ),
          _buildSlider(
            label: 'Particle Lattice Density',
            value: _flareStyle.particleDensity,
            min: 12.0,
            max: 45.0,
            onChanged: (v) => setState(() {
              _flareStyle = _flareStyle.copyWith(particleDensity: v);
            }),
          ),
          _buildSlider(
            label: 'Wake Trail Dispersion',
            value: _flareStyle.dispersionAmount,
            min: 0.2,
            max: 2.5,
            onChanged: (v) => setState(() {
              _flareStyle = _flareStyle.copyWith(dispersionAmount: v);
            }),
          ),
          _buildSlider(
            label: 'Sonic Ripple Waves',
            value: _flareStyle.sonicRippleIntensity,
            min: 0.0,
            max: 1.5,
            onChanged: (v) => setState(() {
              _flareStyle = _flareStyle.copyWith(sonicRippleIntensity: v);
            }),
          ),
          _buildSlider(
            label: 'Flare Glow Intensity',
            value: _flareStyle.glowIntensity,
            min: 0.4,
            max: 2.5,
            onChanged: (v) => setState(() {
              _flareStyle = _flareStyle.copyWith(glowIntensity: v);
            }),
          ),
        ];
    }
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 11, color: Colors.white.withValues(alpha: 0.8)),
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
            width: 38,
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
