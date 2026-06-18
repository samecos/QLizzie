import QtQuick

// Subtle animated ink-wash fluid background.
// Renders slow-moving black and white ink clouds blended into the paper tone.
Item {
    id: root

    // How strongly the ink is visible (0 = paper only, 1 = full ink wash).
    property real intensity: 0.55

    ShaderEffect {
        id: shader
        anchors.fill: parent

        property real time: 0.0
        property real widthFactor: 1.0 / Math.max(1.0, width)
        property real heightFactor: 1.0 / Math.max(1.0, height)
        property real intensity: root.intensity

        // Simple pseudo-random hash.
        fragmentShader: `
            uniform lowp float time;
            uniform lowp float widthFactor;
            uniform lowp float heightFactor;
            uniform lowp float intensity;
            varying highp vec2 qt_TexCoord0;

            lowp float hash(lowp vec2 p) {
                return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
            }

            lowp float noise(lowp vec2 p) {
                lowp vec2 i = floor(p);
                lowp vec2 f = fract(p);
                f = f * f * (3.0 - 2.0 * f);
                lowp float a = hash(i);
                lowp float b = hash(i + vec2(1.0, 0.0));
                lowp float c = hash(i + vec2(0.0, 1.0));
                lowp float d = hash(i + vec2(1.0, 1.0));
                return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
            }

            lowp float fbm(lowp vec2 p) {
                lowp float value = 0.0;
                lowp float amplitude = 0.5;
                for (int i = 0; i < 5; ++i) {
                    value += amplitude * noise(p);
                    p *= 2.0;
                    amplitude *= 0.5;
                }
                return value;
            }

            void main() {
                lowp vec2 uv = qt_TexCoord0;
                lowp vec2 aspect = vec2(widthFactor, heightFactor) * min(1.0 / widthFactor, 1.0 / heightFactor);

                lowp vec2 p = uv * vec2(3.5, 2.5);
                lowp float t = time * 0.05;

                lowp float n1 = fbm(p + vec2(t * 0.3, t * 0.15));
                lowp float n2 = fbm(p * 1.7 - vec2(t * 0.2, t * 0.35) + n1 * 0.6);
                lowp float n3 = fbm(p * 0.6 + vec2(t * 0.1, -t * 0.2) + n2 * 0.3);

                // Warm paper base.
                lowp vec3 paper = vec3(0.961, 0.949, 0.918);

                // Black ink wash.
                lowp float blackInk = smoothstep(0.35, 0.75, n2) * 0.18;
                lowp vec3 inkBlack = vec3(0.063, 0.059, 0.055);

                // White ink / water highlight.
                lowp float whiteInk = smoothstep(0.45, 0.82, n3) * 0.12;
                lowp vec3 inkWhite = vec3(0.988, 0.984, 0.969);

                lowp vec3 color = paper;
                color = mix(color, inkBlack, blackInk * intensity);
                color = mix(color, inkWhite, whiteInk * intensity);

                gl_FragColor = vec4(color, 1.0);
            }
        `

        NumberAnimation on time {
            from: 0
            to: 1000
            duration: 2000000 // very slow loop
            loops: Animation.Infinite
        }
    }
}
