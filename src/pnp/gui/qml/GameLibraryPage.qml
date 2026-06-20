import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: gameLibraryPage
    title: "Steam Game Library"

    Component.onCompleted: backend.refreshSteamGames()

    actions: [
        Kirigami.Action {
            text: "Refresh Library"
            icon.name: "view-refresh"
            onTriggered: backend.refreshSteamGames()
        }
    ]

    Kirigami.CardsListView {
        id: gameList
        anchors.fill: parent
        model: backend.steamGames

        delegate: Kirigami.AbstractCard {
            contentItem: RowLayout {
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Icon {
                    source: "applications-games"
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 2
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Kirigami.Heading {
                        text: modelData.name
                        level: 2
                        Layout.fillWidth: true
                    }
                    Controls.Label {
                        text: "AppID: " + modelData.appid
                        opacity: 0.6
                        font.family: "monospace"
                    }
                }

                Rectangle {
                    width: Kirigami.Units.gridUnit * 6
                    height: Kirigami.Units.gridUnit * 1.5
                    radius: height / 2
                    color: Kirigami.Theme.positiveTextColor
                    visible: modelData.applied
                    Controls.Label {
                        anchors.centerIn: parent
                        text: "Profile Applied"
                        color: "white"
                        font.pixelSize: Kirigami.Units.gridUnit * 0.6
                        font.bold: true
                    }
                }

                Controls.Button {
                    text: modelData.applied ? "Update Profile" : "Download Profile"
                    icon.name: "download"
                    onClicked: backend.downloadGameProfile(modelData.appid)
                }
            }
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            visible: gameList.count === 0
            icon.name: "applications-games"
            text: "No Steam Games Found"
            helpfulText: "Ensure Steam is installed and you have games in your library."
        }
    }
}
