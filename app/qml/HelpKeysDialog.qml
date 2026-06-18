import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "InkTheme.js" as InkTheme

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
        color: InkTheme.colors.paper
        border.color: InkTheme.colors.inkLight
        border.width: 1
    }

    header: Rectangle {
        height: 52
        color: InkTheme.colors.paperDeep
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
            color: InkTheme.colors.inkLight
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            text: helpDialog.title
            color: InkTheme.colors.inkDeep
            font.family: InkTheme.fonts.title
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
                        color: InkTheme.colors.white
                        border.color: InkTheme.colors.inkLight
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
                                color: InkTheme.colors.inkWash
                                border.color: InkTheme.colors.inkLight
                                border.width: 1

                                TextEdit {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    width: parent.width - 8
                                    text: modelData.keys
                                    readOnly: true
                                    selectByMouse: true
                                    cursorVisible: false
                                    color: InkTheme.colors.inkDeep
                                    selectionColor: InkTheme.colors.cinnabar
                                    selectedTextColor: InkTheme.colors.white
                                    font.pixelSize: 14
                                    font.bold: true
                                    font.family: "Consolas"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    clip: true
                                }
                            }

                            TextEdit {
                                Layout.fillWidth: true
                                text: app.trText(modelData.textKey)
                                readOnly: true
                                selectByMouse: true
                                cursorVisible: false
                                color: InkTheme.colors.inkDeep
                                selectionColor: InkTheme.colors.cinnabar
                                selectedTextColor: InkTheme.colors.white
                                font.pixelSize: 15
                                wrapMode: TextEdit.WordWrap
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
