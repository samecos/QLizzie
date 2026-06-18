import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "InkTheme.js" as InkTheme

Rectangle {
    id: commandToolbar
    required property var app
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    height: app.commandToolbarHeight
    clip: true
    color: InkTheme.colors.paper
    border.color: InkTheme.colors.inkLight

    Flickable {
        id: commandToolbarFlick
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        contentWidth: commandToolbarRow.implicitWidth
        contentHeight: height
        interactive: contentWidth > width
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds

        Row {
            id: commandToolbarRow
            height: commandToolbarFlick.height
            spacing: app.compactLayout ? 3 : 4

            Repeater {
                model: app.commandToolbarItems

                delegate: Item {
                    width: Math.round((modelData.width || 52) * (app.compactLayout ? 0.94 : 1.0))
                    height: commandToolbarRow.height

                    Basic.Button {
                        visible: modelData.type === "button"
                        enabled: app.toolbarActionEnabled(modelData.action || "")
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height - (app.compactLayout ? 6 : 8)
                        text: app.language === "zh" ? modelData.zh : modelData.en
                        font.pixelSize: app.compactLayout ? 12 : 13
                        leftPadding: 4
                        rightPadding: 4
                        topPadding: 2
                        bottomPadding: 2
                        onClicked: app.runToolbarAction(modelData.action || "")

                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? InkTheme.colors.inkDeep : InkTheme.colors.ink
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            radius: 6
                            color: parent.pressed ? InkTheme.colors.paperDark
                                 : parent.hovered ? InkTheme.colors.paper : InkTheme.colors.white
                            border.color: InkTheme.colors.inkLight
                            border.width: 1
                            opacity: parent.enabled ? 1 : 0.55
                        }
                    }

                    Basic.TextField {
                        id: moveNumberInput
                        visible: modelData.type === "moveInput"
                        property bool committingMoveNumber: false
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height - (app.compactLayout ? 6 : 8)
                        selectByMouse: true
                        horizontalAlignment: TextInput.AlignHCenter
                        verticalAlignment: TextInput.AlignVCenter
                        font.pixelSize: app.compactLayout ? 12 : 13
                        color: InkTheme.colors.inkDeep
                        validator: IntValidator {
                            bottom: 0
                            top: app.maxMoveNumberValue()
                        }
                        background: Rectangle {
                            radius: 6
                            color: moveNumberInput.activeFocus ? InkTheme.colors.white : InkTheme.colors.paper
                            border.color: moveNumberInput.activeFocus ? InkTheme.colors.cinnabar : InkTheme.colors.inkLight
                            border.width: 1
                        }
                        function commitMoveNumber() {
                            if (committingMoveNumber)
                                return

                            committingMoveNumber = true
                            app.gotoMoveNumber(parseInt(text, 10))
                            text = app.currentMoveNumberText()
                            committingMoveNumber = false
                        }
                        Component.onCompleted: text = app.currentMoveNumberText()
                        onActiveFocusChanged: {
                            if (activeFocus)
                                selectAll()
                        }
                        onAccepted: {
                            commitMoveNumber()
                            app.focusBoardInput()
                        }
                        onEditingFinished: commitMoveNumber()

                        Connections {
                            target: app

                            function onCurrentNodeIdChanged() {
                                if (!moveNumberInput.activeFocus)
                                    moveNumberInput.text = app.currentMoveNumberText()
                            }

                            function onBoardRevisionChanged() {
                                if (!moveNumberInput.activeFocus)
                                    moveNumberInput.text = app.currentMoveNumberText()
                            }
                        }
                    }
                }
            }
        }
    }
}
