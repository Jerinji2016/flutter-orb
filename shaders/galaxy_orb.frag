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
uniform float uArmCount;
uniform float uSpiralTightness;
uniform float uCoreBulgeSize;
uniform float uStarDustDensity;

out vec4 fragColor;

// --- Fast Hash & Noise Utilities ---
float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash12(i);
    float b = hash12(i + vec2(1.0, 0.0));
    float c = hash12(i + vec2(0.0, 1.0));
    float d = hash12(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    mat2 rot = mat2(0.8, 0.6, -0.6, 0.8);
    for (int i = 0; i < 4; i++) {
        v += a * noise(p);
        p = rot * p * 2.05;
        a *= 0.5;
    }
    return v;
}

mat2 rot2D(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution.xy) / min(uResolution.x, uResolution.y);
    
    float audio = clamp(uAudio, 0.0, 1.0);
    float t = uTime * uSpeedMultiplier * 0.7;
    
    // 3D Camera Ray
    vec3 ro = vec3(0.0, 0.0, 2.7);
    vec3 rd = normalize(vec3(uv, -1.35));
    
    // Galactic inclination tilt & slow cosmic yaw
    mat2 pitchMat = rot2D(-0.80); // ~46 degree tilt
    mat2 yawMat = rot2D(t * 0.15);
    
    ro.yz = pitchMat * ro.yz;
    rd.yz = pitchMat * rd.yz;
    ro.xz = yawMat * ro.xz;
    rd.xz = yawMat * rd.xz;
    
    float baseR = max(uBaseRadius * 2.1, 0.2);
    float coreR = baseR * max(uCoreBulgeSize, 0.35) * 0.45;
    float armNum = max(floor(uArmCount + 0.5), 2.0);
    float tightness = max(uSpiralTightness, 0.35) * 2.4;
    
    vec3 totalColor = vec3(0.0);
    float totalAlpha = 0.0;
    
    // --- 1. Continuous Analytical Galactic Disk Sampling (Plane Y = 0) ---
    if (abs(rd.y) > 0.0001) {
        float tPlane = -ro.y / rd.y;
        if (tPlane > 0.0) {
            vec3 p = ro + rd * tPlane;
            float r = length(p.xz);
            
            if (r < baseR * 2.6) {
                float phi = atan(p.z, p.x);
                
                // Differential Keplerian rotation: inner disk spins faster
                float angularVel = (1.4 / (pow(r / baseR, 0.55) + 0.28)) * (1.0 + audio * 0.35);
                float dynamicPhi = phi - t * angularVel;
                
                // Logarithmic spiral density wave equation: phi = tightness * ln(r/r0)
                float logR = log(max(r / baseR, 0.005));
                float spiralPhase = dynamicPhi * armNum - logR * tightness;
                
                // Broad, glowing spiral arm wave profile
                float armCos = cos(spiralPhase);
                float armRidge = smoothstep(-0.45, 0.85, armCos);
                armRidge = pow(armRidge, 1.6);
                
                // Secondary spiral arm harmonic for feathered nebular tendrils
                float armHarmonic = cos(spiralPhase * 2.0 + 1.1) * 0.5 + 0.5;
                float combinedArms = armRidge * 0.8 + armHarmonic * armRidge * 0.35;
                
                // Multi-octave cosmic nebular gas turbulence
                vec2 nebCoord = vec2(r * 4.0 - t * 0.3, dynamicPhi * 3.0);
                float cloudNoise = fbm(nebCoord);
                float gasDensity = combinedArms * (0.65 + 0.85 * cloudNoise);
                
                // Interstellar dust absorption rifts
                vec2 dustCoord = vec2(dynamicPhi * 5.0 + 2.1, r * 9.0);
                float dustNoise = fbm(dustCoord);
                float dustAbsorption = smoothstep(0.18, 0.7, dustNoise);
                
                // Star clusters & sparkling stellar pinpoints
                vec2 starGrid = vec2(r * 30.0, dynamicPhi * 22.0);
                vec2 starCell = floor(starGrid);
                vec2 starFrac = fract(starGrid) - 0.5;
                float starHash = hash12(starCell);
                float starTwinkle = sin(t * 8.0 + starHash * 35.0) * 0.5 + 0.5;
                float starMask = step(0.82 - uStarDustDensity * 0.09, starHash);
                float starPoint = smoothstep(0.4, 0.0, length(starFrac)) * starMask * starTwinkle * (1.6 + audio * 2.4);
                
                // Smooth radial boundary envelopes
                float radialMask = smoothstep(baseR * 2.5, baseR * 0.3, r) * smoothstep(coreR * 0.15, coreR * 0.75, r);
                
                // Optical path depth through the tilted galactic disk
                float opticalDepth = clamp(0.22 / max(abs(rd.y), 0.1), 0.6, 2.5);
                
                // Rich Galactic Color Grading: Deep silent gas -> Vibrant ionized nebula -> Blinding star cores
                float heat = clamp(armRidge * 0.9 + audio * 0.7 + (1.0 - r / (baseR * 2.2)) * 0.4, 0.0, 1.0);
                vec3 gasColor = mix(uSilentColor, uActiveColor, heat);
                
                // Add soft pastel glow to arm ridges
                vec3 ridgeHighlight = mix(uActiveColor, vec3(1.0, 1.0, 1.0), 0.6);
                gasColor = mix(gasColor, ridgeHighlight, pow(armRidge, 2.5) * 0.6);
                gasColor = mix(gasColor, vec3(1.0, 1.0, 1.0), starPoint * 0.95);
                
                float diskIntensity = (gasDensity * dustAbsorption * 3.2 + starPoint * 2.8) * radialMask * opticalDepth;
                float diskAlpha = clamp(diskIntensity * (0.35 * uGlowIntensity), 0.0, 1.0);
                
                totalColor += gasColor * diskAlpha;
                totalAlpha += diskAlpha;
            }
        }
    }
    
    // --- 2. 3D Supermassive Galactic Core (Volumetric Spherical Bulge) ---
    float tCenter = dot(-ro, rd);
    vec3 pNearCenter = ro + rd * tCenter;
    float distToCore = length(pNearCenter);
    
    // Blinding core radiance
    float coreBulge = exp(-distToCore * distToCore * (14.0 / (coreR * coreR + 0.002))) * (1.8 + audio * 3.0);
    vec3 coreColor = mix(uSilentColor, uActiveColor, clamp(audio * 1.8 + 0.35, 0.0, 1.0));
    coreColor = mix(coreColor, vec3(1.0, 0.97, 0.92), clamp(coreBulge * 0.95, 0.0, 1.0));
    
    totalColor += coreColor * coreBulge * (1.1 * uGlowIntensity);
    totalAlpha = clamp(totalAlpha + coreBulge * 0.9, 0.0, 1.0);
    
    // --- 3. Relativistic Polar Jet Beams ---
    if (audio > 0.06) {
        float jetRadius = length(pNearCenter.xz);
        float jetHeight = abs(pNearCenter.y);
        float jetMask = exp(-jetRadius * 40.0) * smoothstep(baseR * 2.6, 0.0, jetHeight) * (audio * 2.8);
        vec3 jetCol = mix(uActiveColor, vec3(1.0, 1.0, 1.0), 0.85);
        totalColor += jetCol * jetMask * uGlowIntensity;
        totalAlpha = clamp(totalAlpha + jetMask * 0.65, 0.0, 1.0);
    }
    
    // --- 4. Deep Space Ambient Corona Glow ---
    float screenDist = length(uv);
    float corona = (0.022 * uGlowIntensity) / (screenDist * screenDist * 3.2 + 0.06);
    vec3 coronaCol = mix(uSilentColor, uActiveColor, 0.55);
    totalColor += coronaCol * corona * (0.6 + audio * 0.8);
    totalAlpha = clamp(totalAlpha + corona * 0.4, 0.0, 1.0);
    
    // Tone mapping and output
    totalColor = clamp(totalColor, 0.0, 2.5);
    totalAlpha = clamp(totalAlpha, 0.0, 1.0);
    
    fragColor = vec4(totalColor * totalAlpha, totalAlpha);
}
