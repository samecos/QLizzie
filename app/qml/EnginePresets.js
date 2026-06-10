.pragma library

function makePreset(id, name, command, ruleMode, ruleVariant, boardSizeX, boardSizeY, komi, legacyHex) {
    return {
        "id": id,
        "name": name,
        "command": command,
        "initialCommands": "",
        "ruleMode": ruleMode,
        "ruleVariant": ruleVariant,
        "boardSizeX": boardSizeX,
        "boardSizeY": boardSizeY,
        "komi": komi,
        "legacyHexEngineCoordinates": legacyHex === true,
        "boardPresentationMode": 0
    }
}

function defaultPresets(app) {
    var command = app.defaultGo7EngineCommand
    return [
        makePreset("katago-go-19", "KataGo / KataGomo Go 19x19", command,
                   app.gameRuleGo, -1, 19, 19, 6.5, false),
        makePreset("katago-go-9", "KataGo / KataGomo Go 9x9", command,
                   app.gameRuleGo, -1, 9, 9, 7.0, false),
        makePreset("katagomo-gomoku-15", "KataGomo Gomoku 15x15", command,
                   app.gameRuleGomoku, app.gomokuRuleCon5, 15, 15, 0.0, false),
        makePreset("katagomo-gomoku-19", "KataGomo Gomoku 19x19", command,
                   app.gameRuleGomoku, app.gomokuRuleCon5, 19, 19, 0.0, false),
        makePreset("katagomo-hex-5-legacy", "KataGomo Hex 5x5 legacy", command,
                   app.gameRuleHex, -1, 5, 5, 0.0, true),
        makePreset("katagomo-hex-11-legacy", "KataGomo Hex 11x11 legacy", command,
                   app.gameRuleHex, -1, 11, 11, 0.0, true)
    ]
}

function clonePreset(preset) {
    var copy = ({})
    for (var key in preset)
        copy[key] = preset[key]
    return copy
}

function cloneList(presets) {
    var list = []
    if (!presets)
        return list
    for (var i = 0; i < presets.length; ++i)
        list.push(clonePreset(presets[i]))
    return list
}

function numeric(value, fallback) {
    var number = Number(value)
    return isNaN(number) ? fallback : number
}

function normalizePreset(app, preset, index) {
    var fallback = defaultPresets(app)[0]
    var copy = clonePreset(preset || fallback)
    copy.id = String(copy.id || ("engine-" + (index + 1)))
    copy.name = String(copy.name || ("Engine " + (index + 1)))
    copy.command = copy.command === undefined || copy.command === null
                   ? app.defaultGo7EngineCommand
                   : String(copy.command)
    copy.initialCommands = String(copy.initialCommands || "")
    delete copy.preload

    copy.ruleMode = Math.round(numeric(copy.ruleMode, app.gameRuleGo))
    if (!app.validRuleMode(copy.ruleMode))
        copy.ruleMode = app.gameRuleGo

    copy.ruleVariant = Math.round(numeric(copy.ruleVariant, -1))
    if (copy.ruleMode !== app.gameRuleGomoku)
        copy.ruleVariant = -1
    else
        copy.ruleVariant = Math.round(app.clamp(copy.ruleVariant,
                                                app.gomokuRuleCon5,
                                                app.gomokuRuleDirectCon5))

    copy.boardSizeX = Math.round(app.clamp(numeric(copy.boardSizeX, app.defaultBoardSize),
                                           app.minBoardSize,
                                           app.maxBoardSize))
    copy.boardSizeY = Math.round(app.clamp(numeric(copy.boardSizeY, copy.boardSizeX),
                                           app.minBoardSize,
                                           app.maxBoardSize))
    var adjusted = app.adjustedBoardDimensionsForRule(copy.ruleMode, copy.boardSizeX, copy.boardSizeY)
    copy.boardSizeX = adjusted.x
    copy.boardSizeY = adjusted.y
    copy.komi = app.clampKomiValue(numeric(copy.komi, copy.ruleMode === app.gameRuleGo ? 6.5 : 0.0))
    copy.legacyHexEngineCoordinates = copy.legacyHexEngineCoordinates === true
    copy.boardPresentationMode = Math.round(app.clamp(numeric(copy.boardPresentationMode, 0),
                                                       app.boardPresentationIntersections,
                                                       app.boardPresentationCells))
    if (copy.ruleMode !== app.gameRuleGomoku)
        copy.boardPresentationMode = app.boardPresentationIntersections
    return copy
}

function normalizeList(app, presets) {
    var source = presets && presets.length > 0 ? presets : defaultPresets(app)
    var list = []
    var used = ({})
    for (var i = 0; i < source.length; ++i) {
        var preset = normalizePreset(app, source[i], i)
        if (used[preset.id]) {
            var suffix = 2
            var base = preset.id
            while (used[base + "-" + suffix])
                ++suffix
            preset.id = base + "-" + suffix
        }
        used[preset.id] = true
        list.push(preset)
    }
    return list
}

function parseList(app, text) {
    try {
        var parsed = JSON.parse(String(text || ""))
        if (Array.isArray(parsed))
            return normalizeList(app, parsed)
    } catch (error) {
    }
    return normalizeList(app, [])
}

function serializeList(presets) {
    return JSON.stringify(cloneList(presets || []))
}

function findIndexById(presets, id) {
    for (var i = 0; presets && i < presets.length; ++i) {
        if (String(presets[i].id) === String(id))
            return i
    }
    return -1
}

function findById(presets, id) {
    var index = findIndexById(presets, id)
    return index >= 0 ? presets[index] : null
}

function newPreset(app) {
    var now = Date.now ? Date.now() : Math.floor(Math.random() * 1000000000)
    var preset = makePreset("engine-" + now,
                            app.trText("newEngine"),
                            "",
                            app.gameRuleGo,
                            -1,
                            19,
                            19,
                            7.5,
                            false)
    preset.boardPresentationMode = app.boardPresentationIntersections
    return normalizePreset(app, preset, 0)
}

function ruleText(app, preset) {
    if (!preset)
        return ""
    if (preset.ruleMode === app.gameRuleGo)
        return app.trText("gameRuleGo")
    if (preset.ruleMode === app.gameRuleHex)
        return app.trText("gameRuleHex")
    if (preset.ruleMode === app.gameRuleSquareFree)
        return app.trText("gameRuleSquareFree")
    if (preset.ruleMode === app.gameRuleReversi)
        return app.trText("gameRuleReversi")
    if (preset.ruleMode === app.gameRuleConnect6)
        return app.trText("gameRuleConnect6")
    if (preset.ruleMode === app.gameRuleHexGoParallelogram)
        return app.trText("gameRuleHexGoParallelogram")
    if (preset.ruleMode === app.gameRuleHexGoHexagon)
        return app.trText("gameRuleHexGoHexagon")
    if (preset.ruleMode === app.gameRuleHexGoTriangle)
        return app.trText("gameRuleHexGoTriangle")
    if (preset.ruleMode === app.gameRuleAtaxx)
        return app.trText("gameRuleAtaxx")
    if (preset.ruleMode === app.gameRuleBreakthrough)
        return app.trText("gameRuleBreakthrough")
    return app.trText("gameRuleGomoku")
}

function ruleDetailText(app, preset) {
    if (!preset)
        return ""
    if (preset.ruleMode === app.gameRuleGomoku)
        return app.gomokuRuleLabel(preset.ruleVariant)
    return ruleText(app, preset)
}

function boardSizeText(preset) {
    if (!preset)
        return ""
    return preset.boardSizeX === preset.boardSizeY
           ? String(preset.boardSizeX)
           : preset.boardSizeX + "x" + preset.boardSizeY
}
