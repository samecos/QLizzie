.pragma library

var COORDINATE_FORMAT_GO_NO_I = 0
var COORDINATE_FORMAT_GOMOKU_WITH_I = 1
var COORDINATE_FORMAT_NUMERIC = 2
var GO_ALPHABET = "ABCDEFGHJKLMNOPQRSTUVWXYZ"
var GOMOKU_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var SGF_COORDINATE_ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

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

function effectiveCoordinateFormat(width, height, preferredFormat) {
    if (width >= 25 || height >= 25)
        return COORDINATE_FORMAT_NUMERIC
    if (preferredFormat === COORDINATE_FORMAT_GOMOKU_WITH_I)
        return COORDINATE_FORMAT_GOMOKU_WITH_I
    if (preferredFormat === COORDINATE_FORMAT_NUMERIC)
        return COORDINATE_FORMAT_NUMERIC
    return COORDINATE_FORMAT_GO_NO_I
}

function coordinateAlphabet(format) {
    return format === COORDINATE_FORMAT_GOMOKU_WITH_I ? GOMOKU_ALPHABET : GO_ALPHABET
}

function gtpAlphabetIndex(text) {
    var alphabet = GO_ALPHABET
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
    return GO_ALPHABET.charAt(x) + String(height - y)
}

function parseGtpCoordinateName(text, width, height) {
    var value = String(text).trim()
    if (value.toLowerCase() === "pass" || value.toLowerCase() === "resign")
        return null

    var numeric = value.match(/^\(?\s*(\d+)\s*[,: ]\s*(\d+)\s*\)?$/)
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

function sgfCoordinateText(x, y, numeric) {
    if (numeric === true
            || x >= SGF_COORDINATE_ALPHABET.length
            || y >= SGF_COORDINATE_ALPHABET.length)
        return x + "," + y
    return SGF_COORDINATE_ALPHABET.charAt(x) + SGF_COORDINATE_ALPHABET.charAt(y)
}

function parseSgfCoordinateText(text) {
    var value = String(text).trim()
    var numeric = value.match(/^\(?\s*(\d+)\s*[,: ]\s*(\d+)\s*\)?$/)
    if (numeric)
        return {
            "x": parseInt(numeric[1], 10),
            "y": parseInt(numeric[2], 10)
        }
    if (value.length < 2)
        return null
    var x = SGF_COORDINATE_ALPHABET.indexOf(value.charAt(0))
    var y = SGF_COORDINATE_ALPHABET.indexOf(value.charAt(1))
    if (x < 0 || y < 0)
        return null
    return {
        "x": x,
        "y": y
    }
}

function xCoordinateText(x, width, height, preferredFormat) {
    var format = effectiveCoordinateFormat(width, height, preferredFormat)
    if (format === COORDINATE_FORMAT_NUMERIC)
        return String(x)
    var alphabet = coordinateAlphabet(format)
    return x >= 0 && x < alphabet.length ? alphabet.charAt(x) : String(x)
}

function yCoordinateText(y, width, height, preferredFormat) {
    var format = effectiveCoordinateFormat(width, height, preferredFormat)
    if (format === COORDINATE_FORMAT_NUMERIC)
        return String(y)
    return String(height - y)
}

function coordinateText(x, y, width, height, preferredFormat) {
    var format = effectiveCoordinateFormat(width, height, preferredFormat)
    if (format === COORDINATE_FORMAT_NUMERIC)
        return x + "," + y
    return xCoordinateText(x, width, height, preferredFormat)
           + yCoordinateText(y, width, height, preferredFormat)
}

function parseCoordinateText(text, width, height, preferredFormat) {
    var value = String(text).trim()
    var format = effectiveCoordinateFormat(width, height, preferredFormat)

    var numeric = value.match(/^\(?\s*(\d+)\s*[,: ]\s*(\d+)\s*\)?$/)
    if (numeric) {
        var nx = parseInt(numeric[1], 10)
        var ny = parseInt(numeric[2], 10)
        if (nx >= 0 && nx < width && ny >= 0 && ny < height)
            return { "x": nx, "y": ny }
        return null
    }

    if (format === COORDINATE_FORMAT_NUMERIC)
        return null

    var named = value.match(/^([A-Z])(\d+)$/i)
    if (!named)
        return null

    var alphabet = coordinateAlphabet(format)
    var x = alphabet.indexOf(named[1].toUpperCase())
    var displayedY = parseInt(named[2], 10)
    var y = height - displayedY
    if (x < 0 || y < 0 || x >= width || y >= height)
        return null
    return { "x": x, "y": y }
}
