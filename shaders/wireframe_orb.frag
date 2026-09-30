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

const float PI = 3.14159265359;

// 2D Rotation Matrix
mat2 rot2D(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

// Deterministic 2D Hash
float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// 3D Hash
float hash3(vec3 p) {
    p = fract(p * 0.3183099 + 0.1);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

// Smooth 3D Value Noise with Quintic Hermite C2 Interpolation
float smoothNoise3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    return mix(
        mix(mix(hash3(i + vec3(0, 0, 0)), hash3(i + vec3(1, 0, 0)), f.x),
            mix(hash3(i + vec3(0, 1, 0)), hash3(i + vec3(1, 1, 0)), f.x), f.y),
        mix(mix(hash3(i + vec3(0, 0, 1)), hash3(i + vec3(1, 0, 1)), f.x),
            mix(hash3(i + vec3(0, 1, 1)), hash3(i + vec3(1, 1, 1)), f.x), f.y),
        f.z
    );
}

// Multi-octave smooth organic 3D surface displacement field
float surfaceDisplacement(vec3 unitP, float t, float audio) {
    // Broad, silky undulating wave lobes matching the reference 3D mesh
    float n1 = smoothNoise3D(unitP * 1.50 + vec3(t * 0.22, -t * 0.16, t * 0.14)) * 0.70;
    float n2 = smoothNoise3D(unitP * 3.00 - vec3(t * 0.30, t * 0.24, -t * 0.18)) * 0.30;
    float totalNoise = (n1 + n2) - 0.50;

    // Harmonic audio ripples
    float ripple = sin(unitP.y * 5.5 - t * 2.6 + audio * 4.2) * cos(unitP.x * 5.5 + t * 1.8) * (0.04 + audio * 0.16);

    return totalNoise * (0.32 + audio * 0.46) + ripple;
}

// Distance to deformed 3D sphere surface
float mapSphere(vec3 p, float baseR, float t, float audio) {
    float r = length(p);
    if (r < 0.001) return 0.0;
    vec3 unitP = p / r;
    float disp = surfaceDisplacement(unitP, t, audio);
    float targetR = baseR * (1.0 + disp);
    return r - targetR;
}

// Normal estimation on the deformed 3D surface
vec3 calcNormal(vec3 p, float baseR, float t, float audio) {
    const float eps = 0.003;
    vec2 e = vec2(1.0, -1.0) * 0.5773 * eps;
    return normalize(
        e.xyy * mapSphere(p + e.xyy, baseR, t, audio) +
        e.yyx * mapSphere(p + e.yyx, baseR, t, audio) +
        e.yxy * mapSphere(p + e.yxy, baseR, t, audio) +
        e.xxx * mapSphere(p + e.xxx, baseR, t, audio)
    );
}

// Evaluates the quad wireframe grid and glowing vertex nodes on the deformed 3D mesh surface
vec4 evaluateWireframeGrid(vec3 p, vec3 normal, float t, float audio, float baseR) {
    vec3 unitP = normalize(p);
    float disp = surfaceDisplacement(unitP, t, audio);

    float density = max(14.0, uGridDensity);
    
    // Conformal stereographic mapping across the 3D surface
    // Eliminates all polar singularities and produces a smooth uniform quad mesh
    float stereoScale = density * 1.20;
    vec2 uvGrid = (unitP.xy / (1.0 + max(unitP.z, -0.65))) * stereoScale;

    // Grid line distances (0.0 at line, 0.5 at center)
    vec2 g = fract(uvGrid);
    vec2 d = min(g, 1.0 - g);

    // Solid continuous wireframe grid lines
    float lineThick = max(0.085 * uLineThickness, 0.035);
    float lineU = smoothstep(lineThick, 0.0, d.x);
    float lineV = smoothstep(lineThick, 0.0, d.y);
    float lineCore = max(lineU, lineV) * 1.8;

    // Smooth volumetric line glow
    float glowU = (0.007 * uGlowIntensity) / (d.x * d.x * 40.0 + 0.0035);
    float glowV = (0.007 * uGlowIntensity) / (d.y * d.y * 40.0 + 0.0035);
    float lineGlow = max(glowU, glowV);

    // Glowing vertex nodes at quad intersections
    float distNode = length(d);
    float nodeRadius = max(0.12 * uVertexGlowSize, 0.050);
    float nodeCore = smoothstep(nodeRadius, 0.0, distNode) * (2.4 + audio * 3.2);
    float nodeHalo = (0.014 * uGlowIntensity) / (distNode * distNode * 65.0 + 0.0025);

    float intensity = lineCore + lineGlow + nodeCore + nodeHalo;

    // --- Dynamic Dual-Tone Color Mapping (uActiveColor to uSilentColor) ---
    // Upper-left crests bias to Active Color, lower-right crests bias to Silent Color
    float diagCoord = (unitP.x * 0.75 - unitP.y * 0.85 + 0.15) * 0.65 + 0.5;
    float colorBias = clamp(diagCoord, 0.0, 1.0);

    vec3 colActive = uActiveColor;
    vec3 colSilent = uSilentColor;
    vec3 colDeep = mix(colSilent * 0.35, colActive * 0.35, 0.5);

    vec3 baseCol = mix(colSilent, colActive, colorBias);
    // Deepen valleys into rich deep midtones
    baseCol = mix(colDeep, baseCol, clamp(disp * 2.4 + 0.75, 0.25, 1.0));

    // Vertex nodes & line core hot-white ignition
    float spark = nodeCore * 0.80 + lineCore * 0.35 + audio * 0.30;
    vec3 col = mix(baseCol, vec3(1.0, 0.98, 1.0), clamp(spark, 0.0, 0.95));

    // Enhance crest luminescence
    float crestBoost = clamp(1.0 + disp * 1.5, 0.6, 2.0);
    intensity *= crestBoost;

    return vec4(col, intensity);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution.xy) / min(uResolution.x, uResolution.y);

    float audio = clamp(uAudio, 0.0, 1.0);
    float t = uTime * uSpeedMultiplier * 0.80;

    // 3D Camera Ray Setup
    vec3 ro = vec3(0.0, 0.0, 2.65);
    vec3 rd = normalize(vec3(uv, -1.35));

    // Global orbital rotation
    mat2 rotY = rot2D(t * 0.26 + audio * 0.12);
    mat2 rotX = rot2D(0.18 + sin(t * 0.20) * 0.10);
    mat2 rotZ = rot2D(sin(t * 0.14) * 0.05);

    float baseR = uBaseRadius * 2.15;

    vec3 totalColor = vec3(0.0);
    float totalAlpha = 0.0;

    // --- 1. Raymarch Front Deformed Surface ---
    float rayT = 1.3;
    float maxT = 3.8;
    float hitT = -1.0;

    for (int i = 0; i < 34; i++) {
        vec3 p = ro + rd * rayT;
        vec3 pRot = p;
        pRot.xz = rotY * pRot.xz;
        pRot.yz = rotX * pRot.yz;
        pRot.xy = rotZ * pRot.xy;

        float dist = mapSphere(pRot, baseR, t, audio);
        if (abs(dist) < 0.0022) {
            hitT = rayT;
            break;
        }
        rayT += dist * 0.70;
        if (rayT > maxT) break;
    }

    if (hitT > 0.0) {
        vec3 pHit = ro + rd * hitT;
        vec3 pRot = pHit;
        pRot.xz = rotY * pRot.xz;
        pRot.yz = rotX * pRot.yz;
        pRot.xy = rotZ * pRot.xy;

        vec3 normal = calcNormal(pRot, baseR, t, audio);
        vec3 worldNormal = normal;
        worldNormal.xy = rot2D(-sin(t * 0.14) * 0.05) * worldNormal.xy;
        worldNormal.yz = rot2D(-(0.18 + sin(t * 0.20) * 0.10)) * worldNormal.yz;
        worldNormal.xz = rot2D(-(t * 0.26 + audio * 0.12)) * worldNormal.xz;

        vec4 gridSample = evaluateWireframeGrid(pRot, normal, t, audio, baseR);

        // Holographic Fresnel Rim Glow along silhouette ridges
        float fresnel = pow(1.0 - max(dot(-rd, worldNormal), 0.0), 2.2);
        float diagNorm = clamp((pRot.x - pRot.y) * 0.6 + 0.5, 0.0, 1.0);
        vec3 rimColor = mix(uSilentColor, uActiveColor, diagNorm);

        // Soft translucent interior volume glow
        float innerGlow = clamp(0.18 + 0.25 * (1.0 - fresnel), 0.0, 1.0);
        vec3 innerCol = mix(uSilentColor * 0.3, uActiveColor * 0.3, diagNorm);

        totalColor += innerCol * innerGlow * (0.8 + audio * 0.6);
        totalColor += gridSample.rgb * gridSample.a * (0.95 + audio * 0.45);
        totalColor += rimColor * fresnel * (1.25 + audio * 1.6) * uGlowIntensity;
        totalAlpha = clamp(gridSample.a * 0.88 + fresnel * 0.70 + innerGlow * 0.35, 0.0, 1.0);
    }

    // --- 2. Outer Floating Stardust Halo (Seamless smoothly bounded particles) ---
    float distCenter = length(uv);
    float rPerimeter = baseR * 0.62;
    float rNorm = distCenter / max(rPerimeter, 0.01);
    
    if (rNorm > 0.70 && rNorm < 1.48) {
        float pFade = exp(-pow((rNorm - 1.08) / 0.18, 2.0));
        float pAngle = atan(uv.y, uv.x);
        vec3 pAuraCol = mix(uSilentColor, uActiveColor, clamp(sin(pAngle + 0.8) * 0.5 + 0.5, 0.0, 1.0));

        // 3 layered concentric stardust clouds
        for (int layer = 0; layer < 3; layer++) {
            float fl = float(layer);
            float layerRot = t * (0.12 + fl * 0.08);
            vec2 pUV = rot2D(layerRot) * uv * (32.0 + fl * 14.0);
            vec2 gCell = floor(pUV);
            vec2 gFract = fract(pUV) - 0.5;

            float h = hash21(gCell + fl * 23.45);
            if (h > 0.52) {
                vec2 pOffset = (vec2(hash21(gCell + 3.4), hash21(gCell + 7.8)) - 0.5) * 0.55;
                float dP = length(gFract - pOffset);
                float pSize = 0.08 + 0.06 * sin(t * 3.5 + h * 6.28);
                float pInt = smoothstep(pSize, 0.0, dP);

                vec3 colP = mix(pAuraCol, vec3(1.0), pInt * 0.7);
                totalColor += colP * pInt * pFade * (1.1 + audio * 1.5);
                totalAlpha = max(totalAlpha, pInt * pFade * 0.85);
            }
        }
    }

    // --- 3. Ambient Volumetric Glow ---
    float aura = exp(-distCenter * distCenter * (8.0 / max(baseR * baseR, 0.01))) * (0.22 + audio * 0.40) * uGlowIntensity;
    vec3 auraCol = mix(uSilentColor * 0.25, uActiveColor * 0.25, clamp(uv.x * 0.5 + 0.5, 0.0, 1.0));
    totalColor += auraCol * aura;
    totalAlpha = clamp(totalAlpha + aura * 0.35, 0.0, 1.0);

    // --- 4. Holographic CRT Scanlines ---
    if (uScanlineIntensity > 0.01) {
        float scanline = sin(fragCoord.y * 1.8 - t * 10.0) * 0.5 + 0.5;
        totalColor *= mix(1.0, 0.88 + 0.12 * scanline, clamp(uScanlineIntensity, 0.0, 1.0));
    }

    // Tone mapping and vibrant saturation
    totalColor = totalColor / (vec3(1.0) + totalColor * 0.15);
    totalColor = pow(max(totalColor, vec3(0.0)), vec3(0.92));

    totalAlpha = clamp(dot(totalColor, vec3(0.299, 0.587, 0.114)) * 1.75, 0.0, 1.0);

    fragColor = vec4(totalColor * totalAlpha, totalAlpha);
}
