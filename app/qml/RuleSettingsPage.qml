import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

ColumnLayout {
    id: ruleSettingsPage

    required property var app

    spacing: 14

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: ruleContent.implicitHeight + 28
        radius: 7
        color: "#f8fbfd"
        border.color: "#c7d4dc"

        ColumnLayout {
            id: ruleContent
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Label {
                text: app.trText("gameKindRuleSettings")
                color: "#17212a"
                font.pixelSize: 16
                font.bold: true
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: app.trText("mainRule")
                    color: "#24313a"
                    Layout.preferredWidth: 110
                }

                GameRuleComboBox {
                    app: ruleSettingsPage.app
                    Layout.preferredWidth: 170
                    implicitHeight: 32
                }

                Label {
                    text: app.trText("ruleVariant")
                    color: "#24313a"
                    Layout.preferredWidth: 86
                }

                RuleVariantComboBox {
                    app: ruleSettingsPage.app
                    Layout.preferredWidth: 230
                    implicitHeight: 32
                }

                Item { Layout.fillWidth: true }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: app.trText("boardPresentation")
                    color: "#24313a"
                    Layout.preferredWidth: 110
                }

                Basic.ComboBox {
                    id: boardPresentationCombo
                    model: app.boardPresentationOptions()
                    textRole: "label"
                    valueRole: "value"
                    currentIndex: app.boardPresentationCurrentIndex()
                    Layout.preferredWidth: 260
                    implicitHeight: 32
                    onActivated: function(index) { app.setBoardPresentationFromIndex(index) }

                    contentItem: Text {
                        leftPadding: 10
                        rightPadding: 28
                        text: boardPresentationCombo.displayText
                        color: "#14242e"
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        radius: 5
                        color: "#ffffff"
                        border.color: boardPresentationCombo.activeFocus ? "#2a91c9" : "#a8bac5"
                        border.width: boardPresentationCombo.activeFocus ? 2 : 1
                    }

                    delegate: Basic.ItemDelegate {
                        width: boardPresentationCombo.width
                        height: 36
                        highlighted: boardPresentationCombo.highlightedIndex === index

                        contentItem: Text {
                            text: modelData.label
                            color: "#14242e"
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            color: highlighted ? "#dfeaf0" : "#ffffff"
                        }
                    }
                }

                Label {
                    text: app.boardPresentationOptions()[app.boardPresentationCurrentIndex()]
                          ? app.boardPresentationOptions()[app.boardPresentationCurrentIndex()].tip
                          : ""
                    color: "#61727c"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: app.komiControlsVisible()

                Label {
                    text: app.trText("komi")
                    color: "#24313a"
                    Layout.preferredWidth: 110
                }

                SpinBox {
                    from: -200
                    to: 200
                    value: Math.round(app.effectiveKomi() * 2)
                    editable: true
                    Layout.preferredWidth: 96
                    textFromValue: function(value) { return (value / 2).toFixed(1) }
                    valueFromText: function(text) { return Math.round(Number(text) * 2) }
                    onValueModified: app.setKomiValue(value / 2)
                }

                Item { Layout.fillWidth: true }
            }
        }
    }
}
