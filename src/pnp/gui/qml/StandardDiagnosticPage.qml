import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Controls.Page {
    id: diagnosticPage

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        RowLayout {
            width: parent.width
            ColumnLayout {
                Controls.Label {
                    text: "System Diagnostics"
                    font.pixelSize: 24
                    font.bold: true
                }
                Controls.Label {
                    text: "Identify and resolve configuration conflicts for Steam Input."
                    font.pixelSize: 14
                    opacity: 0.7
                }
            }
            Item { Layout.fillWidth: true }
            RowLayout {
                spacing: 10
                Controls.Button {
                    text: "🔍 Run Scan"
                    highlighted: true
                    onClicked: backend.runDiagnostics()
                }
                Controls.Button {
                    text: "🚀 Fix All"
                    visible: backend.diagnosticIssues.length > 0
                    onClicked: backend.fixAllIssues()
                }
                Controls.Button {
                    text: "🔄 Revert"
                    onClicked: backend.revertSystemChanges()
                }
            }
        }

        ListView {
            id: diagList
            property string placeholderText: "No issues detected. Your system is correctly configured for PNP."
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: backend.diagnosticIssues
            spacing: 15
            clip: true

            delegate: Controls.Frame {
                width: diagList.width
                padding: 15

                background: Rectangle {
                    color: modelData.severity === "critical" ? "#442222" :
                           modelData.severity === "warning" ? "#443322" : "#2A2A2A"
                    radius: 8
                    border.color: modelData.severity === "critical" ? "#FF5555" :
                                  modelData.severity === "warning" ? "#FFB86C" : "#555"
                }

                RowLayout {
                    width: parent.width
                    spacing: 15

                    Controls.Label {
                        text: modelData.severity === "critical" ? "🔴" :
                              modelData.severity === "warning" ? "🟠" : "🔵"
                        font.pixelSize: 24
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Controls.Label {
                            text: modelData.title
                            font.bold: true
                            font.pixelSize: 16
                        }
                        Controls.Label {
                            text: modelData.description
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            opacity: 0.8
                        }
                    }

                    Controls.Button {
                        text: "🔧 Fix Now"
                        onClicked: {
                            diagMessageDialog.issueId = modelData.id
                            diagMessageDialog.open()
                        }
                    }
                }
            }

            Controls.Label {
                anchors.centerIn: parent
                visible: diagList.count === 0
                text: diagList.placeholderText
                font.italic: true
                opacity: 0.5
            }
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
            spacing: 10
            Controls.Label {
                text: "Applying this fix requires administrative privileges."
                font.bold: true
            }
            Controls.Label {
                text: "A system dialog will ask for your password to authorize the change."
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 300
            }
        }

        onAccepted: backend.applyDiagnosticFix(issueId)
    }

    Connections {
        target: backend
        function onFixCompleted(success, message) {
            toast.show(success ? "Fix applied successfully!" : "Failed to apply fix: " + message)
        }
    }
}
