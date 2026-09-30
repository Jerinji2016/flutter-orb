import 'dart:ui';

/// Helper to load and cache [FragmentProgram] instances for all visualizer shaders.
class OrbShaderLoader {
  static final Map<String, FragmentProgram> _cache = {};
  static final Map<String, Future<FragmentProgram>> _pending = {};

  static const String particleShaderPath = 'shaders/orb.frag';
  static const String liquidShaderPath = 'shaders/liquid_orb.frag';
  static const String galaxyShaderPath = 'shaders/galaxy_orb.frag';
  static const String wireframeShaderPath = 'shaders/wireframe_orb.frag';
  static const String spectrumShaderPath = 'shaders/audio_spectrum.frag';

  /// Loads a fragment shader from the given path (or default particle shader).
  ///
  /// Caches [FragmentProgram] instances in memory to avoid redundant
  /// recompilations across widget lifecycles.
  static Future<FragmentProgram> load({String? customAssetPath}) async {
    final path = customAssetPath ?? particleShaderPath;
    return loadPath(path);
  }

  /// Loads and caches a fragment shader by asset path.
  static Future<FragmentProgram> loadPath(String assetPath) async {
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath]!;
    }

    if (_pending.containsKey(assetPath)) {
      return _pending[assetPath]!;
    }

    final future = _loadInternal(assetPath);
    _pending[assetPath] = future;

    try {
      final program = await future;
      _cache[assetPath] = program;
      return program;
    } finally {
      _pending.remove(assetPath);
    }
  }

  static Future<FragmentProgram> _loadInternal(String assetPath) async {
    // If the path already has 'packages/', use it directly
    if (assetPath.startsWith('packages/')) {
      return await FragmentProgram.fromAsset(assetPath);
    }

    // Try direct asset path first, fallback to package asset path
    try {
      return await FragmentProgram.fromAsset(assetPath);
    } catch (_) {
      return await FragmentProgram.fromAsset(
        'packages/flutter_orb/$assetPath',
      );
    }
  }

  /// Preloads all 5 built-in shaders asynchronously for instant, stutter-free switching.
  static Future<void> preloadAll() async {
    await Future.wait([
      loadPath(particleShaderPath),
      loadPath(liquidShaderPath),
      loadPath(galaxyShaderPath),
      loadPath(wireframeShaderPath),
      loadPath(spectrumShaderPath),
    ]);
  }

  /// Clears the cached program map if needed (e.g. during testing or hot reload).
  static void clearCache() {
    _cache.clear();
    _pending.clear();
  }
}
