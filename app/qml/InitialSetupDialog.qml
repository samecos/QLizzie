import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "InkTheme.js" as InkTheme

Basic.Dialog {
    id: initialSetupDialog

    required property var app

    modal: true
    title: app.trText("initialSetupTitle")
    closePolicy: Popup.NoAutoClose
    onOpened: console.log("InitialSetupDialog opened")
    padding: 18
    topPadding: header.height + 12
    width: Math.min(440, app.width - 70)
    x: Math.round((app.width - width) / 2)
    y: Math.round((app.height - height) / 2)

    background: Rectangle {
        radius: 12
        color: InkTheme.colors.paper
        border.color: InkTheme.colors.inkLight
        border.width: 1
    }

    header: Rectangle {
        height: 52
        implicitHeight: 52
        color: InkTheme.colors.paperDeep
        radius: 12

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
            color: InkTheme.colors.inkLight
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            text: initialSetupDialog.title
            color: InkTheme.colors.inkDeep
            font.pixelSize: 17
            font.bold: true
            font.family: InkTheme.fonts.title
            elide: Text.ElideRight
        }
    }

    contentItem: ColumnLayout {
        implicitWidth: 404
        spacing: 18

        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            Label {
                text: app.trText("menuLanguage")
                color: InkTheme.colors.inkDeep
                font.pixelSize: 15
                font.bold: true
                Layout.preferredWidth: 86
            }

            Basic.ComboBox {
                id: languageCombo
                Layout.fillWidth: true
                model: [
                    { "label": app.trText("languageChinese"), "value": "zh" },
                    { "label": app.trText("languageEnglish"), "value": "en" }
                ]
                textRole: "label"
                valueRole: "value"
                currentIndex: app.language === "en" ? 1 : 0
                onActivated: function(index) {
                    app.language = model[index].value
                }

                contentItem: Text {
                    leftPadding: 12
                    rightPadding: 30
                    text: languageCombo.displayText
                    color: InkTheme.colors.inkDeep
                    font.pixelSize: 15
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    implicitHeight: 38
                    radius: 6
                    color: InkTheme.colors.white
                    border.color: languageCombo.activeFocus ? InkTheme.colors.cinnabar : InkTheme.colors.inkLight
                    border.width: languageCombo.activeFocus ? 2 : 1
                }

                delegate: Basic.ItemDelegate {
                    width: languageCombo.width
                    height: 42
                    highlighted: languageCombo.highlightedIndex === index

                    contentItem: Text {
                        text: modelData.label
                        color: InkTheme.colors.inkDeep
                        font.pixelSize: 15
                        font.bold: languageCombo.currentIndex === index
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 12
                    }

                    background: Rectangle {
                        color: highlighted ? InkTheme.colors.inkWash : InkTheme.colors.white
                    }
                }

                popup: Popup {
                    y: languageCombo.height + 2
                    width: languageCombo.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: languageCombo.popup.visible ? languageCombo.delegateModel : null
                        currentIndex: languageCombo.highlightedIndex
                    }

                    background: Rectangle {
                        color: InkTheme.colors.white
                        border.color: InkTheme.colors.inkLight
                        radius: 4
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            SavePromptButton {
                id: startButton
                text: app.trText("startUsing")
                primary: true
                implicitWidth: 118
                onClicked: {
                    console.log("InitialSetupDialog start button clicked")
                    app.completeInitialSetup()
                    initialSetupDialog.close()
                }
            }
        }
    }
}
