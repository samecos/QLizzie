import QtQuick

Item {
    id: marker

    required property var app
    property var labelLines: []
    property bool drawBackground: false
    property bool drawRing: false
    property color backgroundColor: "#00ffff"
    property real backgroundOpacity: 0.72
    readonly property real markerRadius: app.candidateMarkerRadius(width, height)

    Canvas {
        id: markerCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            marker.app.drawCandidateMarker(ctx,
                                           width * 0.5,
                                           height * 0.5,
                                           marker.markerRadius,
                                           marker.labelLines,
                                           {
                                               drawBackground: marker.drawBackground,
                                               fillColor: marker.backgroundColor,
                                               fillOpacity: marker.backgroundOpacity,
                                               drawRing: marker.drawRing,
                                               ringColor: marker.app.firstCandidateRingColor,
                                               textColor: marker.drawRing ? marker.app.candidateFirstLabelTextColor : ""
                                           })
        }
    }

    onWidthChanged: markerCanvas.requestPaint()
    onHeightChanged: markerCanvas.requestPaint()
    onLabelLinesChanged: markerCanvas.requestPaint()
    onDrawBackgroundChanged: markerCanvas.requestPaint()
    onDrawRingChanged: markerCanvas.requestPaint()
    onBackgroundColorChanged: markerCanvas.requestPaint()
    onBackgroundOpacityChanged: markerCanvas.requestPaint()

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
        function onCandidateFirstLabelTextColorChanged() { markerCanvas.requestPaint() }
        function onCandidateLabelTextColorChanged() { markerCanvas.requestPaint() }
    }
}
