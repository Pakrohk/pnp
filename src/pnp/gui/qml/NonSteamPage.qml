import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: nonSteamPage
    title: "Non-Steam Games"

    property var selectedGame: null

    Component.onCompleted: backend.refreshNonSteamGames()

    actions: [
        Kirigami.Action {
            text: "Refresh Games"
            icon.name: "view-refresh"
            onTriggered: backend.refreshNonSteamGames()
        },
        Kirigami.Action {
            text: "Select Custom Folder"
            icon.name: "folder-open"
            onTriggered: backend.selectGamesDirectory()
        },
        Kirigami.Action {
            text: "Configure Paths"
            icon.name: "settings-configure"
            onTriggered: settingsDialog.open()
        }
    ]

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left Panel - Game List
        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: Kirigami.Units.gridUnit * 15
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                color: Kirigami.Theme.alternateBackgroundColor

                PlasmaComponents.TextField {
                    id: searchBar
                    anchors.centerIn: parent
                    width: parent.width - Kirigami.Units.largeSpacing * 2
                    placeholderText: "Search games..."
                    leftPadding: Kirigami.Units.gridUnit
                }
            }

            Kirigami.Separator { Layout.fillWidth: true }

            ListView {
                id: gameList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: searchBar.text === "" ? backend.nonSteamGames : backend.nonSteamGames.filter(game => game.title.toLowerCase().includes(searchBar.text.toLowerCase()))
                clip: true
                highlight: Rectangle { color: Kirigami.Theme.highlightColor; opacity: 0.2 }
                currentIndex: -1

                delegate: Kirigami.AbstractListItem {
                    height: Kirigami.Units.gridUnit * 3
                    highlighted: ListView.isCurrentItem

                    onClicked: {
                        gameList.currentIndex = index
                        nonSteamPage.selectedGame = modelData
                    }

                    contentItem: RowLayout {
                        spacing: Kirigami.Units.mediumSpacing
                        Kirigami.Icon {
                            source: modelData.source === "Heroic" ? "applications-games" : "applications-other"
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
                            Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            PlasmaComponents.Label {
                                text: modelData.title
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            PlasmaComponents.Label {
                                text: modelData.source
                                font.pixelSize: Kirigami.Units.gridUnit * 0.6
                                opacity: 0.6
                            }
                        }
                        Kirigami.Icon {
                            source: "emblem-added"
                            visible: modelData.isAdded
                            Layout.preferredWidth: Kirigami.Units.gridUnit
                            Layout.preferredHeight: Kirigami.Units.gridUnit
                            color: Kirigami.Theme.positiveTextColor
                        }
                    }
                }

                Kirigami.PlaceholderMessage {
                    anchors.centerIn: parent
                    visible: gameList.count === 0
                    text: "No games found"
                    icon.name: "search"
                }
            }
        }

        Kirigami.Separator { Layout.fillHeight: true }

        // Right Panel - Game Details
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing
            visible: selectedGame !== null

            Kirigami.Heading {
                text: selectedGame ? selectedGame.title : ""
                level: 1
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Kirigami.FormLayout {
                Layout.fillWidth: true

                PlasmaComponents.Label {
                    Kirigami.FormData.label: "Source:"
                    text: selectedGame ? selectedGame.source : ""
                }

                PlasmaComponents.Label {
                    Kirigami.FormData.label: "Install Directory:"
                    text: selectedGame ? selectedGame.installDir : ""
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                }

                PlasmaComponents.Label {
                    Kirigami.FormData.label: "Executable:"
                    text: selectedGame ? selectedGame.executable : ""
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                spacing: Kirigami.Units.largeSpacing
                PlasmaComponents.Button {
                    text: "Add to Steam & Configure"
                    icon.name: "list-add"
                    highlighted: true
                    enabled: selectedGame && !selectedGame.isAdded
                    onClicked: backend.addNonSteamGame(selectedGame)
                }

                PlasmaComponents.Button {
                    text: "Remove from Steam"
                    icon.name: "list-remove"
                    enabled: selectedGame && selectedGame.isAdded
                    onClicked: backend.removeNonSteamGame(selectedGame.title)
                }
            }
        }

        // Empty State for Right Panel
        Kirigami.PlaceholderMessage {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: selectedGame === null
            text: "Select a game to view details"
            icon.name: "applications-games"
        }
    }

    PlasmaComponents.Dialog {
        id: settingsDialog
        title: "Non-Steam Settings"
        standardButtons: PlasmaComponents.Dialog.Ok | PlasmaComponents.Dialog.Cancel
        modal: true
        anchors.centerIn: parent

        Kirigami.FormLayout {
            PlasmaComponents.TextField {
                id: heroicPath
                Kirigami.FormData.label: "Heroic Games Directory"
                placeholderText: "~/Games/Heroic"
                text: backend.config.heroic_games_dir || ""
                Layout.fillWidth: true
            }

            PlasmaComponents.TextField {
                id: hydraPath
                Kirigami.FormData.label: "Hydra Games Directory"
                placeholderText: "~/Games/Hydra"
                text: backend.config.hydra_games_dir || ""
                Layout.fillWidth: true
            }
        }

        onAccepted: {
            backend.updateConfig("heroic_games_dir", heroicPath.text)
            backend.updateConfig("hydra_games_dir", hydraPath.text)
            backend.saveConfig()
            backend.refreshNonSteamGames()
        }
    }
}
