import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.plasma.components 3.0 as PlasmaComponents
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

        delegate: Kirigami.Card {
            banner.title: modelData.name

            contentItem: ColumnLayout {
                PlasmaComponents.Label {
                    text: "AppID: " + modelData.appid
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                }
            }

            actions: [
                Kirigami.Action {
                    text: modelData.applied ? "Update Profile" : "Download Profile"
                    icon.name: "download"
                    onTriggered: backend.downloadGameProfile(modelData.appid)
                }
            ]

            header: Kirigami.InlineMessage {
                visible: modelData.applied
                type: Kirigami.MessageType.Positive
                text: "Profile Applied"
            }
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            visible: gameList.count === 0
            icon.name: "applications-games"
            text: "No Steam Games Found"
            explanation: "Ensure Steam is installed and you have games in your library."
        }
    }
}
