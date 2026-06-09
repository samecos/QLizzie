import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

Item {
    id: root

    property int value: 1
    property int from: 1
    property int to: 19
    signal valueModified()

    implicitWidth: 108
    implicitHeight: 34

    function clampValue(candidate) {
        return Math.max(root.from, Math.min(root.to, candidate))
    }

    function setValue(candidate, modified) {
        var clamped = clampValue(candidate)
        if (root.value === clamped) {
            field.text = String(root.value)
            return
        }
        root.value = clamped
        if (modified)
            root.valueModified()
    }

    onValueChanged: field.text = String(clampValue(value))
    onFromChanged: setValue(value, false)
    onToChanged: setValue(value, false)

    RowLayout {
        anchors.fill: parent
        spacing: 4

        Basic.TextField {
            id: field

            Layout.fillWidth: true
            Layout.fillHeight: true
            text: String(root.value)
            selectByMouse: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 15
            font.bold: true
            color: "#162832"
            padding: 0
            inputMethodHints: Qt.ImhDigitsOnly
            validator: IntValidator {
                bottom: root.from
                top: root.to
            }
            background: Rectangle {
                radius: 6
                color: "#ffffff"
                border.color: field.activeFocus ? "#267fbb" : "#9fb2bd"
                border.width: field.activeFocus ? 2 : 1
            }

            function commit() {
                var parsed = parseInt(text, 10)
                if (isNaN(parsed))
                    parsed = root.value
                root.setValue(parsed, true)
            }

            onEditingFinished: commit()
            Keys.onReturnPressed: commit()
            Keys.onEnterPressed: commit()
        }

        Rectangle {
            Layout.preferredWidth: 26
            Layout.fillHeight: true
            color: "#eef4f7"
            border.color: "#8fa2ab"
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                StepButton {
                    up: true
                    enabled: root.value < root.to
                    onClicked: root.setValue(root.value + 1, true)
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#8fa2ab"
                }

                StepButton {
                    up: false
                    enabled: root.value > root.from
                    onClicked: root.setValue(root.value - 1, true)
                }
            }
        }
    }

    component StepButton: Rectangle {
        id: stepButton

        property bool up: true
        signal clicked()

        Layout.fillWidth: true
        Layout.fillHeight: true
        color: !enabled ? "#e4ebef" : stepMouse.pressed ? "#c2d4de" : stepMouse.containsMouse ? "#d7e7ef" : "#f4f8fa"

        Canvas {
            id: arrowCanvas

            anchors.centerIn: parent
            width: 10
            height: 8

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = stepButton.enabled ? "#24343c" : "#9baab2"
                ctx.lineWidth = 1.7
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                ctx.beginPath()
                if (stepButton.up) {
                    ctx.moveTo(1.5, 5.5)
                    ctx.lineTo(5, 2)
                    ctx.lineTo(8.5, 5.5)
                } else {
                    ctx.moveTo(1.5, 2.5)
                    ctx.lineTo(5, 6)
                    ctx.lineTo(8.5, 2.5)
                }
                ctx.stroke()
            }
        }

        MouseArea {
            id: stepMouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: stepButton.enabled
            onClicked: stepButton.clicked()
            onContainsMouseChanged: arrowCanvas.requestPaint()
            onPressedChanged: arrowCanvas.requestPaint()
        }

        onEnabledChanged: arrowCanvas.requestPaint()
        onUpChanged: arrowCanvas.requestPaint()
    }
}
