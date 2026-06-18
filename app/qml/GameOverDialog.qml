import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "InkTheme.js" as InkTheme

Basic.Dialog {
    id: gameOverDialog

    required property var app

    modal: false
    title: app.trText("gameOverTitle")
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 18
    width: Math.min(360, app.width - 80)
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    background: Rectangle {
        radius: 10
        color: InkTheme.colors.paper
        border.color: InkTheme.colors.inkLight
        border.width: 1
    }

    header: Rectangle {
        height: 48
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
            text: gameOverDialog.title
            color: InkTheme.colors.inkDeep
            font.family: InkTheme.fonts.title
            font.pixelSize: 17
            font.bold: true
        }
    }

    contentItem: ColumnLayout {
        spacing: 16

        Label {
            text: app.gameOverDialogText()
            color: InkTheme.colors.inkDeep
            wrapMode: Text.WordWrap
            font.pixelSize: 16
            font.bold: true
            Layout.fillWidth: true
        }

        SavePromptButton {
            text: app.trText("confirm")
            primary: true
            Layout.alignment: Qt.AlignRight
            onClicked: {
                gameOverDialog.close()
                app.focusBoardInput()
            }
        }
    }
}
