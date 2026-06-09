import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

Rectangle {
    id: toolbar
    required property var app

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    height: app.analysisToolbarHeight
    color: "#e7ecef"
    border.color: "#c4cdd2"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: app.compactLayout ? 8 : 12
        anchors.rightMargin: app.compactLayout ? 8 : 12
        spacing: app.compactLayout ? 7 : 11

        Label {
            visible: app.packageMode !== app.packageModeGo
            text: app.trText("gameRule")
            color: "#26333b"
            font.pixelSize: app.compactLayout ? 13 : 15
            verticalAlignment: Text.AlignVCenter
        }

        RowLayout {
            visible: app.ruleModeButtonsVisible()
            spacing: app.compactLayout ? 3 : 4

            RuleButton {
                mode: app.gameRuleGomoku
                text: app.trText("gameRuleGomoku")
            }

            RuleButton {
                mode: app.gameRuleGo
                text: app.trText("gameRuleGo")
            }
        }

        RuleVariantComboBox {
            id: toolbarRuleVariantCombo
            app: toolbar.app
            visible: app.ruleVariantComboVisible()
            Layout.preferredWidth: app.compactLayout ? 138 : 178
            implicitHeight: app.compactLayout ? 28 : 32
        }

        Rectangle {
            visible: app.packageMode !== app.packageModeGo
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: 7
            Layout.bottomMargin: 7
            color: "#c4cdd2"
        }

        Label {
            visible: app.komiControlsVisible()
            text: app.trText("komi")
            color: app.gameRuleMode === app.gameRuleGo ? "#26333b" : "#7f8b92"
            font.pixelSize: app.compactLayout ? 13 : 15
            verticalAlignment: Text.AlignVCenter
        }

        Basic.TextField {
            id: komiField
            visible: app.komiControlsVisible()
            enabled: app.gameRuleMode === app.gameRuleGo
            text: Number(app.effectiveKomi()).toFixed(1)
            selectByMouse: true
            validator: DoubleValidator {
                bottom: -99
                top: 99
                decimals: 2
                notation: DoubleValidator.StandardNotation
            }
            Layout.preferredWidth: app.compactLayout ? 48 : 54
            implicitHeight: app.compactLayout ? 28 : 32
            leftPadding: 3
            rightPadding: 3
            topPadding: 0
            bottomPadding: 1
            color: enabled ? "#17252d" : "#7f8b92"
            selectedTextColor: "#ffffff"
            selectionColor: "#2e8eb0"
            font.pixelSize: app.compactLayout ? 15 : 17
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            background: Rectangle {
                radius: 4
                color: komiField.enabled ? (komiField.activeFocus ? "#ffffff" : "#f9fbfc") : "#e2e8eb"
                border.color: komiField.activeFocus ? "#2e8eb0" : "#9fb0b8"
                border.width: komiField.activeFocus ? 2 : 1
            }

            function applyValue() {
                var nextValue = Number(text)
                if (!isNaN(nextValue))
                    app.komi = Math.round(nextValue * 10) / 10
                text = Number(app.effectiveKomi()).toFixed(1)
            }

            onEditingFinished: applyValue()
            Keys.onReturnPressed: {
                applyValue()
                app.focusBoardInput()
            }
            Keys.onEnterPressed: {
                applyValue()
                app.focusBoardInput()
            }

            Connections {
                target: app
                function onKomiChanged() {
                    if (!komiField.activeFocus)
                        komiField.text = Number(app.effectiveKomi()).toFixed(1)
                }
                function onGameRuleModeChanged() {
                    if (!komiField.activeFocus)
                        komiField.text = Number(app.effectiveKomi()).toFixed(1)
                }
            }
        }

        ColumnLayout {
            visible: app.komiControlsVisible()
            spacing: 0
            Layout.minimumWidth: app.compactLayout ? 14 : 16
            Layout.preferredWidth: app.compactLayout ? 14 : 16
            Layout.maximumWidth: app.compactLayout ? 14 : 16
            Layout.preferredHeight: app.compactLayout ? 30 : 34

            StepButton {
                text: "^"
                enabled: app.gameRuleMode === app.gameRuleGo
                onClicked: app.adjustKomi(0.5)
            }

            StepButton {
                text: "v"
                enabled: app.gameRuleMode === app.gameRuleGo
                onClicked: app.adjustKomi(-0.5)
            }
        }

        Rectangle {
            visible: app.komiControlsVisible()
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: 7
            Layout.bottomMargin: 7
            color: "#c4cdd2"
        }

        Label {
            text: app.trText("stoneColor")
            color: "#26333b"
            font.pixelSize: app.compactLayout ? 13 : 15
            verticalAlignment: Text.AlignVCenter
        }

        RowLayout {
            spacing: app.compactLayout ? 4 : 5

            StoneColorButton {
                mode: app.stoneColorModeAuto
                tip: app.trText("stoneColorAutoTip")
            }

            StoneColorButton {
                mode: app.stoneColorModeBlack
                tip: app.trText("stoneColorBlackTip")
            }

            StoneColorButton {
                mode: app.stoneColorModeWhite
                tip: app.trText("stoneColorWhiteTip")
            }

            PassButton {}
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: 7
            Layout.bottomMargin: 7
            color: "#c4cdd2"
        }

        RowLayout {
            spacing: app.compactLayout ? 3 : 4

            PlayModeButton {
                mode: app.playModeAnalysis
                text: app.trText("playModeAnalysis")
            }

            PlayModeButton {
                mode: app.playModeAiBlack
                text: app.trText("playModeAiBlack")
            }

            PlayModeButton {
                mode: app.playModeAiWhite
                text: app.trText("playModeAiWhite")
            }

            PlayModeButton {
                mode: app.playModeAiSelf
                text: app.trText("playModeAiSelf")
            }
        }

        Label {
            text: app.trText("secondsPerMove")
            color: app.engineReadyForPlayMode() ? "#26333b" : "#7f8b92"
            font.pixelSize: app.compactLayout ? 12 : 14
            verticalAlignment: Text.AlignVCenter
        }

        Basic.TextField {
            id: secondsField
            enabled: app.engineReadyForPlayMode()
            text: Number(app.secondsPerMove).toFixed(1)
            selectByMouse: true
            validator: DoubleValidator {
                bottom: 0.1
                top: 999
                decimals: 1
                notation: DoubleValidator.StandardNotation
            }
            Layout.preferredWidth: app.compactLayout ? 44 : 50
            implicitHeight: app.compactLayout ? 28 : 32
            leftPadding: 3
            rightPadding: 3
            topPadding: 0
            bottomPadding: 1
            color: enabled ? "#17252d" : "#7f8b92"
            selectedTextColor: "#ffffff"
            selectionColor: "#2e8eb0"
            font.pixelSize: app.compactLayout ? 13 : 15
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            background: Rectangle {
                radius: 4
                color: secondsField.enabled ? (secondsField.activeFocus ? "#ffffff" : "#f9fbfc") : "#e2e8eb"
                border.color: secondsField.activeFocus ? "#2e8eb0" : "#b5c2c9"
                border.width: secondsField.activeFocus ? 2 : 1
            }

            function applyValue() {
                var nextValue = Number(text)
                if (!isNaN(nextValue))
                    app.secondsPerMove = Math.max(0.1, nextValue)
                text = Number(app.secondsPerMove).toFixed(1)
            }

            onEditingFinished: applyValue()
            Keys.onReturnPressed: {
                applyValue()
                app.focusBoardInput()
            }
            Keys.onEnterPressed: {
                applyValue()
                app.focusBoardInput()
            }

            Connections {
                target: app
                function onSecondsPerMoveChanged() {
                    if (!secondsField.activeFocus)
                        secondsField.text = Number(app.secondsPerMove).toFixed(1)
                }
            }
        }

        Label {
            text: app.trText("secondsUnit")
            color: app.engineReadyForPlayMode() ? "#26333b" : "#7f8b92"
            font.pixelSize: app.compactLayout ? 12 : 14
            verticalAlignment: Text.AlignVCenter
        }

        Item { Layout.fillWidth: true }
    }

    component StepButton: Rectangle {
        id: stepButton
        signal clicked()
        property string text: ""

        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 2
        opacity: enabled ? 1 : 0.48
        color: stepMouse.pressed ? "#cfdbe1" : stepMouse.containsMouse ? "#dde6eb" : "#f7fafb"
        border.color: "#aebbc2"

        Text {
            anchors.centerIn: parent
            text: stepButton.text
            color: "#26333b"
            font.pixelSize: app.compactLayout ? 9 : 10
            font.bold: true
        }

        MouseArea {
            id: stepMouse
            anchors.fill: parent
            enabled: stepButton.enabled
            hoverEnabled: true
            onClicked: {
                stepButton.clicked()
                app.focusBoardInput()
            }
        }
    }

    component StoneColorButton: Rectangle {
        id: colorButton
        property int mode: 0
        property string tip: ""
        readonly property bool selected: app.stoneColorMode === mode

        Layout.preferredWidth: app.compactLayout ? 34 : 38
        Layout.preferredHeight: app.compactLayout ? 28 : 32
        radius: 4
        color: selected ? "#d8e9f1" : colorMouse.containsMouse ? "#eef5f8" : "#f8fafb"
        border.color: selected ? "#2e8eb0" : "#b5c2c9"
        border.width: selected ? 2 : 1

        Item {
            anchors.fill: parent

            Rectangle {
                visible: colorButton.mode === app.stoneColorModeAuto
                x: parent.width / 2 - width + 3
                y: parent.height / 2 - height / 2
                width: app.currentPlayer === 1 ? 17 : 13
                height: width
                radius: width / 2
                color: "#050607"
                border.color: "#1a1d20"
            }

            Rectangle {
                visible: colorButton.mode === app.stoneColorModeAuto
                x: parent.width / 2 - 2
                y: parent.height / 2 - height / 2
                width: app.currentPlayer === 2 ? 17 : 13
                height: width
                radius: width / 2
                color: "#ffffff"
                border.color: "#aeb8be"
            }

            Rectangle {
                visible: colorButton.mode === app.stoneColorModeBlack
                anchors.centerIn: parent
                width: app.compactLayout ? 18 : 21
                height: width
                radius: width / 2
                color: "#050607"
                border.color: "#1a1d20"
            }

            Rectangle {
                visible: colorButton.mode === app.stoneColorModeWhite
                anchors.centerIn: parent
                width: app.compactLayout ? 18 : 21
                height: width
                radius: width / 2
                color: "#ffffff"
                border.color: "#aeb8be"
            }
        }

        ToolTip.visible: colorMouse.containsMouse
        ToolTip.text: tip

        MouseArea {
            id: colorMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                app.stoneColorMode = colorButton.mode
                app.focusBoardInput()
            }
        }
    }

    component PassButton: Rectangle {
        id: passButton

        Layout.preferredWidth: app.compactLayout ? 44 : 52
        Layout.preferredHeight: app.compactLayout ? 28 : 32
        radius: 4
        color: passMouse.pressed ? "#d5e1e8" : passMouse.containsMouse ? "#eef5f8" : "#f8fafb"
        border.color: "#b5c2c9"
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: app.trText("passMove")
            color: "#26333b"
            font.pixelSize: app.compactLayout ? 11 : 12
            font.bold: true
        }

        ToolTip.visible: passMouse.containsMouse
        ToolTip.text: app.trText("passMove") + " (P)"

        MouseArea {
            id: passMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                app.passMove()
                app.focusBoardInput()
            }
        }
    }

    component PlayModeButton: Rectangle {
        id: modeButton
        property int mode: 0
        property string text: ""
        readonly property bool selected: app.playMode === mode

        enabled: app.engineReadyForPlayMode()
        Layout.preferredWidth: app.compactLayout ? 54 : 68
        Layout.preferredHeight: app.compactLayout ? 28 : 32
        radius: 4
        opacity: enabled ? 1 : 0.48
        color: selected ? "#d8e9f1" : modeMouse.containsMouse ? "#eef5f8" : "#f8fafb"
        border.color: selected ? "#2e8eb0" : "#b5c2c9"
        border.width: selected ? 2 : 1

        Text {
            anchors.centerIn: parent
            width: parent.width - 6
            text: modeButton.text
            color: "#26333b"
            font.pixelSize: app.compactLayout ? 10 : 12
            font.bold: modeButton.selected
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        MouseArea {
            id: modeMouse
            anchors.fill: parent
            enabled: modeButton.enabled
            hoverEnabled: true
            onClicked: {
                app.setPlayMode(modeButton.mode)
                app.focusBoardInput()
            }
        }
    }

    component RuleButton: Rectangle {
        id: ruleButton
        property int mode: 0
        property string text: ""
        readonly property bool selected: app.gameRuleMode === mode

        Layout.preferredWidth: app.compactLayout ? 44 : 56
        Layout.preferredHeight: app.compactLayout ? 28 : 32
        radius: 4
        color: selected ? "#d8e9f1" : ruleMouse.containsMouse ? "#eef5f8" : "#f8fafb"
        border.color: selected ? "#2e8eb0" : "#b5c2c9"
        border.width: selected ? 2 : 1

        Text {
            anchors.centerIn: parent
            text: ruleButton.text
            color: "#26333b"
            font.pixelSize: app.compactLayout ? 12 : 14
            font.bold: ruleButton.selected
        }

        MouseArea {
            id: ruleMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                app.requestRuleModeChange(ruleButton.mode)
                app.focusBoardInput()
            }
        }
    }
}
