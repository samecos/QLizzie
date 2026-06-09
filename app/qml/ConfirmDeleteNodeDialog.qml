import QtQuick
import QtQuick.Controls

Dialog {
    id: confirmDeleteNodeDialog

    required property var app

    modal: true
    title: app.trText("deleteNodeTitle")
    standardButtons: Dialog.Yes | Dialog.No
    width: Math.min(420, app.width - 80)
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    Label {
        text: app.trText("confirmDeleteBranch")
        color: "#17212a"
        wrapMode: Text.WordWrap
        width: parent.width
    }

    onAccepted: {
        app.deleteCurrentNode(true)
        app.focusBoardInput()
    }

    onRejected: app.focusBoardInput()
}
