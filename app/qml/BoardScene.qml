import QtQuick

Item {
    id: boardScene
    required property var app

    x: app.boardStageLeftReserve
    y: app.analysisToolbarHeight
    width: parent.width - app.boardStageLeftReserve - app.boardStageRightReserve
    height: parent.height - app.analysisToolbarHeight - app.commandToolbarHeight - app.panelGap

    readonly property bool coordinatesVisible: app.effectiveCoordinateDisplayMode() !== app.coordinateDisplayNone
    readonly property real boardOuterMargin: app.compactLayout ? 12 : 18
    readonly property real coordinateFontRatio: 0.32
    readonly property real coordinateCharWidthRatio: 0.58
    readonly property real coordinateGapRatio: 0.10
    readonly property real coordinateOuterGapRatio: 0.10
    readonly property real stoneRadiusRatio: app.stoneScale * 0.5
    readonly property int maxXCoordinateChars: coordinatesVisible
                                                ? Math.max(String(app.xCoordinateText(0)).length,
                                                           String(app.xCoordinateText(Math.max(0, app.boardSizeX - 1))).length)
                                                : 0
    readonly property int maxYCoordinateChars: coordinatesVisible
                                                ? Math.max(String(app.yCoordinateText(0)).length,
                                                           String(app.yCoordinateText(Math.max(0, app.boardSizeY - 1))).length)
                                                : 0
    readonly property real xCoordinateTextWidthRatio: maxXCoordinateChars * coordinateCharWidthRatio * coordinateFontRatio
    readonly property real yCoordinateTextWidthRatio: maxYCoordinateChars * coordinateCharWidthRatio * coordinateFontRatio
    readonly property real horizontalPaddingRatio: coordinatesVisible
                                                    ? stoneRadiusRatio + coordinateGapRatio + yCoordinateTextWidthRatio + coordinateOuterGapRatio
                                                    : stoneRadiusRatio + coordinateOuterGapRatio
    readonly property real verticalPaddingRatio: coordinatesVisible
                                                  ? stoneRadiusRatio + coordinateGapRatio + coordinateFontRatio + coordinateOuterGapRatio
                                                  : stoneRadiusRatio + coordinateOuterGapRatio
    readonly property real availableWidth: Math.max(1, width - boardOuterMargin * 2)
    readonly property real availableHeight: Math.max(1, height - boardOuterMargin * 2)
    readonly property real cellSize: Math.max(0.1, Math.min(
        availableWidth / (Math.max(1, app.boardSizeX - 1) + horizontalPaddingRatio * 2),
        availableHeight / (Math.max(1, app.boardSizeY - 1) + verticalPaddingRatio * 2)))
    readonly property real boardPaddingX: horizontalPaddingRatio * cellSize
    readonly property real boardPaddingY: verticalPaddingRatio * cellSize
    readonly property real coordinateFontSize: coordinateFontRatio * cellSize
    readonly property real xCoordinateLabelOffset: (stoneRadiusRatio + coordinateGapRatio + coordinateFontRatio * 0.5) * cellSize
    readonly property real yCoordinateLabelOffset: (stoneRadiusRatio + coordinateGapRatio + yCoordinateTextWidthRatio * 0.5) * cellSize
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
        x: boardScene.boardLeft - boardScene.boardPaddingX
        y: boardScene.boardTop - boardScene.boardPaddingY
        width: boardScene.gridWidth + boardScene.boardPaddingX * 2
        height: boardScene.gridHeight + boardScene.boardPaddingY * 2
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

        function canvasFont(size, bold) {
            var family = String(app.coordinateFontFamily).replace(/"/g, "")
            return (bold ? "700 " : "400 ") + Math.max(1, Math.round(size)) + "px \"" + family + "\", sans-serif"
        }

        function drawCenteredText(ctx, text, x, y, color, size, bold, maxWidth) {
            ctx.save()
            ctx.fillStyle = color
            ctx.font = canvasFont(size, bold)
            ctx.textAlign = "center"
            ctx.textBaseline = "middle"
            if (maxWidth !== undefined)
                ctx.fillText(text, x, y, maxWidth)
            else
                ctx.fillText(text, x, y)
            ctx.restore()
        }

        function fittedStoneNumberFontSize(ctx, text, radius) {
            var digits = Math.max(1, String(text).length)
            var digitFactor = digits <= 1 ? 1.18
                            : digits === 2 ? 1.02
                            : digits === 3 ? 0.86
                            : Math.max(0.58, 0.86 - (digits - 3) * 0.12)
            var maxWidth = radius * 1.78
            var maxHeight = radius * 1.42
            var targetSize = radius * digitFactor * app.moveNumberLabelScale
            ctx.save()
            ctx.font = canvasFont(targetSize, true)
            var measuredWidth = Math.max(1, ctx.measureText(String(text)).width)
            ctx.restore()
            if (measuredWidth > maxWidth)
                targetSize *= maxWidth / measuredWidth
            return Math.max(8, Math.min(targetSize, maxHeight))
        }

        function stoneNumberMaxWidth(radius) {
            return radius * 1.86
        }

        function stoneNumberOffsetY(fontSize) {
            return Math.max(1, fontSize * 0.08)
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

            if (boardScene.coordinatesVisible) {
                ctx.save()
                ctx.font = canvasFont(boardScene.coordinateFontSize, false)
                ctx.fillStyle = "#4f371f"
                ctx.textAlign = "center"
                ctx.textBaseline = "middle"
                for (var lx = 0; lx < app.boardSizeX; ++lx) {
                    var labelX = left + lx * cell
                    var xLabel = app.xCoordinateText(lx)
                    ctx.fillText(xLabel, labelX, top - boardScene.xCoordinateLabelOffset, cell * 0.96)
                    ctx.fillText(xLabel, labelX, bottom + boardScene.xCoordinateLabelOffset, cell * 0.96)
                }
                ctx.textAlign = "center"
                for (var ly = 0; ly < app.boardSizeY; ++ly) {
                    var labelY = top + ly * cell
                    var yLabel = app.yCoordinateText(ly)
                    var yLabelMaxWidth = Math.max(1, boardScene.boardPaddingX
                                                     - cell * (boardScene.stoneRadiusRatio + boardScene.coordinateGapRatio))
                    ctx.fillText(yLabel, left - boardScene.yCoordinateLabelOffset, labelY, yLabelMaxWidth)
                    ctx.fillText(yLabel, right + boardScene.yCoordinateLabelOffset, labelY, yLabelMaxWidth)
                }
                ctx.restore()
            }

            var stoneRadius = Math.max(8, cell * app.stoneScale * 0.5)
            var candidateRadius = stoneRadius
            for (var c = app.engineCandidateItems.length - 1; c >= 0; --c) {
                var candidate = app.engineCandidateItems[c]
                if (app.stoneAt(candidate.x, candidate.y) !== 0)
                    continue
                var highlightedCandidate = app.hoverKey === candidate.key
                if (!candidate.boardVisible && !highlightedCandidate)
                    continue
                var cp = boardScene.boardPointLocal(candidate.x, candidate.y)
                var showCandidateText = candidate.qualified || highlightedCandidate
                var candidateLines = showCandidateText ? app.candidateLabelLines(candidate) : []
                var isFirstCandidate = candidate.displayIndex === 1
                var isBestCandidate = app.bestCandidateRingVisible
                                      && app.candidateRingVisible
                                      && candidate.key === app.bestCandidateRingKey
                var markerOptions = {
                    "fillColor": candidate.color || app.candidateMarkerColor(candidate.displayIndex,
                                                                              candidate.visitRatio),
                    "fillOpacity": candidate.opacity,
                    "drawOutline": !isFirstCandidate,
                    "outlineOpacity": candidate.outlineOpacity,
                    "drawRing": isBestCandidate,
                    "ringColor": app.firstCandidateRingColor,
                    "textColor": isFirstCandidate ? app.candidateFirstLabelTextColor : "",
                    "rankText": app.candidateRankLabelText(candidate.displayIndex)
                }
                if (showCandidateText) {
                    markerOptions.fallbackText = String(candidate.displayIndex)
                    markerOptions.fallbackColor = isFirstCandidate ? app.candidateFirstLabelTextColor : "#104f29"
                    markerOptions.fallbackFontSize = Math.max(10, Math.min(16, cell * 0.20))
                }
                app.drawCandidateMarker(ctx, cp.x, cp.y, candidateRadius, candidateLines, markerOptions)
            }

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
                    var markerSize = stoneRadius * 0.62
                    var markerCornerX = op.x - stoneRadius
                    var markerCornerY = op.y - stoneRadius
                    ctx.fillStyle = "#e3342f"
                    ctx.beginPath()
                    ctx.moveTo(markerCornerX, markerCornerY)
                    ctx.lineTo(markerCornerX + markerSize, markerCornerY)
                    ctx.lineTo(markerCornerX, markerCornerY + markerSize)
                    ctx.closePath()
                    ctx.fill()
                }
                if (app.stoneNumberVisible(overlayStone.moveNumber, last)) {
                    var moveNumberText = String(overlayStone.moveNumber)
                    var moveNumberFontSize = fittedStoneNumberFontSize(ctx, moveNumberText, stoneRadius)
                    drawCenteredText(ctx, moveNumberText, op.x, op.y + stoneNumberOffsetY(moveNumberFontSize),
                                     app.stoneNumberColor(overlayStone.player, last),
                                     moveNumberFontSize, true,
                                     stoneNumberMaxWidth(stoneRadius))
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

            if (app.hoverKey !== "" && app.pointIsEngineCandidateKey(app.hoverKey)) {
                var hp = boardScene.boardPointLocal(app.hoverX, app.hoverY)
                ctx.save()
                ctx.globalAlpha = 1
                ctx.strokeStyle = "#ff1010"
                ctx.lineWidth = app.candidateRingLineWidthForRadius(stoneRadius)
                ctx.beginPath()
                ctx.arc(hp.x, hp.y, app.candidateRingRadius(stoneRadius), 0, Math.PI * 2)
                ctx.stroke()
                ctx.restore()
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
            function onSelectedPointFromCandidateListChanged() { boardCanvas.requestPaint() }
            function onEngineCandidateItemsChanged() { boardCanvas.requestPaint() }
            function onBestCandidateRingVisibleChanged() { boardCanvas.requestPaint() }
            function onGomokuWinLineItemsChanged() { boardCanvas.requestPaint() }
            function onStoneScaleChanged() { boardCanvas.requestPaint() }
            function onGridOpacityChanged() { boardCanvas.requestPaint() }
            function onGridLineWidthChanged() { boardCanvas.requestPaint() }
            function onSelectedPointScaleChanged() { boardCanvas.requestPaint() }
            function onMoveNumberLabelScaleChanged() { boardCanvas.requestPaint() }
            function onMoveNumberDisplayModeChanged() { boardCanvas.requestPaint() }
            function onCoordinateDisplayModeChanged() { boardCanvas.requestPaint() }
            function onBackgroundColorChanged() { boardCanvas.requestPaint() }
            function onCandidateWinrateLabelVisibleChanged() { boardCanvas.requestPaint() }
            function onCandidateVisitsLabelVisibleChanged() { boardCanvas.requestPaint() }
            function onCandidateScoreLabelVisibleChanged() { boardCanvas.requestPaint() }
            function onCandidateWinrateFontSizeChanged() { boardCanvas.requestPaint() }
            function onCandidateVisitsFontSizeChanged() { boardCanvas.requestPaint() }
            function onCandidateScoreFontSizeChanged() { boardCanvas.requestPaint() }
            function onCandidateWinrateBoldChanged() { boardCanvas.requestPaint() }
            function onCandidateVisitsBoldChanged() { boardCanvas.requestPaint() }
            function onCandidateScoreBoldChanged() { boardCanvas.requestPaint() }
            function onCandidateWinrateOffsetYChanged() { boardCanvas.requestPaint() }
            function onCandidateVisitsOffsetYChanged() { boardCanvas.requestPaint() }
            function onCandidateScoreOffsetYChanged() { boardCanvas.requestPaint() }
            function onCandidateWinrateDecimalsChanged() { boardCanvas.requestPaint() }
            function onCandidateScoreDecimalsChanged() { boardCanvas.requestPaint() }
            function onCandidateWinrateShowPercentChanged() { boardCanvas.requestPaint() }
            function onCandidateScoreShowPercentChanged() { boardCanvas.requestPaint() }
            function onCandidateScoreTitleModeChanged() { boardCanvas.requestPaint() }
            function onCandidateRingVisibleChanged() { boardCanvas.requestPaint() }
            function onCandidateRingLineWidthChanged() { boardCanvas.requestPaint() }
            function onCandidateRankLabelVisibleChanged() { boardCanvas.requestPaint() }
            function onCandidateFirstLabelTextColorChanged() { boardCanvas.requestPaint() }
            function onCandidateLabelTextColorChanged() { boardCanvas.requestPaint() }
        }
    }
}
