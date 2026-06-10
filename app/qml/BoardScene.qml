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
    readonly property real horizontalPointRadiusRatio: hexCellStyle ? 0.5 : stoneRadiusRatio
    readonly property real verticalPointRadiusRatio: hexCellStyle ? hexCellRadiusRatio : stoneRadiusRatio
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

        function hexCellPath(ctx, cx, cy, radius) {
            ctx.beginPath()
            for (var i = 0; i < 6; ++i) {
                var angle = -Math.PI / 2 + i * Math.PI / 3
                var px = cx + Math.cos(angle) * radius
                var py = cy + Math.sin(angle) * radius
                if (i === 0)
                    ctx.moveTo(px, py)
                else
                    ctx.lineTo(px, py)
            }
            ctx.closePath()
        }

        function hexCellVertex(center, radius, index) {
            var angle = -Math.PI / 2 + index * Math.PI / 3
            return Qt.point(center.x + Math.cos(angle) * radius,
                            center.y + Math.sin(angle) * radius)
        }

        function drawHexBoundarySegment(ctx, p1, p2, color, cell) {
            ctx.save()
            ctx.globalAlpha = 1
            ctx.lineCap = "round"
            ctx.lineJoin = "round"
            if (color === "#ffffff") {
                ctx.strokeStyle = "#0b3d73"
                ctx.lineWidth = Math.max(4, cell * 0.16)
                ctx.beginPath()
                ctx.moveTo(p1.x, p1.y)
                ctx.lineTo(p2.x, p2.y)
                ctx.stroke()
            }
            ctx.strokeStyle = color
            ctx.lineWidth = Math.max(3, cell * 0.10)
            ctx.beginPath()
            ctx.moveTo(p1.x, p1.y)
            ctx.lineTo(p2.x, p2.y)
            ctx.stroke()
            ctx.restore()
        }

        function drawHexCellBoundarySide(ctx, x, y, side, color, cell) {
            var center = boardScene.boardPointLocal(x, y)
            var radius = cell / Math.sqrt(3)
            var p1 = hexCellVertex(center, radius, side)
            var p2 = hexCellVertex(center, radius, (side + 1) % 6)
            drawHexBoundarySegment(ctx, p1, p2, color, cell)
        }

        function hexCellBoardVertex(x, y, index, cell) {
            var center = boardScene.boardPointLocal(x, y)
            return hexCellVertex(center, cell / Math.sqrt(3), index)
        }

        function drawHexBoundaryPath(ctx, points, color, cell) {
            if (!points || points.length < 2)
                return
            ctx.save()
            ctx.globalAlpha = 1
            ctx.lineCap = "round"
            ctx.lineJoin = "round"
            if (color === "#ffffff") {
                ctx.strokeStyle = "#0b3d73"
                ctx.lineWidth = Math.max(4, cell * 0.16)
                ctx.beginPath()
                ctx.moveTo(points[0].x, points[0].y)
                for (var back = 1; back < points.length; ++back)
                    ctx.lineTo(points[back].x, points[back].y)
                ctx.stroke()
            }
            ctx.strokeStyle = color
            ctx.lineWidth = Math.max(3, cell * 0.10)
            ctx.beginPath()
            ctx.moveTo(points[0].x, points[0].y)
            for (var i = 1; i < points.length; ++i)
                ctx.lineTo(points[i].x, points[i].y)
            ctx.stroke()
            ctx.restore()
        }

        function drawHexCellColoredEdges(ctx, cell) {
            var topPoints = []
            var bottomPoints = []
            for (var lx = 0; lx < app.boardSizeX; ++lx) {
                if (lx === 0)
                    topPoints.push(hexCellBoardVertex(lx, 0, 5, cell))
                topPoints.push(hexCellBoardVertex(lx, 0, 0, cell))
                topPoints.push(hexCellBoardVertex(lx, 0, 1, cell))

                if (lx === 0)
                    bottomPoints.push(hexCellBoardVertex(lx, app.boardSizeY - 1, 4, cell))
                bottomPoints.push(hexCellBoardVertex(lx, app.boardSizeY - 1, 3, cell))
                bottomPoints.push(hexCellBoardVertex(lx, app.boardSizeY - 1, 2, cell))
            }

            var leftPoints = []
            var rightPoints = []
            for (var ly = 0; ly < app.boardSizeY; ++ly) {
                if (ly === 0)
                    leftPoints.push(hexCellBoardVertex(0, ly, 5, cell))
                leftPoints.push(hexCellBoardVertex(0, ly, 4, cell))
                leftPoints.push(hexCellBoardVertex(0, ly, 3, cell))

                if (ly === 0)
                    rightPoints.push(hexCellBoardVertex(app.boardSizeX - 1, ly, 0, cell))
                rightPoints.push(hexCellBoardVertex(app.boardSizeX - 1, ly, 1, cell))
                rightPoints.push(hexCellBoardVertex(app.boardSizeX - 1, ly, 2, cell))
            }

            drawHexBoundaryPath(ctx, topPoints, "#000000", cell)
            drawHexBoundaryPath(ctx, bottomPoints, "#000000", cell)
            drawHexBoundaryPath(ctx, leftPoints, "#ffffff", cell)
            drawHexBoundaryPath(ctx, rightPoints, "#ffffff", cell)
        }

        function drawStone(ctx, x, y, player, radius) {
            var point = boardScene.boardPointLocal(x, y)
            if (boardScene.hexCellStyle) {
                ctx.save()
                hexCellPath(ctx, point.x, point.y, boardScene.cellSize / Math.sqrt(3))
                ctx.fillStyle = player === 1 ? "#101418" : "#ffffff"
                ctx.fill()
                ctx.strokeStyle = "#0b3d73"
                ctx.lineWidth = Math.max(1, boardScene.cellSize * 0.035)
                ctx.stroke()
                ctx.restore()
                return
            }
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

        function starPoints(size) {
            if (size >= 19)
                return [3, Math.floor(size / 2), size - 4]
            if (size >= 13)
                return [3, size - 4]
            if (size >= 9)
                return [2, Math.floor(size / 2), size - 3]
            return []
        }

        function drawHexEdge(ctx, p1, p2, color, cell) {
            ctx.save()
            ctx.globalAlpha = 1
            ctx.lineCap = "round"
            if (color === "#ffffff") {
                ctx.strokeStyle = "#0b3d73"
                ctx.lineWidth = Math.max(4, cell * 0.16)
                ctx.beginPath()
                ctx.moveTo(p1.x, p1.y)
                ctx.lineTo(p2.x, p2.y)
                ctx.stroke()
            }
            ctx.strokeStyle = color
            ctx.lineWidth = Math.max(3, cell * 0.10)
            ctx.beginPath()
            ctx.moveTo(p1.x, p1.y)
            ctx.lineTo(p2.x, p2.y)
            ctx.stroke()
            ctx.restore()
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
            if (boardScene.hexBoard) {
                if (boardScene.hexCellStyle) {
                    ctx.save()
                    ctx.globalAlpha = 1
                    ctx.strokeStyle = "#0b3d73"
                    ctx.lineWidth = Math.max(1, app.gridLineWidth)
                    for (var cellY = 0; cellY < app.boardSizeY; ++cellY) {
                        for (var cellX = 0; cellX < app.boardSizeX; ++cellX) {
                            var center = boardScene.boardPointLocal(cellX, cellY)
                            hexCellPath(ctx, center.x, center.y, cell / Math.sqrt(3))
                            ctx.fillStyle = "#f2cc62"
                            ctx.fill()
                            ctx.stroke()
                        }
                    }
                    ctx.restore()
                } else {
                    for (var hy = 0; hy < boardScene.hexDisplaySizeY; ++hy) {
                        var hStart = boardScene.hexDisplayPointLocal(0, hy)
                        var hEnd = boardScene.hexDisplayPointLocal(boardScene.hexDisplaySizeX - 1, hy)
                        ctx.beginPath()
                        ctx.moveTo(hStart.x, hStart.y)
                        ctx.lineTo(hEnd.x, hEnd.y)
                        ctx.stroke()
                    }
                    for (var sy = 0; sy < boardScene.hexDisplaySizeY - 1; ++sy) {
                        for (var sx = 0; sx < boardScene.hexDisplaySizeX; ++sx) {
                            var downRightStart = boardScene.hexDisplayPointLocal(sx, sy)
                            var downRightEnd = boardScene.hexDisplayPointLocal(sx, sy + 1)
                            ctx.beginPath()
                            ctx.moveTo(downRightStart.x, downRightStart.y)
                            ctx.lineTo(downRightEnd.x, downRightEnd.y)
                            ctx.stroke()
                        }
                        for (var dx = 0; dx < boardScene.hexDisplaySizeX - 1; ++dx) {
                            var downLeftStart = boardScene.hexDisplayPointLocal(dx + 1, sy)
                            var downLeftEnd = boardScene.hexDisplayPointLocal(dx, sy + 1)
                            ctx.beginPath()
                            ctx.moveTo(downLeftStart.x, downLeftStart.y)
                            ctx.lineTo(downLeftEnd.x, downLeftEnd.y)
                            ctx.stroke()
                        }
                    }
                }
                if (boardScene.hexCellStyle) {
                    drawHexCellColoredEdges(ctx, cell)
                } else {
                    var blackTop1 = boardScene.boardPointLocal(0, 0)
                    var blackTop2 = boardScene.boardPointLocal(app.boardSizeX - 1, 0)
                    var blackBottom1 = boardScene.boardPointLocal(0, app.boardSizeY - 1)
                    var blackBottom2 = boardScene.boardPointLocal(app.boardSizeX - 1, app.boardSizeY - 1)
                    var whiteLeft1 = boardScene.boardPointLocal(0, 0)
                    var whiteLeft2 = boardScene.boardPointLocal(0, app.boardSizeY - 1)
                    var whiteRight1 = boardScene.boardPointLocal(app.boardSizeX - 1, 0)
                    var whiteRight2 = boardScene.boardPointLocal(app.boardSizeX - 1, app.boardSizeY - 1)
                    drawHexEdge(ctx, blackTop1, blackTop2, "#000000", cell)
                    drawHexEdge(ctx, blackBottom1, blackBottom2, "#000000", cell)
                    drawHexEdge(ctx, whiteLeft1, whiteLeft2, "#ffffff", cell)
                    drawHexEdge(ctx, whiteRight1, whiteRight2, "#ffffff", cell)
                }
            } else {
                var xLineCount = boardScene.squareCellBoard ? app.boardSizeX + 1 : app.boardSizeX
                var yLineCount = boardScene.squareCellBoard ? app.boardSizeY + 1 : app.boardSizeY
                for (var x = 0; x < xLineCount; ++x) {
                    var px = left + x * cell
                    ctx.beginPath()
                    ctx.moveTo(px, top)
                    ctx.lineTo(px, bottom)
                    ctx.stroke()
                }
                for (var y = 0; y < yLineCount; ++y) {
                    var py = top + y * cell
                    ctx.beginPath()
                    ctx.moveTo(left, py)
                    ctx.lineTo(right, py)
                    ctx.stroke()
                }
            }
            ctx.restore()

            var xs = starPoints(app.boardSizeX)
            var ys = starPoints(app.boardSizeY)
            ctx.fillStyle = "#2d2114"
            if (app.gameRuleMode === app.gameRuleGo) {
                for (var starX = 0; starX < xs.length; ++starX) {
                    for (var starY = 0; starY < ys.length; ++starY) {
                        var star = boardScene.boardPointLocal(xs[starX], ys[starY])
                        ctx.beginPath()
                        ctx.arc(star.x, star.y, Math.max(2.8, cell * 0.065), 0, Math.PI * 2)
                        ctx.fill()
                    }
                }
            }

            if (boardScene.coordinatesVisible) {
                ctx.save()
                ctx.font = canvasFont(boardScene.coordinateFontSize, false)
                ctx.fillStyle = "#4f371f"
                ctx.textAlign = "center"
                ctx.textBaseline = "middle"
                for (var lx = 0; lx < app.boardSizeX; ++lx) {
                    var topPoint = boardScene.boardPointLocal(lx, 0)
                    var bottomPoint = boardScene.boardPointLocal(lx, app.boardSizeY - 1)
                    var xLabel = app.xCoordinateText(lx)
                    ctx.fillText(xLabel, topPoint.x, topPoint.y - boardScene.xCoordinateLabelOffset, cell * 0.96)
                    ctx.fillText(xLabel, bottomPoint.x, bottomPoint.y + boardScene.xCoordinateLabelOffset, cell * 0.96)
                }
                ctx.textAlign = "center"
                for (var ly = 0; ly < app.boardSizeY; ++ly) {
                    var leftPoint = boardScene.boardPointLocal(0, ly)
                    var rightPoint = boardScene.boardPointLocal(app.boardSizeX - 1, ly)
                    var yLabel = app.yCoordinateText(ly)
                    var yLabelMaxWidth = Math.max(1, boardScene.boardPaddingX
                                                     - cell * (boardScene.stoneRadiusRatio + boardScene.coordinateGapRatio))
                    ctx.fillText(yLabel, leftPoint.x - boardScene.yCoordinateLabelOffset, leftPoint.y, yLabelMaxWidth)
                    ctx.fillText(yLabel, rightPoint.x + boardScene.yCoordinateLabelOffset, rightPoint.y, yLabelMaxWidth)
                }
                ctx.restore()
            }

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
