import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Controls.Page {
    id: standardPage
    property list<var> scannedDevices: []

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        RowLayout {
            width: parent.width
            ColumnLayout {
                Controls.Label {
                    text: "Bluetooth Management (Standard Mode)"
                    font.pixelSize: 24
                    font.bold: true
                }
                Controls.Label {
                    text: "Kirigami not found. Using basic interface."
                    font.pixelSize: 12
                    opacity: 0.7
                }
            }
            Item { Layout.fillWidth: true }
            RowLayout {
                spacing: 10
                Controls.Button {
                    text: "🔍 Scan"
                    onClicked: backend.scanBluetoothDevices()
                }
                Controls.Button {
                    text: "🔄 Reset Stack"
                    onClicked: resetDialog.open()
                }
            }
        }

        Controls.SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Horizontal

            ListView {
                id: deviceList
                Controls.SplitView.preferredWidth: 300
                model: standardPage.scannedDevices
                clip: true
                spacing: 5
                delegate: Controls.ItemDelegate {
                    width: parent.width
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        ColumnLayout {
                            Layout.fillWidth: true
                            Controls.Label { text: modelData.name; font.bold: true }
                            Controls.Label { text: modelData.mac; font.pixelSize: 10; opacity: 0.6 }
                        }
                        Controls.Button {
                            text: "Pair"
                            onClicked: backend.pairBluetoothDevice(modelData.mac)
                        }
                        Controls.Button {
                            text: "🧹"
                            flat: true
                            onClicked: backend.clearBluetoothCache(modelData.mac)
                        }
                    }
                }
            }

            ColumnLayout {
                Controls.Label { text: "Logs:"; font.bold: true }
                Controls.ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Controls.TextArea {
                        id: logs
                        readOnly: true
                        font.family: "Monospace"
                        font.pixelSize: 10
                        color: "#00FF00"
                        background: Rectangle { color: "#111" }
                        onTextChanged: cursorPosition = text.length
                    }
                }
            }
        }
    }

    Controls.Dialog {
        id: resetDialog
        title: "Reset Stack"
        standardButtons: Controls.Dialog.Ok | Controls.Dialog.Cancel
        onAccepted: backend.applyDiagnosticFix("bluetooth_inactive")
    }

    Connections {
        target: backend
        function onBluetoothLogReceived(message, prefix) {
            logs.append(prefix + " " + message)
        }
        function onBluetoothScanFinished(devices) {
            standardPage.scannedDevices = devices
        }
    }
}
