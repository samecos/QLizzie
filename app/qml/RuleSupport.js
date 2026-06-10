.pragma library
.import "rules/RuleCatalog.js" as RuleCatalog

function gomokuRuleLabel(app, rule) {
    if (rule === app.gomokuRuleStdCon5)
        return app.trText("gomokuRuleStdCon5")
    if (rule === app.gomokuRuleFreestyle)
        return app.trText("gomokuRuleFreestyle")
    if (rule === app.gomokuRuleStandard)
        return app.trText("gomokuRuleStandard")
    if (rule === app.gomokuRuleCon7)
        return app.trText("gomokuRuleCon7")
    if (rule === app.gomokuRuleDirectCon5)
        return app.trText("gomokuRuleDirectCon5")
    return app.trText("gomokuRuleCon5")
}

function gomokuRuleTip(app, rule) {
    if (rule === app.gomokuRuleStdCon5)
        return app.trText("gomokuRuleStdCon5Tip")
    if (rule === app.gomokuRuleFreestyle)
        return app.trText("gomokuRuleFreestyleTip")
    if (rule === app.gomokuRuleStandard)
        return app.trText("gomokuRuleStandardTip")
    if (rule === app.gomokuRuleCon7)
        return app.trText("gomokuRuleCon7Tip")
    if (rule === app.gomokuRuleDirectCon5)
        return app.trText("gomokuRuleDirectCon5Tip")
    return app.trText("gomokuRuleCon5Tip")
}

function gomokuRuleEngineValue(app, rule) {
    if (rule === app.gomokuRuleStdCon5)
        return "stdcon5"
    if (rule === app.gomokuRuleFreestyle)
        return "freestyle"
    if (rule === app.gomokuRuleStandard)
        return "standard"
    if (rule === app.gomokuRuleCon7)
        return "con7"
    if (rule === app.gomokuRuleDirectCon5)
        return "dcon5"
    return "con5"
}

function gameRuleText(app) {
    if (app.gameRuleMode === app.gameRuleGo)
        return app.trText("gameRuleGo")
    if (app.gameRuleMode === app.gameRuleHex)
        return app.trText("gameRuleHex")
    return gomokuRuleLabel(app, app.gomokuRuleMode)
}

function gameRuleOptions(app) {
    return [
        { "label": app.trText("gameRuleGo"), "value": app.gameRuleGo, "tip": app.trText("gameRuleGoTip") },
        { "label": app.trText("gameRuleGomoku"), "value": app.gameRuleGomoku, "tip": app.trText("gameRuleGomokuTip") },
        { "label": app.trText("gameRuleHex"), "value": app.gameRuleHex, "tip": app.trText("gameRuleHexTip") }
    ]
}

function gameRuleCurrentIndex(app) {
    var options = gameRuleOptions(app)
    for (var i = 0; i < options.length; ++i) {
        if (options[i].value === app.gameRuleMode)
            return i
    }
    return 0
}

function setGameRuleFromIndex(app, index) {
    var options = gameRuleOptions(app)
    if (index < 0 || index >= options.length)
        return
    app.requestRuleModeChange(options[index].value)
}

function goRuleOptions(app) {
    return [{ "label": app.trText("goRuleTrompTaylor"), "value": -1, "tip": app.trText("goRuleTrompTaylorTip") }]
}

function gomokuRuleOptions(app) {
    var options = [
        { "label": gomokuRuleLabel(app, app.gomokuRuleCon5), "value": app.gomokuRuleCon5, "tip": gomokuRuleTip(app, app.gomokuRuleCon5) },
        { "label": gomokuRuleLabel(app, app.gomokuRuleStdCon5), "value": app.gomokuRuleStdCon5, "tip": gomokuRuleTip(app, app.gomokuRuleStdCon5) },
        { "label": gomokuRuleLabel(app, app.gomokuRuleFreestyle), "value": app.gomokuRuleFreestyle, "tip": gomokuRuleTip(app, app.gomokuRuleFreestyle) },
        { "label": gomokuRuleLabel(app, app.gomokuRuleStandard), "value": app.gomokuRuleStandard, "tip": gomokuRuleTip(app, app.gomokuRuleStandard) },
        { "label": gomokuRuleLabel(app, app.gomokuRuleCon7), "value": app.gomokuRuleCon7, "tip": gomokuRuleTip(app, app.gomokuRuleCon7) },
        { "label": gomokuRuleLabel(app, app.gomokuRuleDirectCon5), "value": app.gomokuRuleDirectCon5, "tip": gomokuRuleTip(app, app.gomokuRuleDirectCon5) }
    ]
    if (app.packageMode !== app.packageModeSix)
        return options
    return [options[app.gomokuRuleFreestyle], options[app.gomokuRuleStandard],
            options[app.gomokuRuleCon7], options[app.gomokuRuleDirectCon5]]
}

function ruleVariantOptions(app) {
    if (app.gameRuleMode === app.gameRuleHex)
        return [{ "label": app.trText("gameRuleHex"), "value": -1, "tip": app.trText("gameRuleHexTip") }]
    return app.gameRuleMode === app.gameRuleGo ? goRuleOptions(app) : gomokuRuleOptions(app)
}

function ruleVariantCurrentIndex(app) {
    var options = ruleVariantOptions(app)
    if (app.gameRuleMode === app.gameRuleGo)
        return 0
    for (var i = 0; i < options.length; ++i) {
        if (options[i].value === app.gomokuRuleMode)
            return i
    }
    return 0
}

function ruleVariantCurrentTip(app) {
    var options = ruleVariantOptions(app)
    var index = ruleVariantCurrentIndex(app)
    return index >= 0 && index < options.length ? options[index].tip : ""
}

function setRuleVariantFromIndex(app, index) {
    var options = ruleVariantOptions(app)
    if (index < 0 || index >= options.length)
        return
    if (app.gameRuleMode === app.gameRuleGomoku) {
        app.gomokuRuleMode = options[index].value
        app.rebuildPositionFromNode(app.currentNodeId)
        app.resetEngineSyncState()
        app.scheduleAutoAnalysis()
    }
}

function ruleModeButtonsVisible(app) {
    return false
}

function ruleVariantComboVisible(app) {
    return true
}

function komiControlsVisible(app) {
    return app.gameRuleMode === app.gameRuleGo && app.packageMode !== app.packageModeSix
}

function boardPresentationOptions(app) {
    return RuleCatalog.boardPresentationOptions(app, app.gameRuleMode)
}

function boardPresentationCurrentIndex(app) {
    return RuleCatalog.boardPresentationCurrentIndex(app)
}

function setBoardPresentationFromIndex(app, index) {
    var options = boardPresentationOptions(app)
    if (index < 0 || index >= options.length)
        return
    app.boardPresentationMode = options[index].value
}

function boardPresentationText(app, mode) {
    return RuleCatalog.boardPresentationText(app, mode)
}

function engineCommandEditable(app) {
    return app.packageMode === app.packageModeUniversal
}

function customBoardSizeAllowed(app) {
    return app.packageMode === app.packageModeUniversal
}

function boardSizePresetAllowed(app, size) {
    if (app.packageMode === app.packageModeGo)
        return size === 5 || size === 7 || size === 9 || size === 13 || size === 19
    if (app.packageMode === app.packageModeSix)
        return size === 11 || size === 13
    return size === 5 || size === 7 || size === 9 || size === 13 || size === 19
}

function boardDimensionsAllowedForPackage(app, xSize, ySize) {
    if (app.packageMode === app.packageModeUniversal)
        return true
    if (xSize !== ySize)
        return false
    return boardSizePresetAllowed(app, xSize)
}

function ruleModeAllowedForPackage(app, mode) {
    if (app.packageMode === app.packageModeGo)
        return mode === app.gameRuleGo
    if (app.packageMode === app.packageModeSix)
        return mode === app.gameRuleGomoku
    return mode === app.gameRuleGo || mode === app.gameRuleGomoku || mode === app.gameRuleHex
}

function packageDefaultBoardSize(app) {
    if (app.packageMode === app.packageModeGo)
        return 19
    if (app.packageMode === app.packageModeSix)
        return 13
    return app.defaultBoardSize
}

function packageModeText(app, mode) {
    if (mode === app.packageModeGo)
        return app.trText("packageModeGo")
    if (mode === app.packageModeSix)
        return app.trText("packageModeSix")
    return app.trText("packageModeUniversal")
}

function packageBoardSizeRejectText(app, xSize, ySize) {
    var dims = app.boardDimensionsTextForSize(xSize, ySize)
    if (app.packageMode === app.packageModeGo)
        return app.trText("packageBoardSizeRejected") + ": " + dims
    if (app.packageMode === app.packageModeSix)
        return app.trText("packageBoardSizeRejected") + ": " + dims + " (11x11 / 13x13)"
    return app.trText("packageBoardSizeRejected") + ": " + dims
}

function normalizeGomokuRuleForCurrentMode(app) {
    if (app.gameRuleMode !== app.gameRuleGomoku)
        return
    if (app.packageMode === app.packageModeSix && app.gomokuRuleMode !== app.gomokuRuleFreestyle
            && app.gomokuRuleMode !== app.gomokuRuleStandard
            && app.gomokuRuleMode !== app.gomokuRuleCon7
            && app.gomokuRuleMode !== app.gomokuRuleDirectCon5)
        app.gomokuRuleMode = app.gomokuRuleFreestyle
}

function requestRuleModeChange(app, mode, dialog) {
    if (mode === app.gameRuleMode)
        return
    if (!ruleModeAllowedForPackage(app, mode))
        return
    if (app.gameDirty) {
        app.pendingClearAction = "ruleMode"
        app.pendingRuleMode = mode
        dialog.open()
        return
    }
    applyRuleModeChange(app, mode)
}

function applyRuleModeChange(app, mode) {
    if (mode !== app.gameRuleGo && mode !== app.gameRuleGomoku && mode !== app.gameRuleHex)
        return
    if (!ruleModeAllowedForPackage(app, mode))
        return
    app.gameRuleMode = mode
    if (mode === app.gameRuleHex)
        app.coordinateDisplayMode = app.coordinateDisplayHex
    app.boardPresentationMode = RuleCatalog.boardPresentationOptions(app, mode)[0].value
    normalizeGomokuRuleForCurrentMode(app)
    app.clearHover(true)
    app.resetGameTree()
    app.gameDirty = false
    app.statusMode = "message"
    app.statusMessage = app.trText("ruleChanged") + ": " + gameRuleText(app)
    app.resetEngineSyncState()
    app.scheduleAutoAnalysis()
    app.requestAiMoveIfNeeded()
    app.focusBoardInput()
}

function requestBoardDimensionsChange(app, xSize, ySize, markDirty, dialog) {
    var nextX = Math.round(app.clamp(xSize, app.minBoardSize, app.maxBoardSize))
    var nextY = Math.round(app.clamp(ySize, app.minBoardSize, app.maxBoardSize))
    if (!boardDimensionsAllowedForPackage(app, nextX, nextY)) {
        app.statusMode = "message"
        app.statusMessage = packageBoardSizeRejectText(app, nextX, nextY)
        return false
    }
    if (nextX === app.boardSizeX && nextY === app.boardSizeY)
        return true
    if (app.gameDirty) {
        app.pendingClearAction = "boardSize"
        app.pendingBoardSizeX = nextX
        app.pendingBoardSizeY = nextY
        dialog.open()
        return false
    }
    return setBoardDimensions(app, nextX, nextY, markDirty)
}

function setBoardDimensions(app, xSize, ySize, markDirty) {
    var nextX = Math.round(app.clamp(xSize, app.minBoardSize, app.maxBoardSize))
    var nextY = Math.round(app.clamp(ySize, app.minBoardSize, app.maxBoardSize))
    if (!boardDimensionsAllowedForPackage(app, nextX, nextY)) {
        app.statusMode = "message"
        app.statusMessage = packageBoardSizeRejectText(app, nextX, nextY)
        return false
    }
    if (nextX === app.boardSizeX && nextY === app.boardSizeY)
        return true
    app.boardSizeX = nextX
    app.boardSizeY = nextY
    app.clearHover(true)
    app.resetGameTree()
    app.setSelectedPoint(0, 0)
    if (markDirty !== false)
        app.gameDirty = true
    app.resetEngineSyncState()
    app.scheduleAutoAnalysis()
    app.requestAiMoveIfNeeded()
    return true
}

function resetBoardSize(app) {
    var size = packageDefaultBoardSize(app)
    setBoardDimensions(app, size, size)
}

function pendingClearMessage(app) {
    if (app.pendingClearAction === "openSgf")
        return app.trText("confirmOpenSgfSave")
    if (app.pendingClearAction === "boardSize")
        return app.trText("confirmBoardSizeChangeSave")
    if (app.pendingClearAction === "clearBoard")
        return app.trText("confirmBoardSizeChangeSave")
    return app.trText("confirmRuleChangeSave")
}

function pendingClearTitle(app) {
    return app.trText("clearGamePromptTitle")
}

function clearPendingClearAction(app) {
    app.pendingClearAction = ""
    app.pendingRuleMode = -1
    app.pendingBoardSizeX = -1
    app.pendingBoardSizeY = -1
}

function applyPendingClearAction(app, loadSgfDialog) {
    if (app.pendingClearAction === "ruleMode") {
        var mode = app.pendingRuleMode
        clearPendingClearAction(app)
        app.gameDirty = false
        applyRuleModeChange(app, mode)
        return
    }
    if (app.pendingClearAction === "boardSize") {
        var xSize = app.pendingBoardSizeX
        var ySize = app.pendingBoardSizeY
        clearPendingClearAction(app)
        app.gameDirty = false
        setBoardDimensions(app, xSize, ySize)
        return
    }
    if (app.pendingClearAction === "openSgf") {
        clearPendingClearAction(app)
        app.gameDirty = false
        loadSgfDialog.open()
        return
    }
    if (app.pendingClearAction === "clearBoard") {
        clearPendingClearAction(app)
        app.gameDirty = false
        app.resetGameTree()
        return
    }
    clearPendingClearAction(app)
    app.focusBoardInput()
}
