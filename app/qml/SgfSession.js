.pragma library
.import "SgfUtils.js" as SgfUtils

function build(app) {
    return SgfUtils.buildSgf(app.gameNodes, app.gameRuleMode,
                             app.boardSizeX, app.boardSizeY, app.gameRuleText())
}

function parse(app, text) {
    return SgfUtils.parseSgf(text, {
        "minBoardSize": app.minBoardSize,
        "maxBoardSize": app.maxBoardSize,
        "defaultRuleMode": app.gameRuleMode,
        "gameRuleGo": app.gameRuleGo,
        "gameRuleGomoku": app.gameRuleGomoku,
        "gameRuleHex": app.gameRuleHex
    })
}

function applyParsed(app, parsed, url) {
    app.resetEngineSyncState()
    var parsedRuleMode = parsed.ruleMode === undefined ? app.gameRuleMode : parsed.ruleMode
    if (!app.ruleModeAllowedForPackage(parsedRuleMode)) {
        app.statusMode = "message"
        app.statusMessage = app.trText("sgfLoadFailed") + ": " + app.trText("packageRuleRejected")
        app.focusBoardInput()
        return
    }
    if (!app.boardDimensionsAllowedForPackage(parsed.boardSizeX, parsed.boardSizeY)) {
        app.statusMode = "message"
        app.statusMessage = app.trText("sgfLoadFailed") + ": "
                            + app.packageBoardSizeRejectText(parsed.boardSizeX, parsed.boardSizeY)
        app.focusBoardInput()
        return
    }
    app.gameRuleMode = parsedRuleMode
    app.boardSizeX = parsed.boardSizeX
    app.boardSizeY = parsed.boardSizeY
    app.gameTreeGeneration += 1
    app.gameNodes = parsed.nodes
    app.nextNodeId = parsed.nextNodeId
    app.currentNodeId = 0
    app.clearHover(true)
    app.rebuildPositionFromNode(app.currentNodeId)
    app.rebuildTreeLayout()
    app.gotoLastMove()
    app.gameDirty = false
    app.statusMode = "message"
    app.statusMessage = app.trText("sgfLoaded") + ": " + url
    app.focusBoardInput()
}

function saveToFile(app, fileIo, url) {
    var ok = fileIo.writeTextFile(url, build(app))
    if (ok) {
        app.gameDirty = false
        app.statusMode = "message"
        app.statusMessage = app.trText("sgfSaved") + ": " + url
    } else {
        app.statusMode = "message"
        app.statusMessage = app.trText("sgfSaveFailed") + ": " + fileIo.lastError
    }
    if (app.saveDialogClosesApp) {
        app.saveDialogClosesApp = false
        app.suppressUnsavedPrompt = true
        Qt.quit()
    }
    app.focusBoardInput()
}

function loadFromFile(app, fileIo, url) {
    var text = fileIo.readTextFile(url)
    if (fileIo.lastError !== "") {
        app.statusMode = "message"
        app.statusMessage = app.trText("sgfLoadFailed") + ": " + fileIo.lastError
        app.focusBoardInput()
        return
    }
    var parsed = parse(app, text)
    if (!parsed.ok) {
        app.statusMode = "message"
        app.statusMessage = app.trText("sgfLoadFailed") + ": " + parsed.error
        app.focusBoardInput()
        return
    }
    applyParsed(app, parsed, url)
}
