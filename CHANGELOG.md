## 1.0.1 (2026-09-28)

- ci: configure tag publish trigger on v* and enable RELEASE_TOKEN tag pushing

## 1.0.0

- Initial release of `flutter_orb`.
- GPU-accelerated raymarched Simplex noise particle orb using Flutter's native `FragmentProgram` API.
- Audio-reactive microphone streaming with `record` package.
- Exponential Moving Average (EMA) audio smoothing, configurable noise floors, and decibel normalization.
- Preset visual styles: `gemini()`, `cyberpunk()`, `solar()`, `emerald()`, `neonRose()`, `monochrome()`.
- Built-in simulation modes (`speech`, `pulse`, `sine`, `idle`) for emulators and previewing without microphone access.
- Drop-in `AudioReactiveOrb` and pure `ParticleOrb` widgets.
