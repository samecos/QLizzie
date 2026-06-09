import QtQuick

Item {
    id: boardScene
    required property var app

    x: app.boardStageLeftReserve
    y: app.analysisToolbarHeight
    width: parent.width - app.boardStageLeftReserve - app.boardStageRightReserve
    height: parent.height - app.analysisToolbarHeight - app.commandToolbarHeight - app.panelGap

    readonly property real targetSide: app.compactLayout ? 620 : 760
    readonly property real usableSide: Math.max(280, Math.min(targetSide, width - 36, height - 36))
    readonly property real boardPadding: app.compactLayout ? 30 : 38
    readonly property real gridSpan: Math.max(1, usableSide - boardPadding * 2)
    readonly property real cellSize: Math.max(1, Math.min(
        gridSpan / Math.max(1, app.boardSizeX - 1),
        gridSpan / Math.max(1, app.boardSizeY - 1)))
    readonly property real gridWidth: cellSize * Math.max(1, app.boardSizeX - 1)
    readonly property real gridHeight: cellSize * Math.max(1, app.boardSizeY - 1)
    readonly property real boardLeft: Math.round((width - gridWidth) / 2)
    readonly property real boardTop: Math.round((height - gridHeight) / 2)
    readonly property real boardRight: boardLeft + gridWidth
    readonly property real boardBottom: boardTop + gridHeight

    function boardPointLocal(x, y) {
        return Qt.point(boardLeft + x * cellSize, boardTop + y * cellSize)
    }

    function pointFromMouse(mouseX, mouseY) {
        if (cellSize <= 0)
            return null

        var x = Math.round((mouseX - boardLeft) / cellSize)
        var y = Math.round((mouseY - boardTop) / cellSize)
        if (!app.pointInBoard(x, y))
            return null

        var point = boardPointLocal(x, y)
        var dx = mouseX - point.x
        var dy = mouseY - point.y
        var hitRadius = Math.max(14, Math.min(30, cellSize * app.mouseHitRadiusScale * 2.8))
        if (Math.sqrt(dx * dx + dy * dy) > hitRadius)
            return null
        return { "x": x, "y": y, "key": app.keyFor(x, y) }
    }

    Rectangle {
        anchors.centerIn: parent
        width: boardScene.gridWidth + boardScene.boardPadding * 2
        height: boardScene.gridHeight + boardScene.boardPadding * 2
        radius: 6
        color: app.boardWoodColor
        border.color: "#9d7442"
        border.width: 1
        opacity: 0.98
    }

    Canvas {
        id: boardCanvas
        anchors.fill: parent

        function drawStone(ctx, x, y, player, radius) {
            var point = boardScene.boardPointLocal(x, y)
            var gradient = ctx.createRadialGradient(point.x - radius * 0.28,
                                                    point.y - radius * 0.34,
                                                    radius * 0.12,
                                                    point.x,
                                                    point.y,
                                                    radius)
            if (player === 1) {
                gradient.addColorStop(0, "#555b60")
                gradient.addColorStop(0.36, "#15191d")
                gradient.addColorStop(1, "#020304")
            } else {
                gradient.addColorStop(0, "#ffffff")
                gradient.addColorStop(0.48, "#fff8e6")
                gradient.addColorStop(1, "#d9cba8")
            }
            ctx.fillStyle = gradient
            ctx.beginPath()
            ctx.arc(point.x, point.y, radius, 0, Math.PI * 2)
            ctx.fill()
            ctx.strokeStyle = player === 1 ? "#000000" : "#9d9279"
            ctx.lineWidth = 1
            ctx.stroke()
        }

        function drawCenteredText(ctx, text, x, y, color, size, bold) {
            ctx.fillStyle = color
            ctx.font = (bold ? "bold " : "") + size + "px " + app.coordinateFontFamily
            ctx.textAlign = "center"
            ctx.textBaseline = "middle"
            ctx.fillText(text, x, y)
        }

        function starPoints(size) {
            if (size >= 19)
                return [3, Math.floor(size / 2), size - 4]
            if (size >= 13)
                return [3, size - 4]
            if (size >= 9)
                return [2, Math.floor(size / 2), size - 3]
            return []
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var left = boardScene.boardLeft
            var top = boardScene.boardTop
            var right = boardScene.boardRight
            var bottom = boardScene.boardBottom
            var cell = boardScene.cellSize

            ctx.save()
            ctx.strokeStyle = "#2d2114"
            ctx.globalAlpha = app.gridOpacity
            ctx.lineWidth = Math.max(1, app.gridLineWidth)
            for (var x = 0; x < app.boardSizeX; ++x) {
                var px = left + x * cell
                ctx.beginPath()
                ctx.moveTo(px, top)
                ctx.lineTo(px, bottom)
                ctx.stroke()
            }
            for (var y = 0; y < app.boardSizeY; ++y) {
                var py = top + y * cell
                ctx.beginPath()
                ctx.moveTo(left, py)
                ctx.lineTo(right, py)
                ctx.stroke()
            }
            ctx.restore()

            var xs = starPoints(app.boardSizeX)
            var ys = starPoints(app.boardSizeY)
            ctx.fillStyle = "#2d2114"
            for (var sx = 0; sx < xs.length; ++sx) {
                for (var sy = 0; sy < ys.length; ++sy) {
                    var star = boardScene.boardPointLocal(xs[sx], ys[sy])
                    ctx.beginPath()
                    ctx.arc(star.x, star.y, Math.max(2.8, cell * 0.065), 0, Math.PI * 2)
                    ctx.fill()
                }
            }

            ctx.font = (app.compactLayout ? "12px " : "13px ") + app.coordinateFontFamily
            ctx.fillStyle = "#4f371f"
            ctx.textAlign = "center"
            ctx.textBaseline = "middle"
            for (var lx = 0; lx < app.boardSizeX; ++lx) {
                var labelX = left + lx * cell
                ctx.fillText(app.xCoordinateText(lx), labelX, top - boardScene.boardPadding * 0.52)
                ctx.fillText(app.xCoordinateText(lx), labelX, bottom + boardScene.boardPadding * 0.52)
            }
            ctx.textAlign = "center"
            for (var ly = 0; ly < app.boardSizeY; ++ly) {
                var labelY = top + ly * cell
                ctx.fillText(app.yCoordinateText(ly), left - boardScene.boardPadding * 0.52, labelY)
                ctx.fillText(app.yCoordinateText(ly), right + boardScene.boardPadding * 0.52, labelY)
            }

            var candidateRadius = Math.max(7, Math.min(18, cell * app.stoneScale * 0.34))
            for (var c = app.engineCandidateItems.length - 1; c >= 0; --c) {
                var candidate = app.engineCandidateItems[c]
                if (app.stoneAt(candidate.x, candidate.y) !== 0)
                    continue
                var cp = boardScene.boardPointLocal(candidate.x, candidate.y)
                ctx.globalAlpha = candidate.opacity
                ctx.fillStyle = candidate.displayIndex === 1 ? "#00c8ff" : "#2ed36f"
                ctx.beginPath()
                ctx.arc(cp.x, cp.y, candidateRadius, 0, Math.PI * 2)
                ctx.fill()
                ctx.globalAlpha = 1
                if (candidate.labelLines && candidate.labelLines.length > 0) {
                    var label = candidate.labelLines[0]
                    drawCenteredText(ctx, label, cp.x, cp.y, app.candidateLabelTextColor,
                                     Math.max(10, Math.min(18, cell * 0.22)), true)
                } else {
                    drawCenteredText(ctx, String(candidate.displayIndex), cp.x, cp.y,
                                     candidate.displayIndex === 1 ? "#d71919" : "#104f29",
                                     Math.max(10, Math.min(16, cell * 0.20)), true)
                }
            }

            if (app.bestCandidateRingVisible && app.candidateRingVisible) {
                var bp = boardScene.boardPointLocal(app.bestCandidateRingX, app.bestCandidateRingY)
                ctx.strokeStyle = "#f01818"
                ctx.lineWidth = Math.max(2, app.candidateRingLineWidth * 0.45)
                ctx.beginPath()
                ctx.arc(bp.x, bp.y, Math.max(12, Math.min(26, cell * app.stoneScale * 0.56)), 0, Math.PI * 2)
                ctx.stroke()
            }

            var stoneRadius = Math.max(8, Math.min(cell * 0.48, cell * app.stoneScale * 0.5))
            for (var s = 0; s < app.stoneItems.length; ++s) {
                var stone = app.stoneItems[s]
                drawStone(ctx, stone.x, stone.y, stone.player, stoneRadius)
            }

            for (var w = 0; w < app.gomokuWinLineItems.length; ++w) {
                var win = app.gomokuWinLineItems[w]
                var start = boardScene.boardPointLocal(win.startX, win.startY)
                var end = boardScene.boardPointLocal(win.endX, win.endY)
                ctx.strokeStyle = "#f01818"
                ctx.lineWidth = Math.max(4, cell * 0.09)
                ctx.lineCap = "round"
                ctx.beginPath()
                ctx.moveTo(start.x, start.y)
                ctx.lineTo(end.x, end.y)
                ctx.stroke()
            }

            for (var o = 0; o < app.stoneItems.length; ++o) {
                var overlayStone = app.stoneItems[o]
                var last = app.isLastMoveAt(overlayStone.x, overlayStone.y)
                if (!app.stoneOverlayVisible(overlayStone.moveNumber, last))
                    continue
                var op = boardScene.boardPointLocal(overlayStone.x, overlayStone.y)
                if (last) {
                    ctx.fillStyle = "#e3342f"
                    ctx.beginPath()
                    ctx.moveTo(op.x - stoneRadius * 0.58, op.y - stoneRadius * 0.58)
                    ctx.lineTo(op.x - stoneRadius * 0.10, op.y - stoneRadius * 0.58)
                    ctx.lineTo(op.x - stoneRadius * 0.58, op.y - stoneRadius * 0.10)
                    ctx.closePath()
                    ctx.fill()
                }
                if (app.stoneNumberVisible(overlayStone.moveNumber, last)) {
                    drawCenteredText(ctx, String(overlayStone.moveNumber), op.x, op.y,
                                     app.stoneNumberColor(overlayStone.player, last),
                                     Math.max(10, Math.min(22, stoneRadius * 0.82)), true)
                }
            }

            if (app.koLocKey !== "" && app.stoneAt(app.koLocX, app.koLocY) === 0) {
                var kp = boardScene.boardPointLocal(app.koLocX, app.koLocY)
                ctx.strokeStyle = "#f01818"
                ctx.lineWidth = 3
                ctx.lineCap = "round"
                ctx.beginPath()
                ctx.moveTo(kp.x - 8, kp.y - 8)
                ctx.lineTo(kp.x + 8, kp.y + 8)
                ctx.moveTo(kp.x + 8, kp.y - 8)
                ctx.lineTo(kp.x - 8, kp.y + 8)
                ctx.stroke()
            }

            if (app.hoverKey !== "") {
                var hp = boardScene.boardPointLocal(app.hoverX, app.hoverY)
                ctx.fillStyle = app.selectedPointLegal() ? "#2fb97f" : "#e3342f"
                ctx.globalAlpha = app.selectedPointLocked ? 0.42 : 0.28
                ctx.beginPath()
                ctx.arc(hp.x, hp.y, Math.max(10, stoneRadius * 0.92), 0, Math.PI * 2)
                ctx.fill()
                ctx.globalAlpha = 1
                if (app.selectedPointLocked) {
                    ctx.strokeStyle = "#1d63c8"
                    ctx.lineWidth = 3
                    ctx.beginPath()
                    ctx.arc(hp.x, hp.y, Math.max(13, stoneRadius * 1.12), 0, Math.PI * 2)
                    ctx.stroke()
                }
            }
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        Connections {
            target: app
            function onBoardRevisionChanged() { boardCanvas.requestPaint() }
            function onBoardSizeXChanged() { boardCanvas.requestPaint() }
            function onBoardSizeYChanged() { boardCanvas.requestPaint() }
            function onHoverKeyChanged() { boardCanvas.requestPaint() }
            function onSelectedPointLockedChanged() { boardCanvas.requestPaint() }
            function onEngineCandidateItemsChanged() { boardCanvas.requestPaint() }
            function onBestCandidateRingVisibleChanged() { boardCanvas.requestPaint() }
            function onGomokuWinLineItemsChanged() { boardCanvas.requestPaint() }
            function onStoneScaleChanged() { boardCanvas.requestPaint() }
            function onGridOpacityChanged() { boardCanvas.requestPaint() }
            function onGridLineWidthChanged() { boardCanvas.requestPaint() }
            function onMoveNumberDisplayModeChanged() { boardCanvas.requestPaint() }
            function onBackgroundColorChanged() { boardCanvas.requestPaint() }
        }
    }
}
