import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

Basic.Dialog {
    id: engineFailureDialog

    required property var app

    modal: true
    title: app.trText("engineFailureTitle")
    closePolicy: Popup.CloseOnEscape
    padding: 18
    width: Math.min(520, app.width - 80)
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    background: Rectangle {
        radius: 10
        color: "#fff8f6"
        border.color: "#d0695f"
        border.width: 1
    }

    header: Rectangle {
        height: 52
        color: "#ffe2de"
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
            color: "#efb3ad"
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            text: engineFailureDialog.title
            color: "#641a14"
            font.pixelSize: 17
            font.bold: true
            elide: Text.ElideRight
        }
    }

    contentItem: ColumnLayout {
        implicitWidth: 484
        spacing: 18

        Label {
            text: app.engineFailureMessage()
            color: "#4a201b"
            wrapMode: Text.WordWrap
            font.pixelSize: 14
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            SavePromptButton {
                text: app.trText("confirm")
                primary: true
                onClicked: {
                    engineFailureDialog.close()
                    app.focusBoardInput()
                }
            }
        }
    }
}
