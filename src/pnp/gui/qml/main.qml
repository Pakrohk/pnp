import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: root
    width: 1024
    height: 768
    title: "PNP – PS NOT PS"

    globalDrawer: Kirigami.GlobalDrawer {
        title: "PNP"
        iconSource: "applications-games"

        actions: [
            Kirigami.Action {
                text: "Monitor"
                iconName: "gamepad"
                onTriggered: pageStack.replace(monitorPage)
            },
            Kirigami.Action {
                text: "Game Library"
                iconName: "games-config"
                onTriggered: pageStack.replace(libraryPage)
            },
            Kirigami.Action {
                text: "Non-Steam Games"
                iconName: "applications-other"
                onTriggered: pageStack.replace(nonSteamPage)
            },
            Kirigami.Action {
                text: "Bluetooth"
                iconName: "preferences-system-bluetooth"
                onTriggered: pageStack.replace(bluetoothPage)
            },
            Kirigami.Action {
                text: "Input Tester"
                iconName: "input-gaming"
                onTriggered: pageStack.replace(testerPage)
            },
            Kirigami.Action {
                text: "Diagnostics"
                iconName: "tools-report-bug"
                onTriggered: pageStack.replace(diagnosticPage)
            },
            Kirigami.Action {
                text: "Settings"
                iconName: "settings-configure"
                onTriggered: pageStack.replace(settingsPage)
            },
            Kirigami.Action {
                text: "Logs"
                iconName: "document-view"
                onTriggered: pageStack.replace(logPage)
            }
        ]
    }

    Component { id: monitorPage; MonitorPage {} }
    Component { id: libraryPage; GameLibraryPage {} }
    Component { id: nonSteamPage; NonSteamPage {} }
    Component { id: bluetoothPage; BluetoothPage {} }
    Component { id: testerPage; TesterPage {} }
    Component { id: diagnosticPage; DiagnosticPage {} }
    Component { id: settingsPage; SettingsPage {} }
    Component { id: logPage; LogPage {} }

    pageStack.initialPage: monitorPage

    // Simple Toast Component using Kirigami.Action if needed or a custom Item
    // Kirigami has its own message mechanisms, but for compatibility:
    Kirigami.OverlaySheet {
        id: toastSheet
        property string message: ""
        Label {
            text: toastSheet.message
            wrapMode: Text.WordWrap
        }
        function show(msg) {
            message = msg
            open()
        }
    }

    // Compatibility function for pages that call window.toast.show()
    property alias toast: toastCompat
    QtObject {
        id: toastCompat
        function show(msg) {
            root.showPassiveNotification(msg)
        }
    }
}
