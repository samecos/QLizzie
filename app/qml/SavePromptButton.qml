import QtQuick
import QtQuick.Controls.Basic as Basic

Basic.Button {
    id: savePromptButton

    property bool primary: false

    implicitWidth: 104
    implicitHeight: 34
    padding: 0

    contentItem: Text {
        text: savePromptButton.text
        color: savePromptButton.primary ? "#ffffff" : "#22333d"
        font.pixelSize: 13
        font.bold: savePromptButton.primary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: 6
        color: savePromptButton.primary
               ? (savePromptButton.pressed ? "#1d6fa8" : savePromptButton.hovered ? "#2c8dcc" : "#267fbb")
               : (savePromptButton.pressed ? "#d5e1e8" : savePromptButton.hovered ? "#edf4f8" : "#f8fbfd")
        border.color: savePromptButton.primary ? "#1d6fa8" : "#9fb2bd"
        border.width: 1
    }
}
