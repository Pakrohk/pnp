import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: testerPage
    title: "Input Tester"

    Kirigami.CardsListView {
        id: deviceList
        anchors.fill: parent
        model: backend.testerDevices

        delegate: Kirigami.AbstractCard {
            contentItem: ColumnLayout {
                spacing: Kirigami.Units.largeSpacing

                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        spacing: 0
                        Kirigami.Heading {
                            text: modelData.name
                            level: 3
                        }
                        Controls.Label {
                            text: modelData.path
                            font.family: "monospace"
                            font.pixelSize: Kirigami.Units.gridUnit * 0.6
                            opacity: 0.6
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: Kirigami.Units.gridUnit * 4
                        height: Kirigami.Units.gridUnit * 1.5
                        radius: height / 2
                        color: modelData.isVirtual ? Kirigami.Theme.highlightColor : Kirigami.Theme.positiveTextColor
                        Controls.Label {
                            anchors.centerIn: parent
                            text: modelData.isVirtual ? "Virtual" : "Physical"
                            color: "white"
                            font.pixelSize: Kirigami.Units.gridUnit * 0.6
                            font.bold: true
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Kirigami.Units.gridUnit * 2

                    // D-Pad
                    GridLayout {
                        columns: 3
                        rows: 3
                        columnSpacing: 4
                        rowSpacing: 4

                        Item { Layout.preferredWidth: 32; Layout.preferredHeight: 32 }
                        TesterButton { text: "U"; active: modelData.buttons[706] || false }
                        Item { Layout.preferredWidth: 32; Layout.preferredHeight: 32 }
                        TesterButton { text: "L"; active: modelData.buttons[704] || false }
                        TesterButton { text: "D"; active: modelData.buttons[707] || false }
                        TesterButton { text: "R"; active: modelData.buttons[705] || false }
                        Item { Layout.preferredWidth: 32; Layout.preferredHeight: 32 }
                        Item { Layout.preferredWidth: 32; Layout.preferredHeight: 32 }
                        Item { Layout.preferredWidth: 32; Layout.preferredHeight: 32 }
                    }

                    // Action Buttons
                    GridLayout {
                        columns: 3
                        rows: 3
                        columnSpacing: 4
                        rowSpacing: 4

                        Item { Layout.preferredWidth: 32; Layout.preferredHeight: 32 }
                        TesterButton { text: "Y"; active: (modelData.buttons[308] || false); accentColor: "#F4D03F" }
                        Item { Layout.preferredWidth: 32; Layout.preferredHeight: 32 }
                        TesterButton { text: "X"; active: (modelData.buttons[307] || false); accentColor: "#3498DB" }
                        Item { Layout.preferredWidth: 32; Layout.preferredHeight: 32 }
                        TesterButton { text: "B"; active: (modelData.buttons[305] || false); accentColor: "#E74C3C" }
                        Item { Layout.preferredWidth: 32; Layout.preferredHeight: 32 }
                        TesterButton { text: "A"; active: (modelData.buttons[304] || false); accentColor: "#2ECC71" }
                        Item { Layout.preferredWidth: 32; Layout.preferredHeight: 32 }
                    }
                }

                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    columnSpacing: Kirigami.Units.largeSpacing

                    Repeater {
                        model: [
                            { label: "LX", value: modelData.axes[0] },
                            { label: "LY", value: modelData.axes[1] },
                            { label: "RX", value: modelData.axes[2] },
                            { label: "RY", value: modelData.axes[3] },
                            { label: "LT", value: modelData.axes[4] },
                            { label: "RT", value: modelData.axes[5] }
                        ]
                        RowLayout {
                            Layout.fillWidth: true
                            Controls.Label { text: modelData.label; Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5 }
                            Controls.ProgressBar {
                                Layout.fillWidth: true
                                value: (modelData.value + 1) / 2 // Mapping -1..1 to 0..1 for sticks, assuming triggers are handled correctly by backend
                            }
                        }
                    }
                }
            }
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            visible: deviceList.count === 0
            icon.name: "input-gaming"
            text: "No Active Controllers"
            helpfulText: "Enable a controller in the Monitor tab to test input."
        }
    }

    component TesterButton: Rectangle {
        property string text: ""
        property bool active: false
        property color accentColor: Kirigami.Theme.positiveTextColor

        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        radius: 16
        color: active ? accentColor : Kirigami.Theme.alternateBackgroundColor
        border.color: Kirigami.Theme.textColor
        border.width: 1
        opacity: active ? 1.0 : 0.3

        Controls.Label {
            anchors.centerIn: parent
            text: parent.text
            font.bold: true
            color: active ? "white" : Kirigami.Theme.textColor
        }

        Behavior on opacity { NumberAnimation { duration: 50 } }
        Behavior on color { ColorAnimation { duration: 50 } }
    }
}
