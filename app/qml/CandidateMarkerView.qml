import QtQuick

Item {
    id: marker

    required property var app
    property var labelLines: []
    property bool drawBackground: false
    property bool drawRing: false
    property bool drawOutline: false
    property string rankText: ""
    property color backgroundColor: "#00ffff"
    property real backgroundOpacity: 0.72
    property real outlineOpacity: 0.3
    readonly property real markerRadius: app.candidateMarkerRadius(width * 0.78, height * 0.78)
    readonly property real markerCenterX: width * 0.45
    readonly property real markerCenterY: height * 0.61

    Canvas {
        id: markerCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            marker.app.drawCandidateMarker(ctx,
                                           marker.markerCenterX,
                                           marker.markerCenterY,
                                           marker.markerRadius,
                                           marker.labelLines,
                                           {
                                               drawBackground: marker.drawBackground,
                                               fillColor: marker.backgroundColor,
                                               fillOpacity: marker.backgroundOpacity,
                                               drawOutline: marker.drawOutline,
                                               outlineOpacity: marker.outlineOpacity,
                                               drawRing: marker.drawRing,
                                               ringColor: marker.app.firstCandidateRingColor,
                                               textColor: marker.drawRing ? marker.app.candidateFirstLabelTextColor : "",
                                               rankText: marker.rankText
                                           })
        }
    }

    onWidthChanged: markerCanvas.requestPaint()
    onHeightChanged: markerCanvas.requestPaint()
    onLabelLinesChanged: markerCanvas.requestPaint()
    onDrawBackgroundChanged: markerCanvas.requestPaint()
    onDrawRingChanged: markerCanvas.requestPaint()
    onDrawOutlineChanged: markerCanvas.requestPaint()
    onRankTextChanged: markerCanvas.requestPaint()
    onBackgroundColorChanged: markerCanvas.requestPaint()
    onBackgroundOpacityChanged: markerCanvas.requestPaint()
    onOutlineOpacityChanged: markerCanvas.requestPaint()

    Connections {
        target: marker.app

        function onCandidateWinrateLabelVisibleChanged() { markerCanvas.requestPaint() }
        function onCandidateVisitsLabelVisibleChanged() { markerCanvas.requestPaint() }
        function onCandidateScoreLabelVisibleChanged() { markerCanvas.requestPaint() }
        function onCandidateWinrateFontSizeChanged() { markerCanvas.requestPaint() }
        function onCandidateVisitsFontSizeChanged() { markerCanvas.requestPaint() }
        function onCandidateScoreFontSizeChanged() { markerCanvas.requestPaint() }
        function onCandidateWinrateBoldChanged() { markerCanvas.requestPaint() }
        function onCandidateVisitsBoldChanged() { markerCanvas.requestPaint() }
        function onCandidateScoreBoldChanged() { markerCanvas.requestPaint() }
        function onCandidateWinrateOffsetYChanged() { markerCanvas.requestPaint() }
        function onCandidateVisitsOffsetYChanged() { markerCanvas.requestPaint() }
        function onCandidateScoreOffsetYChanged() { markerCanvas.requestPaint() }
        function onCandidateWinrateDecimalsChanged() { markerCanvas.requestPaint() }
        function onCandidateScoreDecimalsChanged() { markerCanvas.requestPaint() }
        function onCandidateWinrateShowPercentChanged() { markerCanvas.requestPaint() }
        function onCandidateScoreShowPercentChanged() { markerCanvas.requestPaint() }
        function onCandidateRingVisibleChanged() { markerCanvas.requestPaint() }
        function onCandidateRingLineWidthChanged() { markerCanvas.requestPaint() }
        function onCandidateRankLabelVisibleChanged() { markerCanvas.requestPaint() }
        function onCandidateFirstLabelTextColorChanged() { markerCanvas.requestPaint() }
        function onCandidateLabelTextColorChanged() { markerCanvas.requestPaint() }
    }
}
