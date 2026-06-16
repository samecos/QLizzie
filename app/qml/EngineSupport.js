.pragma library

function applyPackageModeConstraints(app, restartIfChanged, engineController) {
    if (app.packageMode === app.packageModeGo) {
        app.gameRuleMode = app.gameRuleGo
        if (!app.boardDimensionsAllowedForPackage(app.boardSizeX, app.boardSizeY)) {
            app.boardSizeX = 19
            app.boardSizeY = 19
        }
    } else if (app.packageMode === app.packageModeSix) {
        app.gameRuleMode = app.gameRuleGomoku
        if (!app.boardDimensionsAllowedForPackage(app.boardSizeX, app.boardSizeY)) {
            app.boardSizeX = 15
            app.boardSizeY = 15
        }
    }
    app.normalizeGomokuRuleForCurrentMode()
    if (!app.activeEnginePreset())
        applyUniversalEngineCommand(app, restartIfChanged, engineController)
}

function applyUniversalEngineCommand(app, restartIfChanged, engineController) {
    if (!engineController || app.packageMode !== app.packageModeUniversal)
        return
    var command = app.persistedEngineCommand
    if (command.length <= 0 || engineController.command === command)
        return
    engineController.command = command
    app.resetEngineSyncState()
    if (restartIfChanged && app.appReady && engineController.running)
        app.restartEngine()
}

function communicationLineFiltered(stream, line) {
    if (stream !== "stdout")
        return false
    return /^info\s+move\b/.test(String(line).trim())
}

function communicationColor(stream) {
    if (stream === "stdin")
        return "#7ee2a8"
    if (stream === "stderr")
        return "#ff8b7f"
    return "#d9e6ee"
}

function appendCommunication(model, stream, line, limit) {
    if (!model)
        return
    if (communicationLineFiltered(stream, line))
        return
    model.append({
        "stream": stream,
        "line": String(line),
        "color": communicationColor(stream)
    })
    while (model.count > limit)
        model.remove(0)
}

function clearCommunication(model) {
    if (model)
        model.clear()
}
