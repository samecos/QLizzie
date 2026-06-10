import QtQuick
import "BoardRenderer.js" as BoardRenderer

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
    readonly property bool hexBoard: app.gameRuleMode === app.gameRuleHex
    readonly property bool squareCellBoard: app.gameRuleMode === app.gameRuleGomoku
                                            && app.boardPresentationMode === app.boardPresentationCells
    readonly property bool hexCellStyle: hexBoard && app.hexBoardStyle === app.hexBoardStyleCells
    readonly property bool hexTransposed: app.hexBoardRotation === app.hexRotationTranspose
                                          || app.hexBoardRotation === app.hexRotationFlipXTranspose
    readonly property bool hexFlippedX: app.hexBoardRotation === app.hexRotationFlipX
                                        || app.hexBoardRotation === app.hexRotationFlipXTranspose
    readonly property real hexRowHeightRatio: 0.8660254037844386
    readonly property real hexCellRadiusRatio: 0.5773502691896258
    readonly property real horizontalPointRadiusRatio: hexBoard
                                                   ? (hexCellStyle ? 0.5 : Math.max(stoneRadiusRatio, 0.5))
                                                   : stoneRadiusRatio
    readonly property real verticalPointRadiusRatio: hexBoard
                                                 ? (hexCellStyle ? hexCellRadiusRatio : Math.max(stoneRadiusRatio, 0.5))
                                                 : stoneRadiusRatio
    readonly property int hexDisplaySizeX: hexTransposed ? app.boardSizeY : app.boardSizeX
    readonly property int hexDisplaySizeY: hexTransposed ? app.boardSizeX : app.boardSizeY
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
                                                    ? horizontalPointRadiusRatio + coordinateGapRatio + yCoordinateTextWidthRatio + coordinateOuterGapRatio
                                                    : horizontalPointRadiusRatio + coordinateOuterGapRatio
    readonly property real verticalPaddingRatio: coordinatesVisible
                                                  ? verticalPointRadiusRatio + coordinateGapRatio + coordinateFontRatio + coordinateOuterGapRatio
                                                  : verticalPointRadiusRatio + coordinateOuterGapRatio
    readonly property real availableWidth: Math.max(1, width - boardOuterMargin * 2)
    readonly property real availableHeight: Math.max(1, height - boardOuterMargin * 2)
    readonly property real gridUnitWidth: hexBoard
                                           ? Math.max(1, Math.max(0, hexDisplaySizeX - 1)
                                                         + Math.max(0, hexDisplaySizeY - 1) * 0.5)
                                           : squareCellBoard ? Math.max(1, app.boardSizeX)
                                                             : Math.max(1, app.boardSizeX - 1)
    readonly property real gridUnitHeight: hexBoard
                                            ? Math.max(1, Math.max(0, hexDisplaySizeY - 1) * hexRowHeightRatio)
                                            : squareCellBoard ? Math.max(1, app.boardSizeY)
                                                              : Math.max(1, app.boardSizeY - 1)
    readonly property real cellSize: Math.max(0.1, Math.min(
        availableWidth / (gridUnitWidth + horizontalPaddingRatio * 2),
        availableHeight / (gridUnitHeight + verticalPaddingRatio * 2)))
    readonly property real boardPaddingX: horizontalPaddingRatio * cellSize
    readonly property real boardPaddingY: verticalPaddingRatio * cellSize
    readonly property real coordinateFontSize: coordinateFontRatio * cellSize
    readonly property real xCoordinateLabelOffset: (verticalPointRadiusRatio + coordinateGapRatio + coordinateFontRatio * 0.5) * cellSize
    readonly property real yCoordinateLabelOffset: (horizontalPointRadiusRatio + coordinateGapRatio + yCoordinateTextWidthRatio * 0.5) * cellSize
    readonly property real gridWidth: cellSize * gridUnitWidth
    readonly property real gridHeight: cellSize * gridUnitHeight
    readonly property real boardLeft: Math.round((width - gridWidth) / 2)
    readonly property real boardTop: Math.round((height - gridHeight) / 2)
    readonly property real boardRight: boardLeft + gridWidth
    readonly property real boardBottom: boardTop + gridHeight
    readonly property bool variationPreviewActive: app.activeCandidateVariationPreviewActive()

    function hexDisplayCoordForBoard(x, y) {
        return hexTransposed ? Qt.point(y, x) : Qt.point(x, y)
    }

    function boardCoordForHexDisplay(x, y) {
        return hexTransposed ? Qt.point(y, x) : Qt.point(x, y)
    }

    function hexDisplayPointLocal(x, y) {
        var unitX = x + y * 0.5
        if (hexFlippedX)
            unitX = gridUnitWidth - unitX
        return Qt.point(boardLeft + unitX * cellSize,
                        boardTop + y * hexRowHeightRatio * cellSize)
    }

    function boardPointLocal(x, y) {
        if (hexBoard) {
            var display = hexDisplayCoordForBoard(x, y)
            return hexDisplayPointLocal(display.x, display.y)
        }
        if (squareCellBoard)
            return Qt.point(boardLeft + (x + 0.5) * cellSize,
                            boardTop + (y + 0.5) * cellSize)
        return Qt.point(boardLeft + x * cellSize, boardTop + y * cellSize)
    }

    function pointFromMouse(mouseX, mouseY) {
        if (cellSize <= 0)
            return null

        if (squareCellBoard) {
            var cellX = Math.floor((mouseX - boardLeft) / cellSize)
            var cellY = Math.floor((mouseY - boardTop) / cellSize)
            if (!app.pointInBoard(cellX, cellY))
                return null
            return { "x": cellX, "y": cellY, "key": app.keyFor(cellX, cellY) }
        }

        var y
        var x
        if (hexBoard) {
            var displayY = Math.round((mouseY - boardTop) / (cellSize * hexRowHeightRatio))
            var displayUnitX = (mouseX - boardLeft) / cellSize
            if (hexFlippedX)
                displayUnitX = gridUnitWidth - displayUnitX
            var displayX = Math.round(displayUnitX - displayY * 0.5)
            var board = boardCoordForHexDisplay(displayX, displayY)
            x = board.x
            y = board.y
        } else {
            y = Math.round((mouseY - boardTop) / cellSize)
            x = Math.round((mouseX - boardLeft) / cellSize)
        }
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

    function rendererState() {
        return BoardRenderer.stateFromApp(app)
    }

    function rendererGeometry() {
        return BoardRenderer.geometryFromScene(boardScene)
    }

    Rectangle {
        x: boardScene.boardLeft - boardScene.boardPaddingX
        y: boardScene.boardTop - boardScene.boardPaddingY
        width: boardScene.gridWidth + boardScene.boardPaddingX * 2
        height: boardScene.gridHeight + boardScene.boardPaddingY * 2
        radius: 6
        color: boardScene.hexCellStyle ? "#f2cc62" : app.boardWoodColor
        border.color: boardScene.hexCellStyle ? "#0b3d73" : "#9d7442"
        border.width: 1
        opacity: 0.98
    }

    Canvas {
        id: boardCanvas
        anchors.fill: parent
        property var renderState: null
        property var renderGeometry: null

        function drawStone(ctx, x, y, player, radius) {
            var state = renderState || boardScene.rendererState()
            var geometry = renderGeometry || boardScene.rendererGeometry()
            BoardRenderer.drawStone(ctx, state, geometry, x, y, player, radius)
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

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var cell = boardScene.cellSize
            renderState = boardScene.rendererState()
            renderGeometry = boardScene.rendererGeometry()

            BoardRenderer.drawBoardBase(ctx, renderState, renderGeometry)

            var stoneRadius = Math.max(8, cell * app.stoneScale * 0.5)
            var candidateRadius = stoneRadius
            if (!boardScene.variationPreviewActive) {
                for (var c = app.engineCandidateItems.length - 1; c >= 0; --c) {
                    var candidate = app.engineCandidateItems[c]
                    if (app.stoneAt(candidate.x, candidate.y) !== 0)
                        continue
                    if (!candidate.boardVisible)
                        continue
                    var cp = boardScene.boardPointLocal(candidate.x, candidate.y)
                    var showCandidateText = candidate.qualified
                    var candidateLines = showCandidateText ? (candidate.labelLines || []) : []
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

            if (app.hexWinPathItems.length > 0) {
                ctx.strokeStyle = "#f01818"
                ctx.lineWidth = Math.max(4, cell * 0.09)
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                if (app.hexWinPathItems.length === 1) {
                    var single = app.hexWinPathItems[0]
                    var singlePoint = boardScene.boardPointLocal(single.x, single.y)
                    ctx.beginPath()
                    ctx.arc(singlePoint.x, singlePoint.y, Math.max(5, cell * 0.16), 0, Math.PI * 2)
                    ctx.stroke()
                } else {
                    ctx.beginPath()
                    for (var hp = 0; hp < app.hexWinPathItems.length; ++hp) {
                        var pathPoint = app.hexWinPathItems[hp]
                        var point = boardScene.boardPointLocal(pathPoint.x, pathPoint.y)
                        if (hp === 0)
                            ctx.moveTo(point.x, point.y)
                        else
                            ctx.lineTo(point.x, point.y)
                    }
                    ctx.stroke()
                }
            }

            if (!boardScene.variationPreviewActive) {
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
                        var moveNumberFontSize = app.stoneNumberFontSize(ctx, moveNumberText, stoneRadius)
                        drawCenteredText(ctx, moveNumberText, op.x, op.y + app.stoneNumberOffsetY(moveNumberFontSize),
                                         app.stoneNumberColor(overlayStone.player, last),
                                         moveNumberFontSize, true,
                                         app.stoneNumberMaxWidth(stoneRadius))
                    }
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

            renderState = null
            renderGeometry = null
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        Connections {
            target: app
            function onBoardRevisionChanged() { boardCanvas.requestPaint() }
            function onGameRuleModeChanged() { boardCanvas.requestPaint() }
            function onBoardPresentationModeChanged() { boardCanvas.requestPaint() }
            function onHexBoardStyleChanged() { boardCanvas.requestPaint() }
            function onHexBoardRotationChanged() { boardCanvas.requestPaint() }
            function onBoardSizeXChanged() { boardCanvas.requestPaint() }
            function onBoardSizeYChanged() { boardCanvas.requestPaint() }
            function onEngineCandidateItemsChanged() { boardCanvas.requestPaint() }
            function onBestCandidateRingVisibleChanged() { boardCanvas.requestPaint() }
            function onGomokuWinLineItemsChanged() { boardCanvas.requestPaint() }
            function onHexWinPathItemsChanged() { boardCanvas.requestPaint() }
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

    onVariationPreviewActiveChanged: boardCanvas.requestPaint()

    Canvas {
        id: variationPreviewCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var activeCandidate = app.activeCandidateForVariationPreview()
            var variation = app.activeCandidateVariationItems()
            if (!variation || variation.length <= 0)
                return

            var cell = boardScene.cellSize
            var stoneRadius = Math.max(8, cell * app.stoneScale * 0.5)
            var previewRadius = stoneRadius * 0.92

            for (var i = 0; i < variation.length; ++i) {
                var move = variation[i]
                var point = boardScene.boardPointLocal(move.x, move.y)
                var previewOpacity = Number(app.candidateVariationPreviewOpacity)
                if (isNaN(previewOpacity))
                    previewOpacity = app.defaultCandidateVariationPreviewOpacity
                ctx.save()
                ctx.globalAlpha = Math.max(0, Math.min(1, previewOpacity))
                boardCanvas.drawStone(ctx, move.x, move.y, move.player, previewRadius)
                ctx.restore()

                if (i === 0 && activeCandidate) {
                    ctx.save()
                    app.drawCandidateLabelLines(ctx,
                                                activeCandidate.labelLines || [],
                                                point.x,
                                                point.y,
                                                previewRadius,
                                                move.player === 1 ? "#ffffff" : "#000000")
                    ctx.restore()
                    continue
                }

                var text = String(move.moveNumber)
                var size = app.stoneNumberFontSize(ctx, text, previewRadius)
                boardCanvas.drawCenteredText(ctx,
                                             text,
                                             point.x,
                                             point.y + app.stoneNumberOffsetY(size),
                                             app.stoneNumberColor(move.player, false),
                                             size,
                                             true,
                                             app.stoneNumberMaxWidth(previewRadius))
            }
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        Connections {
            target: app
            function onCandidateVariationPreviewVisibleChanged() { variationPreviewCanvas.requestPaint() }
            function onCandidateVariationPreviewMaxMovesChanged() { variationPreviewCanvas.requestPaint() }
            function onCandidateVariationPreviewOpacityChanged() { variationPreviewCanvas.requestPaint() }
            function onHoverKeyChanged() { variationPreviewCanvas.requestPaint() }
            function onSelectedPointLockedChanged() { variationPreviewCanvas.requestPaint() }
            function onSelectedPointFromCandidateListChanged() { variationPreviewCanvas.requestPaint() }
            function onEngineCandidateItemsChanged() { variationPreviewCanvas.requestPaint() }
            function onBoardRevisionChanged() { variationPreviewCanvas.requestPaint() }
            function onGameRuleModeChanged() { variationPreviewCanvas.requestPaint() }
            function onBoardPresentationModeChanged() { variationPreviewCanvas.requestPaint() }
            function onHexBoardStyleChanged() { variationPreviewCanvas.requestPaint() }
            function onHexBoardRotationChanged() { variationPreviewCanvas.requestPaint() }
            function onBoardSizeXChanged() { variationPreviewCanvas.requestPaint() }
            function onBoardSizeYChanged() { variationPreviewCanvas.requestPaint() }
            function onStoneScaleChanged() { variationPreviewCanvas.requestPaint() }
            function onMoveNumberDisplayModeChanged() { variationPreviewCanvas.requestPaint() }
            function onMoveNumberLabelScaleChanged() { variationPreviewCanvas.requestPaint() }
        }
    }

    Canvas {
        id: hoverOverlayCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            if (app.hoverKey === "" || !app.pointIsEngineCandidateKey(app.hoverKey))
                return

            var candidate = app.engineCandidateItemMap[app.hoverKey]
            if (!candidate || app.stoneAt(candidate.x, candidate.y) !== 0)
                return

            var cell = boardScene.cellSize
            var stoneRadius = Math.max(8, cell * app.stoneScale * 0.5)
            var cp = boardScene.boardPointLocal(candidate.x, candidate.y)
            var isFirstCandidate = candidate.displayIndex === 1

            if (!boardScene.variationPreviewActive && (!candidate.qualified || !candidate.boardVisible)) {
                var markerOptions = {
                    "drawBackground": !candidate.boardVisible,
                    "fillColor": candidate.color || app.candidateMarkerColor(candidate.displayIndex,
                                                                              candidate.visitRatio),
                    "fillOpacity": candidate.opacity,
                    "drawOutline": !candidate.boardVisible && !isFirstCandidate,
                    "outlineOpacity": candidate.outlineOpacity,
                    "drawRing": false,
                    "textColor": isFirstCandidate ? app.candidateFirstLabelTextColor : "",
                    "rankText": !candidate.boardVisible ? app.candidateRankLabelText(candidate.displayIndex) : ""
                }
                if (!candidate.labelLines || candidate.labelLines.length <= 0) {
                    markerOptions.fallbackText = String(candidate.displayIndex)
                    markerOptions.fallbackColor = isFirstCandidate ? app.candidateFirstLabelTextColor : "#104f29"
                    markerOptions.fallbackFontSize = Math.max(10, Math.min(16, cell * 0.20))
                }
                app.drawCandidateMarker(ctx, cp.x, cp.y, stoneRadius, candidate.labelLines || [], markerOptions)
            }

            ctx.save()
            ctx.globalAlpha = 1
            ctx.strokeStyle = "#ff1010"
            ctx.lineWidth = app.candidateRingLineWidthForRadius(stoneRadius)
            ctx.beginPath()
            ctx.arc(cp.x, cp.y, app.candidateRingRadius(stoneRadius), 0, Math.PI * 2)
            ctx.stroke()
            ctx.restore()
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        Connections {
            target: app
            function onHoverKeyChanged() { hoverOverlayCanvas.requestPaint() }
            function onSelectedPointLockedChanged() { hoverOverlayCanvas.requestPaint() }
            function onSelectedPointFromCandidateListChanged() { hoverOverlayCanvas.requestPaint() }
            function onEngineCandidateItemsChanged() { hoverOverlayCanvas.requestPaint() }
            function onBoardRevisionChanged() { hoverOverlayCanvas.requestPaint() }
            function onGameRuleModeChanged() { hoverOverlayCanvas.requestPaint() }
            function onBoardPresentationModeChanged() { hoverOverlayCanvas.requestPaint() }
            function onHexBoardStyleChanged() { hoverOverlayCanvas.requestPaint() }
            function onHexBoardRotationChanged() { hoverOverlayCanvas.requestPaint() }
            function onBoardSizeXChanged() { hoverOverlayCanvas.requestPaint() }
            function onBoardSizeYChanged() { hoverOverlayCanvas.requestPaint() }
            function onStoneScaleChanged() { hoverOverlayCanvas.requestPaint() }
            function onCandidateWinrateOffsetYChanged() { hoverOverlayCanvas.requestPaint() }
            function onCandidateVisitsOffsetYChanged() { hoverOverlayCanvas.requestPaint() }
            function onCandidateScoreOffsetYChanged() { hoverOverlayCanvas.requestPaint() }
            function onCandidateRingLineWidthChanged() { hoverOverlayCanvas.requestPaint() }
            function onCandidateRankLabelVisibleChanged() { hoverOverlayCanvas.requestPaint() }
        }
    }
}
