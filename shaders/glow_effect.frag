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

float smoothNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = noise(i);
    float b = noise(i + vec2(1.0, 0.0));
    float c = noise(i + vec2(0.0, 1.0));
    float d = noise(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void main() {
    // 정규화된 좌표 (0.0 ~ 1.0)
    vec2 uv = FlutterFragCoord().xy / uSize;

    // 화면 비율 보정
    float aspect = uSize.x / uSize.y;
    vec2 center = vec2(0.5, 0.5);
    vec2 adjustedUv = uv;
    adjustedUv.x = (uv.x - 0.5) * aspect + 0.5;

    // 중앙으로부터의 거리
    float dist = distance(adjustedUv, center);

    // 각도 계산
    float angle = atan(adjustedUv.y - center.y, adjustedUv.x - center.x);

    // 회전하는 소용돌이 효과
    float spiral = angle + dist * 8.0 - uTime * 0.5;
    float spiralNoise = sin(spiral * 4.0) * 0.5 + 0.5;

    // 강착 디스크 링 효과
    float ring = smoothstep(0.15, 0.25, dist) * (1.0 - smoothstep(0.6, 0.8, dist));
    ring *= 1.0 + spiralNoise * 0.3;

    // 난류 효과 (노이즈 기반)
    float turbulence = smoothNoise(uv * 3.0 + vec2(uTime * 0.1, 0.0));
    turbulence += smoothNoise(uv * 6.0 - vec2(0.0, uTime * 0.15)) * 0.5;
    turbulence /= 1.5;

    // 색상 정의
    vec3 color1 = vec3(0.48, 0.30, 1.0);  // 보라색
    vec3 color2 = vec3(0.0, 0.8, 1.0);    // 청록색
    vec3 color3 = vec3(1.0, 0.4, 0.7);    // 핑크
    vec3 color4 = vec3(1.0, 0.7, 0.2);    // 오렌지

    // 각도에 따른 색상 혼합
    float angleNorm = (angle + 3.14159) / (2.0 * 3.14159);
    angleNorm = fract(angleNorm + uTime * 0.05); // 천천히 회전

    vec3 glowColor;
    if (angleNorm < 0.25) {
        glowColor = mix(color1, color2, angleNorm * 4.0);
    } else if (angleNorm < 0.5) {
        glowColor = mix(color2, color3, (angleNorm - 0.25) * 4.0);
    } else if (angleNorm < 0.75) {
        glowColor = mix(color3, color4, (angleNorm - 0.5) * 4.0);
    } else {
        glowColor = mix(color4, color1, (angleNorm - 0.75) * 4.0);
    }

    // 난류로 색상에 변화 추가
    glowColor = mix(glowColor, glowColor * 1.3, turbulence * 0.3);

    // 중앙 블랙홀 (완전히 어두운 영역)
    float blackHole = 1.0 - smoothstep(0.0, 0.15, dist);

    // 가장자리 글로우
    float edgeGlow = 1.0 - smoothstep(0.5, 1.0, dist);
    edgeGlow = pow(edgeGlow, 2.0);

    // 강착 디스크 밝기
    float brightness = ring * edgeGlow * (0.6 + spiralNoise * 0.4);

    // 최종 색상
    vec3 darkBg = vec3(0.02, 0.04, 0.08); // 어두운 배경
    vec3 finalColor = mix(darkBg, glowColor, brightness);

    // 블랙홀 영역은 완전히 어둡게
    finalColor = mix(finalColor, vec3(0.01, 0.02, 0.04), blackHole);

    // 외곽 페이드아웃
    float vignette = 1.0 - smoothstep(0.7, 1.2, dist);
    finalColor *= vignette;

    fragColor = vec4(finalColor, 1.0);
}
