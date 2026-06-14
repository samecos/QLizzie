import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

Basic.Dialog {
    id: boardSizeDialog

    required property var app
    property int selectedPreset: app.defaultBoardSize
    property string errorText: ""

    modal: true
    title: app.trText("boardSizeDialogTitle")
    closePolicy: Popup.CloseOnEscape
    padding: 18
    width: Math.max(500, Math.min(640, app.width - 80))
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    function showForCurrentBoard() {
        selectedPreset = (app.boardSizeX === app.boardSizeY
                          && app.boardSizePresetAllowed(app.boardSizeX))
                         ? app.boardSizeX
                         : 0
        sizeXSpin.value = app.boardSizeX
        sizeYSpin.value = app.boardSizeY
        errorText = ""
        open()
    }

    function setPreset(size) {
        selectedPreset = size
        sizeXSpin.value = size
        sizeYSpin.value = size
        errorText = ""
    }

    function applySize() {
        var xSize = sizeXSpin.value
        var ySize = sizeYSpin.value
        if (app.requestBoardDimensionsChange(xSize, ySize)) {
            close()
            app.focusBoardInput()
        } else if (app.pendingClearAction === "boardSize") {
            close()
        } else {
            errorText = app.ruleBoardSizeRejectText(app.gameRuleMode, xSize, ySize)
        }
    }

    ButtonGroup { id: boardSizePresetGroup }

    background: Rectangle {
        radius: 10
        color: "#f8fbfd"
        border.color: "#8ea5b1"
        border.width: 1
    }

    header: Rectangle {
        height: 52
        color: "#e6eff4"
        radius: 10

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.radius
            color: parent.color
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: "#c5d4dc"
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            text: boardSizeDialog.title
            color: "#14242e"
            font.pixelSize: 17
            font.bold: true
            elide: Text.ElideRight
        }
    }

    contentItem: Rectangle {
        implicitWidth: 600
        implicitHeight: app.customBoardSizeAllowed() ? 142 : 98
        color: "#f8fbfd"

        ColumnLayout {
            anchors.fill: parent
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: [9, 13, 15, 19]

                    Basic.RadioButton {
                        text: modelData + "x" + modelData
                        visible: app.boardSizePresetAllowed(modelData)
                        checked: boardSizeDialog.selectedPreset === modelData
                        ButtonGroup.group: boardSizePresetGroup
                        onClicked: boardSizeDialog.setPreset(modelData)
                    }
                }

                Basic.RadioButton {
                    text: app.trText("custom")
                    visible: app.customBoardSizeAllowed()
                    checked: boardSizeDialog.selectedPreset === 0
                    ButtonGroup.group: boardSizePresetGroup
                    onClicked: boardSizeDialog.selectedPreset = 0
                }

                Item { Layout.fillWidth: true }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: app.customBoardSizeAllowed()

                Label {
                    text: app.trText("boardSizeX")
                    color: "#24313a"
                    font.pixelSize: 14
                }

                BoardSizeStepper {
                    id: sizeXSpin
                    from: app.minBoardSize
                    to: app.maxBoardSize
                    Layout.preferredWidth: 104
                    onValueModified: boardSizeDialog.selectedPreset = 0
                }

                Label {
                    text: "x " + app.trText("boardSizeY")
                    color: "#24313a"
                    font.pixelSize: 14
                }

                BoardSizeStepper {
                    id: sizeYSpin
                    from: app.minBoardSize
                    to: app.maxBoardSize
                    Layout.preferredWidth: 104
                    onValueModified: boardSizeDialog.selectedPreset = 0
                }

                Item { Layout.fillWidth: true }
            }

            Label {
                text: boardSizeDialog.errorText
                visible: boardSizeDialog.errorText !== ""
                color: "#b3261e"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Item { Layout.fillHeight: true }
        }
    }

    footer: Rectangle {
        implicitHeight: 68
        color: "#f8fbfd"
        radius: 10

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: "#d7e1e7"
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: parent.radius
            color: parent.color
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10

            Item { Layout.fillWidth: true }

            SavePromptButton {
                text: app.trText("confirm")
                primary: true
                Layout.preferredWidth: 120
                onClicked: boardSizeDialog.applySize()
            }

            SavePromptButton {
                text: app.trText("cancel")
                Layout.preferredWidth: 96
                onClicked: {
                    boardSizeDialog.close()
                    app.focusBoardInput()
                }
            }
        }
    }
}
