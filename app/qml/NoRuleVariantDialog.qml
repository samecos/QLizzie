import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

Basic.Dialog {
    id: noRuleVariantDialog

    required property var app

    modal: true
    title: app.trText("noRuleVariantTitle")
    padding: 16
    width: Math.min(420, app.width - 42)
    height: Math.min(210, app.height - 42)
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    background: Rectangle {
        radius: 8
        color: "#f8fbfd"
        border.color: "#b9cbd4"
    }

    contentItem: Label {
        text: app.trText("noRuleVariantBody")
        color: "#24313a"
        font.pixelSize: app.compactLayout ? 13 : 14
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
    }

    footer: RowLayout {
        Item { Layout.fillWidth: true }
        Basic.Button {
            id: okButton

            text: noRuleVariantDialog.app.trText("confirm")
            implicitWidth: 110
            implicitHeight: 34
            onClicked: noRuleVariantDialog.close()

            contentItem: Text {
                text: okButton.text
                color: "#17212a"
                font.pixelSize: noRuleVariantDialog.app.compactLayout ? 12 : 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 5
                color: okButton.pressed ? "#dcecf3" : okButton.hovered ? "#eef7fa" : "#f8fbfd"
                border.color: okButton.activeFocus ? "#2a91c9" : "#a8bac5"
                border.width: okButton.activeFocus ? 2 : 1
            }
        }
        Item { width: 4 }
    }
}
