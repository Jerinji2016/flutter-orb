import 'dart:ui';

/// Helper to load and cache the [FragmentProgram] for the particle orb.
class OrbShaderLoader {
  static FragmentProgram? _cachedProgram;
  static Future<FragmentProgram>? _loadingFuture;

  /// Loads the orb fragment shader.
  ///
  /// Caches the [FragmentProgram] instance in memory to avoid redundant
  /// recompilations across widget lifecycles.
  static Future<FragmentProgram> load({String? customAssetPath}) async {
    if (customAssetPath == null && _cachedProgram != null) {
      return _cachedProgram!;
    }

    if (customAssetPath == null && _loadingFuture != null) {
      return _loadingFuture!;
    }

    final future = _loadInternal(customAssetPath);
    if (customAssetPath == null) {
      _loadingFuture = future;
    }

    try {
      final program = await future;
      if (customAssetPath == null) {
        _cachedProgram = program;
      }
      return program;
    } finally {
      if (customAssetPath == null) {
        _loadingFuture = null;
      }
    }
  }

  static Future<FragmentProgram> _loadInternal(String? customAssetPath) async {
    if (customAssetPath != null) {
      return await FragmentProgram.fromAsset(customAssetPath);
    }

    // Try package asset path first, fallback to root asset path
    try {
      return await FragmentProgram.fromAsset(
        'packages/flutter_orb/shaders/orb.frag',
      );
    } catch (_) {
      return await FragmentProgram.fromAsset('shaders/orb.frag');
    }
  }

  /// Clears the cached program if needed (e.g. during testing or hot reload).
  static void clearCache() {
    _cachedProgram = null;
    _loadingFuture = null;
  }
}
