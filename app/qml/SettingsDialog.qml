import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

Basic.Dialog {
    id: settingsDialog

    required property var app
    required property var controller
    property int currentPage: 0
    property bool syncingEngineCommand: false

    modal: true
    title: app.trText("settingsDialogTitle")
    closePolicy: Popup.CloseOnEscape
    padding: 18
    width: Math.min(820, app.width - 70)
    height: Math.min(680, app.height - 70)
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    function openPage(pageIndex) {
        currentPage = app.clamp(Math.round(pageIndex), 0, 2)
        syncFields()
        open()
    }

    function syncFields() {
        boardXSpin.value = app.boardSizeX
        boardYSpin.value = app.boardSizeY
        backgroundColorField.text = colorToText(app.backgroundColor)
        boardColorField.text = colorToText(app.boardWoodColor)
        candidateTextColorField.text = colorToText(app.candidateLabelTextColor)
        syncingEngineCommand = true
        engineCommandEdit.text = controller ? controller.command : ""
        syncingEngineCommand = false
    }

    function chooseBoardPreset(size) {
        boardXSpin.value = size
        boardYSpin.value = size
    }

    function applyEngineCommand() {
        if (!app.engineCommandEditable())
            return
        if (controller && controller.command !== engineCommandEdit.text)
            controller.command = engineCommandEdit.text
    }

    function colorToText(colorValue) {
        var text = String(colorValue)
        if (text.length === 9 && text[0] === "#" && text.slice(1, 3).toLowerCase() === "ff")
            return "#" + text.slice(3)
        return text
    }

    function applyColorText(field, setter, fallback) {
        var text = field.text.trim()
        if (/^#[0-9a-fA-F]{6}$/.test(text))
            setter(text)
        field.text = colorToText(fallback())
    }

    onOpened: syncFields()
    onClosed: {
        applyEngineCommand()
        app.requestBoardDimensionsChange(boardXSpin.value, boardYSpin.value)
        app.onSettingsDialogClosed()
        app.focusBoardInput()
    }

    background: Rectangle {
        radius: 10
        color: "#f8fbfd"
        border.color: "#8ea5b1"
        border.width: 1
    }

    header: Rectangle {
        height: 52
        color: "#e6eff4"
        radius: 10

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.radius
            color: parent.color
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: "#c5d4dc"
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            text: settingsDialog.title
            color: "#14242e"
            font.pixelSize: 17
            font.bold: true
            elide: Text.ElideRight
        }
    }

    contentItem: RowLayout {
        implicitWidth: 780
        implicitHeight: 570
        spacing: 14

        Rectangle {
            Layout.preferredWidth: 156
            Layout.fillHeight: true
            radius: 6
            color: "#e7eef3"
            border.color: "#c7d4dc"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                PageButton { page: 0; text: app.trText("settingsPageBasic") }
                PageButton { page: 1; text: app.trText("settingsPageVisual") }
                PageButton { page: 2; text: app.trText("settingsPageEngine") }
                Item { Layout.fillHeight: true }
            }
        }

        Flickable {
            id: pageFlick
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: pageColumn.implicitHeight

            ScrollBar.vertical: AppScrollBar {
                policy: pageFlick.contentHeight > pageFlick.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
            }

            ColumnLayout {
                id: pageColumn
                width: pageFlick.width
                spacing: 14

                SectionBox {
                    visible: settingsDialog.currentPage === 0
                    title: app.trText("boardSize")

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Repeater {
                                model: [5, 7, 9, 13, 19]
                                SmallModeButton {
                                    text: modelData + "x" + modelData
                                    visible: app.boardSizePresetAllowed(modelData)
                                    selected: boardXSpin.value === modelData && boardYSpin.value === modelData
                                    onClicked: settingsDialog.chooseBoardPreset(modelData)
                                }
                            }

                            Item { Layout.fillWidth: true }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label { text: app.trText("boardSizeX"); color: "#24313a" }

                            SpinBox {
                                id: boardXSpin
                                from: app.minBoardSize
                                to: app.maxBoardSize
                                enabled: app.customBoardSizeAllowed()
                                editable: true
                                Layout.preferredWidth: 84
                            }

                            Label { text: "x " + app.trText("boardSizeY"); color: "#24313a" }

                            SpinBox {
                                id: boardYSpin
                                from: app.minBoardSize
                                to: app.maxBoardSize
                                enabled: app.customBoardSizeAllowed()
                                editable: true
                                Layout.preferredWidth: 84
                            }

                            Item { Layout.fillWidth: true }

                            SavePromptButton {
                                text: app.trText("apply")
                                primary: true
                                onClicked: app.requestBoardDimensionsChange(boardXSpin.value, boardYSpin.value)
                            }
                        }
                    }
                }

                SectionBox {
                    visible: settingsDialog.currentPage === 0
                    title: app.trText("gameKindRuleSettings")

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                text: app.trText("gameRule")
                                color: "#24313a"
                                Layout.preferredWidth: 88
                            }

                            SmallModeButton {
                                text: app.trText("gameRuleGo")
                                selected: app.gameRuleMode === app.gameRuleGo
                                enabled: app.ruleModeAllowedForPackage(app.gameRuleGo)
                                onClicked: app.requestRuleModeChange(app.gameRuleGo)
                            }

                            SmallModeButton {
                                text: app.trText("gameRuleGomoku")
                                selected: app.gameRuleMode === app.gameRuleGomoku
                                enabled: app.ruleModeAllowedForPackage(app.gameRuleGomoku)
                                onClicked: app.requestRuleModeChange(app.gameRuleGomoku)
                            }

                            RuleVariantComboBox {
                                app: settingsDialog.app
                                Layout.preferredWidth: 220
                                implicitHeight: 32
                            }

                            Item { Layout.fillWidth: true }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            visible: app.komiControlsVisible()

                            Label {
                                text: app.trText("komi")
                                color: "#24313a"
                                Layout.preferredWidth: 88
                            }

                            SpinBox {
                                from: -200
                                to: 200
                                value: Math.round(app.effectiveKomi() * 2)
                                editable: true
                                Layout.preferredWidth: 96
                                textFromValue: function(value) { return (value / 2).toFixed(1) }
                                valueFromText: function(text) { return Math.round(Number(text) * 2) }
                                onValueModified: app.komi = value / 2
                            }
                        }
                    }
                }

                SectionBox {
                    visible: settingsDialog.currentPage === 0
                    title: app.trText("basicGameSettings")

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                text: app.trText("stoneColor")
                                color: "#24313a"
                                Layout.preferredWidth: 100
                            }

                            SmallModeButton {
                                text: app.trText("stoneColorAuto")
                                selected: app.stoneColorMode === app.stoneColorModeAuto
                                onClicked: app.stoneColorMode = app.stoneColorModeAuto
                            }

                            SmallModeButton {
                                text: app.trText("stoneColorBlack")
                                selected: app.stoneColorMode === app.stoneColorModeBlack
                                onClicked: app.stoneColorMode = app.stoneColorModeBlack
                            }

                            SmallModeButton {
                                text: app.trText("stoneColorWhite")
                                selected: app.stoneColorMode === app.stoneColorModeWhite
                                onClicked: app.stoneColorMode = app.stoneColorModeWhite
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                text: app.trText("moveNumberDisplay")
                                color: "#24313a"
                                Layout.preferredWidth: 120
                            }

                            ComboBox {
                                model: [
                                    app.trText("moveNumberAll"),
                                    app.trText("moveNumberLastOnly"),
                                    app.trText("moveNumberHidden")
                                ]
                                currentIndex: app.moveNumberDisplayMode
                                Layout.preferredWidth: 180
                                onActivated: function(index) { app.moveNumberDisplayMode = index }
                            }
                        }
                    }
                }

                SectionBox {
                    visible: settingsDialog.currentPage === 0
                    title: app.trText("gamePlaySettings")

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                text: app.trText("secondsPerMove")
                                color: "#24313a"
                                Layout.preferredWidth: 120
                            }

                            SpinBox {
                                from: 1
                                to: 999
                                value: Math.round(app.secondsPerMove * 10)
                                editable: true
                                Layout.preferredWidth: 110
                                textFromValue: function(value) { return (value / 10).toFixed(1) }
                                valueFromText: function(text) { return Math.round(Number(text) * 10) }
                                onValueModified: app.secondsPerMove = value / 10
                            }

                            Label {
                                text: app.trText("secondsUnit")
                                color: "#52636d"
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                text: app.trText("resignSettings")
                                color: "#24313a"
                                Layout.preferredWidth: 120
                            }

                            Label { text: app.trText("resignAfterMove"); color: "#52636d" }
                            SpinBox {
                                from: 1
                                to: 500
                                value: app.resignMinMove
                                Layout.preferredWidth: 82
                                onValueModified: app.resignMinMove = value
                            }

                            Label { text: app.trText("resignBelowWinrate"); color: "#52636d" }
                            SpinBox {
                                from: 0
                                to: 100
                                value: Math.round(app.resignWinrateThreshold)
                                Layout.preferredWidth: 82
                                onValueModified: app.resignWinrateThreshold = value
                            }
                        }
                    }
                }

                SectionBox {
                    visible: settingsDialog.currentPage === 1
                    title: app.trText("visualSettings")

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        ColorRow {
                            label: app.trText("backgroundColor")
                            field: backgroundColorField
                            onApply: settingsDialog.applyColorText(backgroundColorField,
                                                                    function(value) { app.backgroundColor = value },
                                                                    function() { return app.backgroundColor })
                        }

                        ColorRow {
                            label: app.trText("boardColor")
                            field: boardColorField
                            onApply: settingsDialog.applyColorText(boardColorField,
                                                                    function(value) { app.boardWoodColor = value },
                                                                    function() { return app.boardWoodColor })
                        }

                        SliderRow {
                            label: app.trText("stoneSize")
                            from: app.minStoneScale
                            to: 1.05
                            value: app.stoneScale
                            decimals: 2
                            onMoved: function(v) { app.stoneScale = v }
                        }

                        SliderRow {
                            label: app.trText("gridPointOpacity")
                            from: 0.25
                            to: 1.0
                            value: app.gridOpacity
                            decimals: 2
                            onMoved: function(v) { app.gridOpacity = v }
                        }

                        SliderRow {
                            label: app.trText("gridLineWidth")
                            from: 0.5
                            to: 4.0
                            value: app.gridLineWidth
                            decimals: 1
                            onMoved: function(v) { app.gridLineWidth = v }
                        }

                        SliderRow {
                            label: app.trText("selectedPointSize")
                            from: 0.45
                            to: 1.25
                            value: app.selectedPointScale
                            decimals: 2
                            onMoved: function(v) { app.selectedPointScale = v }
                        }

                        SavePromptButton {
                            text: app.trText("reset")
                            Layout.preferredWidth: 120
                            onClicked: {
                                app.resetVisualSettings()
                                settingsDialog.syncFields()
                            }
                        }
                    }
                }

                SectionBox {
                    visible: settingsDialog.currentPage === 1
                    title: app.trText("candidateLabelSettings")

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            CheckBox {
                                text: app.trText("candidateWinrate")
                                checked: app.candidateWinrateLabelVisible
                                onToggled: app.candidateWinrateLabelVisible = checked
                            }

                            CheckBox {
                                text: app.trText("candidateVisits")
                                checked: app.candidateVisitsLabelVisible
                                onToggled: app.candidateVisitsLabelVisible = checked
                            }

                            CheckBox {
                                text: app.trText("candidateRingVisible")
                                checked: app.candidateRingVisible
                                onToggled: app.candidateRingVisible = checked
                            }
                        }

                        SliderRow {
                            label: app.trText("candidateDisplayCount")
                            from: 0
                            to: 20
                            value: app.candidateDisplayCount
                            decimals: 0
                            onMoved: function(v) { app.candidateDisplayCount = Math.round(v) }
                        }

                        SliderRow {
                            label: app.trText("candidateMinVisitRatio")
                            from: 0
                            to: 1
                            value: app.candidateMinVisitRatio
                            decimals: 2
                            onMoved: function(v) { app.candidateMinVisitRatio = v }
                        }

                        ColorRow {
                            label: app.trText("candidateLabelTextColor")
                            field: candidateTextColorField
                            onApply: settingsDialog.applyColorText(candidateTextColorField,
                                                                    function(value) { app.candidateLabelTextColor = value },
                                                                    function() { return app.candidateLabelTextColor })
                        }
                    }
                }

                SectionBox {
                    visible: settingsDialog.currentPage === 2
                    title: app.trText("engine")

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        Label {
                            text: app.trText("engineCommand")
                            color: "#24313a"
                            font.bold: true
                        }

                        Basic.TextArea {
                            id: engineCommandEdit
                            Layout.fillWidth: true
                            Layout.preferredHeight: 82
                            enabled: app.engineCommandEditable()
                            wrapMode: TextEdit.WrapAnywhere
                            selectByMouse: true
                            color: enabled ? "#13232d" : "#78868d"
                            onTextChanged: {
                                if (!settingsDialog.syncingEngineCommand)
                                    settingsDialog.applyEngineCommand()
                            }
                            background: Rectangle {
                                radius: 5
                                color: engineCommandEdit.enabled ? "#ffffff" : "#edf2f4"
                                border.color: engineCommandEdit.activeFocus ? "#2388b8" : "#b7c5cc"
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            SavePromptButton {
                                text: app.trText("engineStart")
                                primary: true
                                onClicked: app.startEngine()
                            }

                            SavePromptButton {
                                text: app.trText("engineStop")
                                onClicked: app.stopEngine()
                            }

                            SavePromptButton {
                                text: app.trText("engineRestart")
                                onClicked: app.restartEngine()
                            }

                            SavePromptButton {
                                text: app.trText("engineCommunicationLog")
                                onClicked: app.openEngineCommunicationLog()
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                text: app.trText("analysisIntervalCentiseconds")
                                color: "#24313a"
                                Layout.preferredWidth: 240
                            }

                            SpinBox {
                                from: 1
                                to: 1000
                                value: app.analysisIntervalCentiseconds
                                Layout.preferredWidth: 100
                                onValueModified: app.analysisIntervalCentiseconds = value
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                text: app.trText("maxAnalysisSeconds")
                                color: "#24313a"
                                Layout.preferredWidth: 240
                            }

                            SpinBox {
                                from: 0
                                to: 3600
                                value: app.maxAnalysisSeconds
                                Layout.preferredWidth: 100
                                onValueModified: app.maxAnalysisSeconds = value
                            }
                        }
                    }
                }
            }
        }
    }

    footer: Rectangle {
        implicitHeight: 62
        color: "#f8fbfd"
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
            anchors.margins: 16

            Item { Layout.fillWidth: true }

            SavePromptButton {
                text: app.trText("close")
                primary: true
                Layout.preferredWidth: 110
                onClicked: settingsDialog.close()
            }
        }
    }

    component PageButton: Rectangle {
        id: pageButton
        required property int page
        property string text: ""
        readonly property bool selected: settingsDialog.currentPage === page

        Layout.fillWidth: true
        Layout.preferredHeight: 36
        radius: 5
        color: selected ? "#d8e9f1" : pageMouse.containsMouse ? "#f3f8fb" : "#ffffff"
        border.color: selected ? "#2e8eb0" : "#c7d4dc"
        border.width: selected ? 2 : 1

        Text {
            anchors.centerIn: parent
            text: pageButton.text
            color: "#1b2d36"
            font.pixelSize: 14
            font.bold: pageButton.selected
        }

        MouseArea {
            id: pageMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: settingsDialog.currentPage = pageButton.page
        }
    }

    component SectionBox: Rectangle {
        id: section
        property string title: ""
        default property alias content: sectionBody.data

        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(72, sectionColumn.implicitHeight + 28)
        radius: 6
        color: "#f5f8fa"
        border.color: "#c7d4dc"

        ColumnLayout {
            id: sectionColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 10

            Label {
                text: section.title
                color: "#17212a"
                font.pixelSize: 15
                font.bold: true
                Layout.fillWidth: true
            }

            ColumnLayout {
                id: sectionBody
                Layout.fillWidth: true
                spacing: 10
            }
        }
    }

    component SmallModeButton: Rectangle {
        id: modeButton
        property string text: ""
        property bool selected: false
        signal clicked()

        Layout.preferredWidth: Math.max(62, label.implicitWidth + 22)
        Layout.preferredHeight: 30
        radius: 4
        opacity: enabled ? 1 : 0.45
        color: selected ? "#d8e9f1" : modeMouse.containsMouse ? "#eef5f8" : "#ffffff"
        border.color: selected ? "#2e8eb0" : "#b5c2c9"
        border.width: selected ? 2 : 1

        Text {
            id: label
            anchors.centerIn: parent
            text: modeButton.text
            color: "#26333b"
            font.pixelSize: 13
            font.bold: modeButton.selected
        }

        MouseArea {
            id: modeMouse
            anchors.fill: parent
            enabled: modeButton.enabled
            hoverEnabled: true
            onClicked: modeButton.clicked()
        }
    }

    component SliderRow: RowLayout {
        id: sliderRow
        property string label: ""
        property real from: 0
        property real to: 1
        property real value: 0
        property int decimals: 2
        signal moved(real value)

        Layout.fillWidth: true
        spacing: 10

        Label {
            text: sliderRow.label
            color: "#24313a"
            Layout.preferredWidth: 190
        }

        Slider {
            from: sliderRow.from
            to: sliderRow.to
            value: sliderRow.value
            Layout.fillWidth: true
            onMoved: sliderRow.moved(value)
        }

        Label {
            text: Number(sliderRow.value).toFixed(sliderRow.decimals)
            color: "#52636d"
            horizontalAlignment: Text.AlignRight
            Layout.preferredWidth: 56
        }
    }

    component ColorRow: RowLayout {
        id: colorRow
        property string label: ""
        property var field
        signal apply()

        Layout.fillWidth: true
        spacing: 10

        Label {
            text: colorRow.label
            color: "#24313a"
            Layout.preferredWidth: 190
        }

        Basic.TextField {
            id: colorField
            text: colorRow.field ? colorRow.field.text : ""
            selectByMouse: true
            Layout.preferredWidth: 120
            onTextChanged: if (colorRow.field) colorRow.field.text = text
            onEditingFinished: colorRow.apply()
        }

        SavePromptButton {
            text: app.trText("apply")
            Layout.preferredWidth: 88
            onClicked: colorRow.apply()
        }
    }

    QtObject { id: backgroundColorField; property string text: "" }
    QtObject { id: boardColorField; property string text: "" }
    QtObject { id: candidateTextColorField; property string text: "" }
}
