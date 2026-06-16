import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

Basic.Dialog {
    id: aboutDialog

    required property var app
    property int hiddenClickCount: 0

    modal: true
    title: app.trText("aboutTitle")
    closePolicy: Popup.CloseOnEscape
    padding: 18
    width: Math.min(560, app.width - 70)
    height: Math.min(360, app.height - 70)
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    function link(url, label) {
        return "<a href=\"" + url + "\">" + label + "</a>"
    }

    onOpened: hiddenClickCount = 0

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

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            text: aboutDialog.title
            color: "#14242e"
            font.pixelSize: 18
            font.bold: true
            elide: Text.ElideRight
        }
    }

    contentItem: ColumnLayout {
        implicitWidth: 520
        implicitHeight: 250
        spacing: 16

        Text {
            Layout.fillWidth: true
            text: "QLizzie"
            color: "#14242e"
            font.pixelSize: 24
            font.bold: true

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    aboutDialog.hiddenClickCount += 1
                    if (aboutDialog.hiddenClickCount >= 10) {
                        aboutDialog.hiddenClickCount = 0
                        aboutDialog.close()
                        app.openHiddenSettingsDialog()
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            textFormat: Text.RichText
            color: "#17212a"
            linkColor: "#176ea3"
            font.pixelSize: 15
            wrapMode: Text.WordWrap
            text: "<p>" + app.trText("aboutIntroBeforeAuthor") + " "
                  + link("https://github.com/hzyhhzy", "hzyhhzy")
                  + " " + app.trText("aboutIntroAfterAuthor") + "</p>"
                  + "<p>" + app.trText("aboutReferenceBeforeLizzie")
                  + " " + link("https://github.com/yzyray/lizzieyzy", "LizzieYZY")
                  + app.trText("aboutReferenceAfterLizzie") + "</p>"
                  + "<p>" + app.trText("aboutEngineBeforeKataGo")
                  + " " + link("https://github.com/lightvector/KataGo", "KataGo")
                  + " / " + link("https://github.com/hzyhhzy/KataGomo", "KataGomo")
                  + " " + app.trText("aboutEngineAfterKataGomo") + "</p>"
                  + "<p>" + app.trText("aboutQqGroup") + "</p>"
            onLinkActivated: function(url) { Qt.openUrlExternally(url) }
        }

        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            SavePromptButton {
                text: app.trText("close")
                primary: true
                onClicked: {
                    aboutDialog.close()
                    app.focusBoardInput()
                }
            }
        }
    }
}
