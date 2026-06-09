import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

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
            text: engineParametersDialog.title
            color: "#14242e"
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
            color: "#17212a"
            font.pixelSize: 14
            Layout.fillWidth: true
        }

        Basic.TextArea {
            id: engineCommandEdit
            selectByMouse: true
            wrapMode: TextEdit.WrapAnywhere
            font.pixelSize: 13
            color: "#13232d"
            Layout.fillWidth: true
            Layout.preferredHeight: 92

            background: Rectangle {
                radius: 5
                color: "#ffffff"
                border.color: engineCommandEdit.activeFocus ? "#2388b8" : "#b7c5cc"
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
