import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

Basic.Dialog {
    id: helpDialog

    required property var app

    modal: true
    title: app.trText("helpKeysTitle")
    closePolicy: Popup.CloseOnEscape
    padding: 18
    width: Math.min(640, app.width - 70)
    height: Math.min(620, app.height - 70)
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    property var helpRows: [
        { "keys": "Space", "textKey": "helpKeyPauseEngineDesc" },
        { "keys": ",", "textKey": "helpKeyPlayBestDesc" },
        { "keys": "P", "textKey": "helpKeyPassDesc" },
        { "keys": "U", "textKey": "helpKeyEngineLogDesc" },
        { "keys": "Backspace", "textKey": "helpKeyDeleteDesc" },
        { "keys": "M", "textKey": "helpKeyMoveLabelsDesc" },
        { "keys": "Ctrl+O", "textKey": "helpKeyOpenSgfDesc" },
        { "keys": "Ctrl+S", "textKey": "helpKeySaveSgfDesc" },
        { "keys": "Ctrl+I", "textKey": "helpKeyBoardSizeDesc" }
    ]

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

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            text: helpDialog.title
            color: "#14242e"
            font.pixelSize: 18
            font.bold: true
            elide: Text.ElideRight
        }
    }

    contentItem: ColumnLayout {
        implicitWidth: 600
        implicitHeight: 500
        spacing: 12

        Flickable {
            id: helpFlick

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: helpColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: AppScrollBar {
                policy: ScrollBar.AsNeeded
            }

            ColumnLayout {
                id: helpColumn
                width: helpFlick.width - 16
                spacing: 8

                Repeater {
                    model: helpDialog.helpRows

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: Math.max(42, helpRowLayout.implicitHeight + 14)
                        radius: 7
                        color: "#ffffff"
                        border.color: "#cfdae0"
                        border.width: 1

                        RowLayout {
                            id: helpRowLayout
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 8
                            anchors.rightMargin: 10
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 118
                                Layout.preferredHeight: 28
                                radius: 5
                                color: "#e8f0f4"
                                border.color: "#9fb3bf"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    width: parent.width - 8
                                    text: modelData.keys
                                    color: "#10242f"
                                    font.pixelSize: 14
                                    font.bold: true
                                    font.family: "Consolas"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: app.trText(modelData.textKey)
                                color: "#1e2d36"
                                font.pixelSize: 15
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            SavePromptButton {
                text: app.trText("close")
                primary: true
                onClicked: {
                    helpDialog.close()
                    app.focusBoardInput()
                }
            }
        }
    }
}
