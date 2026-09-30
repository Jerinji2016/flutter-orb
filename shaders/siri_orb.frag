#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uAudio;
uniform vec3 uSilentColor;
uniform vec3 uActiveColor;
uniform vec3 uTertiaryColor;
uniform vec3 uQuaternaryColor;
uniform float uBaseRadius;
uniform float uGlowIntensity;
uniform float uSpeedMultiplier;
uniform float uChromaticIntensity;
uniform float uFluidSwirlSpeed;
uniform float uEdgeBlur;
uniform float uWaveDeformation;

out vec4 fragColor;

const float PI = 3.14159265359;

// 2D Rotation Matrix
mat2 rot2D(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

// Evaluates a silky translucent Siri ribbon blade
vec3 evaluateSiriBlade(
    vec2 p,
    float angle,
    float lengthScale,
    float widthScale,
    float waveFreq,
    float waveAmp,
    float timePhase,
    vec3 baseColor,
    vec3 tipColor,
    float baseR,
    float audio
) {
    mat2 rot = rot2D(-angle);
    vec2 q = rot * p;

    float len = baseR * lengthScale * (0.95 + audio * 0.15);
    float u = q.x;
    float v = q.y;

    if (u < -baseR * 0.25 || u > len) {
        return vec3(0.0);
    }

    // Progression along the blade spine [0.0 = center, 1.0 = sharp tip]
    float tProgress = clamp(u / len, 0.0, 1.0);

    // Organic sinusoidal wave crest displacement
    float wave = sin(tProgress * PI * waveFreq - timePhase) * (waveAmp * baseR * tProgress);

    // Lateral distance from the spine
    float distSpine = v - wave;

    // Elegant leaf/blade width profile with smooth base connection and needle-sharp tip
    float widthEnvelope = (sin(pow(tProgress, 0.7) * PI) * 0.88 + (1.0 - tProgress) * 0.18);
    float halfWidth = widthScale * baseR * widthEnvelope * (0.9 + audio * 0.25);
    halfWidth = max(halfWidth, 0.0005);

    if (abs(distSpine) > halfWidth) {
        return vec3(0.0);
    }

    // Translucent ribbon sheet profile
    float normDist = abs(distSpine) / halfWidth;
    float sheet = pow(1.0 - normDist, 1.5);

    // Silky razor-sharp illuminated crest
    float crest = exp(-distSpine * distSpine / (baseR * baseR * 0.0004)) * (1.15 + audio * 0.4);

    // Soft tip fade and base transition
    float tipFade = smoothstep(1.0, 0.88, tProgress) * smoothstep(-0.25, -0.05, u / len);

    // Color gradient from base to tip
    vec3 col = mix(baseColor, tipColor, tProgress);
    col = col * sheet * 1.35 + mix(tipColor, vec3(1.0), 0.75) * crest;

    return col * tipFade;
}

// Large Crimson Red Background Bowl/Curtain (Upper-Left Quadrant)
vec3 evaluateRedBowl(vec2 p, float baseR, float t, float audio, vec3 redColor) {
    vec2 q = rot2D(0.52 + sin(t * 0.5) * 0.08) * p;

    // Parabolic curved sheet boundary in upper hemisphere
    float waveY = 0.07 * baseR * sin(q.x * 3.8 / baseR - t * 1.1) + 0.04 * baseR;
    float dist = q.y - waveY;

    // Deep smooth crimson dome filling the upper-left
    if (dist < -0.08 * baseR || dist > 0.75 * baseR) {
        return vec3(0.0);
    }

    float normDist = clamp(dist / (0.70 * baseR), 0.0, 1.0);
    float sheet = sin(normDist * PI);
    float xFade = smoothstep(0.35 * baseR, -0.20 * baseR, q.x);
    sheet = pow(sheet, 1.05) * xFade;

    // Sharp silky crest along the wave line
    float crest = exp(-dist * dist / (baseR * baseR * 0.0008)) * 0.95 * xFade;

    vec3 col = mix(redColor * 0.75, vec3(1.0, 0.22, 0.38), sheet * 0.5);
    return col * sheet * 1.05 + vec3(1.0, 0.65, 0.75) * (crest * 0.75);
}

void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * uResolution.xy) / min(uResolution.x, uResolution.y);
    float r = length(p);

    float t = uTime * uSpeedMultiplier * uFluidSwirlSpeed;
    float audio = clamp(uAudio, 0.0, 1.0);
    float baseR = uBaseRadius * 1.70;

    baseR *= (1.0 + audio * 0.05);

    vec3 rgb = vec3(0.0);
    float alpha = 0.0;

    // --- 1. Outer Spherical Glass Shell ---
    if (r <= baseR) {
        float z = sqrt(baseR * baseR - r * r);
        float normZ = z / baseR;

        // Pure deep obsidian backdrop
        vec3 sphereBg = vec3(0.012, 0.006, 0.020);

        // Subtle dark glass Fresnel rim reflection
        float fresnel = pow(1.0 - normZ, 4.0);
        sphereBg += mix(uActiveColor, uTertiaryColor, 0.3) * (fresnel * 0.28);
        rgb += sphereBg;

        // --- 2. Crimson Red Satin Sheet (Upper-Left Background) ---
        vec3 redLayer = evaluateRedBowl(p, baseR, t, audio, uTertiaryColor);
        rgb += redLayer;

        // --- 3. Transverse Emerald / Aquamarine Flowing Ribbon Wave (Middle-Left to Right) ---
        {
            float angleGreen = 3.05 + sin(t * 0.7 + 0.4) * 0.12;
            vec3 greenBlade = evaluateSiriBlade(
                p,
                angleGreen,
                0.86,
                0.28 * uWaveDeformation,
                1.4,
                0.14,
                t * 2.0 + 3.5,
                uQuaternaryColor, // Emerald Green
                mix(uQuaternaryColor, vec3(0.1, 0.95, 0.9), 0.7), // Aquamarine tip
                baseR,
                audio
            );
            rgb += greenBlade * 1.15;
        }

        // --- 4. Royal Electric Blue Ribbon Blades (Sharp Spire & Curved Wings) ---

        // Blade A: Top-Right Spire (Prominent vertical blade pointing up & right)
        {
            float angleSpire = 1.32 + sin(t * 0.65) * 0.14;
            vec3 spireBlade = evaluateSiriBlade(
                p,
                angleSpire,
                0.92,
                0.24 * uWaveDeformation,
                1.3,
                0.15,
                t * 2.1,
                uActiveColor, // Royal Electric Blue
                mix(uActiveColor, vec3(0.0, 0.9, 1.0), 0.8), // Cyan needle tip
                baseR,
                audio
            );
            rgb += spireBlade * 1.25;
        }

        // Blade B: Bottom-Right Curved Wing (Pointing down & right)
        {
            float angleBottom = -0.92 + cos(t * 0.75 + 1.2) * 0.14;
            vec3 bottomBlade = evaluateSiriBlade(
                p,
                angleBottom,
                0.88,
                0.26 * uWaveDeformation,
                1.2,
                0.16,
                t * 1.9 + 1.8,
                uActiveColor,
                mix(uActiveColor, vec3(0.15, 0.75, 1.0), 0.6),
                baseR,
                audio
            );
            rgb += bottomBlade * 1.2;
        }

        // Blade C: Far-Right Transverse Petal
        {
            float angleRight = 0.02 + sin(t * 0.85 + 2.2) * 0.10;
            vec3 rightBlade = evaluateSiriBlade(
                p,
                angleRight,
                0.82,
                0.22 * uWaveDeformation,
                1.1,
                0.12,
                t * 2.2 + 3.0,
                mix(uActiveColor, uQuaternaryColor, 0.35),
                mix(uQuaternaryColor, vec3(0.0, 1.0, 0.9), 0.7),
                baseR,
                audio
            );
            rgb += rightBlade * 1.1;
        }

        // Blade D: Upper-Left Cyan Crest
        {
            float angleCyan = 2.40 + cos(t * 0.6 + 2.8) * 0.12;
            vec3 cyanBlade = evaluateSiriBlade(
                p,
                angleCyan,
                0.75,
                0.20 * uWaveDeformation,
                1.2,
                0.10,
                t * 1.8 + 4.5,
                mix(uActiveColor, vec3(0.0, 0.95, 1.0), 0.8),
                vec3(0.9, 0.98, 1.0),
                baseR,
                audio
            );
            rgb += cyanBlade * 1.0;
        }

        // --- 5. Brilliant Compact Incandescent White Core Lens ---
        // Intense focal core at the intersection
        float coreR = baseR * (0.16 + audio * 0.08);
        float coreIntensity = exp(-r * r / (coreR * coreR * 0.45)) * (3.8 + audio * 2.0);
        vec3 coreColor = vec3(1.0, 1.0, 1.0) * coreIntensity;

        // Radiating diffuse glow illuminating ribbon bases
        float auraR = baseR * (0.34 + audio * 0.12);
        float diffuseAura = exp(-r / auraR) * (0.80 + audio * 0.5);
        vec3 diffuseColor = mix(uActiveColor, vec3(1.0, 0.98, 0.95), 0.8) * diffuseAura;

        rgb += coreColor + diffuseColor;

        // Glass sphere boundary vignette
        float rimVignette = smoothstep(baseR, baseR * 0.92, r);
        rgb = mix(rgb * 0.3, rgb, rimVignette);

        alpha = 1.0;
    }

    // --- 6. Outer Soft Diffuse Bloom Halo ---
    float haloR = baseR * (1.18 + audio * 0.25);
    float halo = exp(-r * r / (haloR * haloR)) * (0.22 + audio * 0.25) * uGlowIntensity;
    vec3 haloColor = mix(uActiveColor, uTertiaryColor, 0.35 + 0.3 * sin(t * 0.8)) * halo;
    rgb += haloColor;

    // --- 7. Tone Mapping & High Dynamic Range Contrast ---
    rgb = rgb / (vec3(1.0) + rgb * 0.15);
    rgb = pow(max(rgb, vec3(0.0)), vec3(0.96));

    alpha = clamp(dot(rgb, vec3(0.299, 0.587, 0.114)) * 1.9, 0.0, 1.0);

    fragColor = vec4(rgb * alpha, alpha);
}
