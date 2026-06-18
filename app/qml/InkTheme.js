.pragma library

// QLizzie 水墨主题系统
// Ink-wash (shuimo) theme palette and styling constants.

var colors = {
    // Paper tones
    paper: "#f5f2ea",
    paperDeep: "#ede9de",
    paperDark: "#e6e1d6",
    paperShadow: "#b8b0a3",

    // Ink tones
    inkWash: "#d8d2c6",
    inkLight: "#b5ada0",
    ink: "#8a8279",
    inkDark: "#5c5750",
    inkDeep: "#2e2a26",
    sumi: "#1a1714",

    // Accent: cinnabar seal red
    cinnabar: "#b83e2f",
    cinnabarLight: "#cf5748",
    cinnabarPale: "#e8d6d3",

    // Functional
    white: "#faf8f2",
    black: "#12100e",
    transparent: "transparent"
};

var fonts = {
    // Calligraphy / serif face for titles and coordinates.
    // Falls back through common OS Chinese Kai faces.
    title: "\"STKaiti\", \"Kaiti SC\", \"KaiTi\", \"KaiTi_GB2312\", \"AR PL UKai CN\", \"YuMincho\", \"SimSun\", serif",
    // Clean body face.
    body: "system-ui, -apple-system, \"PingFang SC\", \"Microsoft YaHei\", \"Noto Sans CJK SC\", sans-serif",
    // Monospace for numbers / coordinates when calligraphy is not desired.
    mono: "\"JetBrains Mono\", \"Consolas\", \"SF Mono\", monospace"
};

var radii = {
    small: 4,
    medium: 8,
    large: 12,
    pill: 100
};

var alpha = {
    subtle: 0.22,
    light: 0.45,
    medium: 0.65,
    strong: 0.85
};

// Utility helpers
function colorWithAlpha(hex, a) {
    var c = String(hex).replace("#", "");
    if (c.length === 3) {
        c = c[0] + c[0] + c[1] + c[1] + c[2] + c[2];
    }
    if (c.length === 6) {
        var r = parseInt(c.slice(0, 2), 16);
        var g = parseInt(c.slice(2, 4), 16);
        var b = parseInt(c.slice(4, 6), 16);
        return Qt.rgba(r / 255, g / 255, b / 255, a);
    }
    return hex;
}

function canvasFont(family, size, bold) {
    var f = String(family).replace(/"/g, "");
    return (bold ? "700 " : "400 ") + Math.max(1, Math.round(size)) + "px \"" + f + "\", " + fonts.body;
}
