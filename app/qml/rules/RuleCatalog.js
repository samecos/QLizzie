.pragma library

function boardPresentationOptions(app, ruleMode) {
    if (ruleMode === app.gameRuleGomoku) {
        return [
            {
                "label": app.trText("boardPresentationIntersections"),
                "value": app.boardPresentationIntersections,
                "tip": app.trText("boardPresentationIntersectionsTip")
            },
            {
                "label": app.trText("boardPresentationCells"),
                "value": app.boardPresentationCells,
                "tip": app.trText("boardPresentationCellsTip")
            }
        ]
    }
    return [
        {
            "label": app.trText("boardPresentationIntersections"),
            "value": app.boardPresentationIntersections,
            "tip": app.trText("boardPresentationIntersectionsTip")
        }
    ]
}

function boardPresentationCurrentIndex(app) {
    var options = boardPresentationOptions(app, app.gameRuleMode)
    for (var i = 0; i < options.length; ++i) {
        if (options[i].value === app.boardPresentationMode)
            return i
    }
    return 0
}

function boardPresentationText(app, mode) {
    var options = boardPresentationOptions(app, app.gameRuleMode)
    for (var i = 0; i < options.length; ++i) {
        if (options[i].value === mode)
            return options[i].label
    }
    return options.length > 0 ? options[0].label : ""
}

function rememberedBoardPresentationMode(app, ruleMode) {
    if (ruleMode === app.gameRuleGomoku)
        return app.gomokuBoardPresentationMode
    return app.boardPresentationIntersections
}

function normalizeBoardPresentationMode(app, ruleMode, value) {
    var options = boardPresentationOptions(app, ruleMode)
    for (var i = 0; i < options.length; ++i) {
        if (options[i].value === value)
            return value
    }
    return options.length > 0 ? options[0].value : app.boardPresentationIntersections
}

function hexBoardStyleOptions(app) {
    return [
        {
            "label": app.trText("hexBoardStyleTriangle"),
            "value": app.hexBoardStyleTriangle,
            "tip": app.trText("hexBoardStyleTriangleTip")
        },
        {
            "label": app.trText("hexBoardStyleCells"),
            "value": app.hexBoardStyleCells,
            "tip": app.trText("hexBoardStyleCellsTip")
        }
    ]
}

function hexBoardStyleCurrentIndex(app) {
    var options = hexBoardStyleOptions(app)
    for (var i = 0; i < options.length; ++i) {
        if (options[i].value === app.hexBoardStyle)
            return i
    }
    return 0
}

function hexBoardRotationOptions(app) {
    return [
        {
            "label": app.trText("hexRotationCurrent"),
            "value": app.hexRotationCurrent,
            "tip": app.trText("hexRotationCurrentTip")
        },
        {
            "label": app.trText("hexRotationTranspose"),
            "value": app.hexRotationTranspose,
            "tip": app.trText("hexRotationTransposeTip")
        },
        {
            "label": app.trText("hexRotationFlipX"),
            "value": app.hexRotationFlipX,
            "tip": app.trText("hexRotationFlipXTip")
        },
        {
            "label": app.trText("hexRotationFlipXTranspose"),
            "value": app.hexRotationFlipXTranspose,
            "tip": app.trText("hexRotationFlipXTransposeTip")
        }
    ]
}

function hexBoardRotationCurrentIndex(app) {
    var options = hexBoardRotationOptions(app)
    for (var i = 0; i < options.length; ++i) {
        if (options[i].value === app.hexBoardRotation)
            return i
    }
    return 0
}
