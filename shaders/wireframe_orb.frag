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
uniform float uGridDensity;
uniform float uLineThickness;
uniform float uVertexGlowSize;
uniform float uScanlineIntensity;

out vec4 fragColor;

mat2 rot2D(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

// Ray-Sphere intersection
// Returns vec2(tNear, tFar), with tNear < 0 if no intersection
vec2 intersectSphere(vec3 ro, vec3 rd, float r) {
    float b = dot(ro, rd);
    float c = dot(ro, ro) - r * r;
    float h = b * b - c;
    if (h < 0.0) return vec2(-1.0);
    h = sqrt(h);
    return vec2(-b - h, -b + h);
}

// Evaluates the holographic geodesic lattice & glowing vertex nodes at a 3D sphere surface point
vec4 sampleGeodesicGrid(vec3 p, float t, float audio) {
    vec3 unitP = normalize(p);
    
    // Golden ratio constant for icosahedral symmetry
    const float phi = 1.6180339887;
    const float invLen = 0.5257311121; // 1.0 / sqrt(1.0 + phi*phi)
    
    // 1. Cartesian Great Circles (3 planes)
    float dX = abs(unitP.x);
    float dY = abs(unitP.y);
    float dZ = abs(unitP.z);
    
    // 2. Diagonal Octahedral Planes (4 planes)
    const float invSqrt3 = 0.577350269;
    float dDiag1 = abs(unitP.x + unitP.y + unitP.z) * invSqrt3;
    float dDiag2 = abs(unitP.x - unitP.y + unitP.z) * invSqrt3;
    float dDiag3 = abs(unitP.x + unitP.y - unitP.z) * invSqrt3;
    float dDiag4 = abs(unitP.x - unitP.y - unitP.z) * invSqrt3;
    
    // 3. Icosahedral Golden Planes (6 planes)
    float dIco1 = abs(phi * unitP.x + unitP.y) * invLen;
    float dIco2 = abs(phi * unitP.x - unitP.y) * invLen;
    float dIco3 = abs(phi * unitP.y + unitP.z) * invLen;
    float dIco4 = abs(phi * unitP.y - unitP.z) * invLen;
    float dIco5 = abs(phi * unitP.z + unitP.x) * invLen;
    float dIco6 = abs(phi * unitP.z - unitP.x) * invLen;
    
    // High-Density Geodesic Subdivision Lat/Long Rings
    float latWaves = abs(sin(unitP.y * (uGridDensity * 0.75) + t * 0.4));
    float longWaves = abs(sin(atan(unitP.z, unitP.x) * (uGridDensity * 0.5) - t * 0.25));
    float subGrid = min(latWaves, longWaves) * 0.18;
    
    // Find closest and second closest geodesic lines to locate vertex junctions
    float minD1 = min(min(dX, dY), dZ);
    float minD2 = min(min(dDiag1, dDiag2), min(dDiag3, dDiag4));
    float minD3 = min(min(dIco1, dIco2), min(min(dIco3, dIco4), min(dIco5, dIco6)));
    
    float minDist = min(min(minD1, minD2), min(minD3, subGrid));
    
    // Smooth antialiased line glow
    float thickness = max(uLineThickness * 0.018, 0.004);
    float lineCore = smoothstep(thickness, 0.0, minDist);
    float lineGlow = (0.0035 * uGlowIntensity) / (minDist * minDist * 45.0 + 0.004);
    
    // --- Luminous Vertex Nodes ---
    float secondDist = min(max(minD1, minD2), max(minD2, minD3));
    float vertexDist = sqrt(minDist * minDist + secondDist * secondDist);
    
    float nodeSize = max(uVertexGlowSize * 0.055, 0.016);
    float vertexSpark = smoothstep(nodeSize, 0.0, vertexDist) * (2.6 + audio * 3.5);
    float vertexHalo = (0.007 * uGlowIntensity) / (vertexDist * vertexDist * 80.0 + 0.003);
    
    // Dynamic Equatorial & Meridian Scanning Rings
    float equator = smoothstep(0.015, 0.0, abs(unitP.y)) * (1.0 + audio * 1.2);
    float pulseRing = smoothstep(0.02, 0.0, abs(unitP.y - sin(t * 2.5) * 0.85)) * (0.8 + audio * 1.5);
    
    float totalIntensity = lineCore * 1.6 + lineGlow + vertexSpark + vertexHalo + equator + pulseRing;
    
    // Color dynamics: silent base -> active energetic glow -> brilliant white highlights
    float heat = clamp(audio * 1.5 + vertexSpark * 0.4 + pulseRing * 0.35, 0.0, 1.0);
    vec3 col = mix(uSilentColor, uActiveColor, heat);
    col = mix(col, vec3(1.0, 1.0, 1.0), clamp(vertexSpark * 0.65 + lineCore * 0.25 + audio * 0.35, 0.0, 0.95));
    
    return vec4(col, totalIntensity);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution.xy) / min(uResolution.x, uResolution.y);
    
    float audio = clamp(uAudio, 0.0, 1.0);
    float t = uTime * uSpeedMultiplier * 0.8;
    
    // 3D Camera Ray
    vec3 ro = vec3(0.0, 0.0, 2.6);
    vec3 rd = normalize(vec3(uv, -1.35));
    
    // 3-Axis Multi-Gimbal Rotation
    mat2 rotY = rot2D(t * 0.38 + audio * 0.15);
    mat2 rotX = rot2D(t * 0.22);
    mat2 rotZ = rot2D(t * 0.12);
    
    float sphereRadius = uBaseRadius * 2.05;
    
    // Intersect outer geodesic sphere
    vec2 tHits = intersectSphere(ro, rd, sphereRadius);
    
    vec3 totalColor = vec3(0.0);
    float totalAlpha = 0.0;
    
    if (tHits.x > 0.0) {
        // --- 1. Back Hemisphere Hit (Ghosted translucent 3D lattice) ---
        vec3 pBack = ro + rd * tHits.y;
        vec3 pBackRot = pBack;
        pBackRot.xz = rotY * pBackRot.xz;
        pBackRot.yz = rotX * pBackRot.yz;
        pBackRot.xy = rotZ * pBackRot.xy;
        
        vec4 backSample = sampleGeodesicGrid(pBackRot, t, audio);
        totalColor += backSample.rgb * backSample.a * 0.32;
        totalAlpha += backSample.a * 0.22;
        
        // --- 2. Inner Rotating Octahedral Polyhedron Core (0.52x radius) ---
        vec2 tCoreHits = intersectSphere(ro, rd, sphereRadius * 0.52);
        if (tCoreHits.x > 0.0) {
            vec3 pCore = ro + rd * tCoreHits.x;
            vec3 pCoreRot = pCore;
            pCoreRot.xz = rot2D(-t * 0.65) * pCoreRot.xz;
            pCoreRot.yz = rot2D(-t * 0.45) * pCoreRot.yz;
            
            float coreEdge = min(abs(abs(pCoreRot.x) + abs(pCoreRot.y) + abs(pCoreRot.z) - sphereRadius * 0.52), 1.0);
            float coreLine = smoothstep(0.014, 0.0, coreEdge) * (1.6 + audio * 2.2);
            vec3 coreCol = mix(uSilentColor, uActiveColor, 0.9);
            totalColor += coreCol * coreLine * 0.65;
            totalAlpha += coreLine * 0.45;
        }
        
        // --- 3. Front Hemisphere Hit (Luminous sharp foreground lattice) ---
        vec3 pFront = ro + rd * tHits.x;
        vec3 pFrontRot = pFront;
        pFrontRot.xz = rotY * pFrontRot.xz;
        pFrontRot.yz = rotX * pFrontRot.yz;
        pFrontRot.xy = rotZ * pFrontRot.xy;
        
        vec4 frontSample = sampleGeodesicGrid(pFrontRot, t, audio);
        totalColor += frontSample.rgb * frontSample.a * 0.95;
        totalAlpha += frontSample.a * 0.75;
        
        // Holographic Fresnel Rim Glow on the Sphere Silhouette
        vec3 normal = normalize(pFront);
        float fresnel = pow(1.0 - max(dot(-rd, normal), 0.0), 2.8);
        vec3 rimCol = mix(uSilentColor, uActiveColor, 0.75);
        totalColor += rimCol * fresnel * (0.8 + audio * 1.5) * uGlowIntensity;
        totalAlpha += fresnel * 0.5;
    }
    
    // --- 4. Holographic Volumetric Core Aura ---
    float distToCenter = length(uv);
    float coreGlow = exp(-distToCenter * distToCenter * (14.0 / max(sphereRadius * sphereRadius, 0.01))) * (0.28 + audio * 0.8) * uGlowIntensity;
    vec3 coreColor = mix(uSilentColor, uActiveColor, clamp(audio * 1.6 + 0.25, 0.0, 1.0));
    totalColor += coreColor * coreGlow;
    totalAlpha += coreGlow * 0.5;
    
    // Outer atmospheric bloom rim
    float rimBloom = (0.009 * uGlowIntensity) / (abs(distToCenter - sphereRadius * 0.62) + 0.025);
    totalColor += coreColor * rimBloom * (0.18 + audio * 0.5);
    totalAlpha += rimBloom * 0.25;
    
    // --- 5. Holographic CRT Horizontal Scanlines ---
    float scanline = sin(fragCoord.y * 1.8 - t * 12.0) * 0.5 + 0.5;
    float scanlineFactor = mix(1.0, 0.82 + 0.18 * scanline, clamp(uScanlineIntensity, 0.0, 1.0));
    totalColor *= scanlineFactor;
    
    // Audio glitch chromatic displacement on loud audio
    if (audio > 0.65) {
        float glitch = sin(uv.y * 60.0 + t * 40.0);
        totalColor += mix(uActiveColor, vec3(1.0), 0.5) * step(0.94, glitch) * 0.35 * audio;
    }
    
    // Tone mapping and clamp
    totalColor = clamp(totalColor, 0.0, 2.5);
    totalAlpha = clamp(totalAlpha, 0.0, 1.0);
    
    fragColor = vec4(totalColor * totalAlpha, totalAlpha);
}
