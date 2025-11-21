#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

// 3D 노이즈 시뮬레이션
float hash(vec3 p) {
    p = fract(p * 0.3183099 + 0.1);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise3D(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);

    return mix(
        mix(
            mix(hash(p + vec3(0,0,0)), hash(p + vec3(1,0,0)), f.x),
            mix(hash(p + vec3(0,1,0)), hash(p + vec3(1,1,0)), f.x),
            f.y
        ),
        mix(
            mix(hash(p + vec3(0,0,1)), hash(p + vec3(1,0,1)), f.x),
            mix(hash(p + vec3(0,1,1)), hash(p + vec3(1,1,1)), f.x),
            f.y
        ),
        f.z
    );
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;

    // 시간에 따라 변하는 3D 공간
    vec3 pos = vec3(uv * 2.0, uTime * 0.1);

    // 여러 레이어의 3D 노이즈
    float density = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;

    for(int i = 0; i < 4; i++) {
        density += amplitude * noise3D(pos * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    // 회전하는 에테르 구름 효과
    float angle = uTime * 0.2;
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    vec2 rotUv = rot * (uv - 0.5);

    float cloud = noise3D(vec3(rotUv * 3.0, uTime * 0.15));
    cloud = pow(cloud, 1.5);

    // 색상 (신비로운 에테르 느낌)
    vec3 color1 = vec3(0.4, 0.2, 0.8);   // 진한 보라
    vec3 color2 = vec3(0.6, 0.4, 1.0);   // 밝은 보라
    vec3 color3 = vec3(0.2, 0.6, 1.0);   // 청록색
    vec3 color4 = vec3(0.8, 0.5, 1.0);   // 핑크-보라

    // 밀도에 따른 색상 변화
    vec3 etherColor;
    float t = fract(density + uTime * 0.1);

    if (t < 0.25) {
        etherColor = mix(color1, color2, t * 4.0);
    } else if (t < 0.5) {
        etherColor = mix(color2, color3, (t - 0.25) * 4.0);
    } else if (t < 0.75) {
        etherColor = mix(color3, color4, (t - 0.5) * 4.0);
    } else {
        etherColor = mix(color4, color1, (t - 0.75) * 4.0);
    }

    // 구름 효과 적용
    etherColor = mix(etherColor * 0.3, etherColor, cloud);

    // 중앙에서 바깥으로 페이드
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);
    float glow = exp(-dist * 2.0);

    etherColor *= 0.5 + glow * 0.5;

    // 발광 효과
    float luminance = (density + cloud) * 0.5;
    etherColor += etherColor * luminance * 0.3;

    fragColor = vec4(etherColor, 1.0);
}
