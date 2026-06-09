import QtQuick

Item {
    id: inputLayer
    required property var app
    focus: true

    property real lastX: 0
    property real lastY: 0
    property bool moved: false
    property int pressedButton: 0
    property bool boardPressBlocked: false

    Keys.onPressed: function(event) {
        if (event.modifiers & Qt.ControlModifier)
            return

        if (event.key === Qt.Key_Left || event.key === Qt.Key_A) {
            if (!event.isAutoRepeat)
                app.nudgeSelectedPoint(-1, 0)
            event.accepted = true
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_D) {
            if (!event.isAutoRepeat)
                app.nudgeSelectedPoint(1, 0)
            event.accepted = true
        } else if (event.key === Qt.Key_Up || event.key === Qt.Key_W) {
            if (!event.isAutoRepeat)
                app.nudgeSelectedPoint(0, -1)
            event.accepted = true
        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_S) {
            if (!event.isAutoRepeat)
                app.nudgeSelectedPoint(0, 1)
            event.accepted = true
        } else if (event.key === Qt.Key_Space) {
            if (!event.isAutoRepeat)
                app.toggleEnginePause()
            event.accepted = true
        } else if (event.key === Qt.Key_Comma) {
            if (!event.isAutoRepeat)
                app.playBestEngineMove()
            event.accepted = true
        } else if (event.key === Qt.Key_P) {
            if (!event.isAutoRepeat)
                app.passMove()
            event.accepted = true
        } else if (event.key === Qt.Key_Backspace) {
            if (!event.isAutoRepeat)
                app.requestDeleteCurrentNode()
            event.accepted = true
        } else if (event.key === Qt.Key_M) {
            if (!event.isAutoRepeat)
                app.cycleMoveNumberDisplayMode()
            event.accepted = true
        } else if (event.key === Qt.Key_U) {
            if (!event.isAutoRepeat)
                app.openEngineCommunicationLog()
            event.accepted = true
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: function(mouse) {
            inputLayer.boardPressBlocked = app.boardInputBlocked(inputLayer, mouse.x, mouse.y)
            if (inputLayer.boardPressBlocked) {
                inputLayer.pressedButton = 0
                inputLayer.moved = false
                app.clearHover()
                mouse.accepted = true
                return
            }

            app.focusBoardInput()
            inputLayer.lastX = mouse.x
            inputLayer.lastY = mouse.y
            inputLayer.moved = false
            inputLayer.pressedButton = mouse.button
            mouse.accepted = true
        }

        onPositionChanged: function(mouse) {
            if (inputLayer.boardPressBlocked || (mouse.buttons === Qt.NoButton && app.boardInputBlocked(inputLayer, mouse.x, mouse.y))) {
                app.clearHover()
                mouse.accepted = true
                return
            }

            var dx = mouse.x - inputLayer.lastX
            var dy = mouse.y - inputLayer.lastY
            if (mouse.buttons !== Qt.NoButton && Math.abs(dx) + Math.abs(dy) > 2)
                inputLayer.moved = true
            if (mouse.buttons === Qt.NoButton)
                app.updateHover(mouse.x, mouse.y)
            inputLayer.lastX = mouse.x
            inputLayer.lastY = mouse.y
        }

        onReleased: function(mouse) {
            var skipHoverUpdate = false
            if (!inputLayer.boardPressBlocked && !inputLayer.moved) {
                if (inputLayer.pressedButton === Qt.LeftButton)
                    skipHoverUpdate = app.handleBoardClickFromMouse(mouse.x, mouse.y) === true
                else if (inputLayer.pressedButton === Qt.RightButton) {
                    skipHoverUpdate = app.cancelSelectedPoint() === true
                    if (!skipHoverUpdate)
                        app.undoMove()
                }
            }
            inputLayer.pressedButton = 0
            inputLayer.boardPressBlocked = false
            if (skipHoverUpdate)
                app.clearHover(true)
            else if (app.boardInputBlocked(inputLayer, mouse.x, mouse.y))
                app.clearHover()
            else
                app.updateHover(mouse.x, mouse.y)
            mouse.accepted = true
        }

        onExited: app.clearHover()
    }
}
