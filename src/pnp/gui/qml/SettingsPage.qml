import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: settingsPage
    title: "Settings"

    Kirigami.FormLayout {
        id: form

        Kirigami.Heading {
            text: "Steam Integration"
            level: 2
            Kirigami.FormData.isSection: true
        }

        PlasmaComponents.Switch {
            Kirigami.FormData.label: "Steam Conflict Prevention"
            Kirigami.FormData.buddy: this
            checked: backend.config.steam_handover_enabled
            onToggled: backend.updateConfig("steam_handover_enabled", checked)
            text: "Pause emulation when Steam is running"
        }

        RowLayout {
            Kirigami.FormData.label: "Actions"
            PlasmaComponents.Button {
                text: "Connect to Steam"
                icon.name: "network-connect"
                onClicked: backend.connectToSteam()
            }
            PlasmaComponents.Button {
                text: "Sync with Steam"
                icon.name: "view-refresh"
                onClicked: backend.syncWithSteam()
            }
        }

        Kirigami.Heading {
            text: "General Settings"
            level: 2
            Kirigami.FormData.isSection: true
        }

        PlasmaComponents.TextField {
            Kirigami.FormData.label: "Rumble Gain"
            text: backend.config.rumble_gain
            onEditingFinished: backend.updateConfig("rumble_gain", text)
            placeholderText: "e.g. 1.0"
        }

        Kirigami.Heading {
            text: "System Service"
            level: 2
            Kirigami.FormData.isSection: true
        }

        PlasmaComponents.Switch {
            Kirigami.FormData.label: "Background Service"
            checked: backend.serviceActive
            onToggled: backend.toggleService(checked)
            text: backend.serviceActive ? "Service is Running" : "Service is Stopped"
        }

        Kirigami.Heading {
            text: "Global Mapping"
            level: 2
            Kirigami.FormData.isSection: true
        }

        Repeater {
            model: [
                { label: "Axis Map", key: "axismap", value: backend.config.mapping.axismap },
                { label: "Absolute Map", key: "absmap", value: backend.config.mapping.absmap },
                { label: "Key Map", key: "keymap", value: backend.config.mapping.keymap }
            ]
            PlasmaComponents.TextField {
                Kirigami.FormData.label: modelData.label
                Layout.fillWidth: true
                text: modelData.value
                onEditingFinished: backend.updateMapping(modelData.key, text)
            }
        }

        Kirigami.Separator { Kirigami.FormData.isSection: true }

        PlasmaComponents.Button {
            text: "Save & Apply All"
            icon.name: "document-save"
            highlighted: true
            Layout.fillWidth: true
            onClicked: {
                backend.saveConfig()
                root.showPassiveNotification("Settings saved and applied.")
            }
        }
    }
}
