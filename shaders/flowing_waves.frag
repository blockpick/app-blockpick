#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

// 노이즈 함수
float noise(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for(int i = 0; i < 5; i++) {
        value += amplitude * (noise(p * frequency) * 2.0 - 1.0);
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return value;
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;

    // 파도 효과
    vec2 waveUv = uv;
    waveUv.y += sin(uv.x * 6.0 + uTime) * 0.05;
    waveUv.y += sin(uv.x * 3.0 - uTime * 0.7) * 0.03;
    waveUv.x += cos(uv.y * 4.0 + uTime * 0.5) * 0.04;

    // FBM 노이즈로 복잡한 파도 패턴
    float wave1 = fbm(waveUv * 3.0 + vec2(uTime * 0.3, uTime * 0.2));
    float wave2 = fbm(waveUv * 2.0 - vec2(uTime * 0.2, uTime * 0.3));
    float wave3 = fbm(waveUv * 4.0 + vec2(uTime * 0.1, -uTime * 0.15));

    // 파도 레이어 합성
    float waves = (wave1 + wave2 * 0.7 + wave3 * 0.5) / 2.2;
    waves = waves * 0.5 + 0.5; // 0~1 범위로 정규화

    // 색상 정의 (깊은 바다 느낌)
    vec3 color1 = vec3(0.1, 0.2, 0.4);   // 깊은 파랑
    vec3 color2 = vec3(0.2, 0.5, 0.8);   // 밝은 파랑
    vec3 color3 = vec3(0.3, 0.7, 0.9);   // 청록색
    vec3 color4 = vec3(0.1, 0.4, 0.6);   // 중간 파랑

    // 파도 높이에 따른 색상 그라데이션
    vec3 finalColor;
    if (waves < 0.33) {
        finalColor = mix(color1, color2, waves * 3.0);
    } else if (waves < 0.66) {
        finalColor = mix(color2, color3, (waves - 0.33) * 3.0);
    } else {
        finalColor = mix(color3, color4, (waves - 0.66) * 3.0);
    }

    // 깊이감을 위한 비네팅
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);
    float vignette = 1.0 - smoothstep(0.5, 1.2, dist);

    finalColor *= 0.6 + vignette * 0.4;

    // 반짝이는 효과 추가
    float sparkle = noise(uv * 50.0 + vec2(uTime * 2.0, -uTime * 1.5));
    sparkle = pow(sparkle, 20.0) * 0.3;
    finalColor += vec3(sparkle);

    fragColor = vec4(finalColor, 1.0);
}
