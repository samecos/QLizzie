import QtQuick
import QtQuick.Controls.Basic as Basic

Basic.ScrollBar {
    id: scrollBar

    property real startInset: 0
    property real endInset: 0
    readonly property real basePadding: 2

    leftPadding: basePadding + (orientation === Qt.Horizontal ? startInset : 0)
    rightPadding: basePadding + (orientation === Qt.Horizontal ? endInset : 0)
    topPadding: basePadding + (orientation === Qt.Vertical ? startInset : 0)
    bottomPadding: basePadding + (orientation === Qt.Vertical ? endInset : 0)
    minimumSize: 0.08
    implicitWidth: orientation === Qt.Vertical ? 12 : 48
    implicitHeight: orientation === Qt.Vertical ? 48 : 12

    background: Rectangle {
        x: scrollBar.orientation === Qt.Horizontal ? scrollBar.startInset : 0
        y: scrollBar.orientation === Qt.Vertical ? scrollBar.startInset : 0
        width: scrollBar.orientation === Qt.Horizontal
               ? Math.max(0, scrollBar.width - scrollBar.startInset - scrollBar.endInset)
               : scrollBar.width
        height: scrollBar.orientation === Qt.Vertical
                ? Math.max(0, scrollBar.height - scrollBar.startInset - scrollBar.endInset)
                : scrollBar.height
        radius: 6
        color: "#edf4f7"
        border.color: "#d2dee5"
    }

    contentItem: Rectangle {
        implicitWidth: scrollBar.orientation === Qt.Vertical ? 8 : 34
        implicitHeight: scrollBar.orientation === Qt.Vertical ? 34 : 8
        radius: 4
        color: scrollBar.pressed ? "#5d737f" : scrollBar.hovered ? "#748a96" : "#9aadb6"
    }
}
