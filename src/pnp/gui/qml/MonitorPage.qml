import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami
import ir.pakrohk.pnp

Kirigami.Page {
    id: monitorPage
    title: "Monitor"

    actions: [
        Kirigami.Action {
            text: "Sync with Steam"
            icon.name: "view-refresh"
            onTriggered: backend.syncWithSteam()
        }
    ]

    Kirigami.CardsListView {
        id: cardsList
        anchors.fill: parent
        model: backend.controllers

        delegate: Kirigami.Card {
            banner {
                title: modelData.name
                titleIcon: "gamepad"
            }

            contentItem: ColumnLayout {
                spacing: Kirigami.Units.mediumSpacing

                RowLayout {
                    spacing: Kirigami.Units.largeSpacing

                    Kirigami.Icon {
                        source: "gamepad"
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 2
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                        color: modelData.isActive ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        PlasmaComponents.Label {
                            text: "Serial: " + modelData.serial
                            font.family: "monospace"
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            opacity: 0.7
                        }
                        PlasmaComponents.Label {
                            text: "Path: " + modelData.path
                            font.family: "monospace"
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            opacity: 0.7
                        }
                    }

                    ColumnLayout {
                        visible: modelData.batteryPercentage >= 0
                        spacing: 0
                        PlasmaComponents.Label {
                            text: modelData.batteryPercentage + "%"
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Kirigami.Icon {
                            source: modelData.batteryStatus === "Charging" ? "battery-charging" : "battery-100"
                            Layout.preferredWidth: Kirigami.Units.gridUnit
                            Layout.preferredHeight: Kirigami.Units.gridUnit
                        }
                    }

                    PlasmaComponents.Switch {
                        checked: modelData.isActive
                        onToggled: backend.toggleController(modelData.path, checked)
                    }
                }

                Kirigami.Separator {
                    Layout.fillWidth: true
                    visible: modelData.isActive
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: modelData.isActive
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents.Label {
                        text: "Current Key Mappings"
                        font.bold: true
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        Repeater {
                            model: backend.config.mapping.keymap.split(",")
                            Rectangle {
                                width: mapText.width + Kirigami.Units.gridUnit
                                height: Kirigami.Units.gridUnit * 1.5
                                radius: height / 2
                                color: Kirigami.Theme.alternateBackgroundColor
                                border.color: Kirigami.Theme.focusColor
                                border.width: 1

                                PlasmaComponents.Label {
                                    id: mapText
                                    anchors.centerIn: parent
                                    text: modelData.replace("BTN_", "")
                                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                }
                            }
                        }
                    }
                }
            }
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            visible: cardsList.count === 0
            icon.name: "gamepad"
            text: "No Controllers Detected"
            explanation: "Connect a PlayStation controller via USB or Bluetooth."
        }
    }

    footer: Kirigami.ActionToolBar {
        actions: [
            Kirigami.Action {
                text: "Load Profile"
                icon.name: "document-open"
                onTriggered: profileDialog.open()
            }
        ]
    }

    Kirigami.OverlaySheet {
        id: profileDialog
        header: Kirigami.Heading { text: "Select Profile" }

        ColumnLayout {
            spacing: Kirigami.Units.largeSpacing

            PlasmaComponents.ComboBox {
                id: profileCombo
                Layout.fillWidth: true
                model: ["Default Profile", "Competitive", "Racing", "Fighting"]
            }

            PlasmaComponents.Button {
                text: "Load Selected Profile"
                icon.name: "document-open"
                Layout.fillWidth: true
                onClicked: {
                    backend.loadProfile(profileCombo.currentText)
                    profileDialog.close()
                }
            }

            Kirigami.Separator { Layout.fillWidth: true }

            PlasmaComponents.TextField {
                id: profileNameField
                placeholderText: "New Profile Name"
                Layout.fillWidth: true
            }

            PlasmaComponents.Button {
                text: "Save Current as New Profile"
                icon.name: "document-save"
                Layout.fillWidth: true
                onClicked: {
                    if (profileNameField.text !== "") {
                        backend.saveProfile(profileNameField.text)
                        profileDialog.close()
                    }
                }
            }
        }
    }
}
