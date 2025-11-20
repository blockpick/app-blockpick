#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

// 노이즈 함수들
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;

    for(int i = 0; i < 6; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }

    return value;
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;

    // 오로라 커튼 효과
    vec2 auroraUv = uv;
    auroraUv.y *= 2.0; // 세로로 늘림

    // 시간에 따라 흐르는 오로라
    float flow1 = fbm(auroraUv * 2.0 + vec2(uTime * 0.1, uTime * 0.05));
    float flow2 = fbm(auroraUv * 3.0 - vec2(uTime * 0.15, uTime * 0.08));

    // 파동 효과
    float wave = sin(uv.x * 5.0 + flow1 * 3.0 + uTime * 0.5) * 0.5 + 0.5;
    wave += sin(uv.x * 3.0 - flow2 * 2.0 - uTime * 0.3) * 0.3;

    // 수직 그라데이션 (위쪽이 더 밝음)
    float verticalGrad = pow(1.0 - uv.y, 1.5);

    // 오로라 강도
    float intensity = wave * verticalGrad;
    intensity += flow1 * 0.3 * verticalGrad;
    intensity = clamp(intensity, 0.0, 1.0);

    // 오로라 색상 (녹색-청록색-보라-핑크)
    vec3 color1 = vec3(0.2, 0.8, 0.4);   // 녹색
    vec3 color2 = vec3(0.3, 0.9, 0.7);   // 청록색
    vec3 color3 = vec3(0.5, 0.4, 0.9);   // 보라색
    vec3 color4 = vec3(0.8, 0.3, 0.7);   // 핑크

    // 노이즈 기반 색상 변화
    float colorShift = fbm(uv * 4.0 + vec2(uTime * 0.05, 0.0));

    vec3 auroraColor;
    if (colorShift < 0.33) {
        auroraColor = mix(color1, color2, colorShift * 3.0);
    } else if (colorShift < 0.66) {
        auroraColor = mix(color2, color3, (colorShift - 0.33) * 3.0);
    } else {
        auroraColor = mix(color3, color4, (colorShift - 0.66) * 3.0);
    }

    // 별이 빛나는 밤하늘 배경
    vec3 nightSky = vec3(0.02, 0.03, 0.08);

    // 별 추가
    float stars = 0.0;
    for(int i = 0; i < 40; i++) {
        float fi = float(i);
        vec2 starPos = vec2(
            hash(vec2(fi * 12.34, fi * 56.78)),
            hash(vec2(fi * 91.23, fi * 45.67))
        );

        float dist = length(uv - starPos);
        float starSize = hash(vec2(fi * 78.90, fi * 12.34)) * 0.002 + 0.0005;
        float twinkle = sin(uTime * 3.0 + fi * 10.0) * 0.5 + 0.5;

        stars += smoothstep(starSize, 0.0, dist) * twinkle * 0.3;
    }

    nightSky += vec3(stars);

    // 최종 색상 합성
    vec3 finalColor = mix(nightSky, auroraColor, intensity);

    // 글로우 효과
    float glow = pow(intensity, 2.0) * 0.5;
    finalColor += auroraColor * glow;

    // 부드러운 비네팅
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);
    float vignette = 1.0 - smoothstep(0.3, 1.0, dist);
    finalColor *= 0.7 + vignette * 0.3;

    fragColor = vec4(finalColor, 1.0);
}
