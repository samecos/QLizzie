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
    if (app.gameRuleMode === app.gameRuleSquareFree)
        return app.trText("gameRuleSquareFree")
    if (app.gameRuleMode === app.gameRuleReversi)
        return app.trText("gameRuleReversi")
    if (app.gameRuleMode === app.gameRuleConnect6)
        return app.trText("gameRuleConnect6")
    if (app.gameRuleMode === app.gameRuleHexGoParallelogram)
        return app.trText("gameRuleHexGoParallelogram")
    if (app.gameRuleMode === app.gameRuleHexGoHexagon)
        return app.trText("gameRuleHexGoHexagon")
    if (app.gameRuleMode === app.gameRuleHexGoTriangle)
        return app.trText("gameRuleHexGoTriangle")
    if (app.gameRuleMode === app.gameRuleAtaxx)
        return app.trText("gameRuleAtaxx")
    if (app.gameRuleMode === app.gameRuleBreakthrough)
        return app.trText("gameRuleBreakthrough")
    return gomokuRuleLabel(app, app.gomokuRuleMode)
}

function gameRuleOptions(app) {
    return [
        { "label": app.trText("gameRuleGo"), "value": app.gameRuleGo, "tip": app.trText("gameRuleGoTip") },
        { "label": app.trText("gameRuleGomoku"), "value": app.gameRuleGomoku, "tip": app.trText("gameRuleGomokuTip") },
        { "label": app.trText("gameRuleHex"), "value": app.gameRuleHex, "tip": app.trText("gameRuleHexTip") },
        { "label": app.trText("gameRuleSquareFree"), "value": app.gameRuleSquareFree, "tip": app.trText("gameRuleSquareFreeTip") },
        { "label": app.trText("gameRuleReversi"), "value": app.gameRuleReversi, "tip": app.trText("gameRuleReversiTip") },
        { "label": app.trText("gameRuleConnect6"), "value": app.gameRuleConnect6, "tip": app.trText("gameRuleConnect6Tip") },
        { "label": app.trText("gameRuleHexGoParallelogram"), "value": app.gameRuleHexGoParallelogram, "tip": app.trText("gameRuleHexGoParallelogramTip") },
        { "label": app.trText("gameRuleHexGoHexagon"), "value": app.gameRuleHexGoHexagon, "tip": app.trText("gameRuleHexGoHexagonTip") },
        { "label": app.trText("gameRuleHexGoTriangle"), "value": app.gameRuleHexGoTriangle, "tip": app.trText("gameRuleHexGoTriangleTip") },
        { "label": app.trText("gameRuleAtaxx"), "value": app.gameRuleAtaxx, "tip": app.trText("gameRuleAtaxxTip") },
        { "label": app.trText("gameRuleBreakthrough"), "value": app.gameRuleBreakthrough, "tip": app.trText("gameRuleBreakthroughTip") }
    ]
}

function validRuleMode(app, mode) {
    var options = gameRuleOptions(app)
    for (var i = 0; i < options.length; ++i) {
        if (options[i].value === mode)
            return true
    }
    return false
}

function ruleUsesHexGrid(app, mode) {
    return mode === app.gameRuleHex
           || mode === app.gameRuleHexGoParallelogram
           || mode === app.gameRuleHexGoHexagon
           || mode === app.gameRuleHexGoTriangle
}

function ruleUsesGoCapture(app, mode) {
    return mode === app.gameRuleGo
           || mode === app.gameRuleHexGoParallelogram
           || mode === app.gameRuleHexGoHexagon
           || mode === app.gameRuleHexGoTriangle
}

function ruleUsesSquareCells(app, mode) {
    return (mode === app.gameRuleGomoku && app.boardPresentationMode === app.boardPresentationCells)
           || mode === app.gameRuleReversi
           || mode === app.gameRuleAtaxx
           || mode === app.gameRuleBreakthrough
}

function ruleUsesHexCellStyle(app, mode) {
    return mode === app.gameRuleHex && app.hexBoardStyle === app.hexBoardStyleCells
}

function ruleAllowsOccupiedMoves(app, mode) {
    return mode === app.gameRuleSquareFree
}

function ruleUsesMoveSource(app, mode) {
    return mode === app.gameRuleAtaxx || mode === app.gameRuleBreakthrough
}

function ruleHasBoardPresentation(app, mode) {
    return RuleCatalog.boardPresentationOptions(app, mode).length > 1
}

function ruleHasHexBoardStyle(app, mode) {
    return mode === app.gameRuleHex && RuleCatalog.hexBoardStyleOptions(app, mode).length > 1
}

function ruleHasHexRotation(app, mode) {
    return ruleUsesHexGrid(app, mode) && RuleCatalog.hexBoardRotationOptions(app, mode).length > 1
}

function ruleVisibilityKey(app, mode) {
    return String(mode)
}

function normalizedRuleVisibilityMap(app, source) {
    var map = source || {}
    var options = gameRuleOptions(app)
    var next = {}
    for (var i = 0; i < options.length; ++i) {
        var key = ruleVisibilityKey(app, options[i].value)
        next[key] = map[key] !== false
    }
    return next
}

function ruleModeVisible(app, mode) {
    if (mode === app.gameRuleMode)
        return true
    var key = ruleVisibilityKey(app, mode)
    var map = normalizedRuleVisibilityMap(app, app.ruleVisibilityMap)
    return map[key] !== false
}

function setRuleModeVisible(app, mode, visible) {
    var key = ruleVisibilityKey(app, mode)
    var map = normalizedRuleVisibilityMap(app, app.ruleVisibilityMap)
    map[key] = visible === true
    if (mode === app.gameRuleMode)
        map[key] = true
    app.ruleVisibilityMap = map
    if (app.persistentSettingsLoaded)
        app.savePersistentSettings()
}

function visibleGameRuleOptions(app) {
    var options = gameRuleOptions(app)
    var visible = []
    for (var i = 0; i < options.length; ++i) {
        if (ruleModeVisible(app, options[i].value))
            visible.push(options[i])
    }
    return visible.length > 0 ? visible : options
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

function visibleGameRuleCurrentIndex(app) {
    var options = visibleGameRuleOptions(app)
    for (var i = 0; i < options.length; ++i) {
        if (options[i].value === app.gameRuleMode)
            return i
    }
    return 0
}

function setVisibleGameRuleFromIndex(app, index) {
    var options = visibleGameRuleOptions(app)
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
    if (app.gameRuleMode === app.gameRuleGomoku)
        return gomokuRuleOptions(app)
    if (app.gameRuleMode === app.gameRuleGo)
        return goRuleOptions(app)
    return [{ "label": gameRuleText(app), "value": -1, "tip": "" }]
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
    return app.gameRuleMode === app.gameRuleGo || app.gameRuleMode === app.gameRuleGomoku
}

function komiControlsVisible(app) {
    return ruleUsesGoCapture(app, app.gameRuleMode) && app.packageMode !== app.packageModeSix
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
    var next = RuleCatalog.normalizeBoardPresentationMode(app, app.gameRuleMode, options[index].value)
    if (app.gameRuleMode === app.gameRuleGomoku)
        app.gomokuBoardPresentationMode = next
    else if (app.gameRuleMode === app.gameRuleGo)
        app.goBoardPresentationMode = next
    if (app.boardPresentationMode !== next) {
        app.boardPresentationMode = next
        app.boardRevision += 1
    }
}

function boardPresentationText(app, mode) {
    return RuleCatalog.boardPresentationText(app, mode)
}

function hexBoardStyleOptions(app) {
    return RuleCatalog.hexBoardStyleOptions(app, app.gameRuleMode)
}

function hexBoardStyleCurrentIndex(app) {
    return RuleCatalog.hexBoardStyleCurrentIndex(app)
}

function setHexBoardStyleFromIndex(app, index) {
    var options = hexBoardStyleOptions(app)
    if (index < 0 || index >= options.length)
        return
    var next = options[index].value
    if (app.hexBoardStyle === next)
        return
    app.hexBoardStyle = next
    app.boardRevision += 1
}

function hexBoardRotationOptions(app) {
    return RuleCatalog.hexBoardRotationOptions(app, app.gameRuleMode)
}

function hexBoardRotationCurrentIndex(app) {
    return RuleCatalog.hexBoardRotationCurrentIndex(app)
}

function setHexBoardRotationFromIndex(app, index) {
    var options = hexBoardRotationOptions(app)
    if (index < 0 || index >= options.length)
        return
    var next = options[index].value
    if (app.hexBoardRotation === next)
        return
    app.hexBoardRotation = next
    app.boardRevision += 1
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
    return validRuleMode(app, mode)
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
    if (!validRuleMode(app, mode))
        return
    if (!ruleModeAllowedForPackage(app, mode))
        return
    app.gameRuleMode = mode
    var adjusted = adjustedBoardDimensionsForRule(app, mode, app.boardSizeX, app.boardSizeY)
    app.boardSizeX = adjusted.x
    app.boardSizeY = adjusted.y
    if (mode === app.gameRuleHex)
        app.coordinateDisplayMode = app.coordinateDisplayHex
    app.boardPresentationMode = RuleCatalog.normalizeBoardPresentationMode(
                app, mode, RuleCatalog.rememberedBoardPresentationMode(app, mode))
    if (mode === app.gameRuleGo)
        app.goBoardPresentationMode = app.boardPresentationMode
    else if (mode === app.gameRuleGomoku)
        app.gomokuBoardPresentationMode = app.boardPresentationMode
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

function adjustedBoardDimensionsForRule(app, mode, xSize, ySize) {
    var nextX = Math.round(app.clamp(xSize, app.minBoardSize, app.maxBoardSize))
    var nextY = Math.round(app.clamp(ySize, app.minBoardSize, app.maxBoardSize))
    if (mode === app.gameRuleHexGoHexagon) {
        if (nextX % 2 === 0)
            nextX += 1
        nextX = Math.round(app.clamp(nextX, app.minBoardSize, app.maxBoardSize))
        nextY = nextX
    } else if (mode === app.gameRuleHexGoTriangle) {
        nextY = nextX
    } else if (mode === app.gameRuleBreakthrough && nextY <= 3) {
        nextY = 4
    }
    return { "x": nextX, "y": nextY }
}

function boardDimensionsAllowedForRule(app, mode, xSize, ySize) {
    if (mode === app.gameRuleHexGoHexagon)
        return xSize === ySize && xSize % 2 === 1
    if (mode === app.gameRuleHexGoTriangle)
        return xSize === ySize
    if (mode === app.gameRuleBreakthrough)
        return ySize > 3
    return true
}

function requestBoardDimensionsChange(app, xSize, ySize, markDirty, dialog) {
    var nextX = Math.round(app.clamp(xSize, app.minBoardSize, app.maxBoardSize))
    var nextY = Math.round(app.clamp(ySize, app.minBoardSize, app.maxBoardSize))
    if (!boardDimensionsAllowedForPackage(app, nextX, nextY)) {
        app.statusMode = "message"
        app.statusMessage = packageBoardSizeRejectText(app, nextX, nextY)
        return false
    }
    if (!boardDimensionsAllowedForRule(app, app.gameRuleMode, nextX, nextY)) {
        app.statusMode = "message"
        app.statusMessage = ruleBoardSizeRejectText(app, app.gameRuleMode, nextX, nextY)
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
    if (!boardDimensionsAllowedForRule(app, app.gameRuleMode, nextX, nextY)) {
        app.statusMode = "message"
        app.statusMessage = ruleBoardSizeRejectText(app, app.gameRuleMode, nextX, nextY)
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

function ruleBoardSizeRejectText(app, mode, xSize, ySize) {
    var dims = app.boardDimensionsTextForSize(xSize, ySize)
    if (mode === app.gameRuleHexGoHexagon)
        return app.trText("hexGoHexagonBoardSizeRejected") + ": " + dims
    if (mode === app.gameRuleHexGoTriangle)
        return app.trText("hexGoTriangleBoardSizeRejected") + ": " + dims
    if (mode === app.gameRuleBreakthrough)
        return app.trText("breakthroughBoardSizeRejected") + ": " + dims
    return packageBoardSizeRejectText(app, xSize, ySize)
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
        return app.trText("confirmClearBoardSave")
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
