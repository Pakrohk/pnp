import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: diagnosticPage
    title: "System Diagnostics"

    actions: [
        Kirigami.Action {
            text: "Run Scan"
            icon.name: "view-refresh"
            onTriggered: backend.runDiagnostics()
        },
        Kirigami.Action {
            text: "Fix All"
            icon.name: "tools-check"
            visible: backend.diagnosticIssues.length > 0
            onTriggered: backend.fixAllIssues()
        },
        Kirigami.Action {
            text: "Revert"
            icon.name: "edit-undo"
            onTriggered: backend.revertSystemChanges()
        }
    ]

    Kirigami.CardsListView {
        id: diagList
        anchors.fill: parent
        model: backend.diagnosticIssues

        delegate: Kirigami.AbstractCard {
            contentItem: RowLayout {
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Icon {
                    source: modelData.severity === "critical" ? "error" : "warning"
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5
                    color: modelData.severity === "critical" ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.neutralTextColor
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Kirigami.Heading {
                        text: modelData.title
                        level: 3
                        Layout.fillWidth: true
                    }
                    Controls.Label {
                        text: modelData.description
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        opacity: 0.8
                    }
                }

                Controls.Button {
                    text: "Fix Now"
                    icon.name: "tools-check"
                    onClicked: {
                        diagMessageDialog.issueId = modelData.id
                        diagMessageDialog.open()
                    }
                }
            }
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            visible: diagList.count === 0
            icon.name: "security-high"
            text: "No issues detected"
            helpfulText: "Your system is correctly configured for PNP."
        }
    }

    Controls.Dialog {
        id: diagMessageDialog
        property string issueId: ""
        title: "Administrative Privileges Required"
        standardButtons: Controls.Dialog.Ok | Controls.Dialog.Cancel
        anchors.centerIn: parent
        modal: true

        ColumnLayout {
            spacing: Kirigami.Units.largeSpacing
            Controls.Label {
                text: "Applying this fix requires administrative privileges."
                font.bold: true
            }
            Controls.Label {
                text: "A system dialog will ask for your password to authorize the change."
                wrapMode: Text.WordWrap
                Layout.preferredWidth: Kirigami.Units.gridUnit * 15
            }
        }

        onAccepted: backend.applyDiagnosticFix(issueId)
    }

    Connections {
        target: backend
        function onFixCompleted(success, message) {
            root.showPassiveNotification(success ? "Fix applied successfully!" : "Failed to apply fix: " + message)
        }
    }
}
