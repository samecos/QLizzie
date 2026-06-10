import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "EnginePresets.js" as EnginePresets

Basic.Dialog {
    id: engineListDialog

    required property var app
    required property var controller
    property bool startupMode: false
    property int selectedIndex: -1
    property bool syncingEditor: false
    property string listTooltipText: ""
    property string listTooltipKey: ""
    property bool listTooltipReady: false
    property real listTooltipX: 0
    property real listTooltipY: 0
    readonly property real legacyHexColumnWidth: startupMode ? 0 : 82

    modal: true
    title: startupMode ? app.trText("loadEngineTitle") : app.trText("engineSettingsTitle")
    closePolicy: startupMode ? Popup.NoAutoClose : Popup.CloseOnEscape
    padding: 8
    width: Math.min(1180, app.width - 36)
    height: Math.min(820, app.height - 36)
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    function ensureSelection() {
        if (!app.enginePresets || app.enginePresets.length <= 0) {
            selectedIndex = -1
            return
        }
        if (selectedIndex < 0 || selectedIndex >= app.enginePresets.length)
            selectedIndex = 0
    }

    function openStartup() {
        startupMode = true
        selectedIndex = app.enginePresets.length > 0 ? 0 : -1
        syncEditor()
        open()
    }

    function openManage() {
        startupMode = false
        var activeIndex = app.enginePresetIndexById(app.activeEngineId)
        selectedIndex = activeIndex >= 0 ? activeIndex : (app.enginePresets.length > 0 ? 0 : -1)
        syncEditor()
        open()
    }

    function presetAt(row) {
        return row >= 0 && row < app.enginePresets.length ? app.enginePresets[row] : null
    }

    function selectedPreset() {
        return presetAt(selectedIndex)
    }

    function variantOptionsForRule(ruleMode) {
        if (ruleMode === app.gameRuleGomoku)
            return app.gomokuRuleOptions()
        if (ruleMode === app.gameRuleGo)
            return app.goRuleOptions()
        var options = app.gameRuleOptions()
        for (var i = 0; i < options.length; ++i) {
            if (options[i].value === ruleMode)
                return [{ "label": options[i].label, "value": -1, "tip": options[i].tip }]
        }
        return [{ "label": app.trText("gameRule"), "value": -1, "tip": "" }]
    }

    function currentEditorRuleMode() {
        var options = app.gameRuleOptions()
        var option = options[ruleCombo.currentIndex]
        return option ? option.value : app.gameRuleGo
    }

    function syncEditor() {
        ensureSelection()
        syncingEditor = true
        var preset = selectedPreset()
        var hasPreset = preset !== null
        nameEdit.text = hasPreset ? preset.name : ""
        commandEdit.text = hasPreset ? preset.command : ""
        initialCommandEdit.text = hasPreset ? String(preset.initialCommands || "") : ""
        widthSpin.value = hasPreset ? preset.boardSizeX : app.defaultBoardSize
        heightSpin.value = hasPreset ? preset.boardSizeY : app.defaultBoardSize
        komiSpin.value = hasPreset ? Math.round(Number(preset.komi) * 2) : 13
        legacyHexCheck.checked = hasPreset && preset.legacyHexEngineCoordinates === true

        var ruleOptions = app.gameRuleOptions()
        var ruleIndex = 0
        for (var i = 0; hasPreset && i < ruleOptions.length; ++i) {
            if (ruleOptions[i].value === preset.ruleMode) {
                ruleIndex = i
                break
            }
        }
        ruleCombo.currentIndex = ruleIndex

        var variantOptions = variantOptionsForRule(hasPreset ? preset.ruleMode : app.gameRuleGo)
        var variantIndex = 0
        for (var v = 0; hasPreset && v < variantOptions.length; ++v) {
            if (variantOptions[v].value === preset.ruleVariant) {
                variantIndex = v
                break
            }
        }
        variantCombo.currentIndex = variantIndex
        syncingEditor = false
    }

    function collectPreset() {
        var base = selectedPreset() || EnginePresets.newPreset(app)
        var ruleMode = currentEditorRuleMode()
        var variantOptions = variantOptionsForRule(ruleMode)
        var variantOption = variantOptions[variantCombo.currentIndex]
        var preset = EnginePresets.clonePreset(base)
        preset.name = nameEdit.text.trim().length > 0 ? nameEdit.text.trim() : app.trText("newEngine")
        preset.command = commandEdit.text.trim()
        preset.initialCommands = initialCommandEdit.text.trim()
        preset.ruleMode = ruleMode
        preset.ruleVariant = ruleMode === app.gameRuleGomoku && variantOption ? variantOption.value : -1
        preset.boardSizeX = widthSpin.value
        preset.boardSizeY = heightSpin.value
        preset.komi = komiSpin.value / 2
        preset.legacyHexEngineCoordinates = legacyHexCheck.checked
        preset.boardPresentationMode = app.boardPresentationIntersections
        return app.normalizeEnginePreset(preset, selectedIndex)
    }

    function saveSelected() {
        if (selectedIndex < 0)
            return
        var preset = collectPreset()
        app.replaceEnginePreset(selectedIndex, preset)
        syncEditor()
    }

    function loadSelected() {
        if (!startupMode)
            saveSelected()
        var preset = selectedPreset()
        if (!preset)
            return
        if (app.loadEnginePreset(preset.id, startupMode))
            close()
    }

    function createPreset() {
        selectedIndex = app.addEnginePreset(EnginePresets.newPreset(app))
        syncEditor()
    }

    function deleteSelected() {
        selectedIndex = app.removeEnginePreset(selectedIndex)
        syncEditor()
    }

    function moveSelected(delta) {
        if (selectedIndex < 0)
            return
        saveSelected()
        selectedIndex = app.moveEnginePreset(selectedIndex, delta)
        syncEditor()
    }

    function moveSelectedSteps(delta, steps) {
        if (selectedIndex < 0)
            return
        saveSelected()
        var target = Math.max(0, Math.min(app.enginePresets.length - 1, selectedIndex + delta * steps))
        selectedIndex = app.moveEnginePresetTo(selectedIndex, target)
        syncEditor()
    }

    function moveSelectedTo(target) {
        if (selectedIndex < 0)
            return
        saveSelected()
        selectedIndex = app.moveEnginePresetTo(selectedIndex,
                                               Math.max(0, Math.min(app.enginePresets.length - 1, target)))
        syncEditor()
    }

    function scheduleListTooltip(item, key, text, mouseX, mouseY) {
        if (!item || key.length <= 0 || text.length <= 0) {
            hideListTooltip("")
            return
        }
        var point = item.mapToItem(dialogContent, mouseX + 12, mouseY + 18)
        listTooltipX = point.x
        listTooltipY = point.y
        if (key === listTooltipKey && text === listTooltipText)
            return
        listTooltipKey = key
        listTooltipText = text
        listTooltipReady = false
        listTooltipTimer.restart()
    }

    function hideListTooltip(key) {
        if (key.length > 0 && key !== listTooltipKey)
            return
        listTooltipTimer.stop()
        listTooltipReady = false
        listTooltipKey = ""
        listTooltipText = ""
    }

    Timer {
        id: listTooltipTimer
        interval: 700
        repeat: false
        onTriggered: {
            if (engineListDialog.listTooltipText.length > 0)
                engineListDialog.listTooltipReady = true
        }
    }

    onOpened: syncEditor()
    onClosed: {
        hideListTooltip("")
        app.focusBoardInput()
    }

    background: Rectangle {
        color: "#f6fafc"
        border.color: "#8ea5b1"
    }

    header: Rectangle {
        height: 42
        color: "#e4eef4"

        Label {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            text: engineListDialog.title
            color: "#102532"
            font.pixelSize: 18
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    contentItem: ColumnLayout {
        id: dialogContent

        implicitWidth: 1160
        implicitHeight: 720
        spacing: 8

        Label {
            visible: engineListDialog.startupMode
            Layout.fillWidth: true
            text: app.trText("engineStartupManualHint")
            color: "#4e626e"
            font.pixelSize: 14
            wrapMode: Text.WordWrap
        }

        Rectangle {
            visible: !engineListDialog.startupMode
            Layout.fillWidth: true
            Layout.preferredHeight: 440
            color: "#f6fafc"

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                Label {
                    text: app.trText("engineSettingIndex").replace("%1", Math.max(1, engineListDialog.selectedIndex + 1))
                    color: "#2b53ff"
                    font.pixelSize: 15
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    FieldLabel { text: app.trText("engineName") }
                    Basic.TextField {
                        id: nameEdit
                        Layout.fillWidth: true
                        selectByMouse: true
                        enabled: engineListDialog.selectedPreset() !== null
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 156
                    spacing: 6

                    FieldLabel {
                        Layout.preferredWidth: 86
                        Layout.alignment: Qt.AlignTop
                        text: app.trText("engineCommand")
                    }

                    Basic.TextArea {
                        id: commandEdit
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        enabled: engineListDialog.selectedPreset() !== null
                        selectByMouse: true
                        wrapMode: TextEdit.WrapAnywhere
                        color: enabled ? "#13232d" : "#78868d"
                        background: Rectangle {
                            color: commandEdit.enabled ? "#ffffff" : "#edf2f4"
                            border.color: commandEdit.activeFocus ? "#2388b8" : "#8f9ca3"
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    FieldLabel { text: app.trText("engineInitialCommands") }
                    Basic.TextField {
                        id: initialCommandEdit
                        Layout.fillWidth: true
                        enabled: engineListDialog.selectedPreset() !== null
                        placeholderText: app.trText("engineInitialCommandsPlaceholder")
                        selectByMouse: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Label { text: app.trText("engineWidthShort"); color: "#52636d" }
                    SpinBox {
                        id: widthSpin
                        from: app.minBoardSize
                        to: app.maxBoardSize
                        editable: true
                        enabled: engineListDialog.selectedPreset() !== null
                        Layout.preferredWidth: 70
                    }

                    Label { text: app.trText("engineHeightShort"); color: "#52636d" }
                    SpinBox {
                        id: heightSpin
                        from: app.minBoardSize
                        to: app.maxBoardSize
                        editable: true
                        enabled: engineListDialog.selectedPreset() !== null
                        Layout.preferredWidth: 70
                    }

                    Label { text: app.trText("komi"); color: "#52636d" }
                    SpinBox {
                        id: komiSpin
                        from: -Math.round(app.maxKomiMagnitude * 2)
                        to: Math.round(app.maxKomiMagnitude * 2)
                        editable: true
                        enabled: engineListDialog.selectedPreset() !== null
                        Layout.preferredWidth: 116
                        textFromValue: function(value) { return (value / 2).toFixed(1) }
                        valueFromText: function(text) { return Math.round(Number(text) * 2) }
                    }

                    CheckBox {
                        id: legacyHexCheck
                        enabled: engineListDialog.selectedPreset() !== null
                        text: app.trText("legacyHexEngineCoordinatesShort")
                    }

                    Item { Layout.fillWidth: true }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    FieldLabel { text: app.trText("mainRule") }
                    StyledComboBox {
                        id: ruleCombo
                        model: app.gameRuleOptions()
                        enabled: engineListDialog.selectedPreset() !== null
                        Layout.preferredWidth: 250
                        Layout.minimumWidth: 220
                        onActivated: {
                            if (!engineListDialog.syncingEditor)
                                variantCombo.currentIndex = 0
                        }
                    }

                    FieldLabel {
                        Layout.preferredWidth: 72
                        text: app.trText("ruleVariant")
                    }
                    StyledComboBox {
                        id: variantCombo
                        model: engineListDialog.variantOptionsForRule(engineListDialog.currentEditorRuleMode())
                        enabled: engineListDialog.selectedPreset() !== null
                        Layout.preferredWidth: 300
                        Layout.minimumWidth: 240
                    }

                    Item { Layout.fillWidth: true }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    CompactButton { text: app.trText("moveUp"); enabled: engineListDialog.selectedIndex > 0; onClicked: engineListDialog.moveSelected(-1) }
                    CompactButton { text: app.trText("moveDown"); enabled: engineListDialog.selectedIndex >= 0 && engineListDialog.selectedIndex < app.enginePresets.length - 1; onClicked: engineListDialog.moveSelected(1) }
                    CompactButton { text: app.trText("moveUp5"); enabled: engineListDialog.selectedIndex > 0; onClicked: engineListDialog.moveSelectedSteps(-1, 5) }
                    CompactButton { text: app.trText("moveDown5"); enabled: engineListDialog.selectedIndex >= 0 && engineListDialog.selectedIndex < app.enginePresets.length - 1; onClicked: engineListDialog.moveSelectedSteps(1, 5) }
                    CompactButton { text: app.trText("moveTop"); enabled: engineListDialog.selectedIndex > 0; onClicked: engineListDialog.moveSelectedTo(0) }
                    CompactButton { text: app.trText("moveBottom"); enabled: engineListDialog.selectedIndex >= 0 && engineListDialog.selectedIndex < app.enginePresets.length - 1; onClicked: engineListDialog.moveSelectedTo(app.enginePresets.length - 1) }

                    Item { Layout.fillWidth: true }

                    CompactButton { text: app.trText("newEngine"); onClicked: engineListDialog.createPreset() }
                    CompactButton { text: app.trText("delete"); enabled: engineListDialog.selectedPreset() !== null; onClicked: engineListDialog.deleteSelected() }
                    CompactButton { text: app.trText("save"); enabled: engineListDialog.selectedPreset() !== null; primary: true; onClicked: engineListDialog.saveSelected() }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Label {
                        text: app.trText("engineDefaultEngine")
                        color: "#24313a"
                    }

                    StyledComboBox {
                        id: defaultEngineCombo
                        model: app.engineDefaultOptions()
                        currentIndex: app.engineDefaultCurrentIndex()
                        Layout.preferredWidth: 280
                        Layout.minimumWidth: 220
                        onActivated: function(index) { app.setDefaultEnginePresetFromIndex(index) }
                    }

                    Item { Layout.fillWidth: true }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Label {
                        text: app.trText("engineStartupAutoLoad")
                        color: "#24313a"
                    }

                    RadioButton {
                        text: app.trText("engineStartupDefault")
                        checked: app.engineStartupMode === app.engineStartupDefault
                        onClicked: app.setEngineStartupMode(app.engineStartupDefault)
                    }

                    RadioButton {
                        text: app.trText("engineStartupLast")
                        checked: app.engineStartupMode === app.engineStartupLast
                        onClicked: app.setEngineStartupMode(app.engineStartupLast)
                    }

                    RadioButton {
                        text: app.trText("engineStartupManual")
                        checked: app.engineStartupMode === app.engineStartupManual
                        onClicked: app.setEngineStartupMode(app.engineStartupManual)
                    }

                    RadioButton {
                        text: app.trText("engineStartupNone")
                        checked: app.engineStartupMode === app.engineStartupNone
                        onClicked: app.setEngineStartupMode(app.engineStartupNone)
                    }

                    Item { Layout.fillWidth: true }
                }
            }
        }

        Rectangle {
            id: tablePanel
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: engineListDialog.startupMode ? 390 : 210
            color: "#ffffff"
            border.color: "#b9ccd6"

            Item {
                anchors.fill: parent
                anchors.margins: 1

                Rectangle {
                    id: tableHeader
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 34
                    color: "#e4eef4"

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        HeaderCell { text: app.trText("candidateIndex"); widthValue: 52 }
                        HeaderCell { text: app.trText("engineName"); widthValue: 200 }
                        HeaderCell { text: app.trText("engineCommand"); fill: true }
                        HeaderCell { text: app.trText("engineRule"); widthValue: 94 }
                        HeaderCell { text: app.trText("engineWidthShort"); widthValue: 50; alignCenter: true }
                        HeaderCell { text: app.trText("engineHeightShort"); widthValue: 50; alignCenter: true }
                        HeaderCell { text: app.trText("komi"); widthValue: 58; alignCenter: true }
                        HeaderCell {
                            visible: !engineListDialog.startupMode
                            text: app.trText("legacyHexEngineCoordinatesShort")
                            widthValue: engineListDialog.legacyHexColumnWidth
                            alignCenter: true
                        }
                    }
                }

                ListView {
                    id: engineListView
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: tableHeader.bottom
                    anchors.bottom: parent.bottom
                    clip: true
                    model: app.enginePresets ? app.enginePresets.length : 0
                    currentIndex: engineListDialog.selectedIndex

                    ScrollBar.vertical: AppScrollBar {
                        policy: engineListView.contentHeight > engineListView.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                    }

                    delegate: Rectangle {
                        id: rowItem
                        readonly property var preset: engineListDialog.presetAt(index)
                        readonly property bool selected: index === engineListDialog.selectedIndex
                        readonly property real nameColumnStart: 52
                        readonly property real nameColumnEnd: 252
                        readonly property real trailingColumnsWidth: 252
                                                                    + engineListDialog.legacyHexColumnWidth
                        readonly property real commandColumnStart: nameColumnEnd
                        readonly property real commandColumnEnd: Math.max(commandColumnStart, width - trailingColumnsWidth)
                        property string tooltipKey: ""

                        function tooltipTextAt(mouseX) {
                            if (!preset)
                                return ""
                            if (mouseX >= nameColumnStart && mouseX < nameColumnEnd)
                                return preset.name
                            if (mouseX >= commandColumnStart && mouseX < commandColumnEnd)
                                return preset.command
                            return ""
                        }

                        function updateTooltipCandidate() {
                            var nextText = tooltipTextAt(rowMouse.mouseX)
                            var nextKey = ""
                            if (nextText.length > 0) {
                                nextKey = index + ":"
                                          + (rowMouse.mouseX < commandColumnStart ? "name" : "command")
                            }
                            tooltipKey = nextKey
                            engineListDialog.scheduleListTooltip(rowItem, nextKey, nextText,
                                                                  rowMouse.mouseX, rowMouse.mouseY)
                        }

                        width: engineListView.width
                        height: 28
                        color: selected ? "#0078d7" : rowMouse.containsMouse ? "#e9f3f8" : "#ffffff"
                        border.color: selected ? "#0078d7" : "#d4dce2"

                        RowLayout {
                            anchors.fill: parent
                            spacing: 0

                            DataCell { text: String(index + 1); widthValue: 52; alignCenter: true; selected: rowItem.selected }
                            DataCell { text: rowItem.preset ? rowItem.preset.name : ""; widthValue: 200; selected: rowItem.selected }
                            DataCell { text: rowItem.preset ? rowItem.preset.command : ""; fill: true; selected: rowItem.selected }
                            DataCell { text: rowItem.preset ? app.enginePresetRuleDetailText(rowItem.preset) : ""; widthValue: 94; selected: rowItem.selected }
                            DataCell { text: rowItem.preset ? String(rowItem.preset.boardSizeX) : ""; widthValue: 50; alignCenter: true; selected: rowItem.selected }
                            DataCell { text: rowItem.preset ? String(rowItem.preset.boardSizeY) : ""; widthValue: 50; alignCenter: true; selected: rowItem.selected }
                            DataCell { text: rowItem.preset ? Number(rowItem.preset.komi).toFixed(1) : ""; widthValue: 58; alignCenter: true; selected: rowItem.selected }
                            DataCell {
                                visible: !engineListDialog.startupMode
                                text: rowItem.preset && rowItem.preset.legacyHexEngineCoordinates ? app.trText("yes") : app.trText("no")
                                widthValue: engineListDialog.legacyHexColumnWidth
                                alignCenter: true
                                selected: rowItem.selected
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton
                            onEntered: rowItem.updateTooltipCandidate()
                            onExited: {
                                engineListDialog.hideListTooltip(rowItem.tooltipKey)
                                rowItem.tooltipKey = ""
                            }
                            onPositionChanged: rowItem.updateTooltipCandidate()
                            onClicked: {
                                engineListDialog.selectedIndex = index
                                engineListDialog.syncEditor()
                            }
                            onDoubleClicked: {
                                engineListDialog.selectedIndex = index
                                engineListDialog.syncEditor()
                                engineListDialog.loadSelected()
                            }
                        }
                    }
                }
            }
        }
    }

    footer: Rectangle {
        implicitHeight: 58
        color: "#f6fafc"

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: "#d7e1e7"
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Item { Layout.fillWidth: true }

            SavePromptButton {
                visible: !engineListDialog.startupMode
                text: app.trText("switchEngine")
                primary: true
                enabled: engineListDialog.selectedPreset() !== null
                Layout.preferredWidth: 116
                onClicked: engineListDialog.loadSelected()
            }

            SavePromptButton {
                visible: engineListDialog.startupMode
                text: app.trText("loadSelectedEngine")
                primary: true
                enabled: engineListDialog.selectedPreset() !== null
                Layout.preferredWidth: 144
                onClicked: engineListDialog.loadSelected()
            }

            SavePromptButton {
                text: app.trText("engineNoEngineMode")
                Layout.preferredWidth: 122
                onClicked: {
                    app.chooseNoEngineFromList()
                    engineListDialog.close()
                }
            }

            SavePromptButton {
                text: app.trText("close")
                visible: !engineListDialog.startupMode
                Layout.preferredWidth: 86
                onClicked: engineListDialog.close()
            }
        }
    }

    Popup {
        id: sharedListTooltip
        parent: dialogContent
        visible: engineListDialog.listTooltipReady && engineListDialog.listTooltipText.length > 0
        closePolicy: Popup.NoAutoClose
        padding: 6
        x: Math.max(8, Math.min(engineListDialog.listTooltipX,
                                dialogContent.width - width - 8))
        y: Math.max(8, Math.min(engineListDialog.listTooltipY,
                                dialogContent.height - height - 8))

        contentItem: Text {
            text: engineListDialog.listTooltipText
            color: "#102532"
            font.pixelSize: 13
            wrapMode: Text.WrapAnywhere
            width: Math.min(720, Math.max(180, implicitWidth))
        }

        background: Rectangle {
            radius: 4
            color: "#fffff4"
            border.color: "#8fa5b0"
        }
    }

    component FieldLabel: Label {
        Layout.preferredWidth: 86
        color: "#52636d"
        verticalAlignment: Text.AlignVCenter
    }

    component CompactButton: SavePromptButton {
        Layout.preferredWidth: Math.max(70, implicitWidth + 10)
        Layout.preferredHeight: 32
    }

    component StyledComboBox: Basic.ComboBox {
        id: combo

        textRole: "label"
        valueRole: "value"
        implicitHeight: 34

        contentItem: Text {
            leftPadding: 12
            rightPadding: 28
            text: combo.displayText
            color: combo.enabled ? "#102532" : "#7a8b94"
            font.pixelSize: 14
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        indicator: Text {
            x: combo.width - width - 8
            y: Math.round((combo.height - height) / 2)
            text: "\u25BE"
            color: combo.enabled ? "#657883" : "#9aa8af"
            font.pixelSize: 13
        }

        background: Rectangle {
            radius: 3
            color: combo.enabled ? "#ffffff" : "#eef3f6"
            border.color: combo.activeFocus ? "#2a91c9" : "#aebdc6"
            border.width: combo.activeFocus ? 2 : 1
        }

        delegate: Basic.ItemDelegate {
            width: combo.width
            height: 36
            highlighted: combo.highlightedIndex === index

            contentItem: Text {
                text: modelData && modelData.label !== undefined ? modelData.label : String(modelData)
                color: "#102532"
                font.pixelSize: 14
                font.bold: highlighted
                verticalAlignment: Text.AlignVCenter
                leftPadding: 12
                elide: Text.ElideRight
            }

            background: Rectangle {
                color: highlighted ? "#d8e9f1" : "#ffffff"
                border.color: highlighted ? "#9abaca" : "#eef3f6"
            }
        }
    }

    component HeaderCell: Item {
        property string text: ""
        property real widthValue: 80
        property bool fill: false
        property bool alignCenter: false

        Layout.preferredWidth: widthValue
        Layout.fillWidth: fill
        Layout.fillHeight: true

        Rectangle {
            anchors.fill: parent
            color: "#e4eef4"
            border.color: "#c0d0d9"
        }

        Text {
            anchors.fill: parent
            anchors.leftMargin: alignCenter ? 2 : 8
            anchors.rightMargin: alignCenter ? 2 : 8
            text: parent.text
            color: "#102532"
            font.pixelSize: 13
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: alignCenter ? Text.AlignHCenter : Text.AlignLeft
            elide: Text.ElideRight
        }
    }

    component DataCell: Item {
        id: dataCell
        property string text: ""
        property real widthValue: 80
        property bool fill: false
        property bool alignCenter: false
        property bool selected: false

        Layout.preferredWidth: widthValue
        Layout.fillWidth: fill
        Layout.fillHeight: true

        Text {
            anchors.fill: parent
            anchors.leftMargin: alignCenter ? 2 : 8
            anchors.rightMargin: alignCenter ? 2 : 8
            text: parent.text
            color: parent.selected ? "#ffffff" : "#1c2d36"
            font.pixelSize: 13
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: alignCenter ? Text.AlignHCenter : Text.AlignLeft
            elide: Text.ElideRight
        }
    }
}
