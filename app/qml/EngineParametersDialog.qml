import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "InkTheme.js" as InkTheme

Basic.Dialog {
    id: engineParametersDialog

    required property var app
    required property var controller

    modal: true
    title: app.trText("engineParameters")
    closePolicy: Popup.CloseOnEscape
    padding: 18
    width: Math.min(720, app.width - 80)
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    function openForCurrentEngine() {
        engineCommandEdit.text = controller ? controller.command : ""
        open()
    }

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

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            text: engineParametersDialog.title
            color: InkTheme.colors.inkDeep
            font.family: InkTheme.fonts.title
            font.pixelSize: 17
            font.bold: true
            elide: Text.ElideRight
        }
    }

    contentItem: ColumnLayout {
        implicitWidth: 684
        spacing: 14

        Label {
            text: app.trText("engineCommand")
            color: InkTheme.colors.inkDeep
            font.family: InkTheme.fonts.title
            font.pixelSize: 14
            Layout.fillWidth: true
        }

        Basic.TextArea {
            id: engineCommandEdit
            selectByMouse: true
            wrapMode: TextEdit.WrapAnywhere
            font.pixelSize: 13
            color: InkTheme.colors.inkDeep
            Layout.fillWidth: true
            Layout.preferredHeight: 92

            background: Rectangle {
                radius: 5
                color: InkTheme.colors.white
                border.color: engineCommandEdit.activeFocus ? InkTheme.colors.cinnabar : InkTheme.colors.inkLight
                border.width: 1
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Item { Layout.fillWidth: true }

            SavePromptButton {
                text: app.trText("confirm")
                primary: true
                onClicked: {
                    if (controller && controller.command !== engineCommandEdit.text)
                        controller.command = engineCommandEdit.text
                    engineParametersDialog.close()
                    app.focusBoardInput()
                }
            }

            SavePromptButton {
                text: app.trText("cancel")
                onClicked: {
                    engineParametersDialog.close()
                    app.focusBoardInput()
                }
            }
        }
    }
}
