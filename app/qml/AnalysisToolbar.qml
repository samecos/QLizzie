import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "InkTheme.js" as InkTheme

Rectangle {
    id: toolbar
    required property var app

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    height: app.analysisToolbarHeight
    color: InkTheme.colors.paper
    border.color: InkTheme.colors.inkLight

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: app.compactLayout ? 8 : 12
        anchors.rightMargin: app.compactLayout ? 8 : 12
        spacing: app.compactLayout ? 7 : 11

        RuleSettingsButton {}

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: 7
            Layout.bottomMargin: 7
            color: InkTheme.colors.inkLight
        }

        Label {
            visible: app.boardPresentationOptions().length > 1
            text: app.trText("boardPresentation")
            color: InkTheme.colors.inkDeep
            font.pixelSize: app.compactLayout ? 13 : 15
            verticalAlignment: Text.AlignVCenter
        }

        ToolbarPresentationCombo {
            app: toolbar.app
            visible: app.boardPresentationOptions().length > 1
            options: app.boardPresentationOptions()
            currentIndex: app.boardPresentationCurrentIndex()
            Layout.preferredWidth: app.compactLayout ? 134 : 178
            implicitHeight: app.compactLayout ? 28 : 32
            onPicked: function(index) {
                app.setBoardPresentationFromIndex(index)
                app.focusBoardInput()
            }
        }

        Label {
            visible: app.hexBoardStyleOptions().length > 1
            text: app.trText("hexBoardStyle")
            color: InkTheme.colors.inkDeep
            font.pixelSize: app.compactLayout ? 13 : 15
            verticalAlignment: Text.AlignVCenter
        }

        ToolbarPresentationCombo {
            app: toolbar.app
            visible: app.hexBoardStyleOptions().length > 1
            options: app.hexBoardStyleOptions()
            currentIndex: app.hexBoardStyleCurrentIndex()
            Layout.preferredWidth: app.compactLayout ? 116 : 150
            implicitHeight: app.compactLayout ? 28 : 32
            onPicked: function(index) {
                app.setHexBoardStyleFromIndex(index)
                app.focusBoardInput()
            }
        }

        Label {
            visible: app.hexBoardRotationOptions().length > 1
            text: app.trText("hexBoardRotation")
            color: InkTheme.colors.inkDeep
            font.pixelSize: app.compactLayout ? 13 : 15
            verticalAlignment: Text.AlignVCenter
        }

        ToolbarPresentationCombo {
            app: toolbar.app
            visible: app.hexBoardRotationOptions().length > 1
            options: app.hexBoardRotationOptions()
            currentIndex: app.hexBoardRotationCurrentIndex()
            Layout.preferredWidth: app.compactLayout ? 132 : 178
            implicitHeight: app.compactLayout ? 28 : 32
            onPicked: function(index) {
                app.setHexBoardRotationFromIndex(index)
                app.focusBoardInput()
            }
        }

        Rectangle {
            visible: app.komiControlsVisible()
                     || app.boardPresentationOptions().length > 1
                     || app.hexBoardStyleOptions().length > 1
                     || app.hexBoardRotationOptions().length > 1
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: 7
            Layout.bottomMargin: 7
            color: InkTheme.colors.inkLight
        }

        Label {
            visible: app.komiControlsVisible()
            text: app.trText("komi")
            color: app.ruleUsesGoCapture() ? InkTheme.colors.inkDeep : InkTheme.colors.ink
            font.pixelSize: app.compactLayout ? 13 : 15
            verticalAlignment: Text.AlignVCenter
        }

        Basic.TextField {
            id: komiField
            visible: app.komiControlsVisible()
            enabled: app.ruleUsesGoCapture()
            text: Number(app.effectiveKomi()).toFixed(1)
            selectByMouse: true
            validator: DoubleValidator {
                bottom: -app.maxKomiMagnitude
                top: app.maxKomiMagnitude
                decimals: 2
                notation: DoubleValidator.StandardNotation
            }
            Layout.preferredWidth: app.compactLayout ? 72 : 82
            implicitHeight: app.compactLayout ? 28 : 32
            leftPadding: 3
            rightPadding: 3
            topPadding: 0
            bottomPadding: 1
            color: enabled ? InkTheme.colors.inkDeep : InkTheme.colors.ink
            selectedTextColor: InkTheme.colors.white
            selectionColor: InkTheme.colors.cinnabarLight
            font.pixelSize: app.compactLayout ? 15 : 17
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            background: Rectangle {
                radius: 4
                color: komiField.enabled ? (komiField.activeFocus ? InkTheme.colors.white : InkTheme.colors.paper) : InkTheme.colors.paperDark
                border.color: komiField.activeFocus ? InkTheme.colors.cinnabar : InkTheme.colors.inkLight
                border.width: komiField.activeFocus ? 2 : 1
            }

            function applyValue() {
                var nextValue = Number(text)
                if (!isNaN(nextValue))
                    app.setKomiValue(nextValue)
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
                enabled: app.ruleUsesGoCapture()
                onClicked: app.adjustKomi(0.5)
            }

            StepButton {
                text: "v"
                enabled: app.ruleUsesGoCapture()
                onClicked: app.adjustKomi(-0.5)
            }
        }

        Rectangle {
            visible: app.komiControlsVisible()
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: 7
            Layout.bottomMargin: 7
            color: InkTheme.colors.inkLight
        }

        Label {
            text: app.trText("stoneColor")
            color: InkTheme.colors.inkDeep
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
            color: InkTheme.colors.inkLight
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
            color: app.engineReadyForPlayMode() ? InkTheme.colors.inkDeep : InkTheme.colors.ink
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
            color: enabled ? InkTheme.colors.inkDeep : InkTheme.colors.ink
            selectedTextColor: InkTheme.colors.white
            selectionColor: InkTheme.colors.cinnabarLight
            font.pixelSize: app.compactLayout ? 13 : 15
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            background: Rectangle {
                radius: 4
                color: secondsField.enabled ? (secondsField.activeFocus ? InkTheme.colors.white : InkTheme.colors.paper) : InkTheme.colors.paperDark
                border.color: secondsField.activeFocus ? InkTheme.colors.cinnabar : InkTheme.colors.inkLight
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
            color: app.engineReadyForPlayMode() ? InkTheme.colors.inkDeep : InkTheme.colors.ink
            font.pixelSize: app.compactLayout ? 12 : 14
            verticalAlignment: Text.AlignVCenter
        }

        Item { Layout.fillWidth: true }
    }

    component RuleSettingsButton: Rectangle {
        id: ruleSettingsButton

        Layout.preferredWidth: app.compactLayout ? 84 : 104
        Layout.preferredHeight: app.compactLayout ? 28 : 32
        radius: 6
        color: ruleSettingsMouse.pressed ? InkTheme.colors.paperDark
             : ruleSettingsMouse.containsMouse ? InkTheme.colors.paper : InkTheme.colors.white
        border.color: InkTheme.colors.ink
        border.width: 1

        Text {
            anchors.centerIn: parent
            width: parent.width - 10
            text: app.trText("ruleSettingsButton")
            color: InkTheme.colors.inkDeep
            font.family: InkTheme.fonts.title
            font.pixelSize: app.compactLayout ? 12 : 13
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        ToolTip.visible: ruleSettingsMouse.containsMouse
        ToolTip.text: app.ruleVariantText()

        MouseArea {
            id: ruleSettingsMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                app.openRuleVariantDialog()
                app.focusBoardInput()
            }
        }
    }

    component StepButton: Rectangle {
        id: stepButton
        signal clicked()
        property string text: ""

        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 3
        opacity: enabled ? 1 : 0.48
        color: stepMouse.pressed ? InkTheme.colors.paperDark : stepMouse.containsMouse ? InkTheme.colors.paper : InkTheme.colors.white
        border.color: InkTheme.colors.inkLight

        Text {
            anchors.centerIn: parent
            text: stepButton.text
            color: InkTheme.colors.inkDeep
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
        radius: 6
        color: selected ? InkTheme.colors.inkWash : colorMouse.containsMouse ? InkTheme.colors.paper : InkTheme.colors.white
        border.color: selected ? InkTheme.colors.cinnabar : InkTheme.colors.inkLight
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
                color: InkTheme.colors.sumi
                border.color: InkTheme.colors.ink
            }

            Rectangle {
                visible: colorButton.mode === app.stoneColorModeAuto
                x: parent.width / 2 - 2
                y: parent.height / 2 - height / 2
                width: app.currentPlayer === 2 ? 17 : 13
                height: width
                radius: width / 2
                color: InkTheme.colors.white
                border.color: InkTheme.colors.inkLight
            }

            Rectangle {
                visible: colorButton.mode === app.stoneColorModeBlack
                anchors.centerIn: parent
                width: app.compactLayout ? 18 : 21
                height: width
                radius: width / 2
                color: InkTheme.colors.sumi
                border.color: InkTheme.colors.ink
            }

            Rectangle {
                visible: colorButton.mode === app.stoneColorModeWhite
                anchors.centerIn: parent
                width: app.compactLayout ? 18 : 21
                height: width
                radius: width / 2
                color: InkTheme.colors.white
                border.color: InkTheme.colors.inkLight
            }
        }

        ToolTip.visible: colorMouse.containsMouse
        ToolTip.text: tip

        MouseArea {
            id: colorMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                app.setStoneColorMode(colorButton.mode)
                app.focusBoardInput()
            }
        }
    }

    component PassButton: Rectangle {
        id: passButton

        Layout.preferredWidth: app.compactLayout ? 44 : 52
        Layout.preferredHeight: app.compactLayout ? 28 : 32
        radius: 6
        color: passMouse.pressed ? InkTheme.colors.paperDark : passMouse.containsMouse ? InkTheme.colors.paper : InkTheme.colors.white
        border.color: InkTheme.colors.inkLight
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: app.trText("passMove")
            color: InkTheme.colors.inkDeep
            font.family: InkTheme.fonts.title
            font.pixelSize: app.compactLayout ? 11 : 12
            font.bold: true
        }

        ToolTip.visible: passMouse.containsMouse
        ToolTip.text: app.trText("passMoveTooltip")

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
        radius: 6
        opacity: enabled ? 1 : 0.48
        color: selected ? InkTheme.colors.inkWash : modeMouse.containsMouse ? InkTheme.colors.paper : InkTheme.colors.white
        border.color: selected ? InkTheme.colors.cinnabar : InkTheme.colors.inkLight
        border.width: selected ? 2 : 1

        Text {
            anchors.centerIn: parent
            width: parent.width - 6
            text: modeButton.text
            color: InkTheme.colors.inkDeep
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
        radius: 6
        color: selected ? InkTheme.colors.inkWash : ruleMouse.containsMouse ? InkTheme.colors.paper : InkTheme.colors.white
        border.color: selected ? InkTheme.colors.cinnabar : InkTheme.colors.inkLight
        border.width: selected ? 2 : 1

        Text {
            anchors.centerIn: parent
            text: ruleButton.text
            color: InkTheme.colors.inkDeep
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

    component ToolbarPresentationCombo: Basic.ComboBox {
        id: control

        required property var app
        property var options: []
        signal picked(int index)

        model: options
        textRole: "label"
        valueRole: "value"
        leftPadding: 9
        rightPadding: 28
        onActivated: function(index) { picked(index) }

        contentItem: Text {
            leftPadding: control.leftPadding
            rightPadding: control.rightPadding
            text: control.displayText
            color: InkTheme.colors.inkDeep
            font.pixelSize: control.app.compactLayout ? 13 : 15
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        indicator: Canvas {
            id: toolbarComboArrow
            x: control.width - width - 9
            y: Math.round((control.height - height) / 2)
            width: 12
            height: 8

            Connections {
                target: control
                function onHoveredChanged() { toolbarComboArrow.requestPaint() }
                function onPressedChanged() { toolbarComboArrow.requestPaint() }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = control.pressed ? InkTheme.colors.cinnabar : InkTheme.colors.ink
                ctx.beginPath()
                ctx.moveTo(1, 1)
                ctx.lineTo(width - 1, 1)
                ctx.lineTo(width / 2, height - 1)
                ctx.closePath()
                ctx.fill()
            }
        }

        background: Rectangle {
            radius: 6
            color: control.pressed ? InkTheme.colors.paperDark
                                 : control.hovered ? InkTheme.colors.paper : InkTheme.colors.white
            border.color: control.activeFocus ? InkTheme.colors.cinnabar : InkTheme.colors.inkLight
            border.width: control.activeFocus ? 2 : 1
        }

        delegate: Basic.ItemDelegate {
            id: optionDelegate

            width: control.width
            height: control.app.compactLayout ? 30 : 34
            highlighted: control.highlightedIndex === index
            hoverEnabled: true

            contentItem: Text {
                text: modelData.label
                color: InkTheme.colors.inkDeep
                font.pixelSize: control.app.compactLayout ? 12 : 13
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
                elide: Text.ElideRight
            }

            background: Rectangle {
                color: optionDelegate.highlighted ? InkTheme.colors.inkWash
                                                  : optionDelegate.hovered ? InkTheme.colors.paper : InkTheme.colors.white
            }
        }
    }
}
