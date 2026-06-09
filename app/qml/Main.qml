import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Dialogs
import QtQuick.Layouts
import "CoordinateUtils.js" as CoordinateUtils
import "GameRules.js" as GameRules
import "SgfUtils.js" as SgfUtils
import "Translations.js" as TranslationData

ApplicationWindow {
    id: root

    width: Math.min(1600, Screen.desktopAvailableWidth > 0 ? Screen.desktopAvailableWidth : 1600)
    height: Math.min(900, Screen.desktopAvailableHeight > 0 ? Screen.desktopAvailableHeight : 900)
    minimumWidth: 1024
    minimumHeight: 640
    visible: true
    color: backgroundColor
    title: windowTitleText()

    property string language: "zh"
    property var translations: TranslationData.translations
    property bool firstLaunchCompleted: false
    property bool appReady: false
    property bool persistentSettingsLoaded: false
    property bool gameDirty: false
    property bool suppressUnsavedPrompt: false
    property bool saveDialogClosesApp: false
    property string pendingClearAction: ""
    property int pendingRuleMode: -1
    property int pendingBoardSizeX: -1
    property int pendingBoardSizeY: -1

    readonly property string coordinateFontFamily: coordinateFont.status === FontLoader.Ready
                                                    ? coordinateFont.name
                                                    : "JetBrains Mono"

    readonly property int minBoardSize: 1
    readonly property int maxBoardSize: 1001
    readonly property int maxCachedLegalPoints: 40000
    readonly property int currentSettingsVersion: 2
    property int loadedSettingsVersion: 0
    property bool settingsMigrated: false
    readonly property int defaultBoardSize: 19
    property int boardSizeX: defaultBoardSize
    property int boardSizeY: defaultBoardSize
    readonly property int boardSize: Math.max(boardSizeX, boardSizeY)
    property real spacing: 100

    readonly property bool compactLayout: width < 1500 || height < 820
    readonly property real analysisToolbarHeight: compactLayout ? 40 : 46
    readonly property real commandToolbarHeight: compactLayout ? 34 : 38
    readonly property real panelMargin: compactLayout ? 10 : 18
    readonly property real panelGap: compactLayout ? 8 : 14
    readonly property real panelInnerMargin: compactLayout ? 10 : 14
    readonly property real topContentMargin: analysisToolbarHeight + panelMargin
    readonly property real bottomContentMargin: panelMargin + commandToolbarHeight + panelGap
    readonly property real infoPanelWidth: compactLayout ? 260 : 314
    readonly property real branchPanelWidth: compactLayout ? 180 : 240
    readonly property int minimumTreeCanvasWidth: compactLayout ? 164 : 220
    readonly property int minimumTreeCanvasHeight: compactLayout ? 210 : 260
    readonly property real boardStageLeftReserve: panelMargin + infoPanelWidth + panelGap
    readonly property real boardStageRightReserve: panelMargin + branchPanelWidth + panelGap
    readonly property real boardStageCenterX: boardStageLeftReserve
                                                + (width - boardStageLeftReserve - boardStageRightReserve) / 2

    property var commandToolbarItems: [
        { "type": "button", "action": "candidates", "zh": "选点列表", "en": "Candidates", "width": 76 },
        { "type": "button", "action": "refresh", "zh": "刷新", "en": "Refresh", "width": 52 },
        { "type": "button", "action": "setMainBranch", "zh": "设为主分支", "en": "Set main", "width": 90 },
        { "type": "button", "action": "clearBoard", "zh": "清空棋盘", "en": "Clear board", "width": 76 },
        { "type": "button", "action": "delete", "zh": "删除", "en": "Delete", "width": 52 },
        { "type": "button", "action": "firstMove", "zh": "|<", "en": "|<", "width": 40 },
        { "type": "button", "action": "back10", "zh": "<<", "en": "<<", "width": 40 },
        { "type": "button", "action": "back1", "zh": "<", "en": "<", "width": 38 },
        { "type": "moveInput", "width": 56 },
        { "type": "button", "action": "forward1", "zh": ">", "en": ">", "width": 38 },
        { "type": "button", "action": "forward10", "zh": ">>", "en": ">>", "width": 40 },
        { "type": "button", "action": "lastMove", "zh": ">|", "en": ">|", "width": 40 }
    ]

    property var stones: ({})
    property var stoneItems: []
    property var gameNodes: []
    property var treeNodes: []
    property var treeEdges: []
    property int treeCanvasWidth: 220
    property int treeCanvasHeight: 260
    property int currentNodeId: 0
    property int nextNodeId: 1
    property int boardRevision: 0
    property int treeRevision: 0
    property int legalityRevision: 0
    property int currentPlayer: 1
    property int stoneCount: 0
    property int blackCaptures: 0
    property int whiteCaptures: 0
    property string koLocKey: ""
    property int koLocX: -1
    property int koLocY: -1
    property string hoverKey: ""
    property int hoverX: -1
    property int hoverY: -1
    property bool selectedPointLocked: false
    property bool selectedPointFromCandidateList: false
    property var legalPointMap: ({})
    property string statusMode: "turn"
    property string statusMessage: ""
    property int statusX: -1
    property int statusY: -1

    readonly property int stoneColorModeAuto: 0
    readonly property int stoneColorModeBlack: 1
    readonly property int stoneColorModeWhite: 2
    property int stoneColorMode: stoneColorModeAuto

    readonly property int gameRuleGo: 0
    readonly property int gameRuleGomoku: 1
    property int gameRuleMode: gameRuleGo
    readonly property int gomokuRuleCon5: 0
    readonly property int gomokuRuleStdCon5: 1
    readonly property int gomokuRuleFreestyle: 2
    readonly property int gomokuRuleStandard: 3
    readonly property int gomokuRuleCon7: 4
    readonly property int gomokuRuleDirectCon5: 5
    property int gomokuRuleMode: gomokuRuleCon5
    property var gomokuWinLineItems: []

    property real komi: 6.5
    readonly property int playModeAnalysis: 0
    readonly property int playModeAiBlack: 1
    readonly property int playModeAiWhite: 2
    readonly property int playModeAiSelf: 3
    property int playMode: playModeAnalysis
    property real secondsPerMove: 5.0
    property int resignMinMove: 80
    property int resignConsecutiveMoves: 3
    property real resignWinrateThreshold: 5.0
    property int gameWinner: 0
    property string gameOverReason: ""

    readonly property int moveNumberModeAll: 0
    readonly property int moveNumberModeLastOnly: 1
    readonly property int moveNumberModeHidden: 2
    readonly property int defaultMoveNumberDisplayMode: moveNumberModeAll
    property int moveNumberDisplayMode: defaultMoveNumberDisplayMode
    readonly property int coordinateDisplayGoNoI: 0
    readonly property int coordinateDisplayGomokuWithI: 1
    readonly property int coordinateDisplayNumeric: 2
    readonly property int coordinateDisplayNone: 3
    property int coordinateDisplayMode: coordinateDisplayGoNoI
    readonly property int packageModeUniversal: 0
    readonly property int packageModeGo: 1
    readonly property int packageModeSix: 2
    property int packageMode: packageModeUniversal
    property string defaultGo7EngineCommand: "D:\\katago\\engine2024\\go.exe gtp -config ./engine2024.cfg -model \"D:\\Downloads\\model (68).bin.gz\" -override-config useUncertainty=false"
    property string go5EngineCommand: defaultGo7EngineCommand
    property string go7EngineCommand: defaultGo7EngineCommand
    property string six11EngineCommand: defaultGo7EngineCommand
    property string six13EngineCommand: defaultGo7EngineCommand
    property string persistedEngineCommand: ""

    property bool engineAutoAnalyze: true
    property bool enginePaused: false
    property bool engineDisabled: false
    property bool engineLoading: false
    property bool engineNoticeDismissed: false
    property bool genmoveInFlight: false
    property int genmoveRequestSerial: 0
    property int activeGenmoveRequestId: 0
    property int genmovePlayer: 0
    property bool applyingGeneratedMove: false
    property var engineCandidates: []
    property var engineCandidateItems: []
    property var engineCandidateItemMap: ({})
    property var engineCandidateTableItems: []
    property int engineCandidateRevision: 0
    property bool bestCandidateRingVisible: false
    property string bestCandidateRingKey: ""
    property int bestCandidateRingX: -1
    property int bestCandidateRingY: -1
    property var engineSyncedNodeIds: []
    property string engineSyncedBoardSignature: ""
    property string engineSyncedKomiSignature: ""
    property bool engineNeedsFullSync: true
    property int analysisRevision: 0
    property int analysisIntervalCentiseconds: 10
    property int maxAnalysisSeconds: 0
    readonly property int maxLargeIntegerSetting: 1073741824
    property int candidateDisplayCount: 10
    property real candidateMinVisitRatio: 0.001
    property bool candidateShowFilteredMarkers: true
    property bool candidateVariationPreviewVisible: true
    property int candidateVariationPreviewMaxMoves: 10
    readonly property real defaultCandidateVariationPreviewOpacity: 0.40
    property real candidateVariationPreviewOpacity: defaultCandidateVariationPreviewOpacity
    property bool candidateWinrateLabelVisible: true
    property bool candidateVisitsLabelVisible: true
    property bool candidateScoreLabelVisible: true
    property int candidateWinrateFontSize: 57
    property int candidateVisitsFontSize: 42
    property int candidateScoreFontSize: 36
    property bool candidateWinrateBold: true
    property bool candidateVisitsBold: false
    property bool candidateScoreBold: true
    property int candidateWinrateOffsetY: -10
    property int candidateVisitsOffsetY: -5
    property int candidateScoreOffsetY: -5
    property int candidateWinrateDecimals: 1
    property int candidateScoreDecimals: 1
    property bool candidateWinrateShowPercent: false
    property bool candidateScoreShowPercent: false
    readonly property int candidateScoreTitleScoreMean: 0
    readonly property int candidateScoreTitleDrawRate: 1
    property int candidateScoreTitleMode: candidateScoreTitleScoreMean
    property bool candidateRingVisible: true
    property int candidateRingLineWidth: 12
    property bool candidateRankLabelVisible: true
    property string candidateFirstLabelTextColor: "#ff0000"
    property string candidateLabelTextColor: "#000000"
    readonly property string firstCandidateRingColor: "#003b8e"
    readonly property int candidateYzyMinAlpha: 32
    readonly property int candidateYzyMaxAlpha: 240
    readonly property real candidateYzyAlphaFactor: 5.0
    readonly property real candidateYzyColorRatio: 2.0

    property int engineCommunicationLogLimit: 1000
    property bool showEngineCommunicationStdin: true
    property bool showEngineCommunicationStdout: true
    property bool showEngineCommunicationStderr: true

    readonly property string defaultBackgroundColor: "#dbe5ea"
    readonly property string defaultBoardWoodColor: "#d9a75f"
    property string backgroundColor: defaultBackgroundColor
    property string boardWoodColor: defaultBoardWoodColor
    readonly property real minStoneScale: 0.50
    readonly property real defaultStoneScale: 0.95
    readonly property real defaultGridOpacity: 0.92
    readonly property real defaultGridLineWidth: 1.2
    readonly property real defaultSelectedPointScale: 1.00
    readonly property real defaultMoveNumberLabelScale: 1.00
    readonly property real defaultMouseHitRadiusScale: 0.38
    property real stoneScale: defaultStoneScale
    property real gridOpacity: defaultGridOpacity
    property real gridLineWidth: defaultGridLineWidth
    property real selectedPointScale: defaultSelectedPointScale
    property real moveNumberLabelScale: defaultMoveNumberLabelScale
    property real mouseHitRadiusScale: defaultMouseHitRadiusScale

    FontLoader {
        id: coordinateFont
        source: "qrc:/resources/fonts/JetBrainsMono-Regular.ttf"
    }

    onClosing: function(event) {
        savePersistentSettings()
        if (gameDirty && !suppressUnsavedPrompt) {
            event.accepted = false
            unsavedSgfDialog.open()
        }
    }

    onCoordinateDisplayModeChanged: refreshCoordinateDisplayText()
    onCandidateDisplayCountChanged: rebuildEngineCandidateItems()
    onCandidateMinVisitRatioChanged: rebuildEngineCandidateItems()
    onCandidateShowFilteredMarkersChanged: rebuildEngineCandidateItems()
    onCandidateWinrateLabelVisibleChanged: rebuildEngineCandidateItems()
    onCandidateVisitsLabelVisibleChanged: rebuildEngineCandidateItems()
    onCandidateScoreLabelVisibleChanged: rebuildEngineCandidateItems()
    onCandidateWinrateFontSizeChanged: rebuildEngineCandidateItems()
    onCandidateVisitsFontSizeChanged: rebuildEngineCandidateItems()
    onCandidateScoreFontSizeChanged: rebuildEngineCandidateItems()
    onCandidateWinrateBoldChanged: rebuildEngineCandidateItems()
    onCandidateVisitsBoldChanged: rebuildEngineCandidateItems()
    onCandidateScoreBoldChanged: rebuildEngineCandidateItems()
    onCandidateWinrateDecimalsChanged: rebuildEngineCandidateItems()
    onCandidateScoreDecimalsChanged: rebuildEngineCandidateItems()
    onCandidateWinrateShowPercentChanged: rebuildEngineCandidateItems()
    onCandidateScoreShowPercentChanged: rebuildEngineCandidateItems()
    onCandidateLabelTextColorChanged: rebuildEngineCandidateItems()
    onPackageModeChanged: rebuildEngineCandidateItems()
    onGameRuleModeChanged: rebuildEngineCandidateItems()

    menuBar: MenuBar {
        font.pixelSize: root.compactLayout ? 15 : 17

        Menu {
            title: root.trText("menuFile")
            font.pixelSize: root.compactLayout ? 14 : 16

            Action {
                text: root.trText("menuOpenSgf")
                shortcut: "Ctrl+O"
                onTriggered: root.openLoadSgfDialog()
            }

            Action {
                text: root.trText("menuSaveSgf")
                shortcut: "Ctrl+S"
                onTriggered: root.openSaveSgfDialog()
            }

            Action {
                text: root.trText("menuExit")
                onTriggered: root.requestQuit()
            }
        }

        Menu {
            title: root.trText("menuEdit")
            font.pixelSize: root.compactLayout ? 14 : 16

            Action {
                text: root.trText("menuUndo")
                enabled: root.currentNodeId !== 0
                onTriggered: root.undoMove()
            }

            Action {
                text: root.trText("menuDeleteNode")
                enabled: root.currentNodeId !== 0
                onTriggered: root.requestDeleteCurrentNode()
            }

            Action {
                text: root.trText("menuClearBoard")
                onTriggered: root.requestClearBoard()
            }

            Action {
                text: root.trText("menuBoardSize")
                shortcut: "Ctrl+I"
                onTriggered: root.openBoardSizeDialog()
            }
        }

        Menu {
            title: root.trText("menuView")
            font.pixelSize: root.compactLayout ? 14 : 16

            Action {
                text: root.trText("menuResetVisual")
                onTriggered: root.resetVisualSettings()
            }
        }

        Menu {
            title: root.trText("menuSettings")
            font.pixelSize: root.compactLayout ? 14 : 16

            Action {
                text: root.trText("settingsDialogTitle")
                onTriggered: settingsDialog.openPage(0)
            }

            Menu {
                title: root.trText("menuLanguage")
                Action { text: root.trText("languageChinese"); onTriggered: root.language = "zh" }
                Action { text: root.trText("languageEnglish"); onTriggered: root.language = "en" }
            }
        }

        Menu {
            title: root.trText("menuHelp")
            font.pixelSize: root.compactLayout ? 14 : 16

            Action {
                text: root.trText("helpKeysTitle")
                onTriggered: helpKeysDialog.open()
            }

            Action {
                text: root.trText("beginnerTutorialTitle")
                onTriggered: root.openBeginnerTutorial()
            }

            Action {
                text: root.trText("aboutTitle")
                onTriggered: aboutDialog.open()
            }
        }
    }

    FileDialog {
        id: saveSgfDialog
        title: root.trText("sgfSaveTitle")
        fileMode: FileDialog.SaveFile
        defaultSuffix: "sgf"
        nameFilters: [root.trText("sgfFileFilter"), root.trText("allFileFilter")]
        onAccepted: root.saveSgfToFile(selectedFile)
        onRejected: {
            root.saveDialogClosesApp = false
            root.clearPendingClearAction()
            root.onSettingsDialogClosed()
            root.focusBoardInput()
        }
    }

    FileDialog {
        id: loadSgfDialog
        title: root.trText("sgfOpenTitle")
        fileMode: FileDialog.OpenFile
        nameFilters: [root.trText("sgfFileFilter"), root.trText("allFileFilter")]
        onAccepted: root.loadSgfFromFile(selectedFile)
        onRejected: root.focusBoardInput()
    }

    Shortcut {
        sequence: "Ctrl+I"
        context: Qt.ApplicationShortcut
        onActivated: root.openBoardSizeDialog()
    }

    Timer {
        id: autoAnalyzeTimer
        interval: 280
        repeat: false
        onTriggered: root.requestEngineAnalysis(false)
    }

    Timer {
        id: analysisLimitTimer
        interval: Math.max(1, root.maxAnalysisSeconds) * 1000
        repeat: false
        onTriggered: root.pauseEngineAnalysisByLimit()
    }

    Timer {
        id: treeLayoutTimer
        interval: 1
        repeat: false
        onTriggered: root.rebuildTreeLayout()
    }

    Timer {
        id: firstLaunchTimer
        interval: 120
        repeat: false
        onTriggered: {
            if (!root.firstLaunchCompleted)
                initialSetupDialog.open()
        }
    }

    ListModel {
        id: engineCommunicationLogModel
    }

    SettingsDialog { id: settingsDialog; app: root; controller: engineController }
    HiddenSettingsDialog { id: hiddenSettingsDialog; app: root; controller: engineController }
    EngineParametersDialog { id: engineParametersDialog; app: root; controller: engineController }
    EngineFailureDialog { id: engineFailureDialog; app: root }
    HelpKeysDialog { id: helpKeysDialog; app: root }
    AboutDialog { id: aboutDialog; app: root }
    InitialSetupDialog { id: initialSetupDialog; app: root }
    BeginnerTutorialDialog { id: beginnerTutorialDialog; app: root }
    ConfirmDeleteNodeDialog { id: confirmDeleteNodeDialog; app: root }
    GameOverDialog { id: gameOverDialog; app: root }
    UnsavedSgfDialog { id: unsavedSgfDialog; app: root }
    RuleChangeSaveDialog { id: ruleChangeSaveDialog; app: root }
    BoardSizeDialog { id: boardSizeDialog; app: root }

    EngineCommunicationWindow {
        id: engineCommunicationWindow
        app: root
        logModel: engineCommunicationLogModel
        onSendCommand: function(command) { engineController.sendCommand(command) }
        onClearLogRequested: root.clearEngineCommunicationLog()
    }

    function trText(key) {
        language
        var table = translations[language] || translations.zh
        return table[key] || key
    }

    function windowTitleText() {
        return trText("windowTitle")
    }

    function clamp(value, low, high) {
        return Math.min(Math.max(value, low), high)
    }

    function keyFor(x, y) {
        return CoordinateUtils.keyFor(x, y)
    }

    function passKey() {
        return CoordinateUtils.passKey()
    }

    function boardDimensionsText() {
        return CoordinateUtils.boardDimensionsText(boardSizeX, boardSizeY)
    }

    function boardPointCount() {
        return CoordinateUtils.boardPointCount(boardSizeX, boardSizeY)
    }

    function effectiveCoordinateDisplayMode() {
        return CoordinateUtils.effectiveCoordinateFormat(boardSizeX, boardSizeY, coordinateDisplayMode)
    }

    function coordinateDisplayForcedNumeric() {
        return effectiveCoordinateDisplayMode() === coordinateDisplayNumeric
               && coordinateDisplayMode !== coordinateDisplayNumeric
               && coordinateDisplayMode !== coordinateDisplayNone
    }

    function xCoordinateText(x) {
        return CoordinateUtils.xCoordinateText(x, boardSizeX, boardSizeY, coordinateDisplayMode)
    }

    function yCoordinateText(y) {
        return CoordinateUtils.yCoordinateText(y, boardSizeX, boardSizeY, coordinateDisplayMode)
    }

    function coordinateText(x, y) {
        return CoordinateUtils.coordinateText(x, y, boardSizeX, boardSizeY, coordinateDisplayMode)
    }

    function parseCoordinateText(text) {
        return CoordinateUtils.parseCoordinateText(text, boardSizeX, boardSizeY, coordinateDisplayMode)
    }

    function setCoordinateDisplayMode(mode) {
        var nextMode = Math.round(clamp(mode, coordinateDisplayGoNoI, coordinateDisplayNone))
        if (coordinateDisplayMode === nextMode)
            return
        coordinateDisplayMode = nextMode
    }

    function refreshCoordinateDisplayText() {
        rebuildTreeLayout()
        rebuildEngineCandidateItems()
    }

    function gtpCoordinateName(x, y, width, height) {
        return CoordinateUtils.gtpCoordinateName(x, y, width, height)
    }

    function parseGtpCoordinateName(text, width, height) {
        return CoordinateUtils.parseGtpCoordinateName(text, width, height)
    }

    function sgfCoordinateText(x, y) {
        return SgfUtils.sgfCoordinateText(x, y)
    }

    function pointInBoard(x, y) {
        return x >= 0 && x < boardSizeX && y >= 0 && y < boardSizeY
    }

    function boardDims() {
        return { "x": boardSizeX, "y": boardSizeY }
    }

    function stoneDataAt(x, y) {
        boardRevision
        var value = stones[keyFor(x, y)]
        return value === undefined ? null : value
    }

    function stoneAt(x, y) {
        var value = stoneDataAt(x, y)
        return value ? value.player : 0
    }

    function isLastMoveAt(x, y) {
        boardRevision
        var node = currentNode()
        return !!node && !node.isPass && node.key === keyFor(x, y)
    }

    function nodeById(id) {
        return gameNodes[id] === undefined ? null : gameNodes[id]
    }

    function currentNode() {
        return nodeById(currentNodeId)
    }

    function rootNode() {
        return {
            "id": 0,
            "parent": -1,
            "children": [],
            "x": -1,
            "y": -1,
            "key": "",
            "player": 0,
            "moveNumber": 0,
            "isPass": false,
            "blackCaptures": 0,
            "whiteCaptures": 0,
            "koLocKey": "",
            "koLocX": -1,
            "koLocY": -1,
            "analysisBlackWinrate": -1
        }
    }

    function nodePath(id) {
        var path = []
        var node = nodeById(id)
        while (node && node.id !== 0) {
            path.unshift(node)
            node = nodeById(node.parent)
        }
        return path
    }

    function nextPlayerFromMode() {
        if (stoneColorMode === stoneColorModeBlack)
            return 1
        if (stoneColorMode === stoneColorModeWhite)
            return 2

        var node = currentNode()
        if (node && node.player === 1)
            return 2
        if (node && node.player === 2)
            return 1
        return 1
    }

    function pointLegalInMap(map, x, y, player, activeKoLocKey) {
        return GameRules.pointLegalInMap(map, boardDims(), x, y, player, activeKoLocKey, gameRuleMode)
    }

    function buildPointLegalityMap(map, player, activeKoLocKey) {
        return GameRules.buildPointLegalityMap(map, boardDims(), player, activeKoLocKey, gameRuleMode)
    }

    function shouldCachePointLegality() {
        return false
    }

    function rebuildPointLegality() {
        legalPointMap = shouldCachePointLegality()
                        ? buildPointLegalityMap(stones, currentPlayer, koLocKey)
                        : ({})
        legalityRevision += 1
    }

    function pointIsLegal(x, y) {
        legalityRevision
        if (!pointInBoard(x, y))
            return false
        if (!shouldCachePointLegality())
            return pointLegalInMap(stones, x, y, currentPlayer, koLocKey)
        return legalPointMap[keyFor(x, y)] === true
    }

    function selectedPointLegal() {
        legalityRevision
        hoverKey
        if (hoverKey === "")
            return false
        return pointIsLegal(hoverX, hoverY)
    }

    function selectedPointPlayable() {
        return selectedPointLegal()
    }

    function selectedPointColor() {
        return selectedPointLegal() ? "#2fb97f" : "#e3342f"
    }

    function pointIsEngineCandidateKey(key) {
        if (!key || key.length <= 0)
            return false
        return engineCandidateItemMap[key] !== undefined
    }

    function clampCoordinateInput(text, size) {
        var value = parseInt(String(text), 10)
        if (isNaN(value))
            value = 0
        return Math.round(clamp(value, 0, size - 1))
    }

    function clampOneBasedCoordinateInput(text, size) {
        var value = parseInt(String(text), 10)
        if (isNaN(value))
            value = 1
        return Math.round(clamp(value, 1, size))
    }

    function setHoverPoint(x, y) {
        var nextX = Math.round(clamp(x, 0, boardSizeX - 1))
        var nextY = Math.round(clamp(y, 0, boardSizeY - 1))
        hoverX = nextX
        hoverY = nextY
        hoverKey = keyFor(nextX, nextY)
    }

    function setSelectedPoint(x, y, locked, fromCandidateList) {
        var nextX = Math.round(clamp(x, 0, boardSizeX - 1))
        var nextY = Math.round(clamp(y, 0, boardSizeY - 1))
        if (locked !== undefined) {
            selectedPointLocked = locked
            selectedPointFromCandidateList = locked === true && fromCandidateList === true
        } else if (!selectedPointLocked) {
            selectedPointFromCandidateList = false
        }
        setHoverPoint(nextX, nextY)
        if (!pointIsLegal(nextX, nextY)) {
            statusMode = stoneAt(nextX, nextY) !== 0 ? "occupied" : "message"
            statusMessage = illegalPointMessage(nextX, nextY, "")
            statusX = nextX
            statusY = nextY
        } else if (statusMode === "occupied"
                   || (statusMode === "message"
                       && (statusMessage.indexOf(trText("suicideMove")) === 0
                           || statusMessage.indexOf(trText("koMove")) === 0))) {
            statusMode = "turn"
        }
        return true
    }

    function illegalPointMessage(x, y, fallback) {
        if (stoneAt(x, y) !== 0)
            return trText("occupied") + ": " + coordinateText(x, y)
        if (koLocKey !== "" && keyFor(x, y) === koLocKey)
            return trText("koMove") + ": " + coordinateText(x, y)
        if (gameRuleMode === gameRuleGo)
            return trText("suicideMove") + ": " + coordinateText(x, y)
        return fallback
    }

    function mapStoneItems(map) {
        var items = []
        for (var key in map)
            items.push(map[key])
        items.sort(function(left, right) { return left.moveNumber - right.moveNumber })
        return items
    }

    function rebuildPositionFromNode(id) {
        clearEngineCandidates()
        var map = ({})
        var blackCap = 0
        var whiteCap = 0
        var ko = GameRules.emptyKoLoc()
        var path = nodePath(id)
        for (var i = 0; i < path.length; ++i) {
            var node = path[i]
            if (node.isPass) {
                ko = GameRules.emptyKoLoc()
                node.blackCaptures = blackCap
                node.whiteCaptures = whiteCap
                node.koLocKey = ko.key
                node.koLocX = ko.x
                node.koLocY = ko.y
                continue
            }

            var item = {
                "x": node.x,
                "y": node.y,
                "key": keyFor(node.x, node.y),
                "player": node.player,
                "moveNumber": node.moveNumber,
                "nodeId": node.id
            }
            if (gameRuleMode === gameRuleGo) {
                var result = GameRules.simulateGoMoveOnMap(map, boardDims(), item, true)
                if (result.ok) {
                    if (node.player === 1)
                        blackCap += result.captured
                    else
                        whiteCap += result.captured
                    ko = GameRules.koLocFromGoMoveResult(gameRuleMode, result)
                }
            } else {
                map[item.key] = item
                ko = GameRules.emptyKoLoc()
            }
            node.blackCaptures = blackCap
            node.whiteCaptures = whiteCap
            node.koLocKey = ko.key
            node.koLocX = ko.x
            node.koLocY = ko.y
        }

        stones = map
        stoneItems = mapStoneItems(map)
        stoneCount = stoneItems.length
        blackCaptures = blackCap
        whiteCaptures = whiteCap
        koLocKey = ko.key
        koLocX = ko.x
        koLocY = ko.y
        currentPlayer = nextPlayerFromMode()
        rebuildPointLegality()
        gomokuWinLineItems = buildGomokuWinLineItems(map)
        boardRevision += 1
    }

    function resetGameTree() {
        stopAnalysisLimitTimer()
        gameNodes = [rootNode()]
        currentNodeId = 0
        nextNodeId = 1
        stones = ({})
        stoneItems = []
        stoneCount = 0
        blackCaptures = 0
        whiteCaptures = 0
        koLocKey = ""
        koLocX = -1
        koLocY = -1
        gameWinner = 0
        gameOverReason = ""
        currentPlayer = 1
        clearHover(true)
        clearEngineCandidates()
        rebuildPointLegality()
        rebuildTreeLayout()
        boardRevision += 1
    }

    function branchChildMatching(parent, key, player, isPass) {
        var children = parent ? (parent.children || []) : []
        for (var i = 0; i < children.length; ++i) {
            var child = nodeById(children[i])
            if (child && child.key === key && child.player === player && child.isPass === isPass)
                return child
        }
        return null
    }

    function addMoveNode(player, x, y, isPass, capturedStones, koLoc, skipPositionRebuild, deferTreeLayoutRebuild) {
        var parent = currentNode()
        if (!parent)
            return null
        var key = isPass ? passKey() : keyFor(x, y)
        var existing = branchChildMatching(parent, key, player, isPass)
        if (existing) {
            gotoNode(existing.id)
            return existing
        }

        var id = nextNodeId++
        var node = {
            "id": id,
            "parent": parent.id,
            "children": [],
            "x": isPass ? -1 : x,
            "y": isPass ? -1 : y,
            "key": key,
            "player": player,
            "moveNumber": parent.moveNumber + 1,
            "isPass": isPass,
            "capturedStones": capturedStones || [],
            "blackCaptures": blackCaptures,
            "whiteCaptures": whiteCaptures,
            "koLocKey": koLoc ? koLoc.key : "",
            "koLocX": koLoc ? koLoc.x : -1,
            "koLocY": koLoc ? koLoc.y : -1,
            "analysisBlackWinrate": -1
        }
        gameNodes[id] = node
        parent.children = (parent.children || []).slice()
        parent.children.push(id)
        gameNodes = gameNodes.slice()
        currentNodeId = id
        gameDirty = true
        if (!skipPositionRebuild)
            rebuildPositionFromNode(currentNodeId)
        if (deferTreeLayoutRebuild)
            scheduleTreeLayoutRebuild()
        else
            rebuildTreeLayout()
        clearEngineCandidates()
        if (!skipPositionRebuild) {
            scheduleAutoAnalysis()
            requestAiMoveIfNeeded()
        }
        return node
    }

    function placeStone(x, y) {
        if (!pointInBoard(x, y))
            return false

        if (stoneAt(x, y) !== 0) {
            statusMode = "occupied"
            statusMessage = illegalPointMessage(x, y, "")
            return false
        }

        var pointKey = keyFor(x, y)
        if (gameRuleMode === gameRuleGo && koLocKey !== "" && pointKey === koLocKey) {
            statusMode = "message"
            statusMessage = illegalPointMessage(x, y, "ko")
            return false
        }

        var player = currentPlayer
        var existingChild = branchChildMatching(currentNode(), pointKey, player, false)
        if (existingChild) {
            selectedPointLocked = false
            selectedPointFromCandidateList = false
            gotoNode(existingChild.id)
            return true
        }

        var item = {
            "x": x,
            "y": y,
            "key": pointKey,
            "player": player,
            "moveNumber": currentMoveNumberValue() + 1,
            "nodeId": -1
        }
        var captured = []
        var ko = GameRules.emptyKoLoc()
        var working = GameRules.cloneStoneMap(stones)
        if (gameRuleMode === gameRuleGo) {
            var result = GameRules.simulateGoMoveOnMap(working, boardDims(), item, true)
            if (!result.ok) {
                statusMode = "message"
                statusMessage = illegalPointMessage(x, y, result.reason)
                return false
            }
            captured = result.capturedStones
            ko = GameRules.koLocFromGoMoveResult(gameRuleMode, result)
        } else {
            working[item.key] = item
        }

        selectedPointLocked = false
        selectedPointFromCandidateList = false
        var node = addMoveNode(player, x, y, false, captured, ko, true, true)
        if (!node)
            return false
        applyIncrementalMovePosition(node, working, captured.length, ko)
        statusMode = "turn"
        statusMessage = captured.length > 0 ? trText("captureMessage") + ": " + captured.length : ""
        checkGameOverAfterMove(node)
        scheduleAutoAnalysis()
        requestAiMoveIfNeeded()
        return true
    }

    function applyIncrementalMovePosition(node, nextMap, capturedCount, ko) {
        if (!node || !nextMap)
            return

        if (!node.isPass && nextMap[node.key]) {
            nextMap[node.key].nodeId = node.id
            nextMap[node.key].moveNumber = node.moveNumber
        }

        stones = nextMap
        stoneItems = mapStoneItems(nextMap)
        stoneCount = stoneItems.length
        if (node.player === 1)
            blackCaptures += capturedCount
        else if (node.player === 2)
            whiteCaptures += capturedCount
        ko = ko || GameRules.emptyKoLoc()
        koLocKey = ko.key
        koLocX = ko.x
        koLocY = ko.y
        node.blackCaptures = blackCaptures
        node.whiteCaptures = whiteCaptures
        node.koLocKey = koLocKey
        node.koLocX = koLocX
        node.koLocY = koLocY
        currentPlayer = nextPlayerFromMode()
        rebuildPointLegality()
        gomokuWinLineItems = buildGomokuWinLineItems(nextMap)
        boardRevision += 1
    }

    function passMove() {
        var player = currentPlayer
        selectedPointLocked = false
        selectedPointFromCandidateList = false
        var node = addMoveNode(player, -1, -1, true, [], GameRules.emptyKoLoc())
        if (!node)
            return
        statusMode = "message"
        statusMessage = (player === 1 ? trText("black") : trText("white")) + " " + trText("passMessage")
        checkGameOverAfterMove(node)
    }

    function checkGameOverAfterMove(node) {
        if (!node)
            return
        if (analysisModeActive())
            return
        if (gameRuleMode === gameRuleGo && node.isPass) {
            var parent = nodeById(node.parent)
            if (parent && parent.isPass) {
                gameWinner = 0
                gameOverReason = trText("gameOverDoublePass")
                gameOverDialog.open()
            }
        } else if (gameRuleMode === gameRuleGomoku && gomokuWinLineItems.length > 0) {
            gameWinner = node.player
            gameOverReason = trText("gameOverFive")
            gameOverDialog.open()
        }
    }

    function undoMove() {
        var node = currentNode()
        if (node && node.parent >= 0)
            gotoNode(node.parent)
    }

    function gotoNode(id) {
        if (!nodeById(id))
            return false
        if (id === currentNodeId)
            return false
        currentNodeId = id
        selectedPointLocked = false
        selectedPointFromCandidateList = false
        rebuildPositionFromNode(id)
        rebuildTreeLayout()
        scheduleAutoAnalysis()
        focusBoardInput()
        return true
    }

    function gotoFirstMove() {
        gotoNode(0)
    }

    function gotoLastMove() {
        var id = currentNodeId
        var node = nodeById(id)
        while (node && node.children && node.children.length > 0) {
            id = node.children[0]
            node = nodeById(id)
        }
        gotoNode(id)
    }

    function gotoRelativeMove(delta) {
        var targetId = currentNodeId
        if (delta < 0) {
            for (var i = 0; i < -delta; ++i) {
                var node = nodeById(targetId)
                if (!node || node.parent < 0)
                    break
                targetId = node.parent
            }
            gotoNode(targetId)
            return
        }
        for (var f = 0; f < delta; ++f) {
            var n = nodeById(targetId)
            if (!n || !n.children || n.children.length <= 0)
                break
            targetId = n.children[0]
        }
        gotoNode(targetId)
    }

    function gotoMoveNumber(moveNumber) {
        if (isNaN(moveNumber))
            return
        var path = [nodeById(0)].concat(nodePath(currentNodeId))
        for (var i = 0; i < path.length; ++i) {
            if (path[i] && path[i].moveNumber === moveNumber) {
                gotoNode(path[i].id)
                return
            }
        }
        for (var id = 0; id < gameNodes.length; ++id) {
            var node = nodeById(id)
            if (node && node.moveNumber === moveNumber) {
                gotoNode(node.id)
                return
            }
        }
    }

    function currentMoveNumberValue() {
        var node = currentNode()
        return node ? node.moveNumber : 0
    }

    function currentMoveNumberText() {
        return String(currentMoveNumberValue())
    }

    function maxMoveNumberValue() {
        var maxMove = 0
        for (var i = 0; i < gameNodes.length; ++i) {
            var node = nodeById(i)
            if (node)
                maxMove = Math.max(maxMove, node.moveNumber)
        }
        return maxMove
    }

    function currentNodeText() {
        var node = currentNode()
        if (!node || node.id === 0)
            return trText("rootMove")
        return node.moveNumber + " " + (node.isPass ? trText("passMove") : coordinateText(node.x, node.y))
    }

    function deleteCurrentNode() {
        var node = currentNode()
        if (!node || node.id === 0)
            return
        var parent = nodeById(node.parent)
        if (parent) {
            var children = (parent.children || []).slice()
            var index = children.indexOf(node.id)
            if (index >= 0)
                children.splice(index, 1)
            parent.children = children
        }
        deleteSubtree(node.id)
        currentNodeId = parent ? parent.id : 0
        gameNodes = gameNodes.slice()
        gameDirty = true
        rebuildPositionFromNode(currentNodeId)
        rebuildTreeLayout()
        scheduleAutoAnalysis()
    }

    function deleteSubtree(id) {
        var node = nodeById(id)
        if (!node)
            return
        var children = (node.children || []).slice()
        for (var i = 0; i < children.length; ++i)
            deleteSubtree(children[i])
        gameNodes[id] = undefined
    }

    function requestDeleteCurrentNode() {
        var node = currentNode()
        if (!node || node.id === 0)
            return
        if (node.children && node.children.length > 0)
            confirmDeleteNodeDialog.open()
        else
            deleteCurrentNode()
    }

    function requestClearBoard() {
        if (gameDirty) {
            pendingClearAction = "clearBoard"
            ruleChangeSaveDialog.open()
            return
        }
        resetGameTree()
    }

    function setCurrentVariationAsMainBranch() {
        var path = nodePath(currentNodeId)
        var changed = false
        for (var i = 0; i < path.length; ++i) {
            var child = path[i]
            var parent = nodeById(child.parent)
            if (!parent)
                continue
            var children = (parent.children || []).slice()
            var index = children.indexOf(child.id)
            if (index > 0) {
                children.splice(index, 1)
                children.unshift(child.id)
                parent.children = children
                changed = true
            }
        }
        if (changed) {
            gameNodes = gameNodes.slice()
            rebuildTreeLayout()
            gameDirty = true
        }
    }

    function toolbarActionEnabled(action) {
        if (action === "delete" || action === "back1" || action === "back10" || action === "firstMove")
            return currentNodeId !== 0
        if (action === "forward1" || action === "forward10" || action === "lastMove") {
            var node = currentNode()
            return !!node && node.children && node.children.length > 0
        }
        if (action === "setMainBranch")
            return currentNodeId !== 0
        return true
    }

    function runToolbarAction(action) {
        if (action === "refresh")
            requestEngineAnalysis(false)
        else if (action === "setMainBranch")
            setCurrentVariationAsMainBranch()
        else if (action === "clearBoard")
            requestClearBoard()
        else if (action === "delete")
            requestDeleteCurrentNode()
        else if (action === "firstMove")
            gotoFirstMove()
        else if (action === "back10")
            gotoRelativeMove(-10)
        else if (action === "back1")
            gotoRelativeMove(-1)
        else if (action === "forward1")
            gotoRelativeMove(1)
        else if (action === "forward10")
            gotoRelativeMove(10)
        else if (action === "lastMove")
            gotoLastMove()
        else if (action === "candidates")
            focusBoardInput()
    }

    function treeNodeAt(x, y) {
        for (var i = treeNodes.length - 1; i >= 0; --i) {
            var node = treeNodes[i]
            var dx = x - node.x
            var dy = y - node.y
            if (Math.sqrt(dx * dx + dy * dy) <= node.radius + 4)
                return node.id
        }
        return -1
    }

    function scheduleTreeLayoutRebuild() {
        if (treeLayoutTimer)
            treeLayoutTimer.restart()
        else
            rebuildTreeLayout()
    }

    function rebuildTreeLayout() {
        var rowHeight = 38
        var columnWidth = 42
        var margin = compactLayout ? 32 : 36
        var radius = 12
        var laneById = ({})
        var nextLane = 0

        function assignLane(id) {
            var node = nodeById(id)
            if (!node)
                return 0
            var children = node.children || []
            if (children.length === 0) {
                laneById[id] = nextLane
                nextLane += 1
                return laneById[id]
            }
            var firstLane = -1
            for (var i = 0; i < children.length; ++i) {
                var childLane = assignLane(children[i])
                if (firstLane < 0)
                    firstLane = childLane
            }
            laneById[id] = firstLane < 0 ? 0 : firstLane
            return laneById[id]
        }

        assignLane(0)
        if (nextLane === 0)
            nextLane = 1

        var currentPathMap = ({})
        currentPathMap[0] = true
        var path = nodePath(currentNodeId)
        for (var p = 0; p < path.length; ++p)
            currentPathMap[path[p].id] = true

        var nodes = []
        var nodeMap = ({})
        var maxMove = 0
        for (var id = 0; id < gameNodes.length; ++id) {
            var node = nodeById(id)
            if (!node)
                continue

            var lane = laneById[id] === undefined ? 0 : laneById[id]
            var treeNode = {
                "id": id,
                "parent": node.parent,
                "x": margin + lane * columnWidth,
                "y": margin + node.moveNumber * rowHeight,
                "radius": radius,
                "moveNumber": node.moveNumber,
                "player": node.player,
                "isPass": node.isPass === true,
                "coordinate": node.id === 0
                              ? trText("rootMove")
                              : node.isPass
                                ? trText("passMove")
                                : coordinateText(node.x, node.y),
                "current": id === currentNodeId,
                "currentPath": currentPathMap[id] === true,
                "label": node.moveNumber === 0 ? "0" : node.isPass ? "P" : String(node.moveNumber)
            }
            nodes.push(treeNode)
            nodeMap[id] = treeNode
            maxMove = Math.max(maxMove, node.moveNumber)
        }

        var edges = []
        for (var e = 0; e < nodes.length; ++e) {
            var child = nodes[e]
            var parent = nodeMap[child.parent]
            if (parent) {
                edges.push({
                    "x1": parent.x,
                    "y1": parent.y,
                    "x2": child.x,
                    "y2": child.y,
                    "current": child.currentPath
                })
            }
        }

        treeNodes = nodes
        treeEdges = edges
        treeCanvasWidth = Math.max(minimumTreeCanvasWidth, margin * 2 + Math.max(0, nextLane - 1) * columnWidth + radius * 2)
        treeCanvasHeight = Math.max(minimumTreeCanvasHeight, margin * 2 + maxMove * rowHeight + radius * 2)
        treeRevision += 1
    }

    function gomokuRuleLabel(rule) {
        if (rule === gomokuRuleStdCon5)
            return trText("gomokuRuleStdCon5")
        if (rule === gomokuRuleFreestyle)
            return trText("gomokuRuleFreestyle")
        if (rule === gomokuRuleStandard)
            return trText("gomokuRuleStandard")
        if (rule === gomokuRuleCon7)
            return trText("gomokuRuleCon7")
        if (rule === gomokuRuleDirectCon5)
            return trText("gomokuRuleDirectCon5")
        return trText("gomokuRuleCon5")
    }

    function gomokuRuleTip(rule) {
        if (rule === gomokuRuleStdCon5)
            return trText("gomokuRuleStdCon5Tip")
        if (rule === gomokuRuleFreestyle)
            return trText("gomokuRuleFreestyleTip")
        if (rule === gomokuRuleStandard)
            return trText("gomokuRuleStandardTip")
        if (rule === gomokuRuleCon7)
            return trText("gomokuRuleCon7Tip")
        if (rule === gomokuRuleDirectCon5)
            return trText("gomokuRuleDirectCon5Tip")
        return trText("gomokuRuleCon5Tip")
    }

    function gomokuRuleEngineValue(rule) {
        if (rule === gomokuRuleStdCon5)
            return "stdcon5"
        if (rule === gomokuRuleFreestyle)
            return "freestyle"
        if (rule === gomokuRuleStandard)
            return "standard"
        if (rule === gomokuRuleCon7)
            return "con7"
        if (rule === gomokuRuleDirectCon5)
            return "dcon5"
        return "con5"
    }

    function gameRuleText() {
        return gameRuleMode === gameRuleGo ? trText("gameRuleGo") : gomokuRuleLabel(gomokuRuleMode)
    }

    function goRuleOptions() {
        return [{ "label": trText("goRuleTrompTaylor"), "value": -1, "tip": trText("goRuleTrompTaylorTip") }]
    }

    function gomokuRuleOptions() {
        var options = [
            { "label": gomokuRuleLabel(gomokuRuleCon5), "value": gomokuRuleCon5, "tip": gomokuRuleTip(gomokuRuleCon5) },
            { "label": gomokuRuleLabel(gomokuRuleStdCon5), "value": gomokuRuleStdCon5, "tip": gomokuRuleTip(gomokuRuleStdCon5) },
            { "label": gomokuRuleLabel(gomokuRuleFreestyle), "value": gomokuRuleFreestyle, "tip": gomokuRuleTip(gomokuRuleFreestyle) },
            { "label": gomokuRuleLabel(gomokuRuleStandard), "value": gomokuRuleStandard, "tip": gomokuRuleTip(gomokuRuleStandard) },
            { "label": gomokuRuleLabel(gomokuRuleCon7), "value": gomokuRuleCon7, "tip": gomokuRuleTip(gomokuRuleCon7) },
            { "label": gomokuRuleLabel(gomokuRuleDirectCon5), "value": gomokuRuleDirectCon5, "tip": gomokuRuleTip(gomokuRuleDirectCon5) }
        ]
        if (packageMode !== packageModeSix)
            return options
        return [options[gomokuRuleFreestyle], options[gomokuRuleStandard], options[gomokuRuleCon7], options[gomokuRuleDirectCon5]]
    }

    function ruleVariantOptions() {
        return gameRuleMode === gameRuleGo ? goRuleOptions() : gomokuRuleOptions()
    }

    function ruleVariantCurrentIndex() {
        var options = ruleVariantOptions()
        if (gameRuleMode === gameRuleGo)
            return 0
        for (var i = 0; i < options.length; ++i) {
            if (options[i].value === gomokuRuleMode)
                return i
        }
        return 0
    }

    function ruleVariantCurrentTip() {
        var options = ruleVariantOptions()
        var index = ruleVariantCurrentIndex()
        return index >= 0 && index < options.length ? options[index].tip : ""
    }

    function setRuleVariantFromIndex(index) {
        var options = ruleVariantOptions()
        if (index < 0 || index >= options.length)
            return
        if (gameRuleMode === gameRuleGomoku) {
            gomokuRuleMode = options[index].value
            rebuildPositionFromNode(currentNodeId)
            resetEngineSyncState()
            scheduleAutoAnalysis()
        }
    }

    function ruleModeButtonsVisible() {
        return packageMode === packageModeUniversal
    }

    function ruleVariantComboVisible() {
        return packageMode !== packageModeGo
    }

    function komiControlsVisible() {
        return packageMode !== packageModeSix
    }

    function engineCommandEditable() {
        return packageMode === packageModeUniversal
    }

    function customBoardSizeAllowed() {
        return packageMode === packageModeUniversal
    }

    function boardSizePresetAllowed(size) {
        if (packageMode === packageModeGo)
            return size === 5 || size === 7 || size === 9 || size === 13 || size === 19
        if (packageMode === packageModeSix)
            return size === 11 || size === 13
        return size === 5 || size === 7 || size === 9 || size === 13 || size === 19
    }

    function boardDimensionsAllowedForPackage(xSize, ySize) {
        if (packageMode === packageModeUniversal)
            return true
        if (xSize !== ySize)
            return false
        return boardSizePresetAllowed(xSize)
    }

    function ruleModeAllowedForPackage(mode) {
        if (packageMode === packageModeGo)
            return mode === gameRuleGo
        if (packageMode === packageModeSix)
            return mode === gameRuleGomoku
        return true
    }

    function packageDefaultBoardSize() {
        if (packageMode === packageModeGo)
            return 19
        if (packageMode === packageModeSix)
            return 13
        return defaultBoardSize
    }

    function packageModeText(mode) {
        if (mode === packageModeGo)
            return trText("packageModeGo")
        if (mode === packageModeSix)
            return trText("packageModeSix")
        return trText("packageModeUniversal")
    }

    function packageBoardSizeRejectText(xSize, ySize) {
        var dims = CoordinateUtils.boardDimensionsText(xSize, ySize)
        if (packageMode === packageModeGo)
            return trText("packageBoardSizeRejected") + ": " + dims
        if (packageMode === packageModeSix)
            return trText("packageBoardSizeRejected") + ": " + dims + " (11x11 / 13x13)"
        return trText("packageBoardSizeRejected") + ": " + dims
    }

    function normalizeGomokuRuleForCurrentMode() {
        if (gameRuleMode !== gameRuleGomoku)
            return
        if (packageMode === packageModeSix && gomokuRuleMode !== gomokuRuleFreestyle
                && gomokuRuleMode !== gomokuRuleStandard
                && gomokuRuleMode !== gomokuRuleCon7
                && gomokuRuleMode !== gomokuRuleDirectCon5)
            gomokuRuleMode = gomokuRuleFreestyle
    }

    function requestRuleModeChange(mode) {
        if (mode === gameRuleMode)
            return
        if (!ruleModeAllowedForPackage(mode))
            return
        if (gameDirty) {
            pendingClearAction = "ruleMode"
            pendingRuleMode = mode
            ruleChangeSaveDialog.open()
            return
        }
        applyRuleModeChange(mode)
    }

    function applyRuleModeChange(mode) {
        if (mode !== gameRuleGo && mode !== gameRuleGomoku)
            return
        if (!ruleModeAllowedForPackage(mode))
            return
        gameRuleMode = mode
        normalizeGomokuRuleForCurrentMode()
        clearHover(true)
        resetGameTree()
        gameDirty = false
        statusMode = "message"
        statusMessage = trText("ruleChanged") + ": " + gameRuleText()
        resetEngineSyncState()
        scheduleAutoAnalysis()
        requestAiMoveIfNeeded()
        focusBoardInput()
    }

    function requestBoardDimensionsChange(xSize, ySize, markDirty) {
        var nextX = Math.round(clamp(xSize, minBoardSize, maxBoardSize))
        var nextY = Math.round(clamp(ySize, minBoardSize, maxBoardSize))
        if (!boardDimensionsAllowedForPackage(nextX, nextY)) {
            statusMode = "message"
            statusMessage = packageBoardSizeRejectText(nextX, nextY)
            return false
        }
        if (nextX === boardSizeX && nextY === boardSizeY)
            return true
        if (gameDirty) {
            pendingClearAction = "boardSize"
            pendingBoardSizeX = nextX
            pendingBoardSizeY = nextY
            ruleChangeSaveDialog.open()
            return false
        }
        return setBoardDimensions(nextX, nextY, markDirty)
    }

    function setBoardDimensions(xSize, ySize, markDirty) {
        var nextX = Math.round(clamp(xSize, minBoardSize, maxBoardSize))
        var nextY = Math.round(clamp(ySize, minBoardSize, maxBoardSize))
        if (!boardDimensionsAllowedForPackage(nextX, nextY)) {
            statusMode = "message"
            statusMessage = packageBoardSizeRejectText(nextX, nextY)
            return false
        }
        if (nextX === boardSizeX && nextY === boardSizeY)
            return true
        boardSizeX = nextX
        boardSizeY = nextY
        clearHover(true)
        resetGameTree()
        setSelectedPoint(0, 0)
        if (markDirty !== false)
            gameDirty = true
        applyEngineCommandForCurrentPackageMode(false)
        resetEngineSyncState()
        scheduleAutoAnalysis()
        requestAiMoveIfNeeded()
        return true
    }

    function resetBoardSize() {
        var size = packageDefaultBoardSize()
        setBoardDimensions(size, size)
    }

    function pendingClearMessage() {
        if (pendingClearAction === "openSgf")
            return trText("confirmOpenSgfSave")
        if (pendingClearAction === "boardSize")
            return trText("confirmBoardSizeChangeSave")
        if (pendingClearAction === "clearBoard")
            return trText("confirmBoardSizeChangeSave")
        return trText("confirmRuleChangeSave")
    }

    function pendingClearTitle() {
        return trText("clearGamePromptTitle")
    }

    function clearPendingClearAction() {
        pendingClearAction = ""
        pendingRuleMode = -1
        pendingBoardSizeX = -1
        pendingBoardSizeY = -1
    }

    function applyPendingClearAction() {
        if (pendingClearAction === "ruleMode") {
            var mode = pendingRuleMode
            clearPendingClearAction()
            gameDirty = false
            applyRuleModeChange(mode)
            return
        }
        if (pendingClearAction === "boardSize") {
            var xSize = pendingBoardSizeX
            var ySize = pendingBoardSizeY
            clearPendingClearAction()
            gameDirty = false
            setBoardDimensions(xSize, ySize)
            return
        }
        if (pendingClearAction === "openSgf") {
            clearPendingClearAction()
            gameDirty = false
            loadSgfDialog.open()
            return
        }
        if (pendingClearAction === "clearBoard") {
            clearPendingClearAction()
            gameDirty = false
            resetGameTree()
            return
        }
        clearPendingClearAction()
        focusBoardInput()
    }

    function engineRuleCommand() {
        if (gameRuleMode !== gameRuleGomoku)
            return ""
        return "kata-set-rule basicrule " + gomokuRuleEngineValue(gomokuRuleMode)
    }

    function engineBoardSizeCommands() {
        if (boardSizeX === boardSizeY)
            return [ "boardsize " + boardSizeX ]
        return [ "rectangular_boardsize " + boardSizeX + " " + boardSizeY ]
    }

    function engineCoordinateForNode(node) {
        if (!node)
            return ""
        if (node.isPass)
            return "pass"
        return gtpCoordinateName(node.x, node.y, boardSizeX, boardSizeY)
    }

    function parseEngineCoordinate(text) {
        return parseGtpCoordinateName(text, boardSizeX, boardSizeY)
    }

    function enginePlayCommandForNode(node) {
        var color = node.player === 1 ? "B" : "W"
        return "play " + color + " " + engineCoordinateForNode(node)
    }

    function engineBoardSignature() {
        return [boardSizeX, boardSizeY, gameRuleMode, gameRuleMode === gameRuleGomoku ? gomokuRuleMode : "go"].join(":")
    }

    function engineKomiCommand() {
        return "komi " + Number(effectiveKomi()).toFixed(1)
    }

    function engineKomiSignature() {
        return Number(effectiveKomi()).toFixed(1)
    }

    function engineSyncCommands() {
        var path = nodePath(currentNodeId)
        var commands = [ "stop" ]

        if (engineNeedsFullSync || engineSyncedBoardSignature !== engineBoardSignature()) {
            commands = commands.concat(engineBoardSizeCommands())
            commands.push(engineKomiCommand())
            var fullRuleCommand = engineRuleCommand()
            if (fullRuleCommand.length > 0)
                commands.push(fullRuleCommand)
            commands.push("clear_board")
            for (var fullIndex = 0; fullIndex < path.length; ++fullIndex)
                commands.push(enginePlayCommandForNode(path[fullIndex]))
            engineSyncedNodeIds = []
            for (var fullPathIndex = 0; fullPathIndex < path.length; ++fullPathIndex)
                engineSyncedNodeIds.push(path[fullPathIndex].id)
            engineSyncedBoardSignature = engineBoardSignature()
            engineSyncedKomiSignature = engineKomiSignature()
            engineNeedsFullSync = false
            return commands
        }

        if (engineSyncedKomiSignature !== engineKomiSignature()) {
            commands.push(engineKomiCommand())
            engineSyncedKomiSignature = engineKomiSignature()
        }
        var pathIds = []
        for (var p = 0; p < path.length; ++p)
            pathIds.push(path[p].id)

        var commonLength = 0
        var maxCommonLength = Math.min(engineSyncedNodeIds.length, pathIds.length)
        while (commonLength < maxCommonLength
               && engineSyncedNodeIds[commonLength] === pathIds[commonLength])
            commonLength += 1

        for (var undoIndex = engineSyncedNodeIds.length - 1; undoIndex >= commonLength; --undoIndex)
            commands.push("undo")
        for (var playIndex = commonLength; playIndex < path.length; ++playIndex)
            commands.push(enginePlayCommandForNode(path[playIndex]))

        engineSyncedNodeIds = pathIds
        engineSyncedBoardSignature = engineBoardSignature()
        engineNeedsFullSync = false
        return commands
    }

    function analyzeCommand() {
        var interval = Math.max(1, Math.round(Number(analysisIntervalCentiseconds)))
        return "kata-analyze " + interval
    }

    function genmoveCommand() {
        return "genmove " + (currentPlayer === 1 ? "B" : "W")
    }

    function timeSettingsCommand() {
        var seconds = Math.max(0.1, Number(secondsPerMove))
        if (isNaN(seconds))
            seconds = 5.0
        return "time_settings 0 " + seconds.toFixed(1) + " 1"
    }

    function resetEngineSyncState() {
        stopAnalysisLimitTimer()
        engineSyncedNodeIds = []
        engineSyncedBoardSignature = ""
        engineSyncedKomiSignature = ""
        engineNeedsFullSync = true
    }

    function requestEngineAnalysis(force) {
        if (!analysisModeActive() || enginePaused || engineDisabled || !engineAutoAnalyze || !engineController)
            return
        engineLoading = !engineController.ready
        engineNoticeDismissed = false
        engineController.requestAnalysis(engineSyncCommands(), analyzeCommand())
        statusMode = "message"
        statusMessage = trText("engineAnalyzeRequested")
        resetAnalysisLimitTimer()
    }

    function scheduleAutoAnalysis() {
        if (!appReady || !analysisModeActive() || enginePaused || engineDisabled || !engineAutoAnalyze)
            return
        autoAnalyzeTimer.restart()
    }

    function startEngine() {
        if (!engineController)
            return
        engineDisabled = false
        engineLoading = true
        engineNoticeDismissed = false
        engineController.ensureStarted()
    }

    function stopEngine() {
        if (!engineController)
            return
        engineDisabled = true
        engineController.stop()
        engineLoading = false
        stopAnalysisLimitTimer()
        clearEngineCandidates()
    }

    function restartEngine() {
        if (!engineController)
            return
        engineDisabled = false
        engineLoading = true
        engineNoticeDismissed = false
        resetEngineSyncState()
        engineController.restart()
    }

    function toggleEnginePause() {
        if (!analysisModeActive()) {
            stopAiPlay()
            return
        }
        if (enginePaused)
            resumeEngineAnalysis()
        else
            pauseEngineAnalysis()
    }

    function pauseEngineAnalysis() {
        enginePaused = true
        stopAnalysisLimitTimer()
        if (engineController)
            engineController.sendCommand("stop")
        statusMode = "message"
        statusMessage = trText("enginePaused")
    }

    function resumeEngineAnalysis() {
        enginePaused = false
        scheduleAutoAnalysis()
    }

    function resetAnalysisLimitTimer() {
        if (!analysisModeActive() || enginePaused || engineDisabled || !engineAutoAnalyze || maxAnalysisSeconds <= 0) {
            analysisLimitTimer.stop()
            return
        }
        analysisLimitTimer.interval = Math.max(1, Math.round(Number(maxAnalysisSeconds))) * 1000
        analysisLimitTimer.restart()
    }

    function stopAnalysisLimitTimer() {
        analysisLimitTimer.stop()
    }

    function pauseEngineAnalysisByLimit() {
        if (!analysisModeActive() || enginePaused || maxAnalysisSeconds <= 0)
            return
        pauseEngineAnalysis()
        statusMode = "message"
        statusMessage = trText("analysisAutoPaused")
    }

    function setPlayMode(mode) {
        if (mode < playModeAnalysis || mode > playModeAiSelf)
            return
        playMode = mode
        if (analysisModeActive()) {
            genmoveInFlight = false
            scheduleAutoAnalysis()
        } else {
            enginePaused = false
            requestAiMoveIfNeeded()
        }
    }

    function analysisModeActive() {
        return playMode === playModeAnalysis
    }

    function engineReadyForPlayMode() {
        return !!engineController
               && !engineDisabled
               && engineController.running
               && engineController.ready
               && !engineController.failed
               && !engineLoading
    }

    function aiShouldMove() {
        if (analysisModeActive() || gameWinner !== 0 || gameOverReason !== "")
            return false
        if (playMode === playModeAiSelf)
            return true
        if (playMode === playModeAiBlack)
            return currentPlayer === 1
        if (playMode === playModeAiWhite)
            return currentPlayer === 2
        return false
    }

    function requestAiMoveIfNeeded() {
        if (!aiShouldMove() || genmoveInFlight || engineDisabled || !engineController)
            return
        if (!engineReadyForPlayMode()) {
            startEngine()
            return
        }
        genmoveInFlight = true
        genmovePlayer = currentPlayer
        activeGenmoveRequestId = ++genmoveRequestSerial
        engineController.requestMove(engineSyncCommands(), timeSettingsCommand(), genmoveCommand(), activeGenmoveRequestId)
        statusMode = "message"
        statusMessage = trText("engineThinking")
    }

    function stopAiPlay() {
        genmoveInFlight = false
        activeGenmoveRequestId = 0
        genmovePlayer = 0
        playMode = playModeAnalysis
        if (engineController)
            engineController.sendCommand("stop")
        statusMode = "message"
        statusMessage = trText("gameStopped")
        scheduleAutoAnalysis()
    }

    function applyGeneratedMove(moveText) {
        var text = String(moveText).trim()
        applyingGeneratedMove = true
        if (text.toLowerCase() === "pass" || text.length === 0)
            passMove()
        else {
            var point = parseEngineCoordinate(text)
            if (point)
                placeStone(point.x, point.y)
        }
        applyingGeneratedMove = false
    }

    function candidateVisitCount(candidate) {
        if (!candidate)
            return 0
        var visits = Number(candidate.visits)
        return isNaN(visits) ? 0 : visits
    }

    function candidateWinrateValue(candidate) {
        if (!candidate || candidate.winrate === undefined)
            return 0
        var value = Number(candidate.winrate)
        if (isNaN(value))
            return 0
        if (value <= 1)
            value *= 100
        return clamp(value, 0, 100)
    }

    function candidateScoreValue(candidate) {
        if (!candidate || candidate.scoreMean === undefined)
            return NaN
        var value = Number(candidate.scoreMean)
        return isNaN(value) ? NaN : value
    }

    function formatCandidateNumber(value, decimals, showPercent, normalizePercent) {
        var number = Number(value)
        if (isNaN(number))
            return ""
        var displayValue = number
        if (showPercent && normalizePercent && Math.abs(displayValue) <= 1)
            displayValue *= 100
        var text = displayValue.toFixed(Math.round(clamp(decimals, 0, 2)))
        if (showPercent)
            text += "%"
        return text
    }

    function candidateWinrateText(candidate) {
        if (!candidate || candidate.winrate === undefined)
            return ""
        return formatCandidateNumber(candidateWinrateValue(candidate),
                                     candidateWinrateDecimals,
                                     candidateWinrateShowPercent,
                                     false)
    }

    function candidateScoreDisplayEnabled() {
        return candidateScoreLabelVisible
    }

    function candidateScoreTitle() {
        return candidateScoreTitleMode === candidateScoreTitleDrawRate ? trText("candidateDrawRate")
                                                                       : trText("candidateScoreMean")
    }

    function candidateScoreText(candidate) {
        if (!candidate || candidate.scoreMean === undefined || !candidateScoreDisplayEnabled())
            return ""
        return formatCandidateNumber(candidateScoreValue(candidate),
                                     candidateScoreDecimals,
                                     candidateScoreShowPercent,
                                     false)
    }

    function candidateLabelLines(candidate) {
        var lines = []
        var winrateLabel = candidateWinrateText(candidate)
        if (candidateWinrateLabelVisible && winrateLabel.length > 0) {
            lines.push({
                "kind": 0,
                "text": winrateLabel,
                "fontSize": candidateWinrateFontSize,
                "color": String(candidateLabelTextColor),
                "bold": candidateWinrateBold
            })
        }
        if (candidateVisitsLabelVisible) {
            var visitsLabel = formatVisitCount(candidateVisitCount(candidate))
            if (visitsLabel.length > 0) {
                lines.push({
                    "kind": 1,
                    "text": visitsLabel,
                    "fontSize": candidateVisitsFontSize,
                    "color": String(candidateLabelTextColor),
                    "bold": candidateVisitsBold
                })
            }
        }
        var scoreLabel = candidateScoreText(candidate)
        if (scoreLabel.length > 0) {
            lines.push({
                "kind": 2,
                "text": scoreLabel,
                "fontSize": candidateScoreFontSize,
                "color": String(candidateLabelTextColor),
                "bold": candidateScoreBold
            })
        }
        if (lines.length <= 0 && winrateLabel.length > 0) {
            lines.push({
                "kind": 0,
                "text": winrateLabel,
                "fontSize": candidateWinrateFontSize,
                "color": String(candidateLabelTextColor),
                "bold": candidateWinrateBold
            })
        }
        return lines
    }

    function candidateLabelLineOffset(kind) {
        if (kind === 0)
            return candidateWinrateOffsetY
        if (kind === 1)
            return candidateVisitsOffsetY
        return candidateScoreOffsetY
    }

    function candidateLabelLineHeight(line) {
        return Math.max(16, Number(line.fontSize) * 0.88)
    }

    function candidateLabelScale(markerRadius) {
        return Math.max(0.12, markerRadius * 2 / 151)
    }

    function candidateLabelGap(markerRadius) {
        return 2 * candidateLabelScale(markerRadius)
    }

    function candidateRingRadius(markerRadius) {
        return markerRadius * 1.02
    }

    function candidateRingLineWidthForRadius(markerRadius) {
        return Math.max(1, candidateRingLineWidth * candidateLabelScale(markerRadius))
    }

    function candidateRankLabelText(displayIndex) {
        if (!candidateRankLabelVisible)
            return ""
        var rank = Math.round(Number(displayIndex))
        return rank >= 1 && rank <= 9 ? String(rank) : ""
    }

    function candidateLabelTotalHeight(lines) {
        if (!lines || lines.length <= 0)
            return 0
        var totalHeight = 0
        for (var i = 0; i < lines.length; ++i)
            totalHeight += candidateLabelLineHeight(lines[i])
        return totalHeight + 2 * Math.max(0, lines.length - 1)
    }

    function candidateLabelLineCenterY(lines, lineIndex, height) {
        if (!lines || lineIndex < 0 || lineIndex >= lines.length)
            return height * 0.5
        var gap = 2
        var y = (height - candidateLabelTotalHeight(lines)) * 0.5
        for (var i = 0; i < lineIndex; ++i)
            y += candidateLabelLineHeight(lines[i]) + gap
        return y + candidateLabelLineHeight(lines[lineIndex]) * 0.5
    }

    function candidateLabelScaledTotalHeight(lines, markerRadius) {
        if (!lines || lines.length <= 0)
            return 0
        var scale = candidateLabelScale(markerRadius)
        var totalHeight = 0
        for (var i = 0; i < lines.length; ++i)
            totalHeight += candidateLabelLineHeight(lines[i]) * scale
        return totalHeight + candidateLabelGap(markerRadius) * Math.max(0, lines.length - 1)
    }

    function drawCandidateLabelLines(ctx, lines, centerX, centerY, markerRadius, overrideColor) {
        if (!lines || lines.length <= 0)
            return

        var scale = candidateLabelScale(markerRadius)
        var y = centerY - candidateLabelScaledTotalHeight(lines, markerRadius) * 0.5
        ctx.textAlign = "center"
        ctx.textBaseline = "middle"
        for (var lineIndex = 0; lineIndex < lines.length; ++lineIndex) {
            var line = lines[lineIndex]
            var lineHeight = candidateLabelLineHeight(line) * scale
            var fontSize = Math.max(7, Number(line.fontSize) * scale)
            ctx.font = (line.bold ? "700 " : "400 ") + Math.round(fontSize) + "px sans-serif"
            ctx.fillStyle = overrideColor || line.color || String(candidateLabelTextColor)
            ctx.fillText(line.text || "",
                         centerX,
                         y + lineHeight * 0.5 - candidateLabelLineOffset(line.kind) * scale,
                         Math.max(8, markerRadius * 2 - 4))
            y += lineHeight + candidateLabelGap(markerRadius)
        }
    }

    function drawCandidateRankLabel(ctx, centerX, centerY, markerRadius, rankText) {
        if (!candidateRankLabelVisible || rankText === undefined || String(rankText).length <= 0)
            return

        var text = String(rankText)
        var squareWidth = markerRadius * 2 / Math.max(0.1, Number(stoneScale))
        var anchorX = centerX + squareWidth * 0.43 + (text === "1" ? 1 : 0)
        var anchorY = centerY - squareWidth * 0.358 - (text === "1" ? 1 : 0)
        var maxFontHeight = squareWidth * 0.36
        var maxFontWidth = squareWidth * 0.39
        var fontFamily = String(coordinateFontFamily).replace(/"/g, "")

        ctx.save()
        var fontSize = Math.max(1, maxFontHeight)
        ctx.font = "400 " + Math.round(fontSize) + "px \"" + fontFamily + "\", sans-serif"
        var measured = ctx.measureText(text)
        if (measured.width > maxFontWidth && measured.width > 0) {
            fontSize *= maxFontWidth / measured.width
            ctx.font = "400 " + Math.round(fontSize) + "px \"" + fontFamily + "\", sans-serif"
            measured = ctx.measureText(text)
        }

        var textWidth = Math.max(1, measured.width)
        var ascent = measured.actualBoundingBoxAscent || fontSize * 0.72
        var descent = measured.actualBoundingBoxDescent || fontSize * 0.12
        var textHeight = Math.max(1, ascent - descent)
        var x1 = anchorX - textWidth * 0.5
        var y1 = anchorY

        ctx.globalAlpha = 1
        ctx.fillStyle = "#ffa500"
        ctx.fillRect(x1, y1 - textHeight, textWidth, textHeight + Math.max(1, textHeight / 12))
        ctx.fillStyle = "#15191c"
        ctx.textAlign = "left"
        ctx.textBaseline = "alphabetic"
        ctx.fillText(text, x1, y1)
        ctx.restore()
    }

    function drawCandidateMarker(ctx, centerX, centerY, markerRadius, lines, options) {
        options = options || ({})

        var drawBackground = options.drawBackground === undefined ? true : !!options.drawBackground
        var drawOutline = !!options.drawOutline
        var drawRing = !!options.drawRing && candidateRingVisible
        var fillOpacity = options.fillOpacity === undefined ? 1 : Number(options.fillOpacity)
        var outlineOpacity = options.outlineOpacity === undefined ? 1 : Number(options.outlineOpacity)
        var ringOpacity = options.ringOpacity === undefined ? 1 : Number(options.ringOpacity)

        ctx.save()
        if (drawBackground) {
            ctx.globalAlpha = ctx.globalAlpha * fillOpacity
            ctx.fillStyle = String(options.fillColor || "#00c8ff")
            ctx.beginPath()
            ctx.arc(centerX, centerY, markerRadius, 0, Math.PI * 2)
            ctx.fill()
        }
        ctx.restore()

        ctx.save()
        if (drawOutline) {
            ctx.globalAlpha = ctx.globalAlpha * outlineOpacity
            ctx.strokeStyle = String(options.outlineColor || "#000000")
            ctx.lineWidth = Math.max(1, markerRadius / 26.5)
            ctx.beginPath()
            ctx.arc(centerX, centerY, markerRadius, 0, Math.PI * 2)
            ctx.stroke()
        }
        ctx.restore()

        ctx.save()
        if (drawRing) {
            ctx.globalAlpha = ctx.globalAlpha * ringOpacity
            ctx.strokeStyle = String(options.ringColor || "#f01818")
            ctx.lineWidth = candidateRingLineWidthForRadius(markerRadius)
            ctx.beginPath()
            ctx.arc(centerX, centerY, candidateRingRadius(markerRadius), 0, Math.PI * 2)
            ctx.stroke()
        }
        ctx.restore()

        if (lines && lines.length > 0) {
            drawCandidateLabelLines(ctx, lines, centerX, centerY, markerRadius, options.textColor)
        } else if (options.fallbackText !== undefined) {
            ctx.save()
            ctx.fillStyle = String(options.fallbackColor || candidateLabelTextColor)
            ctx.font = "700 " + Math.round(options.fallbackFontSize || Math.max(8, markerRadius * 0.8)) + "px sans-serif"
            ctx.textAlign = "center"
            ctx.textBaseline = "middle"
            ctx.fillText(String(options.fallbackText), centerX, centerY, Math.max(8, markerRadius * 2 - 4))
            ctx.restore()
        }

        drawCandidateRankLabel(ctx, centerX, centerY, markerRadius, options.rankText)
    }

    function candidateMarkerRadius(width, height) {
        var side = Math.min(width, height)
        var markerRadius = side * 0.48
        var ringSafeRadius = (side * 0.5 - 1) / (1.02 + candidateRingLineWidth / 151)
        return Math.max(1, Math.min(markerRadius, ringSafeRadius))
    }

    function hexComponent(value) {
        var text = Math.round(clamp(value, 0, 255)).toString(16)
        return text.length < 2 ? "0" + text : text
    }

    function hsbColorHex(hue, saturation, brightness) {
        hue = ((Number(hue) % 1) + 1) % 1
        saturation = clamp(Number(saturation), 0, 1)
        brightness = clamp(Number(brightness), 0, 1)
        var r = brightness
        var g = brightness
        var b = brightness
        if (saturation > 0) {
            var h = hue * 6
            var sector = Math.floor(h)
            var fraction = h - sector
            var p = brightness * (1 - saturation)
            var q = brightness * (1 - saturation * fraction)
            var t = brightness * (1 - saturation * (1 - fraction))
            switch (sector) {
            case 0:
                r = brightness; g = t; b = p
                break
            case 1:
                r = q; g = brightness; b = p
                break
            case 2:
                r = p; g = brightness; b = t
                break
            case 3:
                r = p; g = q; b = brightness
                break
            case 4:
                r = t; g = p; b = brightness
                break
            default:
                r = brightness; g = p; b = q
                break
            }
        }
        return "#" + hexComponent(r * 255) + hexComponent(g * 255) + hexComponent(b * 255)
    }

    function candidateYzyAlphaRatio(visitRatio) {
        var ratio = clamp(Number(visitRatio), 0.000001, 1)
        return Math.max(0, Math.log(ratio) / candidateYzyAlphaFactor + 1)
    }

    function candidateMarkerColor(displayIndex, visitRatio) {
        if (displayIndex <= 1)
            return hsbColorHex(0.5, 1.0, 0.85)
        var fraction = Math.pow(clamp(Number(visitRatio), 0, 1), 1 / candidateYzyColorRatio)
        var hue = (1 / 3) * fraction
        return hsbColorHex(hue, 1.0, 0.85)
    }

    function candidateMarkerOpacity(displayIndex, visitRatio) {
        var alphaRatio = candidateYzyAlphaRatio(visitRatio)
        var alpha = candidateYzyMinAlpha + (candidateYzyMaxAlpha - candidateYzyMinAlpha) * alphaRatio
        return clamp(alpha / 255, 0, 1)
    }

    function candidateMarkerOutlineOpacity(visitRatio) {
        var alpha = 48 + 48 * candidateYzyAlphaRatio(visitRatio)
        return clamp(alpha / 255, 0, 1)
    }

    function candidatePreviewLabelLines(digitText) {
        var lines = []
        var decimals = Math.round(clamp(candidateWinrateDecimals, 0, 2))
        var digit = digitText === undefined ? "6" : String(digitText)
        var winrateText = decimals === 0 ? digit + digit
                         : decimals === 1 ? digit + digit + "." + digit
                         : digit + digit + "." + digit + digit
        if (candidateWinrateShowPercent)
            winrateText += "%"

        if (candidateWinrateLabelVisible) {
            lines.push({
                "kind": 0,
                "text": winrateText,
                "fontSize": candidateWinrateFontSize,
                "color": String(candidateLabelTextColor),
                "bold": candidateWinrateBold
            })
        }
        if (candidateVisitsLabelVisible) {
            lines.push({
                "kind": 1,
                "text": digit + digit + "K",
                "fontSize": candidateVisitsFontSize,
                "color": String(candidateLabelTextColor),
                "bold": candidateVisitsBold
            })
        }
        if (candidateScoreDisplayEnabled()) {
            lines.push({
                "kind": 2,
                "text": candidateScoreText({ "scoreMean": Number(digit + "." + digit) }),
                "fontSize": candidateScoreFontSize,
                "color": String(candidateLabelTextColor),
                "bold": candidateScoreBold
            })
        }
        if (lines.length <= 0) {
            lines.push({
                "kind": 0,
                "text": winrateText,
                "fontSize": candidateWinrateFontSize,
                "color": String(candidateLabelTextColor),
                "bold": candidateWinrateBold
            })
        }
        return lines
    }

    function formatVisitCount(value) {
        var visits = Number(value)
        if (isNaN(visits) || visits <= 0)
            return "0"
        if (visits >= 1000000000)
            return (visits / 1000000000).toFixed(visits >= 10000000000 ? 0 : 1) + "G"
        if (visits >= 1000000)
            return (visits / 1000000).toFixed(visits >= 10000000 ? 0 : 1) + "M"
        if (visits >= 1000)
            return (visits / 1000).toFixed(visits >= 10000 ? 0 : 1) + "K"
        return String(Math.round(visits))
    }

    function rebuildEngineCandidateItems() {
        var sorted = []
        for (var s = 0; s < engineCandidates.length; ++s)
            sorted.push(engineCandidates[s])
        sorted.sort(function(left, right) {
            var lo = left.order === undefined ? 0 : Number(left.order)
            var ro = right.order === undefined ? 0 : Number(right.order)
            return lo - ro
        })

        var maxVisits = 0
        for (var m = 0; m < sorted.length; ++m)
            maxVisits = Math.max(maxVisits, candidateVisitCount(sorted[m]))

        var limit = candidateDisplayCount <= 0 ? sorted.length : Math.min(candidateDisplayCount, sorted.length)
        var threshold = maxVisits > 0 ? maxVisits * candidateMinVisitRatio : 0

        var items = []
        var itemMap = ({})
        var table = []
        for (var c = 0; c < sorted.length; ++c) {
            var candidate = sorted[c]
            var point = parseEngineCoordinate(candidate.move)
            if (point && stoneAt(point.x, point.y) === 0) {
                var visits = candidateVisitCount(candidate)
                var visitRatio = maxVisits > 0 ? clamp(visits / maxVisits, 0, 1) : 1
                var rawWinrate = candidateWinrateValue(candidate)
                var qualified = c < limit && (maxVisits <= 0 || visits >= threshold)
                var item = {
                    "x": point.x,
                    "y": point.y,
                    "key": keyFor(point.x, point.y),
                    "move": candidate.move,
                    "order": candidate.order,
                    "displayIndex": c + 1,
                    "visits": visits,
                    "visitRatio": visitRatio,
                    "qualified": qualified,
                    "boardVisible": qualified || candidateShowFilteredMarkers,
                    "opacity": candidateMarkerOpacity(c + 1, visitRatio),
                    "color": candidateMarkerColor(c + 1, visitRatio),
                    "outlineOpacity": candidateMarkerOutlineOpacity(visitRatio),
                    "winrate": rawWinrate,
                    "winrateText": candidateWinrateText(candidate),
                    "scoreMean": candidateScoreValue(candidate),
                    "scoreText": candidateScoreText(candidate),
                    "pv": candidatePvMoves(candidate),
                    "labelLines": candidateLabelLines(candidate)
                }
                items.push(item)
                itemMap[item.key] = item
                table.push({
                    "row": c + 1,
                    "key": item.key,
                    "coordinate": coordinateText(point.x, point.y),
                    "winrateText": item.winrateText,
                    "scoreText": item.scoreText,
                    "visitsText": visits > 0 ? formatVisitCount(visits) : ""
                })
            }
        }
        engineCandidateItems = items
        engineCandidateItemMap = itemMap
        engineCandidateTableItems = table
        updateBestCandidateRing(items)
    }

    function candidatePvMoves(candidate) {
        if (!candidate)
            return []

        var moves = []
        var pv = candidate.pv || []
        for (var i = 0; i < pv.length; ++i) {
            var pvMove = String(pv[i]).trim()
            if (pvMove.length > 0)
                moves.push(pvMove)
        }
        return moves
    }

    function activeCandidateForVariationPreview() {
        if (!candidateVariationPreviewVisible || hoverKey === "" || !pointIsEngineCandidateKey(hoverKey))
            return null
        var candidate = engineCandidateItemMap[hoverKey]
        if (!candidate || stoneAt(candidate.x, candidate.y) !== 0)
            return null
        return candidate
    }

    function activeCandidateVariationPreviewActive() {
        var candidate = activeCandidateForVariationPreview()
        return !!candidate && candidate.pv && candidate.pv.length > 0
    }

    function activeCandidateVariationItems(respectMaxMoves) {
        var candidate = activeCandidateForVariationPreview()
        if (!candidate || !candidate.pv || candidate.pv.length <= 0)
            return []

        var items = []
        var player = currentPlayer
        var moveNumber = 1
        var useMaxMoves = respectMaxMoves !== false
        var maxMoves = useMaxMoves ? Math.round(Number(candidateVariationPreviewMaxMoves)) : 0
        if (isNaN(maxMoves))
            maxMoves = 0
        maxMoves = Math.max(0, maxMoves)

        for (var i = 0; i < candidate.pv.length; ++i) {
            if (maxMoves > 0 && moveNumber > maxMoves)
                break
            var moveText = String(candidate.pv[i])
            var point = parseEngineCoordinate(moveText)
            if (!point) {
                if (moveText.trim().toLowerCase() === "pass") {
                    player = player === 1 ? 2 : 1
                    moveNumber += 1
                }
                continue
            }
            if (!pointInBoard(point.x, point.y))
                continue

            var key = keyFor(point.x, point.y)
            items.push({
                "x": point.x,
                "y": point.y,
                "key": key,
                "player": player,
                "moveNumber": moveNumber,
                "nodeId": -1
            })
            player = player === 1 ? 2 : 1
            moveNumber += 1
        }
        return items
    }

    function playActiveCandidateVariation() {
        if (!activeCandidateVariationPreviewActive())
            return false

        var candidate = activeCandidateForVariationPreview()
        if (!candidate || !candidate.pv || candidate.pv.length <= 0)
            return false

        var moves = candidate.pv.slice()
        var played = false
        for (var i = 0; i < moves.length; ++i) {
            var moveText = String(moves[i]).trim()
            if (moveText.length <= 0)
                continue
            if (moveText.toLowerCase() === "pass") {
                passMove()
                played = true
                continue
            }

            var point = parseEngineCoordinate(moveText)
            if (!point || !pointInBoard(point.x, point.y))
                continue
            if (!placeStone(point.x, point.y))
                break
            played = true
        }
        if (played) {
            clearHover(true)
            focusBoardInput()
        }
        return played
    }

    function updateBestCandidateRing(items) {
        if (!items || items.length <= 0) {
            bestCandidateRingVisible = false
            bestCandidateRingKey = ""
            return
        }
        var best = items[0]
        if (!best || best.displayIndex !== 1 || stoneAt(best.x, best.y) !== 0) {
            bestCandidateRingVisible = false
            bestCandidateRingKey = ""
            return
        }
        bestCandidateRingX = best.x
        bestCandidateRingY = best.y
        bestCandidateRingKey = best.key
        bestCandidateRingVisible = true
    }

    function clearEngineCandidates() {
        engineCandidates = []
        engineCandidateItems = []
        engineCandidateItemMap = ({})
        engineCandidateTableItems = []
        bestCandidateRingVisible = false
        bestCandidateRingKey = ""
        engineCandidateRevision += 1
        if (engineController)
            engineController.clearCandidates()
    }

    function enterNoEngineMode(message) {
        engineDisabled = true
        engineLoading = false
        engineNoticeDismissed = true
        genmoveInFlight = false
        activeGenmoveRequestId = 0
        genmovePlayer = 0
        if (!analysisModeActive())
            playMode = playModeAnalysis
        stopAnalysisLimitTimer()
        clearEngineCandidates()
        statusMode = "message"
        statusMessage = message && message.length > 0 ? message + " - " + trText("engineNoEngineMode")
                                                       : trText("engineNoEngineMode")
    }

    function selectEngineCandidateRow(row) {
        var displayIndex = Math.round(row)
        if (displayIndex <= 0)
            return
        var candidate = null
        for (var i = 0; i < engineCandidateItems.length; ++i) {
            if (engineCandidateItems[i] && engineCandidateItems[i].displayIndex === displayIndex) {
                candidate = engineCandidateItems[i]
                break
            }
        }
        if (!candidate)
            return
        setSelectedPoint(candidate.x, candidate.y, true, true)
        focusBoardInput()
    }

    function playBestEngineMove() {
        if (engineCandidateItems.length <= 0)
            return
        var best = engineCandidateItems[0]
        placeStone(best.x, best.y)
    }

    function recordCurrentAnalysisFromCandidates() {
        if (engineCandidateItems.length <= 0)
            return
        var best = engineCandidateItems[0]
        var node = currentNode()
        if (!node || best.winrate === undefined)
            return
        var blackWinrate = currentPlayer === 1 ? best.winrate : 100 - best.winrate
        node.analysisBlackWinrate = clamp(blackWinrate, 0, 100)
        gameNodes = gameNodes.slice()
        analysisRevision += 1
    }

    function currentAnalysisHasWinrate() {
        var node = currentNode()
        return !!node && node.analysisBlackWinrate !== undefined && node.analysisBlackWinrate >= 0
    }

    function currentAnalysisBlackWinrate() {
        var node = currentNode()
        return currentAnalysisHasWinrate() ? node.analysisBlackWinrate : 50
    }

    function currentAnalysisWhiteWinrate() {
        return 100 - currentAnalysisBlackWinrate()
    }

    function winrateHistoryPoints() {
        var points = []
        var path = nodePath(currentNodeId)
        for (var i = 0; i < path.length; ++i) {
            var node = path[i]
            if (node.analysisBlackWinrate !== undefined && node.analysisBlackWinrate >= 0)
                points.push({ "move": node.moveNumber, "winrate": node.analysisBlackWinrate })
        }
        return points
    }

    function engineWinratePlaceholderActive() {
        return analysisModeActive() && !currentAnalysisHasWinrate()
    }

    function engineWinratePlaceholderText() {
        if (engineDisabled)
            return trText("engineNoEngineMode")
        if (enginePaused)
            return trText("enginePaused")
        if (engineLoading)
            return trText("engineLoading")
        if (engineController && engineController.failed)
            return trText("engineFailedNotice")
        if (engineCandidateItems.length <= 0)
            return trText("engineNoCandidates")
        return ""
    }

    function engineCandidateSummaryText() {
        if (engineCandidateItems.length <= 0)
            return trText("engineNoCandidates")
        var best = engineCandidateItems[0]
        return trText("engineBestMove") + ": " + coordinateText(best.x, best.y) + " " + best.winrateText
    }

    function engineDotColor() {
        if (engineDisabled)
            return "#8d969c"
        if (enginePaused || (engineController && engineController.failed))
            return "#d64238"
        if (engineLoading)
            return "#b5bec4"
        if (engineController && engineController.running)
            return "#25b56f"
        return "#9aa5ab"
    }

    function engineNoticeVisible() {
        if (engineNoticeDismissed)
            return false
        if (engineDisabled)
            return false
        return engineLoading || (engineController && engineController.failed)
    }

    function engineNoticeText() {
        if (engineController && engineController.failed)
            return engineFailureMessage()
        return trText("engineStartingNotice")
    }

    function engineNoticeFillColor() {
        return engineController && engineController.failed ? "#fff1ee" : "#eef5f8"
    }

    function engineNoticeBorderColor() {
        return engineController && engineController.failed ? "#d0695f" : "#8fb7c6"
    }

    function engineNoticeTextColor() {
        return engineController && engineController.failed ? "#641a14" : "#183643"
    }

    function engineFailureMessage() {
        if (engineController && engineController.failureMessage.length > 0)
            return engineController.failureMessage
        if (engineController && engineController.lastError.length > 0)
            return engineController.lastError
        return trText("engineFailedNotice")
    }

    function effectiveKomi() {
        return gameRuleMode === gameRuleGo ? komi : 0
    }

    function adjustKomi(delta) {
        if (gameRuleMode !== gameRuleGo)
            return
        komi = Math.round((komi + delta) * 10) / 10
        scheduleAutoAnalysis()
    }

    function buildGomokuWinLineItems(map) {
        var runs = GameRules.buildGomokuWinRuns(map, boardDims(), gameRuleMode, gomokuRuleMode)
        var items = []
        for (var i = 0; i < runs.length; ++i) {
            var run = runs[i]
            items.push({
                "startX": run.startX,
                "startY": run.startY,
                "endX": run.endX,
                "endY": run.endY,
                "player": run.player
            })
        }
        return items
    }

    function stoneOverlayVisible(moveNumber, lastMove) {
        if (moveNumberDisplayMode === moveNumberModeHidden)
            return lastMove
        if (moveNumberDisplayMode === moveNumberModeLastOnly)
            return lastMove
        return moveNumber > 0
    }

    function stoneNumberVisible(moveNumber, lastMove) {
        if (moveNumberDisplayMode === moveNumberModeHidden)
            return false
        if (moveNumberDisplayMode === moveNumberModeLastOnly)
            return lastMove
        return moveNumber > 0
    }

    function stoneNumberColor(player, lastMove) {
        return player === 1 ? "#f5f7f8" : "#1a252d"
    }

    function stoneNumberCanvasFont(size, bold) {
        var family = String(coordinateFontFamily).replace(/"/g, "")
        return (bold ? "700 " : "400 ") + Math.max(1, Math.round(size))
             + "px \"" + family + "\", sans-serif"
    }

    function stoneNumberBaseFontSize(ctx, text, radius) {
        var label = String(text)
        var digits = Math.max(1, label.length)
        var digitFactor = digits <= 1 ? 1.18
                        : digits === 2 ? 1.02
                        : digits === 3 ? 0.86
                        : Math.max(0.58, 0.86 - (digits - 3) * 0.12)
        var baseSize = Math.min(radius * digitFactor, radius * 1.42)
        var maxWidth = radius * 1.78
        if (ctx) {
            ctx.save()
            ctx.font = stoneNumberCanvasFont(baseSize, true)
            var measuredWidth = Math.max(1, ctx.measureText(label).width)
            ctx.restore()
            if (measuredWidth > maxWidth)
                baseSize *= maxWidth / measuredWidth
        }
        return Math.max(1, baseSize)
    }

    function stoneNumberFontSize(ctx, text, radius) {
        return Math.max(1, stoneNumberBaseFontSize(ctx, text, radius) * Number(moveNumberLabelScale))
    }

    function stoneNumberMaxWidth(radius) {
        return radius * 1.86 * Math.max(1, Number(moveNumberLabelScale))
    }

    function stoneNumberOffsetY(fontSize) {
        return Math.max(1, Number(fontSize) * 0.08)
    }

    function focusBoardInput() {
        if (inputLayer)
            inputLayer.forceActiveFocus()
    }

    function itemContainsInputPoint(item, sourceItem, x, y) {
        if (!item || !item.visible)
            return false
        var point = item.mapFromItem(sourceItem, x, y)
        return point.x >= 0 && point.x <= item.width && point.y >= 0 && point.y <= item.height
    }

    function boardInputBlocked(sourceItem, x, y) {
        return itemContainsInputPoint(analysisToolbar, sourceItem, x, y)
               || itemContainsInputPoint(infoPanel, sourceItem, x, y)
               || itemContainsInputPoint(branchPanel, sourceItem, x, y)
               || itemContainsInputPoint(commandToolbar, sourceItem, x, y)
    }

    function pointFromMouse(x, y) {
        if (!boardScene)
            return null
        return boardScene.pointFromMouse(x, y)
    }

    function clearHover(force) {
        if (selectedPointLocked && force !== true)
            return
        selectedPointLocked = false
        selectedPointFromCandidateList = false
        hoverX = -1
        hoverY = -1
        hoverKey = ""
    }

    function cancelCandidateListSelection() {
        if (!selectedPointLocked || !selectedPointFromCandidateList)
            return false
        clearHover(true)
        return true
    }

    function updateHover(x, y) {
        if (selectedPointLocked)
            return
        var point = pointFromMouse(x, y)
        if (point) {
            var nextKey = keyFor(point.x, point.y)
            if (hoverKey === nextKey)
                return
            selectedPointFromCandidateList = false
            setHoverPoint(point.x, point.y)
        } else {
            clearHover()
        }
    }

    function handleBoardClickFromMouse(x, y) {
        var point = pointFromMouse(x, y)
        if (!point) {
            clearHover(true)
            return false
        }

        selectedPointLocked = false
        selectedPointFromCandidateList = false
        setHoverPoint(point.x, point.y)
        placeStone(point.x, point.y)
        return true
    }

    function cycleMoveNumberDisplayMode() {
        moveNumberDisplayMode = (moveNumberDisplayMode + 1) % 3
        boardRevision += 1
    }

    function resetBoardVisualSettings() {
        backgroundColor = defaultBackgroundColor
        boardWoodColor = defaultBoardWoodColor
        stoneScale = defaultStoneScale
        gridOpacity = defaultGridOpacity
        gridLineWidth = defaultGridLineWidth
        selectedPointScale = defaultSelectedPointScale
        moveNumberLabelScale = defaultMoveNumberLabelScale
        mouseHitRadiusScale = defaultMouseHitRadiusScale
        coordinateDisplayMode = coordinateDisplayGoNoI
        boardRevision += 1
    }

    function resetCandidateVisualSettings() {
        candidateDisplayCount = 10
        candidateMinVisitRatio = 0.001
        candidateShowFilteredMarkers = true
        candidateVariationPreviewVisible = true
        candidateVariationPreviewMaxMoves = 10
        candidateVariationPreviewOpacity = defaultCandidateVariationPreviewOpacity
        candidateWinrateLabelVisible = true
        candidateVisitsLabelVisible = true
        candidateScoreLabelVisible = true
        candidateWinrateFontSize = 57
        candidateVisitsFontSize = 42
        candidateScoreFontSize = 36
        candidateWinrateBold = true
        candidateVisitsBold = false
        candidateScoreBold = true
        candidateWinrateOffsetY = -10
        candidateVisitsOffsetY = -5
        candidateScoreOffsetY = -5
        candidateWinrateDecimals = 1
        candidateScoreDecimals = 1
        candidateWinrateShowPercent = false
        candidateScoreShowPercent = false
        candidateScoreTitleMode = candidateScoreTitleScoreMean
        candidateRingVisible = true
        candidateRingLineWidth = 12
        candidateRankLabelVisible = true
        candidateFirstLabelTextColor = "#ff0000"
        candidateLabelTextColor = "#000000"
        boardRevision += 1
    }

    function resetVisualSettings() {
        resetBoardVisualSettings()
        resetCandidateVisualSettings()
    }

    function openBoardSizeDialog() {
        boardSizeDialog.showForCurrentBoard()
    }

    function openHiddenSettingsDialog() {
        hiddenSettingsDialog.openDialog()
    }

    function openBeginnerTutorial() {
        beginnerTutorialDialog.openTutorial()
    }

    function openEngineCommunicationLog() {
        engineCommunicationWindow.openWindow()
    }

    function openSaveSgfDialog() {
        saveSgfDialog.currentFile = "qlizzie-" + boardDimensionsText() + ".sgf"
        saveSgfDialog.open()
    }

    function openLoadSgfDialog() {
        if (gameDirty) {
            pendingClearAction = "openSgf"
            ruleChangeSaveDialog.open()
            return
        }
        loadSgfDialog.open()
    }

    function buildSgf() {
        return SgfUtils.buildSgf(gameNodes, gameRuleMode, boardSizeX, boardSizeY, gameRuleText())
    }

    function saveSgfToFile(url) {
        var ok = fileIo.writeTextFile(url, buildSgf())
        if (ok) {
            gameDirty = false
            statusMode = "message"
            statusMessage = trText("sgfSaved") + ": " + url
        } else {
            statusMode = "message"
            statusMessage = trText("sgfSaveFailed") + ": " + fileIo.lastError
        }
        if (saveDialogClosesApp) {
            saveDialogClosesApp = false
            suppressUnsavedPrompt = true
            Qt.quit()
        }
        focusBoardInput()
    }

    function parseSgf(text) {
        return SgfUtils.parseSgf(text, {
            "minBoardSize": minBoardSize,
            "maxBoardSize": maxBoardSize,
            "defaultRuleMode": gameRuleMode,
            "gameRuleGo": gameRuleGo,
            "gameRuleGomoku": gameRuleGomoku
        })
    }

    function applyParsedSgf(parsed, url) {
        resetEngineSyncState()
        var parsedRuleMode = parsed.ruleMode === undefined ? gameRuleMode : parsed.ruleMode
        if (!ruleModeAllowedForPackage(parsedRuleMode)) {
            statusMode = "message"
            statusMessage = trText("sgfLoadFailed") + ": " + trText("packageRuleRejected")
            focusBoardInput()
            return
        }
        if (!boardDimensionsAllowedForPackage(parsed.boardSizeX, parsed.boardSizeY)) {
            statusMode = "message"
            statusMessage = trText("sgfLoadFailed") + ": "
                            + packageBoardSizeRejectText(parsed.boardSizeX, parsed.boardSizeY)
            focusBoardInput()
            return
        }
        gameRuleMode = parsedRuleMode
        boardSizeX = parsed.boardSizeX
        boardSizeY = parsed.boardSizeY
        gameNodes = parsed.nodes
        nextNodeId = parsed.nextNodeId
        currentNodeId = 0
        clearHover(true)
        rebuildPositionFromNode(currentNodeId)
        rebuildTreeLayout()
        gotoLastMove()
        gameDirty = false
        statusMode = "message"
        statusMessage = trText("sgfLoaded") + ": " + url
        focusBoardInput()
    }

    function loadSgfFromFile(url) {
        var text = fileIo.readTextFile(url)
        if (fileIo.lastError !== "") {
            statusMode = "message"
            statusMessage = trText("sgfLoadFailed") + ": " + fileIo.lastError
            focusBoardInput()
            return
        }
        var parsed = parseSgf(text)
        if (!parsed.ok) {
            statusMode = "message"
            statusMessage = trText("sgfLoadFailed") + ": " + parsed.error
            focusBoardInput()
            return
        }
        applyParsedSgf(parsed, url)
    }

    function closeWithoutSaving() {
        suppressUnsavedPrompt = true
        Qt.quit()
    }

    function requestQuit() {
        if (gameDirty) {
            unsavedSgfDialog.open()
            return
        }
        suppressUnsavedPrompt = true
        Qt.quit()
    }

    function onSettingsDialogClosed() {
        scheduleAutoAnalysis()
    }

    function normalizeColorHex(value, fallback) {
        var text = String(value)
        if (/^#[0-9a-fA-F]{6}$/.test(text))
            return text
        return fallback
    }

    function normalizePersistentSettings() {
        boardSizeX = Math.round(clamp(boardSizeX, minBoardSize, maxBoardSize))
        boardSizeY = Math.round(clamp(boardSizeY, minBoardSize, maxBoardSize))
        if (gameRuleMode !== gameRuleGo && gameRuleMode !== gameRuleGomoku)
            gameRuleMode = gameRuleGo
        gomokuRuleMode = Math.round(clamp(gomokuRuleMode, gomokuRuleCon5, gomokuRuleDirectCon5))
        if (stoneColorMode !== stoneColorModeAuto
                && stoneColorMode !== stoneColorModeBlack
                && stoneColorMode !== stoneColorModeWhite)
            stoneColorMode = stoneColorModeAuto
        if (moveNumberDisplayMode < moveNumberModeAll || moveNumberDisplayMode > moveNumberModeHidden)
            moveNumberDisplayMode = defaultMoveNumberDisplayMode
        if (coordinateDisplayMode < coordinateDisplayGoNoI || coordinateDisplayMode > coordinateDisplayNone)
            coordinateDisplayMode = coordinateDisplayGoNoI
        packageMode = Math.round(clamp(packageMode, packageModeUniversal, packageModeSix))
        candidateDisplayCount = Math.round(clamp(candidateDisplayCount, 0, 65536))
        candidateMinVisitRatio = clamp(candidateMinVisitRatio, 0, 1)
        var previewMaxMoves = Number(candidateVariationPreviewMaxMoves)
        if (isNaN(previewMaxMoves))
            previewMaxMoves = 0
        candidateVariationPreviewMaxMoves = Math.round(clamp(previewMaxMoves, 0, maxLargeIntegerSetting))
        var previewOpacity = Number(candidateVariationPreviewOpacity)
        if (isNaN(previewOpacity))
            previewOpacity = defaultCandidateVariationPreviewOpacity
        candidateVariationPreviewOpacity = clamp(previewOpacity, 0, 1)
        candidateWinrateFontSize = Math.round(clamp(candidateWinrateFontSize, 12, 120))
        candidateVisitsFontSize = Math.round(clamp(candidateVisitsFontSize, 12, 120))
        candidateScoreFontSize = Math.round(clamp(candidateScoreFontSize, 12, 120))
        candidateWinrateOffsetY = Math.round(clamp(candidateWinrateOffsetY, -64, 64))
        candidateVisitsOffsetY = Math.round(clamp(candidateVisitsOffsetY, -64, 64))
        candidateScoreOffsetY = Math.round(clamp(candidateScoreOffsetY, -64, 64))
        candidateWinrateDecimals = Math.round(clamp(candidateWinrateDecimals, 0, 2))
        candidateScoreDecimals = Math.round(clamp(candidateScoreDecimals, 0, 2))
        candidateScoreTitleMode = Math.round(clamp(candidateScoreTitleMode,
                                                   candidateScoreTitleScoreMean,
                                                   candidateScoreTitleDrawRate))
        candidateRingLineWidth = Math.round(clamp(candidateRingLineWidth, 1, 64))
        candidateFirstLabelTextColor = normalizeColorHex(candidateFirstLabelTextColor, "#ff0000")
        candidateLabelTextColor = normalizeColorHex(candidateLabelTextColor, "#000000")
        backgroundColor = normalizeColorHex(backgroundColor, defaultBackgroundColor)
        boardWoodColor = normalizeColorHex(boardWoodColor, defaultBoardWoodColor)
        analysisIntervalCentiseconds = Math.round(clamp(Number(analysisIntervalCentiseconds), 0, maxLargeIntegerSetting))
        maxAnalysisSeconds = Math.round(clamp(Number(maxAnalysisSeconds), 0, maxLargeIntegerSetting))
        stoneScale = clamp(stoneScale, minStoneScale, 1.0)
        gridOpacity = clamp(gridOpacity, 0.25, 1)
        gridLineWidth = clamp(Number(gridLineWidth), 0.5, 4)
        selectedPointScale = clamp(Number(selectedPointScale), 0.5, 1.0)
        moveNumberLabelScale = clamp(Number(moveNumberLabelScale), 0.5, 2.0)
        mouseHitRadiusScale = clamp(Number(mouseHitRadiusScale), 0.1, 1.0)
        secondsPerMove = Math.max(0.1, Number(secondsPerMove))
        resignMinMove = Math.max(1, Math.round(Number(resignMinMove)))
        resignConsecutiveMoves = Math.max(1, Math.round(Number(resignConsecutiveMoves)))
        resignWinrateThreshold = clamp(Number(resignWinrateThreshold), 0, 100)
        normalizeGomokuRuleForCurrentMode()
        applyPackageModeConstraints(false)
    }

    function settingValue(key, fallback) {
        return appSettings.value(key, fallback)
    }

    function settingBool(key, fallback) {
        var value = settingValue(key, fallback)
        if (typeof value === "boolean")
            return value
        var text = String(value).toLowerCase()
        return text === "true" || text === "1" || text === "yes"
    }

    function settingNumberEquals(value, expected) {
        return Math.abs(Number(value) - Number(expected)) < 0.000001
    }

    function migratePersistentSettings() {
        if (loadedSettingsVersion < 2) {
            persistedEngineCommand = defaultGo7EngineCommand
            go5EngineCommand = defaultGo7EngineCommand
            go7EngineCommand = defaultGo7EngineCommand
            six11EngineCommand = defaultGo7EngineCommand
            six13EngineCommand = defaultGo7EngineCommand
            settingsMigrated = true
        }
        loadedSettingsVersion = currentSettingsVersion
    }

    function loadPersistentSettings() {
        loadedSettingsVersion = Number(settingValue("settingsVersion", loadedSettingsVersion))
        language = String(settingValue("language", language))
        firstLaunchCompleted = settingBool("firstLaunchCompleted", firstLaunchCompleted)
        boardSizeX = Number(settingValue("boardSizeX", boardSizeX))
        boardSizeY = Number(settingValue("boardSizeY", boardSizeY))
        gameRuleMode = Number(settingValue("gameRuleMode", gameRuleMode))
        gomokuRuleMode = Number(settingValue("gomokuRuleMode", gomokuRuleMode))
        stoneColorMode = Number(settingValue("stoneColorMode", stoneColorMode))
        komi = Number(settingValue("komi", komi))
        moveNumberDisplayMode = Number(settingValue("moveNumberDisplayMode", moveNumberDisplayMode))
        coordinateDisplayMode = Number(settingValue("coordinateDisplayMode", coordinateDisplayMode))
        packageMode = Number(settingValue("packageMode", packageMode))
        persistedEngineCommand = String(settingValue("engineCommand", persistedEngineCommand))
        go5EngineCommand = String(settingValue("go5EngineCommand", go5EngineCommand))
        go7EngineCommand = String(settingValue("go7EngineCommand", go7EngineCommand))
        six11EngineCommand = String(settingValue("six11EngineCommand", six11EngineCommand))
        six13EngineCommand = String(settingValue("six13EngineCommand", six13EngineCommand))
        analysisIntervalCentiseconds = Number(settingValue("analysisIntervalCentiseconds", analysisIntervalCentiseconds))
        maxAnalysisSeconds = Number(settingValue("maxAnalysisSeconds", maxAnalysisSeconds))
        candidateDisplayCount = Number(settingValue("candidateDisplayCount", candidateDisplayCount))
        candidateMinVisitRatio = Number(settingValue("candidateMinVisitRatio", candidateMinVisitRatio))
        candidateShowFilteredMarkers = settingBool("candidateShowFilteredMarkers", candidateShowFilteredMarkers)
        candidateVariationPreviewVisible = settingBool("candidateVariationPreviewVisible", candidateVariationPreviewVisible)
        candidateVariationPreviewMaxMoves = Number(settingValue("candidateVariationPreviewMaxMoves", candidateVariationPreviewMaxMoves))
        candidateVariationPreviewOpacity = Number(settingValue("candidateVariationPreviewOpacity", candidateVariationPreviewOpacity))
        candidateWinrateLabelVisible = settingBool("candidateWinrateLabelVisible", candidateWinrateLabelVisible)
        candidateVisitsLabelVisible = settingBool("candidateVisitsLabelVisible", candidateVisitsLabelVisible)
        candidateScoreLabelVisible = settingBool("candidateScoreLabelVisible", candidateScoreLabelVisible)
        candidateWinrateFontSize = Number(settingValue("candidateWinrateFontSize", candidateWinrateFontSize))
        candidateVisitsFontSize = Number(settingValue("candidateVisitsFontSize", candidateVisitsFontSize))
        candidateScoreFontSize = Number(settingValue("candidateScoreFontSize", candidateScoreFontSize))
        candidateWinrateBold = settingBool("candidateWinrateBold", candidateWinrateBold)
        candidateVisitsBold = settingBool("candidateVisitsBold", candidateVisitsBold)
        candidateScoreBold = settingBool("candidateScoreBold", candidateScoreBold)
        candidateWinrateOffsetY = Number(settingValue("candidateWinrateOffsetY", candidateWinrateOffsetY))
        candidateVisitsOffsetY = Number(settingValue("candidateVisitsOffsetY", candidateVisitsOffsetY))
        candidateScoreOffsetY = Number(settingValue("candidateScoreOffsetY", candidateScoreOffsetY))
        candidateWinrateDecimals = Number(settingValue("candidateWinrateDecimals", candidateWinrateDecimals))
        candidateScoreDecimals = Number(settingValue("candidateScoreDecimals", candidateScoreDecimals))
        candidateWinrateShowPercent = settingBool("candidateWinrateShowPercent", candidateWinrateShowPercent)
        candidateScoreShowPercent = settingBool("candidateScoreShowPercent", candidateScoreShowPercent)
        candidateScoreTitleMode = Number(settingValue("candidateScoreTitleMode", candidateScoreTitleMode))
        candidateRingVisible = settingBool("candidateRingVisible", candidateRingVisible)
        candidateRingLineWidth = Number(settingValue("candidateRingLineWidth", candidateRingLineWidth))
        candidateRankLabelVisible = settingBool("candidateRankLabelVisible", candidateRankLabelVisible)
        candidateFirstLabelTextColor = String(settingValue("candidateFirstLabelTextColor", candidateFirstLabelTextColor))
        candidateLabelTextColor = String(settingValue("candidateLabelTextColor", candidateLabelTextColor))
        backgroundColor = String(settingValue("backgroundColor", backgroundColor))
        boardWoodColor = String(settingValue("boardWoodColor", boardWoodColor))
        stoneScale = Number(settingValue("stoneScale", stoneScale))
        gridOpacity = Number(settingValue("gridOpacity", gridOpacity))
        gridLineWidth = Number(settingValue("gridLineWidth", gridLineWidth))
        selectedPointScale = Number(settingValue("selectedPointScale", selectedPointScale))
        moveNumberLabelScale = Number(settingValue("moveNumberLabelScale", moveNumberLabelScale))
        secondsPerMove = Number(settingValue("secondsPerMove", secondsPerMove))
        resignMinMove = Number(settingValue("resignMinMove", resignMinMove))
        resignConsecutiveMoves = Number(settingValue("resignConsecutiveMoves", resignConsecutiveMoves))
        resignWinrateThreshold = Number(settingValue("resignWinrateThreshold", resignWinrateThreshold))
        migratePersistentSettings()
    }

    function savePersistentSettings() {
        if (!appSettings)
            return
        appSettings.setValue("settingsVersion", currentSettingsVersion)
        appSettings.setValue("language", language)
        appSettings.setValue("firstLaunchCompleted", firstLaunchCompleted)
        appSettings.setValue("boardSizeX", boardSizeX)
        appSettings.setValue("boardSizeY", boardSizeY)
        appSettings.setValue("gameRuleMode", gameRuleMode)
        appSettings.setValue("gomokuRuleMode", gomokuRuleMode)
        appSettings.setValue("stoneColorMode", stoneColorMode)
        appSettings.setValue("komi", komi)
        appSettings.setValue("moveNumberDisplayMode", moveNumberDisplayMode)
        appSettings.setValue("coordinateDisplayMode", coordinateDisplayMode)
        appSettings.setValue("packageMode", packageMode)
        appSettings.setValue("engineCommand", engineController ? engineController.command : persistedEngineCommand)
        appSettings.setValue("go5EngineCommand", go5EngineCommand)
        appSettings.setValue("go7EngineCommand", go7EngineCommand)
        appSettings.setValue("six11EngineCommand", six11EngineCommand)
        appSettings.setValue("six13EngineCommand", six13EngineCommand)
        appSettings.setValue("analysisIntervalCentiseconds", analysisIntervalCentiseconds)
        appSettings.setValue("maxAnalysisSeconds", maxAnalysisSeconds)
        appSettings.setValue("candidateDisplayCount", candidateDisplayCount)
        appSettings.setValue("candidateMinVisitRatio", candidateMinVisitRatio)
        appSettings.setValue("candidateShowFilteredMarkers", candidateShowFilteredMarkers)
        appSettings.setValue("candidateVariationPreviewVisible", candidateVariationPreviewVisible)
        appSettings.setValue("candidateVariationPreviewMaxMoves", candidateVariationPreviewMaxMoves)
        appSettings.setValue("candidateVariationPreviewOpacity", candidateVariationPreviewOpacity)
        appSettings.setValue("candidateWinrateLabelVisible", candidateWinrateLabelVisible)
        appSettings.setValue("candidateVisitsLabelVisible", candidateVisitsLabelVisible)
        appSettings.setValue("candidateScoreLabelVisible", candidateScoreLabelVisible)
        appSettings.setValue("candidateWinrateFontSize", candidateWinrateFontSize)
        appSettings.setValue("candidateVisitsFontSize", candidateVisitsFontSize)
        appSettings.setValue("candidateScoreFontSize", candidateScoreFontSize)
        appSettings.setValue("candidateWinrateBold", candidateWinrateBold)
        appSettings.setValue("candidateVisitsBold", candidateVisitsBold)
        appSettings.setValue("candidateScoreBold", candidateScoreBold)
        appSettings.setValue("candidateWinrateOffsetY", candidateWinrateOffsetY)
        appSettings.setValue("candidateVisitsOffsetY", candidateVisitsOffsetY)
        appSettings.setValue("candidateScoreOffsetY", candidateScoreOffsetY)
        appSettings.setValue("candidateWinrateDecimals", candidateWinrateDecimals)
        appSettings.setValue("candidateScoreDecimals", candidateScoreDecimals)
        appSettings.setValue("candidateWinrateShowPercent", candidateWinrateShowPercent)
        appSettings.setValue("candidateScoreShowPercent", candidateScoreShowPercent)
        appSettings.setValue("candidateScoreTitleMode", candidateScoreTitleMode)
        appSettings.setValue("candidateRingVisible", candidateRingVisible)
        appSettings.setValue("candidateRingLineWidth", candidateRingLineWidth)
        appSettings.setValue("candidateRankLabelVisible", candidateRankLabelVisible)
        appSettings.setValue("candidateFirstLabelTextColor", candidateFirstLabelTextColor)
        appSettings.setValue("candidateLabelTextColor", candidateLabelTextColor)
        appSettings.setValue("backgroundColor", backgroundColor)
        appSettings.setValue("boardWoodColor", boardWoodColor)
        appSettings.setValue("stoneScale", stoneScale)
        appSettings.setValue("gridOpacity", gridOpacity)
        appSettings.setValue("gridLineWidth", gridLineWidth)
        appSettings.setValue("selectedPointScale", selectedPointScale)
        appSettings.setValue("moveNumberLabelScale", moveNumberLabelScale)
        appSettings.setValue("secondsPerMove", secondsPerMove)
        appSettings.setValue("resignMinMove", resignMinMove)
        appSettings.setValue("resignConsecutiveMoves", resignConsecutiveMoves)
        appSettings.setValue("resignWinrateThreshold", resignWinrateThreshold)
        appSettings.sync()
    }

    function applyPackageModeConstraints(restartIfChanged) {
        if (packageMode === packageModeGo) {
            gameRuleMode = gameRuleGo
            if (!boardDimensionsAllowedForPackage(boardSizeX, boardSizeY)) {
                boardSizeX = 19
                boardSizeY = 19
            }
        } else if (packageMode === packageModeSix) {
            gameRuleMode = gameRuleGomoku
            if (!boardDimensionsAllowedForPackage(boardSizeX, boardSizeY)) {
                boardSizeX = 13
                boardSizeY = 13
            }
        }
        normalizeGomokuRuleForCurrentMode()
        if (packageMode === packageModeUniversal)
            applyUniversalEngineCommand(restartIfChanged)
        else
            applyEngineCommandForCurrentPackageMode(restartIfChanged)
    }

    function packageEngineCommandForCurrentBoard() {
        if (packageMode === packageModeGo)
            return boardSizeX === 5 ? go5EngineCommand : go7EngineCommand
        if (packageMode === packageModeSix)
            return boardSizeX === 11 ? six11EngineCommand : six13EngineCommand
        return ""
    }

    function applyEngineCommandForCurrentPackageMode(restartIfChanged) {
        if (!engineController || packageMode === packageModeUniversal)
            return
        var command = packageEngineCommandForCurrentBoard()
        if (command.length <= 0 || engineController.command === command)
            return
        engineController.command = command
        resetEngineSyncState()
        if (restartIfChanged && appReady && engineController.running)
            restartEngine()
    }

    function applyUniversalEngineCommand(restartIfChanged) {
        if (!engineController || packageMode !== packageModeUniversal)
            return
        var command = persistedEngineCommand.length > 0 ? persistedEngineCommand : defaultGo7EngineCommand
        if (command.length <= 0 || engineController.command === command)
            return
        engineController.command = command
        resetEngineSyncState()
        if (restartIfChanged && appReady && engineController.running)
            restartEngine()
    }

    function completeInitialSetup(openTutorial) {
        firstLaunchCompleted = true
        savePersistentSettings()
        if (initialSetupDialog.visible)
            initialSetupDialog.close()
        if (openTutorial)
            openBeginnerTutorial()
        focusBoardInput()
    }

    function appendEngineCommunication(stream, line) {
        if (!engineCommunicationLogModel)
            return
        if (engineCommunicationLineFiltered(stream, line))
            return
        engineCommunicationLogModel.append({
            "stream": stream,
            "line": String(line),
            "color": engineCommunicationColor(stream)
        })
        while (engineCommunicationLogModel.count > engineCommunicationLogLimit)
            engineCommunicationLogModel.remove(0)
    }

    function clearEngineCommunicationLog() {
        engineCommunicationLogModel.clear()
    }

    function engineCommunicationLineFiltered(stream, line) {
        if (stream !== "stdout")
            return false
        return /^info\s+move\b/.test(String(line).trim())
    }

    function engineCommunicationColor(stream) {
        if (stream === "stdin")
            return "#7ee2a8"
        if (stream === "stderr")
            return "#ff8b7f"
        return "#d9e6ee"
    }

    Connections {
        target: engineController

        function onEngineInput(line) {
            root.appendEngineCommunication("stdin", line)
        }

        function onEngineOutput(line) {
            root.appendEngineCommunication("stdout", line)
        }

        function onEngineErrorOutput(line) {
            root.appendEngineCommunication("stderr", line)
        }

        function onCommandChanged() {
            if (root.packageMode === root.packageModeUniversal) {
                root.persistedEngineCommand = engineController.command
                if (root.persistentSettingsLoaded)
                    root.savePersistentSettings()
            }
        }

        function onCandidatesChanged() {
            if (!root.analysisModeActive()) {
                root.engineCandidates = []
                root.engineCandidateRevision = engineController.candidateRevision
                root.rebuildEngineCandidateItems()
                return
            }
            root.engineLoading = false
            root.engineCandidates = engineController.candidates
            root.engineCandidateRevision = engineController.candidateRevision
            root.rebuildEngineCandidateItems()
            root.recordCurrentAnalysisFromCandidates()
            if (root.engineCandidateItems.length > 0) {
                root.statusMode = "message"
                root.statusMessage = root.engineCandidateSummaryText()
            }
        }

        function onReadyChanged() {
            if (engineController.ready) {
                root.engineLoading = false
                root.scheduleAutoAnalysis()
                root.requestAiMoveIfNeeded()
            }
        }

        function onFailedChanged() {
            if (engineController.failed) {
                root.enterNoEngineMode(root.engineFailureMessage())
            }
        }

        function onMoveGenerated(requestId, move, ok, rawLine) {
            if (requestId !== root.activeGenmoveRequestId)
                return
            root.genmoveInFlight = false
            root.activeGenmoveRequestId = 0
            root.genmovePlayer = 0
            if (!ok) {
                root.statusMode = "message"
                root.statusMessage = rawLine
                return
            }
            root.applyGeneratedMove(move)
            root.requestAiMoveIfNeeded()
        }
    }

    Component.onCompleted: {
        loadPersistentSettings()
        normalizePersistentSettings()
        if (packageMode === packageModeUniversal && persistedEngineCommand.length > 0)
            engineController.command = persistedEngineCommand
        else
            applyEngineCommandForCurrentPackageMode(false)
        persistentSettingsLoaded = true
        if (settingsMigrated)
            savePersistentSettings()
        resetGameTree()
        setSelectedPoint(0, 0)
        appReady = true
        if (!firstLaunchCompleted)
            firstLaunchTimer.start()
        startEngine()
        scheduleAutoAnalysis()
    }

    AnalysisToolbar { id: analysisToolbar; app: root }
    CommandToolbar { id: commandToolbar; app: root }
    BoardScene { id: boardScene; app: root }
    BoardInputLayer { id: inputLayer; app: root; anchors.fill: boardScene }
    InfoPanel { id: infoPanel; app: root }

    Rectangle {
        id: engineStartupNotice
        visible: root.engineNoticeVisible()
        x: Math.round(root.clamp(root.boardStageCenterX - width / 2,
                                 root.boardStageLeftReserve + root.panelGap,
                                 root.width - root.boardStageRightReserve - root.panelGap - width))
        anchors.bottom: commandToolbar.top
        anchors.bottomMargin: root.panelGap
        width: Math.min(root.compactLayout ? 390 : 470,
                        Math.max(280, root.width - root.boardStageLeftReserve
                                 - root.boardStageRightReserve - root.panelGap * 2))
        height: root.compactLayout ? 42 : 48
        radius: 6
        color: root.engineNoticeFillColor()
        border.color: root.engineNoticeBorderColor()
        border.width: 2
        opacity: 0.96

        Text {
            anchors.left: parent.left
            anchors.right: noticeCloseButton.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 12
            anchors.rightMargin: 6
            text: root.engineNoticeText()
            color: root.engineNoticeTextColor()
            font.pixelSize: root.compactLayout ? 16 : 18
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Basic.Button {
            id: noticeCloseButton
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: root.compactLayout ? 34 : 38
            text: "x"
            font.pixelSize: root.compactLayout ? 18 : 20
            font.bold: true
            onClicked: root.engineNoticeDismissed = true

            contentItem: Text {
                text: noticeCloseButton.text
                color: noticeCloseButton.hovered ? "#11181d" : root.engineNoticeTextColor()
                font: noticeCloseButton.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: noticeCloseButton.hovered ? "#ffffff66" : "transparent"
                radius: 4
            }
        }
    }

    BranchPanel { id: branchPanel; app: root }
}
