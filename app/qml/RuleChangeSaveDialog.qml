import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

Basic.Dialog {
    id: ruleChangeSaveDialog

    required property var app

    modal: true
    title: app.pendingClearTitle()
    closePolicy: Popup.CloseOnEscape
    padding: 18
    width: Math.max(400, Math.min(480, app.width - 80))
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

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
            text: ruleChangeSaveDialog.title
            color: "#14242e"
            font.pixelSize: 17
            font.bold: true
            elide: Text.ElideRight
        }
    }

    contentItem: Rectangle {
        implicitWidth: 440
        implicitHeight: Math.max(72, messageLabel.implicitHeight + 24)
        color: "#f8fbfd"

        Label {
            id: messageLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            text: app.pendingClearMessage()
            color: "#17212a"
            wrapMode: Text.WordWrap
            font.pixelSize: 15
            lineHeight: 1.12
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
                text: app.trText("save")
                primary: true
                onClicked: {
                    ruleChangeSaveDialog.close()
                    app.openSaveSgfDialog(false)
                }
            }

            SavePromptButton {
                text: app.trText("dontSave")
                onClicked: {
                    ruleChangeSaveDialog.close()
                    app.applyPendingClearAction()
                }
            }

            SavePromptButton {
                text: app.trText("cancel")
                onClicked: {
                    ruleChangeSaveDialog.close()
                    app.clearPendingClearAction()
                    app.onSettingsDialogClosed()
                    app.focusBoardInput()
                }
            }
        }
    }
}
