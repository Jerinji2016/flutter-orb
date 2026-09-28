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

out vec4 fragColor;

// --- Fast Hash & Noise Utilities ---
float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec3 hash33(vec3 p) {
    p = fract(p * vec3(0.1031, 0.1030, 0.0973));
    p += dot(p, p.yxz + 33.33);
    return fract((p.xxy + p.yxx) * p.zyx);
}

// 2D Rotation Matrix
mat2 rot2D(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

// Evaluates a 3D spherical particle shell with randomized heights and speeds
// p: 3D point along ray
// baseR: reference sphere circumference radius
// shellIndex: identifier for particle stratum (0: surface, 1: mid-altitude, 2: outer ejecta)
float sampleAltitudeParticleShell(
    vec3 p,
    float baseR,
    float t,
    float audio,
    float density,
    float heightSpread,
    float speedSpread,
    int shellIndex,
    out vec3 particleColorOut
) {
    float r = length(p);
    if (r < 0.001) return 0.0;
    
    vec3 unitP = p / r;
    
    // Spherical coordinates
    float phi = asin(clamp(unitP.y, -1.0, 1.0));
    float theta = atan(unitP.z, unitP.x);
    
    float cosPhi = max(cos(phi), 0.08);
    float numRings = density;
    float numSegments = floor(density * 2.0 * cosPhi + 1.0);
    
    vec2 gridCoord = vec2(
        (theta + 3.14159265) / (2.0 * 3.14159265) * numSegments,
        (phi + 1.5707963) / 3.14159265 * numRings + float(shellIndex) * 31.7
    );
    
    vec2 cellId = floor(gridCoord);
    vec2 cellFract = fract(gridCoord) - 0.5;
    
    vec3 rnd = hash33(vec3(cellId, float(shellIndex) * 17.3));
    
    // --- 1. Randomized Speed per Particle ---
    // Individual speed factor varying widely (e.g. 0.4x slow drift to 2.2x fast orbit)
    float particleSpeed = (0.4 + rnd.y * speedSpread * 1.8);
    float particlePhase = t * particleSpeed + rnd.x * 6.28;
    
    // Angular motion in spherical coordinate space
    vec2 angularMotion = vec2(
        sin(particlePhase) * 0.32,
        cos(particlePhase * 1.25) * 0.28
    );
    
    // Angular distance to particle center on sphere
    vec2 deltaAngle = cellFract - angularMotion;
    deltaAngle.x *= cosPhi; // Longitude convergence correction
    float angularDist = length(deltaAngle) / max(density, 1.0) * 3.14159265;
    
    // --- 2. Randomized Height from Circumference ---
    // Random base radial altitude offset + dynamic breathing + audio burst
    float randomHeightOffset = rnd.x * heightSpread * baseR;
    float dynamicHeight = randomHeightOffset + sin(particlePhase * 1.4 + rnd.z * 6.28) * (0.04 * baseR);
    
    // Audio energy pushes particles higher off the circumference at variable rates
    float audioEjection = audio * (0.15 + rnd.z * 0.35) * baseR;
    float targetParticleRadius = baseR + dynamicHeight + audioEjection;
    
    // Radial distance from ray point to particle altitude shell
    float radialDist = abs(r - targetParticleRadius);
    
    // Combined 3D distance metric (angular surface distance + radial altitude distance)
    float totalDist3D = sqrt(angularDist * angularDist * r * r + radialDist * radialDist * 4.0);
    
    // --- 3. Particle Size, Twinkle & Sparkle ---
    float twinkle = 0.55 + 0.45 * sin(t * 5.0 * particleSpeed + rnd.z * 20.0);
    float pSize = (0.014 + rnd.x * 0.016 + audio * 0.02) * twinkle;
    
    // Sharp core spark + soft glowing halo
    float spark = smoothstep(pSize, 0.0, totalDist3D);
    float halo = (0.005 * uGlowIntensity) / (totalDist3D * totalDist3D * 50.0 + 0.006);
    
    float intensity = spark * 2.0 + halo;
    
    // --- 4. Particle Color Grading ---
    // Lower particles closer to silentColor, higher/faster particles ignite to activeColor / hot white
    float energyRatio = clamp(audio * 1.5 + (dynamicHeight / (heightSpread * baseR + 0.01)) * 0.4 + rnd.y * 0.3, 0.0, 1.0);
    vec3 baseColor = mix(uSilentColor, uActiveColor, energyRatio);
    // Add white-hot highlight for fast sparks
    particleColorOut = mix(baseColor, vec3(1.0, 1.0, 1.0), clamp(spark * 0.4 + audio * 0.4, 0.0, 0.85));
    
    return intensity;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution.xy) / min(uResolution.x, uResolution.y);

    float audio = clamp(uAudio, 0.0, 1.0);
    float t = uTime * uSpeedMultiplier * 0.8;
    
    // 3D Camera Ray Setup
    vec3 ro = vec3(0.0, 0.0, 2.5);
    vec3 rd = normalize(vec3(uv, -1.4));
    
    // Global orbital rotation matrices
    mat2 rotY = rot2D(t * 0.4 + audio * 0.2);
    mat2 rotX = rot2D(t * 0.25);
    
    float baseR = uBaseRadius * 2.0;
    
    vec3 totalColor = vec3(0.0);
    float totalAlpha = 0.0;
    
    // March through the 3D altitude volume surrounding the sphere
    const int NUM_STEPS = 28;
    float maxAltitude = baseR * 1.65 + audio * 0.35;
    float startRayT = 2.5 - maxAltitude * 1.3;
    float stepSize = (maxAltitude * 2.6) / float(NUM_STEPS);
    
    for (int i = 0; i < NUM_STEPS; i++) {
        float rayT = startRayT + float(i) * stepSize;
        vec3 p = ro + rd * rayT;
        
        // Rotate 3D space
        vec3 pRot = p;
        pRot.xz = rotY * pRot.xz;
        pRot.yz = rotX * pRot.yz;
        
        float r = length(pRot);
        
        // Depth cueing (front particles brighter, back particles dimmed for 3D depth)
        float depthAttenuation = clamp((2.8 - p.z) * 0.55, 0.25, 1.0);
        
        // --- Stratum 1: Surface Orbit Particles (Low altitude, high density, steady) ---
        vec3 col1;
        float p1 = sampleAltitudeParticleShell(
            pRot, baseR, t, audio, 34.0, 0.15, 1.0, 0, col1
        );
        
        // --- Stratum 2: Mid-Altitude Floating Sparks (Randomized heights 0-45%, varied speeds) ---
        vec3 col2;
        float p2 = sampleAltitudeParticleShell(
            pRot, baseR, t * 1.2, audio, 24.0, 0.45, 1.6, 1, col2
        );
        
        // --- Stratum 3: High-Altitude Ejecta & Embers (High heights up to 75%, fast shooting) ---
        vec3 col3;
        float p3 = sampleAltitudeParticleShell(
            pRot, baseR, t * 1.5, audio, 14.0, 0.75, 2.2, 2, col3
        );
        
        float stepIntensity = (p1 * 0.45) + (p2 * 0.35) + (p3 * 0.30);
        vec3 stepColor = (col1 * p1 * 0.45) + (col2 * p2 * 0.35) + (col3 * p3 * 0.30);
        
        totalColor += stepColor * depthAttenuation * 0.16;
        totalAlpha += stepIntensity * depthAttenuation * 0.14;
    }
    
    // --- Volumetric Core Ambient Plasma ---
    float distToCenter = length(uv);
    float normalizedDist = distToCenter / max(baseR * 0.6, 0.001);
    
    float coreGlow = exp(-normalizedDist * normalizedDist * 3.0) * (0.16 + audio * 0.45) * uGlowIntensity;
    vec3 coreColor = mix(uSilentColor, uActiveColor, clamp(audio * 1.6, 0.0, 1.0));
    totalColor += coreColor * coreGlow * 0.6;
    totalAlpha += coreGlow * 0.5;
    
    // Outer atmospheric rim bloom
    float rimBloom = (0.010 * uGlowIntensity) / (abs(distToCenter - baseR * 0.65) + 0.035);
    totalColor += coreColor * rimBloom * (0.12 + audio * 0.4);
    totalAlpha += rimBloom * 0.2;
    
    // Tone mapping and clamp
    totalColor = clamp(totalColor, 0.0, 1.8);
    totalAlpha = clamp(totalAlpha, 0.0, 1.0);
    
    // Premultiplied alpha output for clean Flutter Canvas compositing
    fragColor = vec4(totalColor * totalAlpha, totalAlpha);
}
