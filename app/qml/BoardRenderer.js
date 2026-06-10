.pragma library
.import "CoordinateUtils.js" as CoordinateUtils

var HEX_ROW_HEIGHT = 0.8660254037844386
var HEX_CELL_RADIUS_RATIO = 0.5773502691896258

function stateFromApp(app, overrides) {
    var state = {
        "boardSizeX": app.boardSizeX,
        "boardSizeY": app.boardSizeY,
        "gameRuleMode": app.gameRuleMode,
        "gameRuleGo": app.gameRuleGo,
        "gameRuleGomoku": app.gameRuleGomoku,
        "gameRuleHex": app.gameRuleHex,
        "boardPresentationMode": app.boardPresentationMode,
        "boardPresentationCells": app.boardPresentationCells,
        "hexBoardStyle": app.hexBoardStyle,
        "hexBoardStyleCells": app.hexBoardStyleCells,
        "hexBoardRotation": app.hexBoardRotation,
        "hexRotationTranspose": app.hexRotationTranspose,
        "hexRotationFlipX": app.hexRotationFlipX,
        "hexRotationFlipXTranspose": app.hexRotationFlipXTranspose,
        "coordinateDisplayMode": app.coordinateDisplayMode,
        "coordinateDisplayNone": app.coordinateDisplayNone,
        "stoneScale": app.stoneScale,
        "gridOpacity": app.gridOpacity,
        "gridLineWidth": app.gridLineWidth,
        "boardWoodColor": app.boardWoodColor,
        "coordinateFontFamily": app.coordinateFontFamily,
        "compactLayout": app.compactLayout
    }
    for (var key in overrides || ({}))
        state[key] = overrides[key]
    return state
}

function hexBoard(state) {
    return state.gameRuleMode === state.gameRuleHex
}

function squareCellBoard(state) {
    return state.gameRuleMode === state.gameRuleGomoku
           && state.boardPresentationMode === state.boardPresentationCells
}

function hexCellStyle(state) {
    return hexBoard(state) && state.hexBoardStyle === state.hexBoardStyleCells
}

function hexTransposed(state) {
    return state.hexBoardRotation === state.hexRotationTranspose
           || state.hexBoardRotation === state.hexRotationFlipXTranspose
}

function hexFlippedX(state) {
    return state.hexBoardRotation === state.hexRotationFlipX
           || state.hexBoardRotation === state.hexRotationFlipXTranspose
}

function hexDisplaySizeX(state) {
    return hexTransposed(state) ? state.boardSizeY : state.boardSizeX
}

function hexDisplaySizeY(state) {
    return hexTransposed(state) ? state.boardSizeX : state.boardSizeY
}

function effectiveCoordinateDisplayMode(state) {
    return CoordinateUtils.effectiveCoordinateFormat(state.boardSizeX,
                                                     state.boardSizeY,
                                                     state.coordinateDisplayMode)
}

function coordinatesVisible(state) {
    return effectiveCoordinateDisplayMode(state) !== state.coordinateDisplayNone
}

function xCoordinateText(state, x) {
    return CoordinateUtils.xCoordinateText(x, state.boardSizeX, state.boardSizeY, state.coordinateDisplayMode)
}

function yCoordinateText(state, y) {
    return CoordinateUtils.yCoordinateText(y, state.boardSizeX, state.boardSizeY, state.coordinateDisplayMode)
}

function gridUnitWidth(state) {
    if (hexBoard(state))
        return Math.max(1, Math.max(0, hexDisplaySizeX(state) - 1)
                           + Math.max(0, hexDisplaySizeY(state) - 1) * 0.5)
    return squareCellBoard(state) ? Math.max(1, state.boardSizeX)
                                  : Math.max(1, state.boardSizeX - 1)
}

function gridUnitHeight(state) {
    if (hexBoard(state))
        return Math.max(1, Math.max(0, hexDisplaySizeY(state) - 1) * HEX_ROW_HEIGHT)
    return squareCellBoard(state) ? Math.max(1, state.boardSizeY)
                                  : Math.max(1, state.boardSizeY - 1)
}

function createGeometry(state, width, height, options) {
    var visible = coordinatesVisible(state)
    var coordinateFontRatio = 0.32
    var coordinateCharWidthRatio = 0.58
    var coordinateGapRatio = 0.10
    var coordinateOuterGapRatio = 0.10
    var stoneRadiusRatio = state.stoneScale * 0.5
    var horizontalPointRadiusRatio = hexBoard(state)
            ? (hexCellStyle(state) ? 0.5 : Math.max(stoneRadiusRatio, 0.5))
            : stoneRadiusRatio
    var verticalPointRadiusRatio = hexBoard(state)
            ? (hexCellStyle(state) ? HEX_CELL_RADIUS_RATIO : Math.max(stoneRadiusRatio, 0.5))
            : stoneRadiusRatio
    var maxXCoordinateChars = visible
            ? Math.max(String(xCoordinateText(state, 0)).length,
                       String(xCoordinateText(state, Math.max(0, state.boardSizeX - 1))).length)
            : 0
    var maxYCoordinateChars = visible
            ? Math.max(String(yCoordinateText(state, 0)).length,
                       String(yCoordinateText(state, Math.max(0, state.boardSizeY - 1))).length)
            : 0
    var xCoordinateTextWidthRatio = maxXCoordinateChars * coordinateCharWidthRatio * coordinateFontRatio
    var yCoordinateTextWidthRatio = maxYCoordinateChars * coordinateCharWidthRatio * coordinateFontRatio
    var horizontalPaddingRatio = visible
            ? horizontalPointRadiusRatio + coordinateGapRatio + yCoordinateTextWidthRatio + coordinateOuterGapRatio
            : horizontalPointRadiusRatio + coordinateOuterGapRatio
    var verticalPaddingRatio = visible
            ? verticalPointRadiusRatio + coordinateGapRatio + coordinateFontRatio + coordinateOuterGapRatio
            : verticalPointRadiusRatio + coordinateOuterGapRatio
    var outerMargin = options && options.outerMargin !== undefined ? options.outerMargin : (state.compactLayout ? 12 : 18)
    var availableWidth = Math.max(1, width - outerMargin * 2)
    var availableHeight = Math.max(1, height - outerMargin * 2)
    var unitWidth = gridUnitWidth(state)
    var unitHeight = gridUnitHeight(state)
    var cellSize = Math.max(0.1, Math.min(
        availableWidth / (unitWidth + horizontalPaddingRatio * 2),
        availableHeight / (unitHeight + verticalPaddingRatio * 2)))
    var gridWidth = cellSize * unitWidth
    var gridHeight = cellSize * unitHeight
    var geometry = {
        "width": width,
        "height": height,
        "coordinatesVisible": visible,
        "coordinateFontSize": coordinateFontRatio * cellSize,
        "xCoordinateLabelOffset": (verticalPointRadiusRatio + coordinateGapRatio + coordinateFontRatio * 0.5) * cellSize,
        "yCoordinateLabelOffset": (horizontalPointRadiusRatio + coordinateGapRatio + yCoordinateTextWidthRatio * 0.5) * cellSize,
        "boardPaddingX": horizontalPaddingRatio * cellSize,
        "boardPaddingY": verticalPaddingRatio * cellSize,
        "cellSize": cellSize,
        "gridUnitWidth": unitWidth,
        "gridUnitHeight": unitHeight,
        "gridWidth": gridWidth,
        "gridHeight": gridHeight,
        "boardLeft": Math.round((width - gridWidth) / 2),
        "boardTop": Math.round((height - gridHeight) / 2)
    }
    geometry.boardRight = geometry.boardLeft + geometry.gridWidth
    geometry.boardBottom = geometry.boardTop + geometry.gridHeight
    geometry.point = function(x, y) { return boardPointLocal(state, geometry, x, y) }
    geometry.hexDisplayPoint = function(x, y) { return hexDisplayPointLocal(state, geometry, x, y) }
    return geometry
}

function geometryFromScene(scene) {
    return {
        "width": scene.width,
        "height": scene.height,
        "coordinatesVisible": scene.coordinatesVisible,
        "coordinateFontSize": scene.coordinateFontSize,
        "xCoordinateLabelOffset": scene.xCoordinateLabelOffset,
        "yCoordinateLabelOffset": scene.yCoordinateLabelOffset,
        "boardPaddingX": scene.boardPaddingX,
        "boardPaddingY": scene.boardPaddingY,
        "cellSize": scene.cellSize,
        "gridUnitWidth": scene.gridUnitWidth,
        "gridUnitHeight": scene.gridUnitHeight,
        "gridWidth": scene.gridWidth,
        "gridHeight": scene.gridHeight,
        "boardLeft": scene.boardLeft,
        "boardTop": scene.boardTop,
        "boardRight": scene.boardRight,
        "boardBottom": scene.boardBottom,
        "point": function(x, y) { return scene.boardPointLocal(x, y) },
        "hexDisplayPoint": function(x, y) { return scene.hexDisplayPointLocal(x, y) }
    }
}

function hexDisplayCoordForBoard(state, x, y) {
    return hexTransposed(state) ? { "x": y, "y": x } : { "x": x, "y": y }
}

function hexDisplayPointLocal(state, geometry, x, y) {
    var unitX = x + y * 0.5
    if (hexFlippedX(state))
        unitX = geometry.gridUnitWidth - unitX
    return {
        "x": geometry.boardLeft + unitX * geometry.cellSize,
        "y": geometry.boardTop + y * HEX_ROW_HEIGHT * geometry.cellSize
    }
}

function boardPointLocal(state, geometry, x, y) {
    if (hexBoard(state)) {
        var display = hexDisplayCoordForBoard(state, x, y)
        return hexDisplayPointLocal(state, geometry, display.x, display.y)
    }
    if (squareCellBoard(state))
        return {
            "x": geometry.boardLeft + (x + 0.5) * geometry.cellSize,
            "y": geometry.boardTop + (y + 0.5) * geometry.cellSize
        }
    return {
        "x": geometry.boardLeft + x * geometry.cellSize,
        "y": geometry.boardTop + y * geometry.cellSize
    }
}

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
    return {
        "x": center.x + Math.cos(angle) * radius,
        "y": center.y + Math.sin(angle) * radius
    }
}

function hexCellBoardVertex(state, geometry, x, y, index) {
    return hexCellVertex(geometry.point(x, y), geometry.cellSize / Math.sqrt(3), index)
}

function pointDistanceSquared(a, b) {
    var dx = a.x - b.x
    var dy = a.y - b.y
    return dx * dx + dy * dy
}

function offsetPoint(point, normal, distance) {
    return {
        "x": point.x + normal.x * distance,
        "y": point.y + normal.y * distance
    }
}

function boardCenter(state, geometry) {
    var p1 = geometry.point(0, 0)
    var p2 = geometry.point(Math.max(0, state.boardSizeX - 1), 0)
    var p3 = geometry.point(0, Math.max(0, state.boardSizeY - 1))
    var p4 = geometry.point(Math.max(0, state.boardSizeX - 1), Math.max(0, state.boardSizeY - 1))
    return {
        "x": (p1.x + p2.x + p3.x + p4.x) / 4,
        "y": (p1.y + p2.y + p3.y + p4.y) / 4
    }
}

function normalizedVector(x, y, fallbackX, fallbackY) {
    var length = Math.sqrt(x * x + y * y)
    if (length <= 0.000001)
        return { "x": fallbackX, "y": fallbackY }
    return { "x": x / length, "y": y / length }
}

function outwardNormalForSegment(state, geometry, a, b) {
    var center = boardCenter(state, geometry)
    var dx = b.x - a.x
    var dy = b.y - a.y
    var normal = normalizedVector(-dy, dx, 0, -1)
    var mid = { "x": (a.x + b.x) / 2, "y": (a.y + b.y) / 2 }
    var awayX = mid.x - center.x
    var awayY = mid.y - center.y
    if (normal.x * awayX + normal.y * awayY < 0) {
        normal.x = -normal.x
        normal.y = -normal.y
    }
    return normal
}

function logicalEdgeNormal(state, geometry, edge) {
    var maxX = Math.max(0, state.boardSizeX - 1)
    var maxY = Math.max(0, state.boardSizeY - 1)
    if (edge === "top")
        return outwardNormalForSegment(state, geometry, geometry.point(0, 0), geometry.point(maxX, 0))
    if (edge === "bottom")
        return outwardNormalForSegment(state, geometry, geometry.point(0, maxY), geometry.point(maxX, maxY))
    if (edge === "left")
        return outwardNormalForSegment(state, geometry, geometry.point(0, 0), geometry.point(0, maxY))
    return outwardNormalForSegment(state, geometry, geometry.point(maxX, 0), geometry.point(maxX, maxY))
}

function sideIndexForNeighbor(state, geometry, x, y, neighborX, neighborY) {
    var center = geometry.point(x, y)
    var neighbor = geometry.point(neighborX, neighborY)
    var vector = normalizedVector(neighbor.x - center.x, neighbor.y - center.y, 1, 0)
    var bestSide = 0
    var bestDot = -999999
    for (var side = 0; side < 6; ++side) {
        var angle = -Math.PI / 3 + side * Math.PI / 3
        var dot = vector.x * Math.cos(angle) + vector.y * Math.sin(angle)
        if (dot > bestDot) {
            bestDot = dot
            bestSide = side
        }
    }
    return bestSide
}

function hexBoundarySegmentForMissingNeighbor(state, geometry, x, y, neighborX, neighborY, outwardOffset) {
    var side = sideIndexForNeighbor(state, geometry, x, y, neighborX, neighborY)
    var segment = {
        "a": hexCellBoardVertex(state, geometry, x, y, side),
        "b": hexCellBoardVertex(state, geometry, x, y, (side + 1) % 6)
    }
    if (outwardOffset > 0) {
        var center = geometry.point(x, y)
        var neighbor = geometry.point(neighborX, neighborY)
        var normal = normalizedVector(neighbor.x - center.x, neighbor.y - center.y, 0, -1)
        segment.a = offsetPoint(segment.a, normal, outwardOffset)
        segment.b = offsetPoint(segment.b, normal, outwardOffset)
    }
    return segment
}

function boundaryChainsFromSegments(segments, snapDistance) {
    var remaining = segments.slice()
    var chains = []
    var snapDistanceSquared = snapDistance * snapDistance
    while (remaining.length > 0) {
        var first = remaining.shift()
        var chain = [first.a, first.b]
        var extended = true
        while (extended && remaining.length > 0) {
            extended = false
            var best = null
            var bestDistance = snapDistanceSquared
            for (var i = 0; i < remaining.length; ++i) {
                var segment = remaining[i]
                var head = chain[0]
                var tail = chain[chain.length - 1]
                var tailToA = pointDistanceSquared(tail, segment.a)
                var tailToB = pointDistanceSquared(tail, segment.b)
                var headToA = pointDistanceSquared(head, segment.a)
                var headToB = pointDistanceSquared(head, segment.b)
                if (tailToA <= bestDistance) {
                    bestDistance = tailToA
                    best = { "index": i, "mode": "tailA" }
                }
                if (tailToB <= bestDistance) {
                    bestDistance = tailToB
                    best = { "index": i, "mode": "tailB" }
                }
                if (headToA <= bestDistance) {
                    bestDistance = headToA
                    best = { "index": i, "mode": "headA" }
                }
                if (headToB <= bestDistance) {
                    bestDistance = headToB
                    best = { "index": i, "mode": "headB" }
                }
            }
            if (best !== null) {
                var chosen = remaining.splice(best.index, 1)[0]
                if (best.mode === "tailA")
                    chain.push(chosen.b)
                else if (best.mode === "tailB")
                    chain.push(chosen.a)
                else if (best.mode === "headA")
                    chain.unshift(chosen.b)
                else
                    chain.unshift(chosen.a)
                extended = true
            }
        }
        chains.push(chain)
    }
    return chains
}

function canvasFont(state, size, bold) {
    var family = String(state.coordinateFontFamily).replace(/"/g, "")
    return (bold ? "700 " : "400 ") + Math.max(1, Math.round(size)) + "px \"" + family + "\", sans-serif"
}

function drawCenteredText(ctx, state, text, x, y, color, size, bold, maxWidth) {
    ctx.save()
    ctx.fillStyle = color
    ctx.font = canvasFont(state, size, bold)
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

function hexBoundaryOuterLineWidth(color, cell) {
    return color === "#ffffff" ? Math.max(4, cell * 0.16)
                               : Math.max(3, cell * 0.10)
}

function drawHexStraightEdge(ctx, p1, p2, color, cell) {
    drawHexBoundaryPath(ctx, [p1, p2], color, cell)
}

function drawHexCellColoredEdges(ctx, state, geometry) {
    var cell = geometry.cellSize
    var maxX = Math.max(0, state.boardSizeX - 1)
    var maxY = Math.max(0, state.boardSizeY - 1)
    var topSegments = []
    var bottomSegments = []
    var leftSegments = []
    var rightSegments = []
    var blackOffset = hexBoundaryOuterLineWidth("#000000", cell) * 0.5
    var whiteOffset = hexBoundaryOuterLineWidth("#ffffff", cell) * 0.5

    for (var lx = 0; lx < state.boardSizeX; ++lx) {
        topSegments.push(hexBoundarySegmentForMissingNeighbor(state, geometry, lx, 0, lx, -1, blackOffset))
        topSegments.push(hexBoundarySegmentForMissingNeighbor(state, geometry, lx, 0, lx + 1, -1, blackOffset))
        bottomSegments.push(hexBoundarySegmentForMissingNeighbor(state, geometry, lx, maxY, lx - 1, maxY + 1, blackOffset))
        bottomSegments.push(hexBoundarySegmentForMissingNeighbor(state, geometry, lx, maxY, lx, maxY + 1, blackOffset))
    }

    for (var ly = 0; ly < state.boardSizeY; ++ly) {
        leftSegments.push(hexBoundarySegmentForMissingNeighbor(state, geometry, 0, ly, -1, ly, whiteOffset))
        leftSegments.push(hexBoundarySegmentForMissingNeighbor(state, geometry, 0, ly, -1, ly + 1, whiteOffset))
        rightSegments.push(hexBoundarySegmentForMissingNeighbor(state, geometry, maxX, ly, maxX + 1, ly - 1, whiteOffset))
        rightSegments.push(hexBoundarySegmentForMissingNeighbor(state, geometry, maxX, ly, maxX + 1, ly, whiteOffset))
    }

    var snap = Math.max(1, cell * 0.12)
    var topChains = boundaryChainsFromSegments(topSegments, snap)
    var bottomChains = boundaryChainsFromSegments(bottomSegments, snap)
    var leftChains = boundaryChainsFromSegments(leftSegments, snap)
    var rightChains = boundaryChainsFromSegments(rightSegments, snap)
    for (var top = 0; top < topChains.length; ++top)
        drawHexBoundaryPath(ctx, topChains[top], "#000000", cell)
    for (var bottom = 0; bottom < bottomChains.length; ++bottom)
        drawHexBoundaryPath(ctx, bottomChains[bottom], "#000000", cell)
    for (var left = 0; left < leftChains.length; ++left)
        drawHexBoundaryPath(ctx, leftChains[left], "#ffffff", cell)
    for (var right = 0; right < rightChains.length; ++right)
        drawHexBoundaryPath(ctx, rightChains[right], "#ffffff", cell)
}

function drawStone(ctx, state, geometry, x, y, player, radius) {
    var point = geometry.point(x, y)
    if (hexCellStyle(state)) {
        ctx.save()
        hexCellPath(ctx, point.x, point.y, geometry.cellSize / Math.sqrt(3))
        ctx.fillStyle = player === 1 ? "#101418" : "#ffffff"
        ctx.fill()
        ctx.strokeStyle = "#0b3d73"
        ctx.lineWidth = Math.max(1, geometry.cellSize * 0.035)
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

function drawBoardBackground(ctx, state, geometry, width, height) {
    ctx.save()
    ctx.fillStyle = hexCellStyle(state) ? "#f2cc62" : state.boardWoodColor
    ctx.fillRect(0, 0, width, height)
    ctx.restore()
}

function drawGrid(ctx, state, geometry) {
    var cell = geometry.cellSize
    ctx.save()
    ctx.strokeStyle = hexCellStyle(state) ? "#0b3d73" : "#2d2114"
    ctx.globalAlpha = hexCellStyle(state) ? 1 : state.gridOpacity
    ctx.lineWidth = Math.max(1, state.gridLineWidth)
    if (hexBoard(state)) {
        if (hexCellStyle(state)) {
            for (var cellY = 0; cellY < state.boardSizeY; ++cellY) {
                for (var cellX = 0; cellX < state.boardSizeX; ++cellX) {
                    var center = geometry.point(cellX, cellY)
                    hexCellPath(ctx, center.x, center.y, cell / Math.sqrt(3))
                    ctx.fillStyle = "#f2cc62"
                    ctx.fill()
                    ctx.stroke()
                }
            }
            drawHexCellColoredEdges(ctx, state, geometry)
        } else {
            for (var hy = 0; hy < hexDisplaySizeY(state); ++hy) {
                var hStart = geometry.hexDisplayPoint(0, hy)
                var hEnd = geometry.hexDisplayPoint(hexDisplaySizeX(state) - 1, hy)
                ctx.beginPath()
                ctx.moveTo(hStart.x, hStart.y)
                ctx.lineTo(hEnd.x, hEnd.y)
                ctx.stroke()
            }
            for (var sy = 0; sy < hexDisplaySizeY(state) - 1; ++sy) {
                for (var sx = 0; sx < hexDisplaySizeX(state); ++sx) {
                    var downRightStart = geometry.hexDisplayPoint(sx, sy)
                    var downRightEnd = geometry.hexDisplayPoint(sx, sy + 1)
                    ctx.beginPath()
                    ctx.moveTo(downRightStart.x, downRightStart.y)
                    ctx.lineTo(downRightEnd.x, downRightEnd.y)
                    ctx.stroke()
                }
                for (var dx = 0; dx < hexDisplaySizeX(state) - 1; ++dx) {
                    var downLeftStart = geometry.hexDisplayPoint(dx + 1, sy)
                    var downLeftEnd = geometry.hexDisplayPoint(dx, sy + 1)
                    ctx.beginPath()
                    ctx.moveTo(downLeftStart.x, downLeftStart.y)
                    ctx.lineTo(downLeftEnd.x, downLeftEnd.y)
                    ctx.stroke()
                }
            }
            var blackTop1 = geometry.point(0, 0)
            var blackTop2 = geometry.point(state.boardSizeX - 1, 0)
            var blackBottom1 = geometry.point(0, state.boardSizeY - 1)
            var blackBottom2 = geometry.point(state.boardSizeX - 1, state.boardSizeY - 1)
            var whiteLeft1 = geometry.point(0, 0)
            var whiteLeft2 = geometry.point(0, state.boardSizeY - 1)
            var whiteRight1 = geometry.point(state.boardSizeX - 1, 0)
            var whiteRight2 = geometry.point(state.boardSizeX - 1, state.boardSizeY - 1)
            var triangleEdgeOffset = cell * 0.5
            var blackTopNormal = logicalEdgeNormal(state, geometry, "top")
            var blackBottomNormal = logicalEdgeNormal(state, geometry, "bottom")
            var whiteLeftNormal = logicalEdgeNormal(state, geometry, "left")
            var whiteRightNormal = logicalEdgeNormal(state, geometry, "right")
            drawHexStraightEdge(ctx,
                                offsetPoint(blackTop1, blackTopNormal, triangleEdgeOffset),
                                offsetPoint(blackTop2, blackTopNormal, triangleEdgeOffset),
                                "#000000", cell)
            drawHexStraightEdge(ctx,
                                offsetPoint(blackBottom1, blackBottomNormal, triangleEdgeOffset),
                                offsetPoint(blackBottom2, blackBottomNormal, triangleEdgeOffset),
                                "#000000", cell)
            drawHexStraightEdge(ctx,
                                offsetPoint(whiteLeft1, whiteLeftNormal, triangleEdgeOffset),
                                offsetPoint(whiteLeft2, whiteLeftNormal, triangleEdgeOffset),
                                "#ffffff", cell)
            drawHexStraightEdge(ctx,
                                offsetPoint(whiteRight1, whiteRightNormal, triangleEdgeOffset),
                                offsetPoint(whiteRight2, whiteRightNormal, triangleEdgeOffset),
                                "#ffffff", cell)
        }
    } else {
        var xLineCount = squareCellBoard(state) ? state.boardSizeX + 1 : state.boardSizeX
        var yLineCount = squareCellBoard(state) ? state.boardSizeY + 1 : state.boardSizeY
        for (var x = 0; x < xLineCount; ++x) {
            var px = geometry.boardLeft + x * cell
            ctx.beginPath()
            ctx.moveTo(px, geometry.boardTop)
            ctx.lineTo(px, geometry.boardBottom)
            ctx.stroke()
        }
        for (var y = 0; y < yLineCount; ++y) {
            var py = geometry.boardTop + y * cell
            ctx.beginPath()
            ctx.moveTo(geometry.boardLeft, py)
            ctx.lineTo(geometry.boardRight, py)
            ctx.stroke()
        }
    }
    ctx.restore()
}

function drawStarPoints(ctx, state, geometry) {
    if (state.gameRuleMode !== state.gameRuleGo)
        return
    var cell = geometry.cellSize
    var xs = starPoints(state.boardSizeX)
    var ys = starPoints(state.boardSizeY)
    ctx.save()
    ctx.fillStyle = "#2d2114"
    for (var starX = 0; starX < xs.length; ++starX) {
        for (var starY = 0; starY < ys.length; ++starY) {
            var star = geometry.point(xs[starX], ys[starY])
            ctx.beginPath()
            ctx.arc(star.x, star.y, Math.max(2.8, cell * 0.065), 0, Math.PI * 2)
            ctx.fill()
        }
    }
    ctx.restore()
}

function drawCoordinates(ctx, state, geometry) {
    if (!geometry.coordinatesVisible)
        return
    var cell = geometry.cellSize
    var maxX = Math.max(0, state.boardSizeX - 1)
    var maxY = Math.max(0, state.boardSizeY - 1)
    var topNormal = logicalEdgeNormal(state, geometry, "top")
    var bottomNormal = logicalEdgeNormal(state, geometry, "bottom")
    var leftNormal = logicalEdgeNormal(state, geometry, "left")
    var rightNormal = logicalEdgeNormal(state, geometry, "right")
    ctx.save()
    ctx.font = canvasFont(state, geometry.coordinateFontSize, false)
    ctx.fillStyle = "#4f371f"
    ctx.textAlign = "center"
    ctx.textBaseline = "middle"
    for (var lx = 0; lx < state.boardSizeX; ++lx) {
        var topPoint = geometry.point(lx, 0)
        var bottomPoint = geometry.point(lx, maxY)
        var xLabel = xCoordinateText(state, lx)
        ctx.fillText(xLabel,
                     topPoint.x + topNormal.x * geometry.xCoordinateLabelOffset,
                     topPoint.y + topNormal.y * geometry.xCoordinateLabelOffset,
                     cell * 0.96)
        ctx.fillText(xLabel,
                     bottomPoint.x + bottomNormal.x * geometry.xCoordinateLabelOffset,
                     bottomPoint.y + bottomNormal.y * geometry.xCoordinateLabelOffset,
                     cell * 0.96)
    }
    for (var ly = 0; ly < state.boardSizeY; ++ly) {
        var leftPoint = geometry.point(0, ly)
        var rightPoint = geometry.point(maxX, ly)
        var yLabel = yCoordinateText(state, ly)
        var yLabelMaxWidth = Math.max(1, geometry.boardPaddingX - cell * (state.stoneScale * 0.5 + 0.10))
        ctx.fillText(yLabel,
                     leftPoint.x + leftNormal.x * geometry.yCoordinateLabelOffset,
                     leftPoint.y + leftNormal.y * geometry.yCoordinateLabelOffset,
                     yLabelMaxWidth)
        ctx.fillText(yLabel,
                     rightPoint.x + rightNormal.x * geometry.yCoordinateLabelOffset,
                     rightPoint.y + rightNormal.y * geometry.yCoordinateLabelOffset,
                     yLabelMaxWidth)
    }
    ctx.restore()
}

function drawBoardBase(ctx, state, geometry) {
    drawGrid(ctx, state, geometry)
    drawStarPoints(ctx, state, geometry)
    drawCoordinates(ctx, state, geometry)
}

function drawBoard(ctx, state, geometry, options) {
    var opts = options || ({})
    if (opts.fillBackground === true)
        drawBoardBackground(ctx, state, geometry, opts.width || geometry.width, opts.height || geometry.height)
    drawBoardBase(ctx, state, geometry)
    var stones = opts.stones || []
    var radius = Math.max(8, geometry.cellSize * state.stoneScale * 0.5)
    for (var i = 0; i < stones.length; ++i)
        drawStone(ctx, state, geometry, stones[i].x, stones[i].y, stones[i].player, radius)
}
