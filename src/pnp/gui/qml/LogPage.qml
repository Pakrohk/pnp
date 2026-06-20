import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: logPage
    title: "System Logs"

    actions: [
        Kirigami.Action {
            text: "Copy All"
            icon.name: "edit-copy"
            onTriggered: {
                logArea.selectAll()
                logArea.copy()
                logArea.deselect()
                root.showPassiveNotification("Logs copied to clipboard")
            }
        },
        Kirigami.Action {
            text: "Clear Logs"
            icon.name: "edit-clear-all"
            onTriggered: backend.clearLogs()
        }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.smallSpacing

            Controls.ComboBox {
                id: levelFilter
                model: ["All", "INFO", "WARNING", "ERROR", "DEBUG"]
                onCurrentTextChanged: backend.setLogLevelFilter(currentText)
                Layout.preferredWidth: Kirigami.Units.gridUnit * 6
            }

            Controls.ComboBox {
                id: moduleFilter
                model: ["All", "USB", "Steam", "Mapping", "System", "GUI"]
                onCurrentTextChanged: backend.setLogModuleFilter(currentText)
                Layout.preferredWidth: Kirigami.Units.gridUnit * 6
            }

            Item { Layout.fillWidth: true }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        Controls.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollBar.vertical.policy: Controls.ScrollBar.AlwaysOn

            Controls.TextArea {
                id: logArea
                readOnly: true
                text: backend.logs
                font.family: "Monospace"
                font.pixelSize: Kirigami.Units.gridUnit * 0.7
                color: Kirigami.Theme.textColor
                wrapMode: Text.Wrap
                background: Rectangle {
                    color: Kirigami.Theme.backgroundColor
                }

                onTextChanged: {
                    if (logArea.length > 0) {
                        cursorPosition = logArea.length - 1
                    }
                }
            }
        }
    }
}
