#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// 별 생성
float star(vec2 uv, float size) {
    float d = length(uv);
    float brightness = size / d;
    brightness *= smoothstep(size * 20.0, 0.0, d);

    // 십자 모양의 빛
    float cross = max(
        abs(uv.x) < size * 0.1 ? 1.0 : 0.0,
        abs(uv.y) < size * 0.1 ? 1.0 : 0.0
    );

    return brightness + cross * brightness * 0.5;
}

// 유성 효과
float shootingStar(vec2 uv, vec2 start, vec2 end, float t, float speed) {
    // 유성의 현재 위치
    vec2 pos = mix(start, end, fract(t * speed));
    vec2 direction = normalize(end - start);

    // 유성 꼬리
    vec2 toStar = uv - pos;
    float alongTrail = dot(toStar, direction);

    if (alongTrail > 0.0) return 0.0; // 앞쪽에는 꼬리 없음

    float perpDist = length(toStar - direction * alongTrail);
    float trailLength = abs(alongTrail);

    float brightness = exp(-perpDist * 100.0) * exp(-trailLength * 5.0);
    brightness *= smoothstep(1.0, 0.0, fract(t * speed)); // 페이드 아웃

    return brightness;
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;

    // 배경 그라데이션 (우주 느낌)
    vec3 bgColor = vec3(0.02, 0.02, 0.08); // 깊은 밤하늘
    vec3 horizonColor = vec3(0.05, 0.08, 0.15); // 지평선 쪽

    float horizonGradient = pow(1.0 - uv.y, 2.0);
    vec3 skyColor = mix(bgColor, horizonColor, horizonGradient * 0.3);

    vec3 finalColor = skyColor;

    // 작은 별들 (배경)
    for(int i = 0; i < 50; i++) {
        float fi = float(i);
        vec2 starPos = vec2(
            random(vec2(fi * 0.123, fi * 0.456)),
            random(vec2(fi * 0.789, fi * 0.234))
        );

        float size = random(vec2(fi * 0.567, fi * 0.891)) * 0.003 + 0.001;
        float twinkle = sin(uTime * 2.0 + fi) * 0.5 + 0.5;

        float brightness = star(uv - starPos, size) * twinkle;
        finalColor += vec3(0.8, 0.9, 1.0) * brightness * 0.5;
    }

    // 유성들
    for(int i = 0; i < 8; i++) {
        float fi = float(i);
        float offset = fi * 0.3;

        vec2 start = vec2(
            random(vec2(fi * 1.1, offset)) * 0.5 + 0.5,
            random(vec2(fi * 2.2, offset)) * 0.3 + 0.7
        );

        vec2 end = start + vec2(
            random(vec2(fi * 3.3, offset)) * 0.4 - 0.8,
            random(vec2(fi * 4.4, offset)) * -0.6 - 0.4
        );

        float speed = 0.15 + random(vec2(fi * 5.5, offset)) * 0.2;
        float timeOffset = random(vec2(fi * 6.6, offset)) * 5.0;

        float brightness = shootingStar(uv, start, end, uTime + timeOffset, speed);

        // 유성 색상 (흰색-파랑-보라 그라데이션)
        vec3 starColor = mix(
            vec3(1.0, 1.0, 1.0),
            vec3(0.6, 0.8, 1.0),
            random(vec2(fi * 7.7, offset))
        );

        finalColor += starColor * brightness * 2.0;
    }

    // 은하수 효과 (선택적)
    float milkyWay = random(uv * vec2(0.5, 10.0) + vec2(uTime * 0.01, 0.0));
    milkyWay = pow(milkyWay, 3.0) * 0.1;
    finalColor += vec3(0.5, 0.6, 0.8) * milkyWay;

    fragColor = vec4(finalColor, 1.0);
}
