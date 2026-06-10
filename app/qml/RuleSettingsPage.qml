import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "BoardRenderer.js" as BoardRenderer

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

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            var state = BoardRenderer.stateFromApp(app, {
                                "boardSizeX": 3,
                                "boardSizeY": 3
                            })
                            var geometry = BoardRenderer.createGeometry(state, width, height, { "outerMargin": 8 })
                            BoardRenderer.drawBoard(ctx, state, geometry, {
                                "fillBackground": true,
                                "width": width,
                                "height": height,
                                "stones": [
                                    { "x": 0, "y": 0, "player": 1 },
                                    { "x": 1, "y": 1, "player": 2 },
                                    { "x": 2, "y": 2, "player": 1 }
                                ]
                            })
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
