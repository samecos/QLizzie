import QtQuick
import QtQuick.Controls.Basic as Basic
import "InkTheme.js" as InkTheme

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
        color: InkTheme.colors.paperDark
        border.color: InkTheme.colors.inkLight
    }

    contentItem: Rectangle {
        implicitWidth: scrollBar.orientation === Qt.Vertical ? 8 : 34
        implicitHeight: scrollBar.orientation === Qt.Vertical ? 34 : 8
        radius: 4
        color: scrollBar.pressed ? InkTheme.colors.inkDark : scrollBar.hovered ? InkTheme.colors.ink : InkTheme.colors.inkLight
    }
}
