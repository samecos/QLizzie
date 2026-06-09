import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

Basic.Dialog {
    id: confirmDeleteNodeDialog

    required property var app

    modal: true
    title: app.trText("deleteNodeTitle")
    closePolicy: Popup.CloseOnEscape
    padding: 0
    width: Math.min(520, Math.max(360, app.width - 80))
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    function descendantCountForNode(id) {
        var node = app.nodeById(id)
        if (!node)
            return 0
        var children = node.children || []
        var count = children.length
        for (var i = 0; i < children.length; ++i)
            count += descendantCountForNode(children[i])
        return count
    }

    function descendantCountText() {
        var node = app.currentNode()
        if (!node)
            return "0"
        var count = descendantCountForNode(node.id)
        var unit = app.trText("deleteNodeDescendantUnit")
        return unit.length > 0 ? count + unit : String(count)
    }

    onClosed: app.focusBoardInput()

    background: Rectangle {
        radius: 10
        color: "#f8fbfd"
        border.color: "#94aab6"
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 14
        width: confirmDeleteNodeDialog.width

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 16
        }

        Label {
            Layout.leftMargin: 18
            Layout.rightMargin: 18
            Layout.fillWidth: true
            text: app.trText("deleteNodeWarningTitle")
            color: "#17212a"
            font.pixelSize: 20
            font.bold: true
        }

        Rectangle {
            Layout.leftMargin: 18
            Layout.rightMargin: 18
            Layout.fillWidth: true
            Layout.preferredHeight: warningBody.implicitHeight + 22
            radius: 6
            color: "#fff4ed"
            border.color: "#efb08b"

            Label {
                id: warningBody
                anchors.fill: parent
                anchors.margins: 11
                text: app.trText("deleteNodeWarningBody")
                color: "#653018"
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
            }
        }

        GridLayout {
            Layout.leftMargin: 18
            Layout.rightMargin: 18
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 16
            rowSpacing: 10

            Label {
                text: app.trText("deleteNodeMoveLabel")
                color: "#52636d"
                Layout.preferredWidth: 92
            }

            Label {
                text: app.currentNodeText()
                color: "#17212a"
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Label {
                text: app.trText("deleteNodeDescendantLabel")
                color: "#52636d"
                Layout.preferredWidth: 92
            }

            Label {
                text: confirmDeleteNodeDialog.descendantCountText()
                color: "#17212a"
                font.bold: true
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            color: "#f1f6f9"
            radius: 10

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 1
                color: "#d7e1e7"
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Item { Layout.fillWidth: true }

                SavePromptButton {
                    text: app.trText("cancel")
                    Layout.preferredWidth: 98
                    onClicked: confirmDeleteNodeDialog.close()
                }

                Basic.Button {
                    id: deleteButton
                    text: app.trText("deleteNodeConfirm")
                    Layout.preferredWidth: 116
                    Layout.preferredHeight: 34
                    padding: 0
                    onClicked: {
                        app.deleteCurrentNode(true)
                        confirmDeleteNodeDialog.close()
                    }

                    contentItem: Text {
                        text: deleteButton.text
                        color: "#ffffff"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 6
                        color: deleteButton.pressed ? "#a02a1f"
                             : deleteButton.hovered ? "#d14635" : "#c7352a"
                        border.color: "#a02a1f"
                        border.width: 1
                    }
                }
            }
        }
    }
}
