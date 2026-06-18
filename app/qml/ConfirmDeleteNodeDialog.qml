import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "InkTheme.js" as InkTheme

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
        color: InkTheme.colors.paper
        border.color: InkTheme.colors.inkLight
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
            color: InkTheme.colors.inkDeep
            font.family: InkTheme.fonts.title
            font.pixelSize: 20
            font.bold: true
        }

        Rectangle {
            Layout.leftMargin: 18
            Layout.rightMargin: 18
            Layout.fillWidth: true
            Layout.preferredHeight: warningBody.implicitHeight + 22
            radius: 6
            color: InkTheme.colors.cinnabarPale
            border.color: InkTheme.colors.cinnabarLight

            Label {
                id: warningBody
                anchors.fill: parent
                anchors.margins: 11
                text: app.trText("deleteNodeWarningBody")
                color: InkTheme.colors.cinnabar
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
                color: InkTheme.colors.inkDark
                Layout.preferredWidth: 92
            }

            Label {
                text: app.currentNodeText()
                color: InkTheme.colors.inkDeep
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Label {
                text: app.trText("deleteNodeDescendantLabel")
                color: InkTheme.colors.inkDark
                Layout.preferredWidth: 92
            }

            Label {
                text: confirmDeleteNodeDialog.descendantCountText()
                color: InkTheme.colors.inkDeep
                font.bold: true
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            color: InkTheme.colors.paper
            radius: 10

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 1
                color: InkTheme.colors.inkLight
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
                        color: InkTheme.colors.white
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 6
                        color: deleteButton.pressed ? InkTheme.colors.inkDeep
                             : deleteButton.hovered ? InkTheme.colors.cinnabarLight : InkTheme.colors.cinnabar
                        border.color: deleteButton.pressed ? InkTheme.colors.inkDeep : InkTheme.colors.cinnabar
                        border.width: 1
                    }
                }
            }
        }
    }
}
