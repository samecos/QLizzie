import QtQuick
import QtQuick.Controls.Basic as Basic
import "InkTheme.js" as InkTheme

Basic.Button {
    id: savePromptButton

    property bool primary: false

    implicitWidth: 104
    implicitHeight: 34
    padding: 0

    contentItem: Text {
        text: savePromptButton.text
        color: savePromptButton.primary ? InkTheme.colors.white : InkTheme.colors.inkDeep
        font.pixelSize: 13
        font.bold: savePromptButton.primary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: InkTheme.fonts.title
    }

    background: Rectangle {
        radius: 8
        color: savePromptButton.primary
               ? (savePromptButton.pressed ? InkTheme.colors.inkDeep : savePromptButton.hovered ? InkTheme.colors.inkDark : InkTheme.colors.sumi)
               : (savePromptButton.pressed ? InkTheme.colors.paperDark : savePromptButton.hovered ? InkTheme.colors.paper : InkTheme.colors.white)
        border.color: savePromptButton.primary ? InkTheme.colors.sumi : InkTheme.colors.inkLight
        border.width: 1
    }
}
