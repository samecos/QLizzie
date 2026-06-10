import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

Basic.Dialog {
    id: warningDialog

    required property var app
    property string messageText: ""

    modal: true
    title: app.trText("engineRuleMismatchTitle")
    closePolicy: Popup.CloseOnEscape
    padding: 18
    width: Math.min(520, app.width - 80)
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    function openForPreset(preset) {
        title = app.trText("engineRuleMismatchTitle")
        messageText = app.trText("engineRuleMismatchBody")
                      + "\n\n"
                      + app.trText("currentRule") + ": " + app.gameRuleText()
                      + "\n"
                      + app.trText("enginePresetRule") + ": " + app.enginePresetRuleDetailText(preset)
        open()
    }

    function openForSgf(gameId, expectedGameId) {
        title = app.trText("sgfGameTypeMismatchTitle")
        messageText = app.trText("sgfGameTypeMismatchBody")
                      + "\n\n"
                      + app.trText("currentRule") + ": " + app.gameRuleText()
                      + "\n"
                      + app.trText("sgfGameTypeField") + ": GM[" + gameId + "]"
                      + "\n"
                      + app.trText("expectedGameType") + ": GM[" + expectedGameId + "]"
        open()
    }

    background: Rectangle {
        radius: 10
        color: "#fff8ed"
        border.color: "#c99452"
    }

    header: Rectangle {
        height: 50
        radius: 10
        color: "#f5e4cc"

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.radius
            color: parent.color
        }

        Label {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            text: warningDialog.title
            color: "#3d2a12"
            font.pixelSize: 17
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    contentItem: ColumnLayout {
        implicitWidth: 484
        spacing: 16

        Label {
            Layout.fillWidth: true
            text: warningDialog.messageText
            color: "#342414"
            font.pixelSize: 14
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            Item { Layout.fillWidth: true }
            SavePromptButton {
                text: app.trText("confirm")
                primary: true
                Layout.preferredWidth: 100
                onClicked: {
                    warningDialog.close()
                    app.focusBoardInput()
                }
            }
        }
    }
}
