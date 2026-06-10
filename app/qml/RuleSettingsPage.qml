import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

ColumnLayout {
    id: ruleSettingsPage

    required property var app

    spacing: 14

    component PresentationCombo: Basic.ComboBox {
        id: control

        required property var app
        property var options: []
        signal picked(int index)

        model: options
        textRole: "label"
        valueRole: "value"
        implicitHeight: 32
        leftPadding: 10
        rightPadding: 30
        onActivated: function(index) { picked(index) }

        contentItem: Text {
            leftPadding: control.leftPadding
            rightPadding: control.rightPadding
            text: control.displayText
            color: "#14242e"
            font.pixelSize: control.app.compactLayout ? 13 : 14
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        indicator: Canvas {
            id: arrowCanvas
            x: control.width - width - 10
            y: Math.round((control.height - height) / 2)
            width: 12
            height: 8

            Connections {
                target: control
                function onHoveredChanged() { arrowCanvas.requestPaint() }
                function onPressedChanged() { arrowCanvas.requestPaint() }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = control.pressed ? "#1f6f8d" : "#6b7880"
                ctx.beginPath()
                ctx.moveTo(1, 1)
                ctx.lineTo(width - 1, 1)
                ctx.lineTo(width / 2, height - 1)
                ctx.closePath()
                ctx.fill()
            }
        }

        background: Rectangle {
            radius: 5
            color: control.pressed ? "#dcecf3"
                                 : control.hovered ? "#eef7fa" : "#f8fbfd"
            border.color: control.activeFocus ? "#2a91c9" : "#a8bac5"
            border.width: control.activeFocus ? 2 : 1
        }

        delegate: Basic.ItemDelegate {
            id: optionDelegate
            width: control.width
            height: control.app.compactLayout ? 30 : 34
            highlighted: control.highlightedIndex === index
            hoverEnabled: true

            contentItem: Text {
                text: modelData.label
                color: "#14242e"
                font.pixelSize: control.app.compactLayout ? 12 : 13
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
                elide: Text.ElideRight
            }

            background: Rectangle {
                color: optionDelegate.highlighted ? "#d8e9f1"
                                                  : optionDelegate.hovered ? "#edf5f8" : "#ffffff"
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: ruleContent.implicitHeight + 28
        radius: 7
        color: "#f8fbfd"
        border.color: "#c7d4dc"

        ColumnLayout {
            id: ruleContent
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Label {
                text: app.trText("gameKindRuleSettings")
                color: "#17212a"
                font.pixelSize: 16
                font.bold: true
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: app.trText("mainRule")
                    color: "#24313a"
                    Layout.preferredWidth: 110
                }

                GameRuleComboBox {
                    app: ruleSettingsPage.app
                    Layout.preferredWidth: 170
                    implicitHeight: 32
                }

                Label {
                    text: app.trText("ruleVariant")
                    color: "#24313a"
                    Layout.preferredWidth: 86
                }

                RuleVariantComboBox {
                    app: ruleSettingsPage.app
                    Layout.preferredWidth: 230
                    implicitHeight: 32
                }

                Item { Layout.fillWidth: true }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: app.gameRuleMode !== app.gameRuleHex

                Label {
                    text: app.trText("boardPresentation")
                    color: "#24313a"
                    Layout.preferredWidth: 110
                }

                PresentationCombo {
                    app: ruleSettingsPage.app
                    options: app.boardPresentationOptions()
                    currentIndex: app.boardPresentationCurrentIndex()
                    Layout.preferredWidth: 260
                    onPicked: function(index) { app.setBoardPresentationFromIndex(index) }
                }

                Label {
                    text: app.boardPresentationOptions()[app.boardPresentationCurrentIndex()]
                          ? app.boardPresentationOptions()[app.boardPresentationCurrentIndex()].tip
                          : ""
                    color: "#61727c"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: app.gameRuleMode === app.gameRuleHex

                Label {
                    text: app.trText("hexBoardStyle")
                    color: "#24313a"
                    Layout.preferredWidth: 110
                }

                PresentationCombo {
                    app: ruleSettingsPage.app
                    options: app.hexBoardStyleOptions()
                    currentIndex: app.hexBoardStyleCurrentIndex()
                    Layout.preferredWidth: 260
                    onPicked: function(index) { app.setHexBoardStyleFromIndex(index) }
                }

                Label {
                    text: app.hexBoardStyleOptions()[app.hexBoardStyleCurrentIndex()]
                          ? app.hexBoardStyleOptions()[app.hexBoardStyleCurrentIndex()].tip
                          : ""
                    color: "#61727c"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: app.gameRuleMode === app.gameRuleHex

                Label {
                    text: app.trText("hexBoardRotation")
                    color: "#24313a"
                    Layout.preferredWidth: 110
                }

                PresentationCombo {
                    app: ruleSettingsPage.app
                    options: app.hexBoardRotationOptions()
                    currentIndex: app.hexBoardRotationCurrentIndex()
                    Layout.preferredWidth: 260
                    onPicked: function(index) { app.setHexBoardRotationFromIndex(index) }
                }

                Label {
                    text: app.hexBoardRotationOptions()[app.hexBoardRotationCurrentIndex()]
                          ? app.hexBoardRotationOptions()[app.hexBoardRotationCurrentIndex()].tip
                          : ""
                    color: "#61727c"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: app.trText("boardPreview")
                    color: "#24313a"
                    Layout.preferredWidth: 110
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 170
                    radius: 7
                    color: "#ffffff"
                    border.color: "#c7d4dc"

                    Canvas {
                        id: previewCanvas
                        anchors.fill: parent
                        anchors.margins: 8

                        function hexPoint(left, top, cell, dx, dy, unitWidth, flipX) {
                            var ux = dx + dy * 0.5
                            if (flipX)
                                ux = unitWidth - ux
                            return Qt.point(left + ux * cell, top + dy * 0.8660254037844386 * cell)
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
                            return Qt.point(center.x + Math.cos(angle) * radius,
                                            center.y + Math.sin(angle) * radius)
                        }

                        function drawEdge(ctx, p1, p2, color, cell) {
                            ctx.save()
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

                        function drawHexCellEdge(ctx, point, side, color, cell) {
                            var radius = cell / Math.sqrt(3)
                            var p1 = hexCellVertex(point, radius, side)
                            var p2 = hexCellVertex(point, radius, (side + 1) % 6)
                            drawEdge(ctx, p1, p2, color, cell)
                        }

                        function drawHexBoundaryPath(ctx, points, color, cell) {
                            if (!points || points.length < 2)
                                return
                            ctx.save()
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

                        function hexPreviewVertex(left, top, cell, x, y, index, unitWidth, flipX) {
                            return hexCellVertex(hexPoint(left, top, cell, x, y, unitWidth, flipX),
                                                 cell / Math.sqrt(3),
                                                 index)
                        }

                        function drawHexPreviewColoredEdges(ctx, left, top, cell, unitWidth, flipX) {
                            var topPoints = []
                            var bottomPoints = []
                            for (var lx = 0; lx < 3; ++lx) {
                                if (lx === 0)
                                    topPoints.push(hexPreviewVertex(left, top, cell, lx, 0, 5, unitWidth, flipX))
                                topPoints.push(hexPreviewVertex(left, top, cell, lx, 0, 0, unitWidth, flipX))
                                topPoints.push(hexPreviewVertex(left, top, cell, lx, 0, 1, unitWidth, flipX))

                                if (lx === 0)
                                    bottomPoints.push(hexPreviewVertex(left, top, cell, lx, 2, 4, unitWidth, flipX))
                                bottomPoints.push(hexPreviewVertex(left, top, cell, lx, 2, 3, unitWidth, flipX))
                                bottomPoints.push(hexPreviewVertex(left, top, cell, lx, 2, 2, unitWidth, flipX))
                            }

                            var leftPoints = []
                            var rightPoints = []
                            for (var ly = 0; ly < 3; ++ly) {
                                if (ly === 0)
                                    leftPoints.push(hexPreviewVertex(left, top, cell, 0, ly, 5, unitWidth, flipX))
                                leftPoints.push(hexPreviewVertex(left, top, cell, 0, ly, 4, unitWidth, flipX))
                                leftPoints.push(hexPreviewVertex(left, top, cell, 0, ly, 3, unitWidth, flipX))

                                if (ly === 0)
                                    rightPoints.push(hexPreviewVertex(left, top, cell, 2, ly, 0, unitWidth, flipX))
                                rightPoints.push(hexPreviewVertex(left, top, cell, 2, ly, 1, unitWidth, flipX))
                                rightPoints.push(hexPreviewVertex(left, top, cell, 2, ly, 2, unitWidth, flipX))
                            }

                            drawHexBoundaryPath(ctx, topPoints, "#000000", cell)
                            drawHexBoundaryPath(ctx, bottomPoints, "#000000", cell)
                            drawHexBoundaryPath(ctx, leftPoints, "#ffffff", cell)
                            drawHexBoundaryPath(ctx, rightPoints, "#ffffff", cell)
                        }

                        function drawPreviewStone(ctx, cx, cy, cell, player, hexCell) {
                            ctx.save()
                            if (hexCell) {
                                hexCellPath(ctx, cx, cy, cell / Math.sqrt(3))
                                ctx.fillStyle = player === 1 ? "#101418" : "#ffffff"
                                ctx.fill()
                                ctx.strokeStyle = "#0b3d73"
                                ctx.lineWidth = Math.max(1, cell * 0.035)
                                ctx.stroke()
                            } else {
                                var radius = cell * app.stoneScale * 0.5
                                ctx.beginPath()
                                ctx.fillStyle = player === 1 ? "#101418" : "#ffffff"
                                ctx.arc(cx, cy, radius, 0, Math.PI * 2)
                                ctx.fill()
                                ctx.strokeStyle = player === 1 ? "#000000" : "#9d9279"
                                ctx.lineWidth = Math.max(1, cell * 0.025)
                                ctx.stroke()
                            }
                            ctx.restore()
                        }

                        function drawPreviewCoordinates(ctx, positionsX, positionsY, topY, bottomY, leftX, rightX, cell) {
                            if (app.effectiveCoordinateDisplayMode() === app.coordinateDisplayNone)
                                return
                            ctx.save()
                            ctx.fillStyle = "#4f371f"
                            ctx.font = "400 " + Math.max(9, Math.round(cell * 0.22)) + "px sans-serif"
                            ctx.textAlign = "center"
                            ctx.textBaseline = "middle"
                            var xGap = cell * 0.42
                            var yGap = cell * 0.42
                            for (var x = 0; x < 3; ++x) {
                                var xLabel = app.xCoordinateText(x)
                                ctx.fillText(xLabel, positionsX[x].x, topY - xGap, cell * 0.95)
                                ctx.fillText(xLabel, positionsX[x].x, bottomY + xGap, cell * 0.95)
                            }
                            for (var y = 0; y < 3; ++y) {
                                var yLabel = app.yCoordinateText(y)
                                ctx.fillText(yLabel, leftX - yGap, positionsY[y].y, cell * 0.95)
                                ctx.fillText(yLabel, rightX + yGap, positionsY[y].y, cell * 0.95)
                            }
                            ctx.restore()
                        }

                        function drawHexPreview(ctx, left, top, cell) {
                            var transposed = app.hexBoardRotation === app.hexRotationTranspose
                                             || app.hexBoardRotation === app.hexRotationFlipXTranspose
                            var flipX = app.hexBoardRotation === app.hexRotationFlipX
                                        || app.hexBoardRotation === app.hexRotationFlipXTranspose
                            var displayX = transposed ? 3 : 3
                            var displayY = transposed ? 3 : 3
                            var unitWidth = Math.max(1, displayX - 1 + (displayY - 1) * 0.5)
                            var styleCells = app.hexBoardStyle === app.hexBoardStyleCells

                            ctx.save()
                            ctx.strokeStyle = styleCells ? "#0b3d73" : "#2d2114"
                            ctx.lineWidth = Math.max(1, cell * 0.035)
                            ctx.globalAlpha = 1

                            if (styleCells) {
                                for (var cy = 0; cy < 3; ++cy) {
                                    for (var cx = 0; cx < 3; ++cx) {
                                        var point = hexPoint(left, top, cell, cx, cy, unitWidth, flipX)
                                        hexCellPath(ctx, point.x, point.y, cell / Math.sqrt(3))
                                        ctx.fillStyle = "#f2cc62"
                                        ctx.fill()
                                        ctx.stroke()
                                    }
                                }
                            } else {
                                for (var hy = 0; hy < 3; ++hy) {
                                    var h1 = hexPoint(left, top, cell, 0, hy, unitWidth, flipX)
                                    var h2 = hexPoint(left, top, cell, 2, hy, unitWidth, flipX)
                                    ctx.beginPath()
                                    ctx.moveTo(h1.x, h1.y)
                                    ctx.lineTo(h2.x, h2.y)
                                    ctx.stroke()
                                }
                                for (var sy = 0; sy < 2; ++sy) {
                                    for (var sx = 0; sx < 3; ++sx) {
                                        var r1 = hexPoint(left, top, cell, sx, sy, unitWidth, flipX)
                                        var r2 = hexPoint(left, top, cell, sx, sy + 1, unitWidth, flipX)
                                        ctx.beginPath()
                                        ctx.moveTo(r1.x, r1.y)
                                        ctx.lineTo(r2.x, r2.y)
                                        ctx.stroke()
                                    }
                                    for (var dx = 0; dx < 2; ++dx) {
                                        var l1 = hexPoint(left, top, cell, dx + 1, sy, unitWidth, flipX)
                                        var l2 = hexPoint(left, top, cell, dx, sy + 1, unitWidth, flipX)
                                        ctx.beginPath()
                                        ctx.moveTo(l1.x, l1.y)
                                        ctx.lineTo(l2.x, l2.y)
                                        ctx.stroke()
                                    }
                                }
                            }
                            ctx.restore()

                            var h00 = hexPoint(left, top, cell, 0, 0, unitWidth, flipX)
                            var h11 = hexPoint(left, top, cell, 1, 1, unitWidth, flipX)
                            var h22 = hexPoint(left, top, cell, 2, 2, unitWidth, flipX)

                            var b1 = hexPoint(left, top, cell, 0, 0, unitWidth, flipX)
                            var b2 = hexPoint(left, top, cell, 2, 0, unitWidth, flipX)
                            var b3 = hexPoint(left, top, cell, 2, 2, unitWidth, flipX)
                            var b4 = hexPoint(left, top, cell, 0, 2, unitWidth, flipX)
                            if (styleCells) {
                                drawHexPreviewColoredEdges(ctx, left, top, cell, unitWidth, flipX)
                            } else {
                                drawEdge(ctx, b1, b2, "#000000", cell)
                                drawEdge(ctx, b4, b3, "#000000", cell)
                                drawEdge(ctx, b1, b4, "#ffffff", cell)
                                drawEdge(ctx, b2, b3, "#ffffff", cell)
                            }

                            drawPreviewStone(ctx, h00.x, h00.y, cell, 1, styleCells)
                            drawPreviewStone(ctx, h11.x, h11.y, cell, 2, styleCells)
                            drawPreviewStone(ctx, h22.x, h22.y, cell, 1, styleCells)

                            var topY = Math.min(b1.y, b2.y) - (styleCells ? cell / Math.sqrt(3) : 0)
                            var bottomY = Math.max(b4.y, b3.y) + (styleCells ? cell / Math.sqrt(3) : 0)
                            var leftX = Math.min(b1.x, b4.x) - (styleCells ? cell * 0.5 : 0)
                            var rightX = Math.max(b2.x, b3.x) + (styleCells ? cell * 0.5 : 0)
                            drawPreviewCoordinates(ctx,
                                                   [hexPoint(left, top, cell, 0, 0, unitWidth, flipX),
                                                    hexPoint(left, top, cell, 1, 0, unitWidth, flipX),
                                                    hexPoint(left, top, cell, 2, 0, unitWidth, flipX)],
                                                   [hexPoint(left, top, cell, 0, 0, unitWidth, flipX),
                                                    hexPoint(left, top, cell, 0, 1, unitWidth, flipX),
                                                    hexPoint(left, top, cell, 0, 2, unitWidth, flipX)],
                                                   topY, bottomY, leftX, rightX, cell)
                        }

                        function drawSquarePreview(ctx, left, top, cell) {
                            var cellMode = app.gameRuleMode === app.gameRuleGomoku
                                           && app.boardPresentationMode === app.boardPresentationCells
                            ctx.strokeStyle = "#2d2114"
                            ctx.lineWidth = Math.max(1, cell * 0.035)
                            if (cellMode) {
                                for (var gx = 0; gx <= 3; ++gx) {
                                    ctx.beginPath()
                                    ctx.moveTo(left + gx * cell, top)
                                    ctx.lineTo(left + gx * cell, top + cell * 3)
                                    ctx.stroke()
                                }
                                for (var gy = 0; gy <= 3; ++gy) {
                                    ctx.beginPath()
                                    ctx.moveTo(left, top + gy * cell)
                                    ctx.lineTo(left + cell * 3, top + gy * cell)
                                    ctx.stroke()
                                }
                            } else {
                                for (var ix = 0; ix < 3; ++ix) {
                                    ctx.beginPath()
                                    ctx.moveTo(left + ix * cell, top)
                                    ctx.lineTo(left + ix * cell, top + cell * 2)
                                    ctx.stroke()
                                }
                                for (var iy = 0; iy < 3; ++iy) {
                                    ctx.beginPath()
                                    ctx.moveTo(left, top + iy * cell)
                                    ctx.lineTo(left + cell * 2, top + iy * cell)
                                    ctx.stroke()
                                }
                            }
                            var centers = cellMode
                                          ? [[left + cell * 0.5, top + cell * 0.5],
                                             [left + cell * 1.5, top + cell * 1.5],
                                             [left + cell * 2.5, top + cell * 2.5]]
                                          : [[left, top],
                                             [left + cell, top + cell],
                                             [left + cell * 2, top + cell * 2]]
                            for (var s = 0; s < centers.length; ++s) {
                                drawPreviewStone(ctx, centers[s][0], centers[s][1], cell, s === 1 ? 2 : 1, false)
                            }
                            var positionsX = []
                            var positionsY = []
                            for (var px = 0; px < 3; ++px) {
                                positionsX.push(Qt.point(cellMode ? left + (px + 0.5) * cell : left + px * cell,
                                                         cellMode ? top + cell * 0.5 : top))
                            }
                            for (var py = 0; py < 3; ++py) {
                                positionsY.push(Qt.point(cellMode ? left + cell * 0.5 : left,
                                                         cellMode ? top + (py + 0.5) * cell : top + py * cell))
                            }
                            drawPreviewCoordinates(ctx, positionsX, positionsY,
                                                   top, top + (cellMode ? 3 : 2) * cell,
                                                   left, left + (cellMode ? 3 : 2) * cell,
                                                   cell)
                        }

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.fillStyle = app.gameRuleMode === app.gameRuleHex
                                            && app.hexBoardStyle === app.hexBoardStyleCells
                                            ? "#f2cc62" : app.boardWoodColor
                            ctx.fillRect(0, 0, width, height)

                            var margin = 12
                            var coordinates = app.effectiveCoordinateDisplayMode() !== app.coordinateDisplayNone
                            var coordinatePad = coordinates ? 0.84 : 0.0
                            var hexCell = app.gameRuleMode === app.gameRuleHex
                                          && app.hexBoardStyle === app.hexBoardStyleCells
                            var widthUnits = app.gameRuleMode === app.gameRuleHex
                                             ? (hexCell ? 4.0 : 3.0) + coordinatePad
                                             : (app.gameRuleMode === app.gameRuleGomoku
                                                && app.boardPresentationMode === app.boardPresentationCells ? 3.0 : 2.0) + coordinatePad
                            var heightUnits = app.gameRuleMode === app.gameRuleHex
                                              ? (2 * 0.8660254037844386
                                                 + (hexCell ? 2 / Math.sqrt(3) : 0.0)
                                                 + coordinatePad)
                                              : (app.gameRuleMode === app.gameRuleGomoku
                                                 && app.boardPresentationMode === app.boardPresentationCells ? 3.0 : 2.0) + coordinatePad
                            var cell = Math.min((width - margin * 2) / widthUnits,
                                                (height - margin * 2) / heightUnits)
                            cell = Math.max(16, cell)
                            if (app.gameRuleMode === app.gameRuleHex) {
                                var unitWidth = 3
                                var gridHeight = 2 * 0.8660254037844386 * cell
                                drawHexPreview(ctx, (width - unitWidth * cell) / 2, (height - gridHeight) / 2, cell)
                            } else {
                                var intervals = app.gameRuleMode === app.gameRuleGomoku
                                                && app.boardPresentationMode === app.boardPresentationCells ? 3 : 2
                                drawSquarePreview(ctx,
                                                  (width - intervals * cell) / 2,
                                                  (height - intervals * cell) / 2,
                                                  cell)
                            }
                        }

                        Connections {
                            target: app
                            function onGameRuleModeChanged() { previewCanvas.requestPaint() }
                            function onBoardPresentationModeChanged() { previewCanvas.requestPaint() }
                            function onHexBoardStyleChanged() { previewCanvas.requestPaint() }
                            function onHexBoardRotationChanged() { previewCanvas.requestPaint() }
                            function onBoardWoodColorChanged() { previewCanvas.requestPaint() }
                        }

                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: app.komiControlsVisible()

                Label {
                    text: app.trText("komi")
                    color: "#24313a"
                    Layout.preferredWidth: 110
                }

                SpinBox {
                    from: -200
                    to: 200
                    value: Math.round(app.effectiveKomi() * 2)
                    editable: true
                    Layout.preferredWidth: 96
                    textFromValue: function(value) { return (value / 2).toFixed(1) }
                    valueFromText: function(text) { return Math.round(Number(text) * 2) }
                    onValueModified: app.setKomiValue(value / 2)
                }

                Item { Layout.fillWidth: true }
            }
        }
    }
}
