import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

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
        color: "#f8fbfd"
        border.color: "#8ea5b1"
        border.width: 1
    }

    header: Rectangle {
        height: 48
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
            text: gameOverDialog.title
            color: "#14242e"
            font.pixelSize: 17
            font.bold: true
        }
    }

    contentItem: ColumnLayout {
        spacing: 16

        Label {
            text: app.gameOverDialogText()
            color: "#17212a"
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
