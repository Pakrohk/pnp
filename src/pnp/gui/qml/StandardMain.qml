import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Controls.ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 768
    title: "PNP – PS NOT PS (Standard Mode)"

    Material.theme: Material.Dark
    Material.accent: Material.LightBlue

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar for Standard Mode
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 200
            color: "#1A1A1A"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                Controls.Label {
                    text: "PNP"
                    font.pixelSize: 24
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                }

                Repeater {
                    model: [
                        { text: "Monitor", icon: "📺", page: 0 },
                        { text: "Library", icon: "🎮", page: 1 },
                        { text: "Non-Steam", icon: "🚀", page: 2 },
                        { text: "Bluetooth", icon: "📡", page: 3 },
                        { text: "Tester", icon: "🎮", page: 4 },
                        { text: "Diags", icon: "🔍", page: 5 },
                        { text: "Settings", icon: "⚙️", page: 6 },
                        { text: "Logs", icon: "📜", page: 7 }
                    ]

                    Controls.ItemDelegate {
                        Layout.fillWidth: true
                        text: modelData.icon + " " + modelData.text
                        highlighted: stackLayout.currentIndex === modelData.page
                        onClicked: stackLayout.currentIndex = modelData.page
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            width: 1
            color: "#333"
        }

        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true

            StandardMonitorPage {}
            StandardGameLibraryPage {}
            StandardNonSteamPage {}
            StandardBluetoothPage {}
            StandardTesterPage {}
            StandardDiagnosticPage {}
            StandardSettingsPage {}
            StandardLogPage {}
        }
    }

    // Simple Toast Component
    Item {
        id: toast
        property string message: ""
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        width: toastLabel.width + 40
        height: 40
        opacity: 0
        visible: opacity > 0

        Rectangle {
            anchors.fill: parent
            color: "#333"
            radius: 20
            border.color: "#555"
        }

        Controls.Label {
            id: toastLabel
            anchors.centerIn: parent
            text: toast.message
            color: "white"
        }

        function show(msg) {
            message = msg
            toastAnim.restart()
        }

        SequentialAnimation on opacity {
            id: toastAnim
            NumberAnimation { to: 1; duration: 200 }
            PauseAnimation { duration: 3000 }
            NumberAnimation { to: 0; duration: 500 }
        }
    }

    // Compatibility for backend signals
    Connections {
        target: backend
        function onShowToast(message) {
            toast.show(message)
        }
    }
}
