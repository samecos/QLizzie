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
        candidateFirstTextColorField.text = colorToText(app.candidateFirstLabelTextColor)
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
            Layout.preferredWidth: 136
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

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                text: app.trText("coordinateDisplay")
                                color: "#24313a"
                                Layout.preferredWidth: 150
                            }

                            ComboBox {
                                model: [
                                    app.trText("coordinateDisplayGoNoI"),
                                    app.trText("coordinateDisplayGomokuWithI"),
                                    app.trText("coordinateDisplayNumeric")
                                ]
                                currentIndex: app.effectiveCoordinateDisplayMode()
                                enabled: !app.coordinateDisplayForcedNumeric()
                                Layout.preferredWidth: 210
                                onActivated: function(index) { app.setCoordinateDisplayMode(index) }
                            }

                            Label {
                                text: app.coordinateDisplayForcedNumeric() ? app.trText("coordinateDisplayForcedNumeric") : ""
                                color: "#6a7a84"
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }

                        SliderRow {
                            label: app.trText("stoneSize")
                            from: app.minStoneScale
                            to: 1.0
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

                        SelectionPreview {
                            Layout.fillWidth: true
                        }

                        SliderRow {
                            label: app.trText("selectedPointSize")
                            from: 0.5
                            to: 1.0
                            value: app.selectedPointScale
                            decimals: 2
                            onMoved: function(v) { app.selectedPointScale = v }
                        }

                        SliderRow {
                            label: app.trText("moveNumberLabelScale")
                            from: 0.5
                            to: 2.0
                            value: app.moveNumberLabelScale
                            decimals: 2
                            percent: true
                            onMoved: function(v) { app.moveNumberLabelScale = v }
                        }

                        SavePromptButton {
                            text: app.trText("reset")
                            Layout.preferredWidth: 120
                            onClicked: {
                                app.resetBoardVisualSettings()
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
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Item {
                                Layout.preferredWidth: 88
                                Layout.preferredHeight: 178

                                CandidateMarkerView {
                                    x: 4
                                    y: 0
                                    width: 80
                                    height: 80
                                    app: settingsDialog.app
                                    labelLines: app.candidatePreviewLabelLines("6")
                                    drawBackground: true
                                    drawRing: true
                                    backgroundColor: "#00ffff"
                                    backgroundOpacity: 1.0
                                }

                                CandidateMarkerView {
                                    x: 4
                                    y: 92
                                    width: 80
                                    height: 80
                                    app: settingsDialog.app
                                    labelLines: app.candidatePreviewLabelLines("5")
                                    drawBackground: true
                                    drawRing: false
                                    backgroundColor: "#2ed36f"
                                    backgroundOpacity: 0.88
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                CandidateLabelControl {
                                    lineKind: 0
                                    title: app.trText("candidateWinrate")
                                }

                                CandidateLabelControl {
                                    lineKind: 1
                                    title: app.trText("candidateVisits")
                                }

                                CandidateLabelControl {
                                    lineKind: 2
                                    title: app.candidateScoreTitle()
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 44
                                    radius: 6
                                    color: "#ffffff"
                                    border.color: "#c7d4db"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 8

                                        CheckBox {
                                            text: app.trText("candidateRingVisible")
                                            checked: app.candidateRingVisible
                                            onToggled: app.candidateRingVisible = checked
                                        }

                                        Label {
                                            text: app.trText("candidateRingWidth")
                                            color: "#53656f"
                                            font.pixelSize: 12
                                        }

                                        SpinBox {
                                            enabled: app.candidateRingVisible
                                            from: 1
                                            to: 64
                                            editable: true
                                            value: app.candidateRingLineWidth
                                            Layout.preferredWidth: 78
                                            onValueModified: app.candidateRingLineWidth = value
                                        }

                                        Item { Layout.fillWidth: true }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    ColorRow {
                                        label: app.trText("candidateFirstLabelTextColor")
                                        field: candidateFirstTextColorField
                                        compact: true
                                        onApply: settingsDialog.applyColorText(candidateFirstTextColorField,
                                                                                function(value) { app.candidateFirstLabelTextColor = value },
                                                                                function() { return app.candidateFirstLabelTextColor })
                                    }

                                    ColorRow {
                                        label: app.trText("candidateSecondLabelTextColor")
                                        field: candidateTextColorField
                                        compact: true
                                        onApply: settingsDialog.applyColorText(candidateTextColorField,
                                                                                function(value) { app.candidateLabelTextColor = value },
                                                                                function() { return app.candidateLabelTextColor })
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                text: app.trText("candidateDisplayCount")
                                color: "#24313a"
                                Layout.preferredWidth: 190
                            }

                            SpinBox {
                                from: 0
                                to: 65536
                                editable: true
                                value: app.candidateDisplayCount
                                Layout.preferredWidth: 116
                                onValueModified: app.candidateDisplayCount = value
                            }

                            Label {
                                text: app.trText("candidateCountUnlimitedTip")
                                color: "#52636d"
                                font.pixelSize: 12
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                text: app.trText("candidateMinVisitRatio")
                                color: "#24313a"
                                Layout.preferredWidth: 190
                            }

                            SpinBox {
                                from: 0
                                to: 1000
                                editable: true
                                value: Math.round(app.candidateMinVisitRatio * 1000)
                                Layout.preferredWidth: 96
                                textFromValue: function(value) {
                                    var percent = value / 10
                                    return value % 10 === 0 ? percent.toFixed(0) : percent.toFixed(1)
                                }
                                valueFromText: function(text) {
                                    var parsed = Number(String(text).replace("%", ""))
                                    return isNaN(parsed) ? 0 : Math.round(parsed * 10)
                                }
                                onValueModified: app.candidateMinVisitRatio = value / 1000
                            }

                            Label {
                                text: "%"
                                color: "#52636d"
                                font.pixelSize: 14
                            }

                            Item { Layout.fillWidth: true }
                        }

                        SavePromptButton {
                            text: app.trText("reset")
                            Layout.preferredWidth: 120
                            onClicked: {
                                app.resetCandidateVisualSettings()
                                settingsDialog.syncFields()
                            }
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

    component CandidateLabelControl: Rectangle {
        id: labelControl

        required property int lineKind
        required property string title
        property bool controlsEnabled: lineKind !== 2 || app.packageMode !== app.packageModeGo

        function lineVisible() {
            if (lineKind === 0)
                return app.candidateWinrateLabelVisible
            if (lineKind === 1)
                return app.candidateVisitsLabelVisible
            return app.candidateScoreLabelVisible
        }

        function setLineVisible(value) {
            if (lineKind === 0)
                app.candidateWinrateLabelVisible = value
            else if (lineKind === 1)
                app.candidateVisitsLabelVisible = value
            else
                app.candidateScoreLabelVisible = value
        }

        function lineFontSize() {
            if (lineKind === 0)
                return app.candidateWinrateFontSize
            if (lineKind === 1)
                return app.candidateVisitsFontSize
            return app.candidateScoreFontSize
        }

        function setLineFontSize(value) {
            if (lineKind === 0)
                app.candidateWinrateFontSize = value
            else if (lineKind === 1)
                app.candidateVisitsFontSize = value
            else
                app.candidateScoreFontSize = value
        }

        function lineBold() {
            if (lineKind === 0)
                return app.candidateWinrateBold
            if (lineKind === 1)
                return app.candidateVisitsBold
            return app.candidateScoreBold
        }

        function setLineBold(value) {
            if (lineKind === 0)
                app.candidateWinrateBold = value
            else if (lineKind === 1)
                app.candidateVisitsBold = value
            else
                app.candidateScoreBold = value
        }

        function lineOffsetY() {
            if (lineKind === 0)
                return app.candidateWinrateOffsetY
            if (lineKind === 1)
                return app.candidateVisitsOffsetY
            return app.candidateScoreOffsetY
        }

        function setLineOffsetY(value) {
            if (lineKind === 0)
                app.candidateWinrateOffsetY = value
            else if (lineKind === 1)
                app.candidateVisitsOffsetY = value
            else
                app.candidateScoreOffsetY = value
        }

        function lineDecimals() {
            return lineKind === 0 ? app.candidateWinrateDecimals : app.candidateScoreDecimals
        }

        function setLineDecimals(value) {
            if (lineKind === 0)
                app.candidateWinrateDecimals = value
            else if (lineKind === 2)
                app.candidateScoreDecimals = value
        }

        function lineShowPercent() {
            return lineKind === 0 ? app.candidateWinrateShowPercent : app.candidateScoreShowPercent
        }

        function setLineShowPercent(value) {
            if (lineKind === 0)
                app.candidateWinrateShowPercent = value
            else if (lineKind === 2)
                app.candidateScoreShowPercent = value
        }

        Layout.fillWidth: true
        Layout.preferredHeight: 44
        radius: 6
        color: "#ffffff"
        border.color: "#c7d4db"
        opacity: controlsEnabled ? 1 : 0.52

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            spacing: 3

            Label {
                text: "<"
                color: "#58717e"
                font.pixelSize: 14
                font.bold: true
                Layout.preferredWidth: 10
            }

            CheckBox {
                enabled: labelControl.controlsEnabled
                checked: labelControl.lineVisible()
                Layout.preferredWidth: 28
                onToggled: labelControl.setLineVisible(checked)
            }

            Label {
                text: labelControl.title
                color: "#17212a"
                font.pixelSize: 13
                font.bold: true
                Layout.preferredWidth: 40
                elide: Text.ElideRight
            }

            CheckBox {
                enabled: labelControl.controlsEnabled
                text: app.trText("candidateLabelBold")
                checked: labelControl.lineBold()
                Layout.preferredWidth: 34
                onToggled: labelControl.setLineBold(checked)
            }

            Label {
                text: app.trText("candidateLabelFontSize")
                color: "#53656f"
                font.pixelSize: 11
                Layout.preferredWidth: 22
                elide: Text.ElideRight
            }

            SpinBox {
                enabled: labelControl.controlsEnabled
                from: 12
                to: 120
                editable: true
                value: labelControl.lineFontSize()
                Layout.preferredWidth: 54
                onValueModified: labelControl.setLineFontSize(value)
            }

            Label {
                text: app.trText("candidateLabelOffsetY")
                color: "#53656f"
                font.pixelSize: 11
                Layout.preferredWidth: 22
                elide: Text.ElideRight
            }

            SpinBox {
                enabled: labelControl.controlsEnabled
                from: -64
                to: 64
                editable: true
                value: labelControl.lineOffsetY()
                Layout.preferredWidth: 54
                onValueModified: labelControl.setLineOffsetY(value)
            }

            Label {
                visible: labelControl.lineKind !== 1
                text: app.trText("candidateLabelDecimals")
                color: "#53656f"
                font.pixelSize: 11
                Layout.preferredWidth: 24
                elide: Text.ElideRight
            }

            ComboBox {
                visible: labelControl.lineKind !== 1
                enabled: labelControl.controlsEnabled
                model: [ "0", "1", "2" ]
                currentIndex: labelControl.lineDecimals()
                Layout.preferredWidth: 42
                onActivated: function(index) { labelControl.setLineDecimals(index) }
            }

            CheckBox {
                visible: labelControl.lineKind === 0
                         || (labelControl.lineKind === 2 && app.gameRuleMode !== app.gameRuleGo)
                enabled: labelControl.controlsEnabled
                text: "%"
                checked: labelControl.lineShowPercent()
                Layout.preferredWidth: 38
                onToggled: labelControl.setLineShowPercent(checked)
            }

            Label {
                visible: labelControl.lineKind === 2 && app.packageMode === app.packageModeGo
                text: app.trText("candidateScoreUnsupported")
                color: "#7f3f38"
                font.pixelSize: 12
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Item {
                visible: !(labelControl.lineKind === 2 && app.packageMode === app.packageModeGo)
                Layout.fillWidth: true
            }
        }
    }

    component SliderRow: RowLayout {
        id: sliderRow
        property string label: ""
        property real from: 0
        property real to: 1
        property real value: 0
        property int decimals: 2
        property bool percent: false
        signal moved(real value)

        Layout.fillWidth: true
        spacing: colorRow.compact ? 6 : 10

        Label {
            text: sliderRow.label
            color: "#24313a"
            Layout.preferredWidth: 190
        }

        Slider {
            id: rowSlider
            from: sliderRow.from
            to: sliderRow.to
            value: sliderRow.value
            live: true
            Layout.fillWidth: true
            onMoved: sliderRow.moved(value)
        }

        Label {
            text: sliderRow.percent ? Math.round(Number(rowSlider.value) * 100) + "%"
                                    : Number(rowSlider.value).toFixed(sliderRow.decimals)
            color: "#52636d"
            horizontalAlignment: Text.AlignRight
            Layout.preferredWidth: 56
        }
    }

    component SelectionPreview: RowLayout {
        id: selectionPreview
        spacing: 10

        Label {
            text: app.trText("selectedPointPreview")
            color: "#24313a"
            Layout.preferredWidth: 190
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 88
            radius: 5
            color: "#ffffff"
            border.color: "#c4d0d7"

            Canvas {
                id: selectionPreviewCanvas
                anchors.fill: parent
                anchors.margins: 8

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    var centerX = Math.round(width * 0.38)
                    var centerY = Math.round(height * 0.5)
                    var stoneRadius = Math.min(28, Math.max(18, height * 0.34))
                    var selectionRadius = stoneRadius * app.selectedPointScale

                    ctx.fillStyle = app.boardWoodColor
                    ctx.fillRect(8, 8, width - 16, height - 16)
                    ctx.strokeStyle = "#6b4b29"
                    ctx.lineWidth = 1
                    ctx.beginPath()
                    ctx.moveTo(centerX - stoneRadius * 1.45, centerY)
                    ctx.lineTo(centerX + stoneRadius * 1.45, centerY)
                    ctx.moveTo(centerX, centerY - stoneRadius * 1.45)
                    ctx.lineTo(centerX, centerY + stoneRadius * 1.45)
                    ctx.stroke()

                    ctx.strokeStyle = "#1b252c"
                    ctx.globalAlpha = 0.36
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    ctx.arc(centerX, centerY, stoneRadius, 0, Math.PI * 2)
                    ctx.stroke()

                    ctx.globalAlpha = 0.30
                    ctx.fillStyle = "#2fb97f"
                    ctx.beginPath()
                    ctx.arc(centerX, centerY, selectionRadius, 0, Math.PI * 2)
                    ctx.fill()
                    ctx.globalAlpha = 1

                    ctx.strokeStyle = "#2fb97f"
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    ctx.arc(centerX, centerY, selectionRadius, 0, Math.PI * 2)
                    ctx.stroke()

                    ctx.fillStyle = "#52636d"
                    ctx.font = "13px \"" + String(app.coordinateFontFamily).replace(/"/g, "") + "\", sans-serif"
                    ctx.textAlign = "left"
                    ctx.textBaseline = "middle"
                    ctx.fillText(Math.round(app.selectedPointScale * 100) + "%", centerX + stoneRadius * 1.8, centerY)
                }

                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()

                Connections {
                    target: app
                    function onSelectedPointScaleChanged() { selectionPreviewCanvas.requestPaint() }
                    function onBoardWoodColorChanged() { selectionPreviewCanvas.requestPaint() }
                }
            }
        }
    }

    component ColorRow: RowLayout {
        id: colorRow
        property string label: ""
        property var field
        property bool compact: false
        signal apply()

        Layout.fillWidth: true
        spacing: 10

        Label {
            text: colorRow.label
            color: "#24313a"
            Layout.preferredWidth: colorRow.compact ? 70 : 190
            elide: Text.ElideRight
        }

        Basic.TextField {
            id: colorField
            text: colorRow.field ? colorRow.field.text : ""
            selectByMouse: true
            Layout.preferredWidth: colorRow.compact ? 88 : 120
            onTextChanged: if (colorRow.field) colorRow.field.text = text
            onEditingFinished: colorRow.apply()
        }

        SavePromptButton {
            text: app.trText("apply")
            Layout.preferredWidth: colorRow.compact ? 58 : 88
            onClicked: colorRow.apply()
        }
    }

    QtObject { id: backgroundColorField; property string text: "" }
    QtObject { id: boardColorField; property string text: "" }
    QtObject { id: candidateFirstTextColorField; property string text: "" }
    QtObject { id: candidateTextColorField; property string text: "" }
}
