import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "InkTheme.js" as InkTheme

Rectangle {
    id: branchPanel
    required property var app
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.rightMargin: app.panelMargin
    anchors.topMargin: app.topContentMargin
    anchors.bottomMargin: app.bottomContentMargin
    width: app.branchPanelWidth
    radius: 8
    color: InkTheme.colors.paperDeep
    border.color: InkTheme.colors.inkLight

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: app.panelInnerMargin
        spacing: app.compactLayout ? 6 : 8

        Label {
            text: app.trText("gameTree")
            color: InkTheme.colors.inkDeep
            font.pixelSize: app.compactLayout ? 16 : 18
            font.bold: true
            font.family: InkTheme.fonts.title
            Layout.fillWidth: true
        }

        Label {
            text: app.trText("currentMove") + ": " + app.currentNodeText()
            color: InkTheme.colors.inkDark
            font.family: app.coordinateFontFamily
            font.pixelSize: 12
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Rectangle {
            id: treeViewport
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: InkTheme.colors.paper
            border.color: InkTheme.colors.inkLight
            clip: true

            Flickable {
                id: treeFlick
                anchors.fill: parent
                anchors.margins: app.compactLayout ? 6 : 8
                clip: true
                contentWidth: Math.max(width, app.treeCanvasWidth)
                contentHeight: Math.max(height, app.treeCanvasHeight)
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.horizontal: AppScrollBar {
                    policy: ScrollBar.AsNeeded
                    endInset: 14
                }

                ScrollBar.vertical: AppScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                Canvas {
                    id: branchCanvas
                    width: treeFlick.contentWidth
                    height: treeFlick.contentHeight

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)

                        var leftNodeByMove = ({})
                        for (var r = 0; r < app.treeNodes.length; ++r) {
                            var rowNode = app.treeNodes[r]
                            var currentLeft = leftNodeByMove[rowNode.moveNumber]
                            if (!currentLeft || rowNode.x < currentLeft.x)
                                leftNodeByMove[rowNode.moveNumber] = rowNode
                        }

                        ctx.font = "9px sans-serif"
                        ctx.textAlign = "right"
                        ctx.textBaseline = "middle"
                        ctx.fillStyle = InkTheme.colors.ink
                        for (var moveNumber in leftNodeByMove) {
                            var leftNode = leftNodeByMove[moveNumber]
                            ctx.fillText(String(leftNode.moveNumber),
                                         Math.max(10, leftNode.x - leftNode.radius - 7),
                                         leftNode.y)
                        }

                        ctx.lineCap = "round"
                        ctx.lineJoin = "round"
                        for (var e = 0; e < app.treeEdges.length; ++e) {
                            var edge = app.treeEdges[e]
                            ctx.beginPath()
                            ctx.moveTo(edge.x1, edge.y1)
                            ctx.lineTo(edge.x2, edge.y2)
                            ctx.lineWidth = edge.current ? 3 : 2
                            ctx.strokeStyle = edge.current ? InkTheme.colors.cinnabar : InkTheme.colors.inkLight
                            ctx.stroke()
                        }

                        for (var i = 0; i < app.treeNodes.length; ++i) {
                            var node = app.treeNodes[i]

                            if (node.moveNumber === 0) {
                                var side = node.radius * 1.72
                                ctx.beginPath()
                                ctx.rect(node.x - side / 2, node.y - side / 2, side, side)
                                ctx.fillStyle = InkTheme.colors.cinnabar
                                ctx.fill()
                                ctx.lineWidth = node.current ? 3 : 1.5
                                ctx.strokeStyle = node.current ? InkTheme.colors.cinnabar : InkTheme.colors.cinnabarLight
                                ctx.stroke()
                                ctx.fillStyle = InkTheme.colors.white
                            } else {
                                ctx.beginPath()
                                ctx.arc(node.x, node.y, node.radius, 0, Math.PI * 2)
                                if (node.player === 1) {
                                    ctx.fillStyle = InkTheme.colors.sumi
                                } else if (node.player === 2) {
                                    ctx.fillStyle = InkTheme.colors.white
                                } else {
                                    ctx.fillStyle = InkTheme.colors.paperDark
                                }
                                ctx.fill()
                                ctx.lineWidth = node.current ? 3 : 1.5
                                ctx.strokeStyle = node.current ? InkTheme.colors.cinnabar : (node.player === 2 ? InkTheme.colors.ink : InkTheme.colors.inkDark)
                                ctx.stroke()
                                ctx.fillStyle = node.player === 1 ? InkTheme.colors.white : InkTheme.colors.inkDeep
                            }

                            ctx.font = node.current ? "bold 10px sans-serif" : "10px sans-serif"
                            ctx.textAlign = "center"
                            ctx.textBaseline = "middle"
                            ctx.fillText(node.label, node.x, node.y)
                        }
                    }

                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()

                    Connections {
                        target: app
                        function onTreeRevisionChanged() {
                            branchCanvas.requestPaint()
                        }
                    }
                }

                MouseArea {
                    anchors.fill: branchCanvas
                    acceptedButtons: Qt.LeftButton
                    hoverEnabled: true

                    onClicked: function(mouse) {
                        var nodeId = app.treeNodeAt(mouse.x, mouse.y)
                        if (nodeId >= 0) {
                            app.focusBoardInput()
                            app.gotoNode(nodeId)
                        }
                        mouse.accepted = true
                    }
                }
            }
        }
    }
}
