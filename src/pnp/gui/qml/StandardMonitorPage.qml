import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import ir.pakrohk.pnp

Controls.Page {
    id: monitorPage

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Controls.Label {
            text: "PNP Controller Mapper"
            font.pixelSize: 24
            font.bold: true
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: backend.controllers
            clip: true
            spacing: 20

            delegate: ColumnLayout {
                width: parent.width
                spacing: 10

                Controls.Frame {
                    Layout.fillWidth: true
                    padding: 15

                    RowLayout {
                        width: parent.width
                        spacing: 15

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: modelData.isActive ? "#4CAF50" : "#F44336"

                            Controls.Label {
                                anchors.centerIn: parent
                                text: "🎮"
                                font.pixelSize: 20
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Controls.Label {
                                text: modelData.name
                                font.bold: true
                                font.pixelSize: 16
                            }
                            Controls.Label {
                                text: "Serial: " + modelData.serial + " | Path: " + modelData.path
                                font.pixelSize: 12
                                opacity: 0.7
                            }
                        }

                        RowLayout {
                            spacing: 5
                            visible: modelData.batteryPercentage >= 0
                            Controls.Label {
                                text: modelData.batteryPercentage + "%"
                            }
                            Controls.Label {
                                text: modelData.batteryStatus === "Charging" ? "⚡" : "🔋"
                            }
                        }

                        Controls.Switch {
                            checked: modelData.isActive
                            onToggled: backend.toggleController(modelData.path, checked)
                        }
                    }
                }

                Controls.Frame {
                    Layout.fillWidth: true
                    visible: modelData.isActive
                    background: Rectangle {
                        color: "#2A2A2A"
                        radius: 4
                    }

                    ColumnLayout {
                        width: parent.width
                        Controls.Label {
                            text: "Current Key Mappings"
                            font.bold: true
                            font.pixelSize: 12
                            opacity: 0.8
                        }

                        Flow {
                            Layout.fillWidth: true
                            spacing: 10

                            Repeater {
                                model: backend.config.mapping.keymap.split(",")
                                Rectangle {
                                    width: mapText.width + 20
                                    height: 24
                                    radius: 12
                                    color: "#3A3A3A"
                                    border.color: "#555"

                                    Controls.Label {
                                        id: mapText
                                        anchors.centerIn: parent
                                        text: modelData.replace("BTN_", "")
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Controls.ComboBox {
                id: profileCombo
                model: ["Default Profile", "Competitive", "Racing", "Fighting"]
                Layout.fillWidth: true
            }

            Controls.Button {
                text: "📥 Download from Steam"
                onClicked: backend.syncWithSteam()
            }

            Controls.Button {
                text: "📂 Load Profile"
                onClicked: backend.loadProfile(profileCombo.currentText)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Controls.TextField {
                id: profileNameField
                placeholderText: "Profile Name"
                Layout.fillWidth: true
            }

            Controls.Button {
                text: "💾 Save Profile"
                onClicked: {
                    if (profileNameField.text !== "") {
                        backend.saveProfile(profileNameField.text)
                    } else {
                        backend.saveConfig()
                    }
                }
            }
        }
    }
}
