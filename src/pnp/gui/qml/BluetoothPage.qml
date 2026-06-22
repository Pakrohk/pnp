import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: bluetoothPage
    title: "Bluetooth Management"

    property list<var> scannedDevices: []

    actions: [
        Kirigami.Action {
            text: "Scan for Devices"
            icon.name: "view-refresh"
            onTriggered: {
                scannedDevices = []
                backend.scanBluetoothDevices()
            }
        },
        Kirigami.Action {
            text: "Reset Stack"
            icon.name: "view-restore"
            onTriggered: resetDialog.open()
        }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing

        Kirigami.InlineMessage {
            id: statusMessage
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.smallSpacing
            visible: text !== ""
            text: ""
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Device List
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Kirigami.Heading {
                    text: "Available Devices"
                    level: 3
                    Layout.margins: Kirigami.Units.smallSpacing
                }

                Kirigami.CardsListView {
                    id: deviceList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: bluetoothPage.scannedDevices

                    delegate: Kirigami.AbstractCard {
                        contentItem: RowLayout {
                            spacing: Kirigami.Units.mediumSpacing

                            Kirigami.Icon {
                                source: "bluetooth"
                                Layout.preferredWidth: Kirigami.Units.gridUnit
                                Layout.preferredHeight: Kirigami.Units.gridUnit
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                PlasmaComponents.Label {
                                    text: modelData.name
                                    font.bold: true
                                }
                                PlasmaComponents.Label {
                                    text: modelData.mac
                                    font.family: "monospace"
                                    font.pixelSize: Kirigami.Units.gridUnit * 0.6
                                    opacity: 0.6
                                }
                            }

                            PlasmaComponents.Button {
                                text: "Pair"
                                icon.name: "network-connect"
                                onClicked: backend.pairBluetoothDevice(modelData.mac)
                            }

                            PlasmaComponents.Button {
                                icon.name: "edit-clear"
                                flat: true
                                onClicked: backend.clearBluetoothCache(modelData.mac)
                                Controls.ToolTip.visible: hovered
                                Controls.ToolTip.text: "Clear Device Cache"
                            }
                        }
                    }

                    Kirigami.PlaceholderMessage {
                        anchors.centerIn: parent
                        text: "No devices found"
                        visible: deviceList.count === 0
                        icon.name: "bluetooth"
                        explanation: "Click 'Scan for Devices' to begin discovery."
                    }
                }
            }

            Kirigami.Separator { Layout.fillHeight: true }

            // Live Monitor
            ColumnLayout {
                Layout.preferredWidth: parent.width * 0.4
                Layout.fillHeight: true

                Kirigami.Heading {
                    text: "Live Monitor"
                    level: 3
                    Layout.margins: Kirigami.Units.smallSpacing
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Kirigami.Theme.alternateBackgroundColor
                    border.color: Kirigami.Theme.focusColor

                    PlasmaComponents.ScrollView {
                        anchors.fill: parent
                        anchors.margins: 1

                        PlasmaComponents.TextArea {
                            id: bluetoothLogs
                            readOnly: true
                            font.family: "Monospace"
                            font.pixelSize: Kirigami.Units.gridUnit * 0.6
                            color: Kirigami.Theme.textColor
                            wrapMode: Text.Wrap
                            background: null

                            onTextChanged: {
                                if (length > 0) cursorPosition = length - 1
                            }
                        }
                    }
                }
            }
        }
    }

    PlasmaComponents.Dialog {
        id: resetDialog
        title: "Reset Bluetooth Stack"
        standardButtons: PlasmaComponents.Dialog.Ok | PlasmaComponents.Dialog.Cancel
        modal: true
        anchors.centerIn: parent

        PlasmaComponents.Label {
            text: "This will attempt to restart the Bluetooth service and reload kernel modules. Continue?"
            wrapMode: Text.WordWrap
            width: Kirigami.Units.gridUnit * 15
        }

        onAccepted: backend.applyDiagnosticFix("bluetooth_inactive")
    }

    Connections {
        target: backend
        function onBluetoothLogReceived(message, prefix) {
            bluetoothLogs.append("<font color=\"" + Kirigami.Theme.highlightColor + "\">" + prefix + "</font> " + message)
            if (message.includes("Pairing SM [")) {
                statusMessage.text = message
                statusMessage.type = message.includes("FAIL") ? Kirigami.MessageType.Error : Kirigami.MessageType.Information
            }
        }
        function onBluetoothScanFinished(devices) {
            bluetoothPage.scannedDevices = devices
        }
    }
}
