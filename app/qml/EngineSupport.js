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
            app.boardSizeX = 13
            app.boardSizeY = 13
        }
    }
    app.normalizeGomokuRuleForCurrentMode()
    if (app.packageMode === app.packageModeUniversal)
        applyUniversalEngineCommand(app, restartIfChanged, engineController)
    else
        applyEngineCommandForCurrentPackageMode(app, restartIfChanged, engineController)
}

function packageEngineCommandForCurrentBoard(app) {
    if (app.packageMode === app.packageModeGo)
        return app.boardSizeX === 5 ? app.go5EngineCommand : app.go7EngineCommand
    if (app.packageMode === app.packageModeSix)
        return app.boardSizeX === 11 ? app.six11EngineCommand : app.six13EngineCommand
    return ""
}

function applyEngineCommandForCurrentPackageMode(app, restartIfChanged, engineController) {
    if (!engineController || app.packageMode === app.packageModeUniversal)
        return
    var command = packageEngineCommandForCurrentBoard(app)
    if (command.length <= 0 || engineController.command === command)
        return
    engineController.command = command
    app.resetEngineSyncState()
    if (restartIfChanged && app.appReady && engineController.running)
        app.restartEngine()
}

function applyUniversalEngineCommand(app, restartIfChanged, engineController) {
    if (!engineController || app.packageMode !== app.packageModeUniversal)
        return
    var command = app.persistedEngineCommand.length > 0 ? app.persistedEngineCommand : app.defaultGo7EngineCommand
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
