.pragma library

function focusBoardInput(inputLayer) {
    if (inputLayer)
        inputLayer.forceActiveFocus()
}

function itemContainsInputPoint(item, sourceItem, x, y) {
    if (!item || !item.visible)
        return false
    var point = item.mapFromItem(sourceItem, x, y)
    return point.x >= 0 && point.x <= item.width && point.y >= 0 && point.y <= item.height
}

function boardInputBlocked(sourceItem, x, y, analysisToolbar, infoPanel, branchPanel, commandToolbar) {
    return itemContainsInputPoint(analysisToolbar, sourceItem, x, y)
           || itemContainsInputPoint(infoPanel, sourceItem, x, y)
           || itemContainsInputPoint(branchPanel, sourceItem, x, y)
           || itemContainsInputPoint(commandToolbar, sourceItem, x, y)
}

function pointFromMouse(boardScene, x, y) {
    if (!boardScene)
        return null
    return boardScene.pointFromMouse(x, y)
}

function clearHover(app, force) {
    if (app.selectedPointLocked && force !== true)
        return
    app.selectedPointLocked = false
    app.selectedPointFromCandidateList = false
    app.hoverX = -1
    app.hoverY = -1
    app.hoverKey = ""
}

function cancelCandidateListSelection(app) {
    if (!app.selectedPointLocked || !app.selectedPointFromCandidateList)
        return false
    clearHover(app, true)
    return true
}

function updateHover(app, boardScene, x, y) {
    if (app.selectedPointLocked)
        return
    var point = pointFromMouse(boardScene, x, y)
    if (point) {
        var nextKey = app.keyFor(point.x, point.y)
        if (app.hoverKey === nextKey)
            return
        app.selectedPointFromCandidateList = false
        app.setHoverPoint(point.x, point.y)
    } else {
        clearHover(app)
    }
}

function handleBoardClickFromMouse(app, boardScene, x, y) {
    var point = pointFromMouse(boardScene, x, y)
    if (!point) {
        clearHover(app, true)
        return false
    }

    app.selectedPointLocked = false
    app.selectedPointFromCandidateList = false
    app.setHoverPoint(point.x, point.y)
    app.placeStone(point.x, point.y)
    return true
}

function cycleMoveNumberDisplayMode(app) {
    app.moveNumberDisplayMode = (app.moveNumberDisplayMode + 1) % 3
    app.boardRevision += 1
}
