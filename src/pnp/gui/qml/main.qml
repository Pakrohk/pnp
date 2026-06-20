import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: root
    width: 1024
    height: 768
    title: "PNP – PS NOT PS"

    pageStack.initialPage: Kirigami.PagePool.loadPage("MonitorPage.qml")

    globalDrawer: Kirigami.GlobalDrawer {
        title: "PNP"
        iconSource: "applications-games"

        actions: [
            Kirigami.PagePoolAction {
                text: "Monitor"
                icon.name: "gamepad"
                page: "MonitorPage.qml"
            },
            Kirigami.PagePoolAction {
                text: "Game Library"
                icon.name: "games-config"
                page: "GameLibraryPage.qml"
            },
            Kirigami.PagePoolAction {
                text: "Non-Steam Games"
                icon.name: "applications-other"
                page: "NonSteamPage.qml"
            },
            Kirigami.PagePoolAction {
                text: "Bluetooth"
                icon.name: "preferences-system-bluetooth"
                page: "BluetoothPage.qml"
            },
            Kirigami.PagePoolAction {
                text: "Input Tester"
                icon.name: "input-gaming"
                page: "TesterPage.qml"
            },
            Kirigami.PagePoolAction {
                text: "Diagnostics"
                icon.name: "tools-report-bug"
                page: "DiagnosticPage.qml"
            },
            Kirigami.PagePoolAction {
                text: "Settings"
                icon.name: "settings-configure"
                page: "SettingsPage.qml"
            },
            Kirigami.PagePoolAction {
                text: "Logs"
                icon.name: "document-view"
                page: "LogPage.qml"
            }
        ]
    }


    // Compatibility function for pages that call window.toast.show()
    property alias toast: toastCompat
    QtObject {
        id: toastCompat
        function show(msg) {
            root.showPassiveNotification(msg)
        }
    }

    Connections {
        target: backend
        function onShowToast(message) {
            root.showPassiveNotification(message)
        }
    }
}
