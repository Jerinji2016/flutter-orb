#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uAudio;
uniform vec3 uSilentColor;
uniform vec3 uActiveColor;
uniform float uBaseRadius;
uniform float uGlowIntensity;
uniform float uSpeedMultiplier;
uniform float uBarCount;
uniform float uBarHeightScale;
uniform float uBarWidth;
uniform float uRibbonThickness;

out vec4 fragColor;

// --- Fast Hash & Noise Utilities ---
float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution.xy) / min(uResolution.x, uResolution.y);
    
    float audio = clamp(uAudio, 0.0, 1.0);
    float t = uTime * uSpeedMultiplier;
    
    // Polar coordinate mapping
    float r = length(uv);
    float theta = atan(uv.y, uv.x); // [-PI, PI]
    float normTheta = (theta + 3.14159265) / (2.0 * 3.14159265); // [0.0, 1.0]
    
    float baseR = uBaseRadius * 1.5;
    float barCount = max(floor(uBarCount + 0.5), 16.0);
    
    // 1. Radial Discrete Equalizer Bars
    float barIndex = floor(normTheta * barCount);
    float barFract = fract(normTheta * barCount) - 0.5; // [-0.5, 0.5]
    
    // Multi-harmonic procedural frequency simulation per bar
    float freqHash = hash11(barIndex * 13.37);
    float bassBand = sin(barIndex * 0.25 + t * 2.0) * 0.5 + 0.5;
    float midBand = cos(barIndex * 0.65 - t * 3.2 + freqHash * 6.28) * 0.5 + 0.5;
    float trebleBand = sin(barIndex * 1.4 + t * 5.0) * 0.5 + 0.5;
    
    // Frequency bar target height
    float simulatedHeight = (bassBand * 0.45 + midBand * 0.35 + trebleBand * 0.20);
    float barMaxHeight = (0.04 + simulatedHeight * 0.22 * uBarHeightScale * (0.15 + audio * 1.2));
    
    // Bar distance evaluation
    float barDistR = r - baseR;
    float angularDist = abs(barFract) * (2.0 * 3.14159265 * r / barCount);
    float barWidthHalf = max(uBarWidth * 0.008, 0.002);
    
    // Signed distance to rectangular bar with rounded cap
    float dBarX = max(angularDist - barWidthHalf, 0.0);
    float dBarY = max(abs(barDistR - barMaxHeight * 0.5) - barMaxHeight * 0.5, 0.0);
    float dBar = length(vec2(dBarX, dBarY));
    
    float barIntensity = smoothstep(0.006, 0.0, dBar) * (1.2 + audio * 0.8);
    float barHalo = (0.002 * uGlowIntensity) / (dBar * dBar * 120.0 + 0.003);
    
    // Floating peak dot / cap
    float peakR = baseR + barMaxHeight + 0.015;
    float dPeak = length(vec2(angularDist, r - peakR));
    float peakIntensity = smoothstep(0.008, 0.0, dPeak) * (1.5 + audio * 1.5);
    
    // 2. Concentric Waveform Oscillating Ribbons
    float ribbon1Wave = sin(theta * 8.0 + t * 4.0) * (0.01 + audio * 0.035)
                      + cos(theta * 14.0 - t * 6.0) * (0.006 + audio * 0.02);
    float ribbon1R = baseR * 0.85 + ribbon1Wave;
    float dRibbon1 = abs(r - ribbon1R);
    float ribbon1Intensity = smoothstep(max(uRibbonThickness * 0.012, 0.003), 0.0, dRibbon1) * (1.0 + audio * 1.5);
    
    float ribbon2Wave = cos(theta * 6.0 - t * 3.0) * (0.015 + audio * 0.04);
    float ribbon2R = baseR * 1.0 + barMaxHeight * 0.5 + ribbon2Wave;
    float dRibbon2 = abs(r - ribbon2R);
    float ribbon2Glow = (0.003 * uGlowIntensity) / (dRibbon2 * dRibbon2 * 60.0 + 0.005);
    
    // 3. Central Core Bass Pulse & Bloom
    float corePulse = exp(-r * r * (18.0 / max(baseR * baseR, 0.01))) * (0.2 + audio * 0.8) * uGlowIntensity;
    
    // 4. Color Grading
    float totalEnergy = clamp(audio * 1.4 + (barDistR / max(barMaxHeight + 0.01, 0.01)) * 0.5, 0.0, 1.0);
    vec3 baseColor = mix(uSilentColor, uActiveColor, totalEnergy);
    
    vec3 totalColor = vec3(0.0);
    float totalAlpha = 0.0;
    
    // Add Bars & Caps
    totalColor += baseColor * (barIntensity + barHalo);
    totalAlpha += (barIntensity * 0.9 + barHalo * 0.3);
    
    // Add White-Hot Peak Dots
    totalColor += mix(uActiveColor, vec3(1.0), 0.7) * peakIntensity;
    totalAlpha += peakIntensity * 0.8;
    
    // Add Ribbons & Core Glow
    totalColor += mix(uSilentColor, uActiveColor, 0.6) * (ribbon1Intensity + ribbon2Glow);
    totalAlpha += ribbon1Intensity * 0.6 + ribbon2Glow * 0.3;
    
    totalColor += baseColor * corePulse;
    totalAlpha += corePulse * 0.5;
    
    // Tone mapping and clamp
    totalColor = clamp(totalColor, 0.0, 2.0);
    totalAlpha = clamp(totalAlpha, 0.0, 1.0);
    
    fragColor = vec4(totalColor * totalAlpha, totalAlpha);
}
