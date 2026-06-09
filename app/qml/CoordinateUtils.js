.pragma library

function keyFor(x, y) {
    return x + "," + y
}

function passKey() {
    return "pass"
}

function boardDimensionsText(xSize, ySize) {
    return xSize === ySize ? String(xSize) : xSize + "x" + ySize
}

function boardPointCount(xSize, ySize) {
    return xSize * ySize
}

function gtpAlphabetIndex(text) {
    var alphabet = "ABCDEFGHJKLMNOPQRSTUVWXYZ"
    var value = 0
    for (var i = 0; i < text.length; ++i) {
        var digit = alphabet.indexOf(text.charAt(i).toUpperCase())
        if (digit < 0)
            return -1
        value = value * alphabet.length + digit
    }
    return value
}

function gtpCoordinateName(x, y, width, height) {
    if (x < 0 || y < 0)
        return "pass"
    if (width > 25 || height > 25)
        return "(" + x + "," + y + ")"
    var alphabet = "ABCDEFGHJKLMNOPQRSTUVWXYZ"
    return alphabet.charAt(x) + String(height - y)
}

function parseGtpCoordinateName(text, width, height) {
    var value = String(text).trim()
    if (value.toLowerCase() === "pass" || value.toLowerCase() === "resign")
        return null

    var numeric = value.match(/^\(?\s*(\d+)\s*[, ]\s*(\d+)\s*\)?$/)
    if (numeric) {
        var nx = parseInt(numeric[1], 10)
        var ny = parseInt(numeric[2], 10)
        if (nx >= 0 && nx < width && ny >= 0 && ny < height)
            return { "x": nx, "y": ny }
        return null
    }

    var named = value.match(/^([A-HJ-Z]+)(\d+)$/i)
    if (!named)
        return null

    var x = gtpAlphabetIndex(named[1])
    var y = height - parseInt(named[2], 10)
    if (x < 0 || y < 0 || x >= width || y >= height)
        return null
    return { "x": x, "y": y }
}

function sgfCoordinateText(x, y) {
    var base = "a".charCodeAt(0)
    return String.fromCharCode(base + x) + String.fromCharCode(base + y)
}

function parseSgfCoordinateText(text) {
    var value = String(text).trim().toLowerCase()
    if (value.length < 2)
        return null
    var base = "a".charCodeAt(0)
    return {
        "x": value.charCodeAt(0) - base,
        "y": value.charCodeAt(1) - base
    }
}

function xCoordinateText(x) {
    return String(x + 1)
}

function yCoordinateText(y) {
    return String(y + 1)
}

function coordinateText(x, y, width, height) {
    return gtpCoordinateName(x, y, width, height)
}

function parseCoordinateText(text, width, height) {
    return parseGtpCoordinateName(text, width, height)
}
