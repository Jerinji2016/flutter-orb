#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uAudio;
uniform vec3 uSilentColor;
uniform vec3 uActiveColor;
uniform vec3 uFlareColor;
uniform vec3 uCoreHighlightColor;
uniform float uBaseRadius;
uniform float uGlowIntensity;
uniform float uSpeedMultiplier;
uniform float uRingThickness;
uniform float uOrbitalSpeed;
uniform float uParticleDensity;
uniform float uDispersionAmount;
uniform float uSonicRippleIntensity;

out vec4 fragColor;

const float PI = 3.14159265359;

// 2D Rotation Matrix
mat2 rot2D(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

// Pseudo-random hash
float hash(vec3 p) {
    p = fract(p * 0.3183099 + 0.1);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

// 3D Simplex-style Noise
float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(mix(hash(i + vec3(0, 0, 0)), hash(i + vec3(1, 0, 0)), f.x),
            mix(hash(i + vec3(0, 1, 0)), hash(i + vec3(1, 1, 0)), f.x), f.y),
        mix(mix(hash(i + vec3(0, 0, 1)), hash(i + vec3(1, 0, 1)), f.x),
            mix(hash(i + vec3(0, 1, 1)), hash(i + vec3(1, 1, 1)), f.x), f.y),
        f.z
    );
}

void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * uResolution.xy) / min(uResolution.x, uResolution.y);
    float r = length(p);

    float t = uTime * uSpeedMultiplier;
    float audio = clamp(uAudio, 0.0, 1.0);
    float baseR = uBaseRadius * 1.65;

    // --- 1. Dynamic 3D Inclined Orbital Vector System ---
    float orbitAngle = t * 0.45 + audio * 0.15;
    float inclination = 0.72; // ~41 degrees tilt
    vec3 nRing = vec3(sin(inclination) * cos(orbitAngle), cos(inclination), sin(inclination) * sin(orbitAngle));
    nRing = normalize(nRing);

    vec3 uRing = normalize(cross(nRing, vec3(0.0, 0.0, 1.0)));
    vec3 vRing = cross(nRing, uRing);

    float headAngle = t * uOrbitalSpeed * 1.5 + audio * 0.45;
    vec3 pHead = uRing * cos(headAngle) + vRing * sin(headAngle);

    vec3 rgb = vec3(0.0);
    float alpha = 0.0;

    // --- 2. Concentric Ambient Sonic Soundwaves (Deep Violet / Indigo ripples) ---
    if (uSonicRippleIntensity > 0.01) {
        float rippleWave = sin(r * 38.0 - t * 4.0) * 0.5 + 0.5;
        float rippleFalloff = exp(-r * 3.0) * uSonicRippleIntensity * (0.2 + audio * 0.7);
        vec3 rippleColor = mix(uSilentColor, vec3(0.14, 0.06, 0.32), 0.75) * (rippleWave * rippleFalloff);
        rgb += rippleColor;
    }

    // Scanline & Holographic Raster Weave
    float scanline = sin((p.y + p.x * 0.32) * 240.0) * 0.22 + 0.78;
    float density = max(24.0, uParticleDensity * 1.6);

    // --- 3. 3D Holographic Particle Sphere Shading ---
    if (r <= baseR) {
        float zFront = sqrt(baseR * baseR - r * r);
        float zBack = -zFront;

        vec3 pFront = vec3(p.x, p.y, zFront);
        vec3 pBack = vec3(p.x, p.y, zBack);

        // Spherical coordinates for latitude/longitude dot projection
        vec3 nFront = pFront / baseR;
        vec3 nBack = pBack / baseR;

        float ringThick = max(0.05, 0.12 * uRingThickness * (1.0 + audio * 0.35));

        // --- BACK HEMISPHERE (Deep, translucent, stippled particles) ---
        {
            float deltaBack = abs(dot(nBack, nRing));
            float ringBack = exp(-deltaBack * deltaBack / (ringThick * ringThick * 1.2));

            float phiB = atan(nBack.z, nBack.x);
            float thetaB = asin(clamp(nBack.y, -1.0, 1.0));
            vec2 uvB = vec2(phiB / PI, thetaB / (0.5 * PI)) * (density * 0.5);

            vec2 cellB = fract(uvB) - 0.5;
            float dotB = smoothstep(0.42, 0.08, length(cellB));
            float stippleB = hash(vec3(floor(uvB), 1.0));
            float particleBack = dotB * (0.35 + 0.65 * stippleB);

            vec3 colBack = uSilentColor * (particleBack * 0.5);
            colBack += uFlareColor * ringBack * (0.35 + 0.35 * particleBack);
            rgb += colBack * 0.45;
        }

        // --- FRONT HEMISPHERE (Crisp, luminous, sweeping flare ribbon) ---
        {
            float deltaFront = abs(dot(nFront, nRing));
            float ringFront = exp(-deltaFront * deltaFront / (ringThick * ringThick));

            // Flare Head Nucleus & Incandescent Crest
            float cosHead = clamp(dot(nFront, pHead), -1.0, 1.0);
            float distHead = acos(cosHead);
            float headIntensity = exp(-distHead * distHead / (0.055 * (1.0 + audio * 0.45))) * 3.4;

            // Trailing plasma wake along the orbital ring
            float wakeAngle = mod(headAngle - atan(dot(nFront, vRing), dot(nFront, uRing)) + 2.0 * PI, 2.0 * PI);
            float wakeFactor = exp(-wakeAngle * 1.7) * ringFront * (0.85 + audio * 0.5);

            // Front Spherical Coordinate Dot Grid
            float phiF = atan(nFront.z, nFront.x);
            float thetaF = asin(clamp(nFront.y, -1.0, 1.0));
            vec2 uvF = vec2(phiF / PI, thetaF / (0.5 * PI)) * (density * 0.5);

            vec2 cellF = fract(uvF) - 0.5;
            float dotF = smoothstep(0.44, 0.08, length(cellF));
            float stippleF = hash(vec3(floor(uvF), 2.0));
            float particleFront = dotF * (0.45 + 0.55 * stippleF) * scanline;

            // Base Particle Sphere Color (Fine celestial cyan dots)
            vec3 colFront = uActiveColor * (particleFront * (0.6 + audio * 0.45));

            // Sweeping Orbital Plasma Band (Neon Cyan with Violet/Magenta corona fringe)
            vec3 magentaFringe = vec3(0.85, 0.25, 0.95);
            vec3 ringColor = mix(uFlareColor, magentaFringe, clamp(deltaFront * 4.5, 0.0, 0.7));
            colFront += ringColor * ringFront * (0.95 + 0.85 * particleFront + audio * 0.6);

            // Trailing Particle Wake Dispersion
            colFront += mix(uFlareColor, uActiveColor, 0.5) * (wakeFactor * uDispersionAmount * (0.85 + 0.85 * particleFront));

            // Incandescent White-Hot Flare Head with Violet/Magenta Fringe
            vec3 flareNucleus = mix(magentaFringe, uCoreHighlightColor, 0.82) * headIntensity
                              + uCoreHighlightColor * pow(headIntensity * 0.45, 2.4) * 2.4;
            colFront += flareNucleus * (1.0 + audio * 0.5);

            // Spherical Rim / Limb Fresnel Glow
            float limb = pow(1.0 - nFront.z, 2.6) * (0.65 + audio * 0.45);
            colFront += mix(uActiveColor, magentaFringe, 0.35) * limb * 0.95;

            rgb += colFront;
        }

        alpha = 1.0;
    }

    // --- 4. Dispersed Particle Wake Sparks (Organic Quantum Ejecta) ---
    if (uDispersionAmount > 0.05) {
        vec3 pHeadRay = pHead * baseR;
        float distToHead = length(p - pHeadRay.xy);
        float ejectaMask = exp(-distToHead * distToHead / (baseR * baseR * 0.12)) * (0.55 + audio * 0.55);
        if (ejectaMask > 0.01) {
            float sparkNoise = noise(vec3(p * 45.0, t * 1.8));
            float spark = pow(sparkNoise, 3.5) * ejectaMask * uDispersionAmount;
            vec3 ejectaColor = mix(uFlareColor, vec3(0.85, 0.35, 1.0), 0.4) * spark * 2.8;
            rgb += ejectaColor;
        }
    }

    // --- 5. Outer Radiant Bloom & Incandescent Lens Glow ---
    vec2 pHeadScreen = pHead.xy * baseR;
    float distHead2D = length(p - pHeadScreen);
    float flareBloom = exp(-distHead2D * distHead2D / (baseR * baseR * 0.10)) * (1.05 + audio * 1.2) * uGlowIntensity;
    vec3 flareBloomColor = mix(uFlareColor, uCoreHighlightColor, 0.65) * flareBloom;
    rgb += flareBloomColor;

    // Outer Limb Soft Glow
    float haloR = baseR * (1.15 + audio * 0.3);
    float halo = exp(-r * r / (haloR * haloR)) * (0.22 + audio * 0.25) * uGlowIntensity;
    rgb += uActiveColor * halo;

    // --- 6. Tone Mapping & Saturation Boost ---
    rgb = rgb / (vec3(1.0) + rgb * 0.18);
    rgb = pow(max(rgb, vec3(0.0)), vec3(0.95));

    alpha = clamp(dot(rgb, vec3(0.299, 0.587, 0.114)) * 1.8, 0.0, 1.0);

    fragColor = vec4(rgb * alpha, alpha);
}
