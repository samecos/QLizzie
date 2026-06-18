import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "InkTheme.js" as InkTheme

Basic.Dialog {
    id: hiddenDialog

    required property var app
    required property var controller

    modal: true
    title: app.trText("hiddenSettingsTitle")
    closePolicy: Popup.CloseOnEscape
    padding: 18
    width: Math.min(760, app.width - 70)
    height: Math.min(640, app.height - 70)
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    function openDialog() {
        syncFields()
        open()
    }

    function syncFields() {
        packageModeCombo.currentIndex = app.packageMode
    }

    onOpened: syncFields()
    onClosed: {
        app.focusBoardInput()
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
            text: hiddenDialog.title
            color: InkTheme.colors.inkDeep
            font.family: InkTheme.fonts.title
            font.pixelSize: 17
            font.bold: true
            elide: Text.ElideRight
        }
    }

    contentItem: ColumnLayout {
        implicitWidth: 700
        implicitHeight: 220
        spacing: 12

        Label {
            Layout.fillWidth: true
            text: app.trText("hiddenSettingsWarning")
            color: InkTheme.colors.cinnabar
            font.pixelSize: 15
            font.bold: true
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: app.trText("packageMode")
                color: InkTheme.colors.inkDeep
                font.family: InkTheme.fonts.title
                font.pixelSize: 14
                Layout.preferredWidth: 100
            }

            ComboBox {
                id: packageModeCombo
                model: [
                    app.trText("packageModeUniversal"),
                    app.trText("packageModeGo"),
                    app.trText("packageModeSix")
                ]
                Layout.preferredWidth: 210
                onActivated: function(index) {
                    app.packageMode = index
                    hiddenDialog.syncFields()
                }
            }

            Label {
                text: app.packageModeText(app.packageMode)
                color: InkTheme.colors.inkDark
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            SavePromptButton {
                text: app.trText("close")
                primary: true
                onClicked: hiddenDialog.close()
            }
        }
    }

}
