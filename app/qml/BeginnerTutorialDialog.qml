import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

Basic.Dialog {
    id: tutorialDialog

    required property var app
    property int pageIndex: 0
    readonly property var pages: [
        { "title": app.trText("tutorialPageViewTitle"), "body": app.trText("tutorialPageViewBody") },
        { "title": app.trText("tutorialPageRulesTitle"), "body": app.trText("tutorialPageRulesBody") },
        { "title": app.trText("tutorialPageMoveTitle"), "body": app.trText("tutorialPageMoveBody") },
        { "title": app.trText("tutorialPageEngineTitle"), "body": app.trText("tutorialPageEngineBody") },
        { "title": app.trText("tutorialPageTreeTitle"), "body": app.trText("tutorialPageTreeBody") }
    ]
    readonly property int pageCount: pages.length

    modal: false
    title: app.trText("beginnerTutorialTitle")
    closePolicy: Popup.NoAutoClose
    padding: 18
    width: Math.min(560, app.width - 70)
    height: Math.min(430, app.height - 70)
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    function openFirstPage() {
        pageIndex = 0
        open()
    }

    function openTutorial() {
        openFirstPage()
    }

    function currentPageTitle() {
        return pages[pageIndex] ? pages[pageIndex].title : ""
    }

    function currentPageBody() {
        return pages[pageIndex] ? pages[pageIndex].body : ""
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
            anchors.rightMargin: 54
            text: tutorialDialog.title
            color: "#14242e"
            font.pixelSize: 17
            font.bold: true
            elide: Text.ElideRight
        }

        Basic.Button {
            id: closeButton
            width: 34
            height: 34
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            padding: 0
            onClicked: skipTutorialDialog.open()

            contentItem: Text {
                text: "×"
                color: "#23343e"
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 6
                color: closeButton.pressed ? "#d4e0e7" : closeButton.hovered ? "#edf4f8" : "transparent"
                border.color: closeButton.hovered || closeButton.pressed ? "#9fb2bd" : "transparent"
            }
        }
    }

    contentItem: ColumnLayout {
        implicitWidth: 524
        spacing: 14

        Label {
            Layout.fillWidth: true
            text: (tutorialDialog.pageIndex + 1) + "/" + tutorialDialog.pageCount
            color: "#267fbb"
            font.pixelSize: 16
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            text: tutorialDialog.currentPageTitle()
            color: "#14242e"
            font.pixelSize: 21
            font.bold: true
            Layout.fillWidth: true
        }

        ScrollView {
            id: tutorialScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical: AppScrollBar {
                parent: tutorialScroll
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
            ScrollBar.horizontal: Basic.ScrollBar {
                policy: ScrollBar.AlwaysOff
            }

            Column {
                width: Math.max(0, tutorialScroll.availableWidth - 14)
                spacing: 14

                TextEdit {
                    width: parent.width
                    text: tutorialDialog.currentPageBody()
                    readOnly: true
                    selectByMouse: true
                    cursorVisible: false
                    color: "#1d2f39"
                    selectionColor: "#2a91c9"
                    selectedTextColor: "#ffffff"
                    font.pixelSize: 15
                    wrapMode: TextEdit.WordWrap
                }

                Item {
                    visible: tutorialDialog.pageIndex === 3
                    width: parent.width
                    height: visible ? 170 : 0

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "#e7f0f4"
                        border.color: "#c3d2db"
                    }

                    Repeater {
                        model: [
                            { "x": 0.50, "y": 0.46, "rate": "60%", "index": "1", "size": 104, "color": "#00ffff", "opacity": 0.72, "ring": true },
                            { "x": 0.25, "y": 0.32, "rate": "50%", "index": "2", "size": 72, "color": "#00ff36", "opacity": 0.58, "ring": false },
                            { "x": 0.76, "y": 0.34, "rate": "40%", "index": "3", "size": 68, "color": "#00ff36", "opacity": 0.46, "ring": false },
                            { "x": 0.32, "y": 0.74, "rate": "30%", "index": "4", "size": 62, "color": "#00ff36", "opacity": 0.34, "ring": false },
                            { "x": 0.72, "y": 0.72, "rate": "20%", "index": "5", "size": 58, "color": "#00ff36", "opacity": 0.24, "ring": false }
                        ]

                        Item {
                            width: modelData.size
                            height: modelData.size
                            x: Math.round(parent.width * modelData.x - width * 0.5)
                            y: Math.round(parent.height * modelData.y - height * 0.5)

                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: modelData.color
                                opacity: modelData.opacity
                            }

                            Rectangle {
                                visible: modelData.ring
                                anchors.fill: parent
                                radius: width / 2
                                color: "transparent"
                                border.color: "#ff1818"
                                border.width: 10
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.rate
                                color: "#000000"
                                font.pixelSize: modelData.ring ? 30 : 20
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: modelData.ring ? -2 : -4
                                anchors.rightMargin: modelData.ring ? -2 : -4
                                text: modelData.index
                                color: "#ff1818"
                                font.pixelSize: modelData.ring ? 26 : 21
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            SavePromptButton {
                text: app.trText("previous")
                enabled: tutorialDialog.pageIndex > 0
                onClicked: tutorialDialog.pageIndex -= 1
            }

            SavePromptButton {
                text: tutorialDialog.pageIndex + 1 >= tutorialDialog.pageCount
                      ? app.trText("finish")
                      : app.trText("next")
                primary: true
                onClicked: {
                    if (tutorialDialog.pageIndex + 1 >= tutorialDialog.pageCount) {
                        tutorialDialog.close()
                        app.focusBoardInput()
                    } else {
                        tutorialDialog.pageIndex += 1
                    }
                }
            }
        }
    }

    Basic.Dialog {
        id: skipTutorialDialog

        parent: Overlay.overlay
        modal: true
        title: app.trText("skipTutorialTitle")
        closePolicy: Popup.NoAutoClose
        padding: 18
        width: Math.min(440, app.width - 80)
        x: Math.round(((Overlay.overlay ? Overlay.overlay.width : app.width) - width) / 2)
        y: Math.round(((Overlay.overlay ? Overlay.overlay.height : app.height) - height) / 2)

        background: Rectangle {
            radius: 10
            color: "#fffaf0"
            border.color: "#d6a23a"
            border.width: 1
        }

        header: Rectangle {
            height: 48
            color: "#fff0c8"
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
                color: "#dfbd73"
            }

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                text: skipTutorialDialog.title
                color: "#3e2b05"
                font.pixelSize: 16
                font.bold: true
            }
        }

        contentItem: ColumnLayout {
            implicitWidth: 404
            spacing: 18

            TextEdit {
                Layout.fillWidth: true
                text: app.trText("skipTutorialMessage")
                readOnly: true
                selectByMouse: true
                cursorVisible: false
                color: "#352609"
                selectionColor: "#2a91c9"
                selectedTextColor: "#ffffff"
                font.pixelSize: 14
                wrapMode: TextEdit.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                SavePromptButton {
                    text: app.trText("continueTutorial")
                    onClicked: skipTutorialDialog.close()
                }

                SavePromptButton {
                    text: app.trText("skipTutorial")
                    primary: true
                    onClicked: {
                        skipTutorialDialog.close()
                        tutorialDialog.close()
                        app.focusBoardInput()
                    }
                }
            }
        }
    }
}
