#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

float noise(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;

    vec3 finalColor = vec3(0.0);

    // 여러 레이어의 물결선
    for(int i = 0; i < 20; i++) {
        float fi = float(i);

        // 각 선의 기본 높이
        float baseY = (fi + 0.5) / 20.0;

        // 시간에 따른 위상 변화
        float phase = uTime * (0.3 + fi * 0.05);

        // 복잡한 파형 생성
        float wave = 0.0;
        wave += sin(uv.x * 8.0 + phase) * 0.03;
        wave += sin(uv.x * 4.0 - phase * 0.7) * 0.02;
        wave += sin(uv.x * 12.0 + phase * 1.3) * 0.015;

        // 노이즈 추가로 불규칙성
        wave += noise(vec2(uv.x * 5.0 + uTime * 0.1, fi)) * 0.01;

        float y = baseY + wave;

        // 선의 두께
        float thickness = 0.003 + noise(vec2(fi, uTime * 0.2)) * 0.002;
        float line = smoothstep(thickness, 0.0, abs(uv.y - y));

        // 색상 (무지개 그라데이션)
        float hue = fract(fi / 20.0 + uTime * 0.05);
        vec3 lineColor;

        if (hue < 0.166) {
            lineColor = mix(vec3(1.0, 0.0, 0.0), vec3(1.0, 0.5, 0.0), hue * 6.0);
        } else if (hue < 0.333) {
            lineColor = mix(vec3(1.0, 0.5, 0.0), vec3(1.0, 1.0, 0.0), (hue - 0.166) * 6.0);
        } else if (hue < 0.5) {
            lineColor = mix(vec3(1.0, 1.0, 0.0), vec3(0.0, 1.0, 0.0), (hue - 0.333) * 6.0);
        } else if (hue < 0.666) {
            lineColor = mix(vec3(0.0, 1.0, 0.0), vec3(0.0, 0.5, 1.0), (hue - 0.5) * 6.0);
        } else if (hue < 0.833) {
            lineColor = mix(vec3(0.0, 0.5, 1.0), vec3(0.5, 0.0, 1.0), (hue - 0.666) * 6.0);
        } else {
            lineColor = mix(vec3(0.5, 0.0, 1.0), vec3(1.0, 0.0, 0.0), (hue - 0.833) * 6.0);
        }

        // 글로우 효과
        float glow = exp(-abs(uv.y - y) * 50.0) * 0.1;

        finalColor += lineColor * (line + glow);
    }

    // 배경 그라데이션
    vec3 bgColor = mix(
        vec3(0.05, 0.05, 0.15),
        vec3(0.1, 0.05, 0.2),
        uv.y
    );

    finalColor = bgColor + finalColor;

    // 비네팅
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);
    float vignette = 1.0 - smoothstep(0.5, 1.0, dist);
    finalColor *= 0.6 + vignette * 0.4;

    fragColor = vec4(finalColor, 1.0);
}
