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
uniform float uViscosity;
uniform float uBlobScale;
uniform float uSpecularShininess;
uniform float uRefractiveGlow;

out vec4 fragColor;

// 2D Rotation Matrix
mat2 rot2D(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

// Polynomial smooth minimum
float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / max(k, 0.001), 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

// Distance Field representation of the fluid blob system
float mapScene(vec3 p, float t, float audio) {
    float baseR = uBaseRadius * 1.8;
    float blobR = baseR * uBlobScale;
    float k = max(uViscosity * 0.45, 0.04);
    
    // Core Mother Blob with audio-reactive surface ripples
    float ripple = sin(p.x * 6.0 + t * 3.0) * cos(p.y * 6.0 - t * 2.5) * sin(p.z * 6.0 + t * 2.0);
    float dynamicCoreR = baseR * (1.0 + audio * 0.3) + ripple * (0.02 + audio * 0.06);
    float d = length(p) - dynamicCoreR;
    
    // Satellite Droplets orbiting along 3D Lissajous harmonic curves
    // Satellite 1
    vec3 c1 = vec3(
        sin(t * 1.4) * (baseR * 1.3 + audio * 0.2),
        cos(t * 1.1) * (baseR * 0.9),
        sin(t * 0.8) * (baseR * 1.1)
    );
    float d1 = length(p - c1) - (blobR * (0.8 + 0.3 * sin(t * 2.0 + audio)));
    d = smin(d, d1, k);
    
    // Satellite 2
    vec3 c2 = vec3(
        cos(t * 0.9 + 2.0) * (baseR * 1.2),
        sin(t * 1.6 + 1.0) * (baseR * 1.4 + audio * 0.25),
        cos(t * 1.3) * (baseR * 0.8)
    );
    float d2 = length(p - c2) - (blobR * (0.7 + 0.25 * cos(t * 2.5)));
    d = smin(d, d2, k);
    
    // Satellite 3 (fast, small ejecta)
    vec3 c3 = vec3(
        sin(t * 2.1 + 4.0) * (baseR * 1.4 + audio * 0.3),
        cos(t * 1.8 + 3.0) * (baseR * 1.2 + audio * 0.2),
        sin(t * 2.4) * (baseR * 1.3)
    );
    float d3 = length(p - c3) - (blobR * (0.55 + 0.2 * sin(t * 3.0)));
    d = smin(d, d3, k);

    // Satellite 4 (audio surge droplet)
    if (audio > 0.05) {
        vec3 c4 = vec3(
            cos(t * 2.8) * (baseR * 1.5 * audio),
            sin(t * 2.3) * (baseR * 1.5 * audio),
            cos(t * 1.9 + 1.5) * (baseR * 1.2 * audio)
        );
        float d4 = length(p - c4) - (blobR * 0.45 * audio);
        d = smin(d, d4, k);
    }
    
    return d;
}

// Calculate SDF surface normal via central differences
vec3 calcNormal(vec3 p, float t, float audio) {
    const float eps = 0.002;
    vec2 e = vec2(eps, -eps);
    return normalize(
        e.xyy * mapScene(p + e.xyy, t, audio) +
        e.yyx * mapScene(p + e.yyx, t, audio) +
        e.yxy * mapScene(p + e.yxy, t, audio) +
        e.xxx * mapScene(p + e.xxx, t, audio)
    );
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution.xy) / min(uResolution.x, uResolution.y);
    
    float audio = clamp(uAudio, 0.0, 1.0);
    float t = uTime * uSpeedMultiplier;
    
    // Camera setup
    vec3 ro = vec3(0.0, 0.0, 2.6);
    vec3 rd = normalize(vec3(uv, -1.4));
    
    // Orbital rotation
    mat2 rotY = rot2D(t * 0.35 + audio * 0.15);
    mat2 rotX = rot2D(t * 0.2);
    
    ro.xz = rotY * ro.xz;
    ro.yz = rotX * ro.yz;
    rd.xz = rotY * rd.xz;
    rd.yz = rotX * rd.yz;
    
    // Light setup
    vec3 lightPos1 = vec3(2.0, 3.0, 3.0);
    vec3 lightPos2 = vec3(-3.0, -2.0, -1.0);
    
    // Raymarching loop
    float dist = 0.0;
    float maxDist = 5.0;
    float minStep = 0.002;
    bool hit = false;
    vec3 hitPoint = vec3(0.0);
    
    for (int i = 0; i < 48; i++) {
        vec3 p = ro + rd * dist;
        float d = mapScene(p, t, audio);
        if (d < minStep) {
            hit = true;
            hitPoint = p;
            break;
        }
        dist += d * 0.85; // Step relaxation
        if (dist > maxDist) break;
    }
    
    vec3 color = vec3(0.0);
    float alpha = 0.0;
    
    if (hit) {
        vec3 n = calcNormal(hitPoint, t, audio);
        vec3 v = -rd;
        
        // Key light
        vec3 l1 = normalize(lightPos1 - hitPoint);
        float diff1 = max(dot(n, l1), 0.0);
        vec3 h1 = normalize(l1 + v);
        float spec1 = pow(max(dot(n, h1), 0.0), max(uSpecularShininess * 32.0, 4.0));
        
        // Fill / backlight
        vec3 l2 = normalize(lightPos2 - hitPoint);
        float diff2 = max(dot(n, l2), 0.0);
        
        // Fresnel rim reflection
        float fresnel = pow(1.0 - max(dot(n, v), 0.0), 3.0);
        
        // Subsurface scattering (SSS) approximation
        float sss = smoothstep(0.0, 1.0, mapScene(hitPoint + l1 * 0.12, t, audio)) * uRefractiveGlow;
        
        // Dynamic fluid color ramp
        float energyLevel = clamp(audio * 1.4 + diff1 * 0.4 + fresnel * 0.5, 0.0, 1.0);
        vec3 fluidBase = mix(uSilentColor, uActiveColor, energyLevel);
        
        // Composite liquid surface shading
        color = fluidBase * (0.25 + diff1 * 0.65 + diff2 * 0.2 + sss * 0.4)
              + vec3(1.0, 1.0, 1.0) * spec1 * (0.8 + audio * 0.5)
              + mix(uActiveColor, vec3(1.0), 0.5) * fresnel * 0.7 * uGlowIntensity;
              
        alpha = clamp(0.92 + fresnel * 0.08, 0.0, 1.0);
    }
    
    // Atmospheric Outer Plasma Glow & Volumetric Halo
    float distToCenter = length(uv);
    float baseR = uBaseRadius * 1.8;
    float halo = (0.015 * uGlowIntensity) / (abs(distToCenter - baseR * 0.65) + 0.035);
    vec3 haloCol = mix(uSilentColor, uActiveColor, clamp(audio * 1.5 + 0.2, 0.0, 1.0));
    
    color += haloCol * halo * (0.2 + audio * 0.5);
    alpha = clamp(alpha + halo * 0.25 * uGlowIntensity, 0.0, 1.0);
    
    // Tone mapping and clamp
    color = clamp(color, 0.0, 2.0);
    alpha = clamp(alpha, 0.0, 1.0);
    
    fragColor = vec4(color * alpha, alpha);
}
