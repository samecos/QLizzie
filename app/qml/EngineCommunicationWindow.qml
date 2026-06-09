import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

Window {
    id: engineCommunicationDialog

    required property var app
    required property var logModel

    signal sendCommand(string command)
    signal clearLogRequested()

    title: app.trText("engineCommunicationLog")
    flags: Qt.Window
    color: "#f7fafc"
    minimumWidth: 520
    minimumHeight: 320
    width: 860
    height: 560
    visible: false
    property bool positionedOnce: false
    property bool logFollowsTail: true
    property bool rebuildingLog: false

    function logAtTail() {
        if (!engineCommunicationList || engineCommunicationList.contentHeight <= engineCommunicationList.height)
            return true
        return engineCommunicationList.contentY >= engineCommunicationList.contentHeight
               - engineCommunicationList.height - 6
    }

    function scrollLogToEnd() {
        if (!engineCommunicationList)
            return
        if (engineCommunicationList.count <= 0) {
            engineCommunicationList.contentY = 0
            logFollowsTail = true
            return
        }

        engineCommunicationList.forceLayout()
        engineCommunicationList.positionViewAtIndex(engineCommunicationList.count - 1, ListView.End)
        logFollowsTail = true
    }

    function queueScrollLogToEnd() {
        Qt.callLater(function() {
            if (engineCommunicationDialog.logFollowsTail)
                engineCommunicationDialog.scrollLogToEnd()
        })
    }

    function currentContentY() {
        return engineCommunicationList ? engineCommunicationList.contentY : 0
    }

    function restoreLogPosition(previousContentY) {
        Qt.callLater(function() {
            if (!engineCommunicationList)
                return
            var maxY = Math.max(0, engineCommunicationList.contentHeight - engineCommunicationList.height)
            engineCommunicationList.contentY = Math.min(previousContentY, maxY)
            engineCommunicationDialog.logFollowsTail = engineCommunicationDialog.logAtTail()
        })
    }

    function submitCommand() {
        var command = engineCommunicationCommandField.text.trim()
        if (command.length <= 0)
            return

        engineCommunicationDialog.sendCommand(command)
        engineCommunicationCommandField.text = ""
        engineCommunicationCommandField.forceActiveFocus()
    }

    function openWindow() {
        if (!positionedOnce) {
            width = Math.min(860, Math.max(minimumWidth, app.width - 80))
            height = Math.min(560, Math.max(minimumHeight, app.height - 90))
            x = Math.round(app.x + (app.width - width) / 2)
            y = Math.round(app.y + (app.height - height) / 2)
            positionedOnce = true
        }
        visible = true
        raise()
        requestActivate()
        logFollowsTail = true
        Qt.callLater(function() {
            engineCommunicationDialog.scrollLogToEnd()
            engineCommunicationCommandField.forceActiveFocus()
        })
    }

    onVisibleChanged: {
        if (!visible)
            app.focusBoardInput()
    }

    Shortcut {
        sequence: "Esc"
        onActivated: engineCommunicationDialog.visible = false
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 18

            CheckBox {
                text: "stdin"
                checked: app.showEngineCommunicationStdin
                onToggled: app.showEngineCommunicationStdin = checked
            }

            CheckBox {
                text: "stdout"
                checked: app.showEngineCommunicationStdout
                onToggled: app.showEngineCommunicationStdout = checked
            }

            CheckBox {
                text: "stderr"
                checked: app.showEngineCommunicationStderr
                onToggled: app.showEngineCommunicationStderr = checked
            }

            Item { Layout.fillWidth: true }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#111820"
            border.color: "#2d3a44"
            border.width: 1
            clip: true

            ListView {
                id: engineCommunicationList
                anchors.fill: parent
                anchors.margins: 1
                clip: true
                model: engineCommunicationDialog.logModel
                boundsBehavior: Flickable.StopAtBounds
                spacing: 1

                onContentYChanged: {
                    if (!engineCommunicationDialog.rebuildingLog)
                        engineCommunicationDialog.logFollowsTail = engineCommunicationDialog.logAtTail()
                }
                onHeightChanged: {
                    if (engineCommunicationDialog.logFollowsTail)
                        engineCommunicationDialog.queueScrollLogToEnd()
                }
                onCountChanged: {
                    if (engineCommunicationDialog.logFollowsTail)
                        engineCommunicationDialog.queueScrollLogToEnd()
                }

                ScrollBar.vertical: Basic.ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                delegate: Rectangle {
                    width: engineCommunicationList.width
                    height: Math.max(23, logText.implicitHeight + 8)
                    color: index % 2 === 0 ? "#111820" : "#16212b"

                    Text {
                        id: logText
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        text: model.lineText
                        color: app.engineCommunicationColor(model.stream)
                        font.family: "Consolas"
                        font.pixelSize: app.compactLayout ? 11 : 12
                        wrapMode: Text.WrapAnywhere
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Basic.TextField {
                id: engineCommunicationCommandField
                selectByMouse: true
                font.family: "Consolas"
                font.pixelSize: app.compactLayout ? 12 : 13
                color: "#13232d"
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                onAccepted: engineCommunicationDialog.submitCommand()

                background: Rectangle {
                    radius: 5
                    color: "#ffffff"
                    border.color: engineCommunicationCommandField.activeFocus ? "#2388b8" : "#b7c5cc"
                    border.width: 1
                }
            }

            SavePromptButton {
                text: app.trText("send")
                primary: true
                onClicked: engineCommunicationDialog.submitCommand()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Item { Layout.fillWidth: true }

            SavePromptButton {
                text: app.trText("clear")
                onClicked: engineCommunicationDialog.clearLogRequested()
            }

            SavePromptButton {
                text: app.trText("close")
                primary: true
                onClicked: {
                    engineCommunicationDialog.visible = false
                    app.focusBoardInput()
                }
            }
        }
    }
}
