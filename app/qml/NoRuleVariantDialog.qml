import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "InkTheme.js" as InkTheme

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
        color: InkTheme.colors.paper
        border.color: InkTheme.colors.inkLight
    }

    contentItem: Label {
        text: app.trText("noRuleVariantBody")
        color: InkTheme.colors.inkDeep
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
                color: InkTheme.colors.inkDeep
                font.pixelSize: noRuleVariantDialog.app.compactLayout ? 12 : 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 5
                color: okButton.pressed ? InkTheme.colors.inkWash : okButton.hovered ? InkTheme.colors.inkWash : InkTheme.colors.paper
                border.color: okButton.activeFocus ? InkTheme.colors.cinnabar : InkTheme.colors.inkLight
                border.width: okButton.activeFocus ? 2 : 1
            }
        }
        Item { width: 4 }
    }
}
