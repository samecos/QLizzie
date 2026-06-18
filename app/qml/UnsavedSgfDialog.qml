import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "InkTheme.js" as InkTheme

Basic.Dialog {
    id: unsavedSgfDialog

    required property var app

    modal: true
    title: app.trText("unsavedGameTitle")
    closePolicy: Popup.CloseOnEscape
    padding: 18
    width: Math.max(380, Math.min(460, app.width - 80))
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

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
            text: unsavedSgfDialog.title
            color: InkTheme.colors.inkDeep
            font.family: InkTheme.fonts.title
            font.pixelSize: 17
            font.bold: true
            elide: Text.ElideRight
        }
    }

    contentItem: Rectangle {
        implicitWidth: 424
        implicitHeight: Math.max(72, messageLabel.implicitHeight + 24)
        color: InkTheme.colors.paper

        Label {
            id: messageLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            text: app.trText("confirmSaveGame")
            color: InkTheme.colors.inkDeep
            wrapMode: Text.WordWrap
            font.pixelSize: 15
            lineHeight: 1.12
        }
    }

    footer: Rectangle {
        implicitHeight: 68
        color: InkTheme.colors.paper
        radius: 10

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: InkTheme.colors.inkLight
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
                    unsavedSgfDialog.close()
                    app.openSaveSgfDialog(true)
                }
            }

            SavePromptButton {
                text: app.trText("dontSave")
                onClicked: {
                    unsavedSgfDialog.close()
                    app.closeWithoutSaving()
                }
            }

            SavePromptButton {
                text: app.trText("cancel")
                onClicked: {
                    unsavedSgfDialog.close()
                    app.focusBoardInput()
                }
            }
        }
    }
}
