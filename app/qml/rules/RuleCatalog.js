.pragma library

function boardPresentationOptions(app, ruleMode) {
    if (ruleMode === app.gameRuleHex) {
        return [
            {
                "label": app.trText("boardPresentationHexTriangle"),
                "value": app.boardPresentationIntersections,
                "tip": app.trText("boardPresentationHexTriangleTip")
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
