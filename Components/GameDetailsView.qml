/*
    GameDetailsView.qml

    This QML component defines the main view for displaying game details and associated media in the Minimis theme for Pegasus Frontend.

    Structure and Features:
    -----------------------
    - Imports various Qt modules for UI, multimedia, layouts, and model handling.
    - Exposes properties for scaling, animation, and game data, all sourced from an external API memory object.
    - Dynamically updates the displayed media list when the selected game changes.
    - Contains a MediaView for displaying game media (videos, screenshots, backgrounds).
    - Uses a ListModel and SortFilterProxyModel to manage and filter the display of game details and media sections.
    - Employs a DelegateChooser to switch between two main delegate types:
        - 'gameDetails': Shows game metadata and action buttons, with keyboard interaction to toggle details.
        - 'media': Shows a horizontally scrolling list of media assets, with keyboard navigation and activation.
    - The main ListView at the bottom of the component allows navigation between the details and media sections, with animated opacity and highlight behaviors.
    - Focus management ensures intuitive navigation between sections and within media items.
    - Customizable margins and styling are applied based on user settings.

    Key Properties:
    ---------------
    - `game`: The currently selected game object.
    - `gameMedia`: Array of media assets associated with the current game.
    - `scaleEnabled`, `scaleSelected`, `scaleUnselected`: Control scaling behavior for UI elements.
    - `animationEnabled`, `animationArtScaleDuration`: Control animation settings for art scaling.

    Signals and Handlers:
    ---------------------
    - `onGameChanged`: Updates the media list and resets the media view index when the game changes.
    - `onFocusChanged`: Resets the list view index when focus changes.
    - Keyboard handlers for toggling details and navigating media.

    Dependencies:
    -------------
    - Relies on external components: `GameMetadata`, `GameDetailsButtons`, `MediaView`, `MediaDelegate`, `DelegateBorder`, and `DropShadowLow`.
    - Uses API memory for user settings and theme customization.

    Usage:
    ------
    - Intended as a focused, interactive view for browsing and inspecting game details and media within the Pegasus Frontend UI.
*/

import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import QtQuick.Layouts 1.15
import SortFilterProxyModel 0.2
import Qt.labs.qmlmodels 1.0

FocusScope {
    id: root

    readonly property bool scaleEnabled: api.memory.get('settings.cardTheme.scaleEnabled')
    readonly property real scaleSelected: api.memory.get('settings.cardTheme.scaleSelected')
    readonly property real scaleUnselected: api.memory.get('settings.cardTheme.scale')

    readonly property bool animationEnabled: api.memory.get('settings.cardTheme.animationEnabled')
    readonly property int animationArtScaleDuration: api.memory.get('settings.cardTheme.animationArtScaleSpeed')

    anchors.fill: parent

    property var game
    property var gameMedia: [];

    onGameChanged: {
        const media = [];

        if (game) {
            game.assets.videoList.forEach(v => media.push(v));
            game.assets.screenshotList.forEach(v => media.push(v));
            game.assets.backgroundList.forEach(v => media.push(v));
        }

        gameMedia = media;
        listView.currentIndex = 0;
    }

    onFocusChanged: {
        listView.currentIndex = 0;
    }

    MediaView {
        id: mediaView
        anchors.fill: root

        media: gameMedia

        onClosed: {
            listView.focus = true
            mediaListView.currentIndex = mediaView.currentIndex
        }
    }

    ListModel {
        id: listModel

        ListElement { type: 'gameDetails' }
        // ListElement { type: 'media' }
    }

    SortFilterProxyModel {
        id: proxyModel
        filters: ExpressionFilter {
            expression: {
                gameMedia.length;
                return type === 'gameDetails' || (type === 'media' && gameMedia.length > 0);
            }
        }

        sourceModel: listModel
    }

    DelegateChooser {
        id: listViewDelegate

        role: 'type'

        DelegateChoice {
            roleValue: 'gameDetails'

            FocusScope {
                id: gameDetails

                width: listView.width
                height: listView.height

                readonly property bool selected: root.focus && ListView.isCurrentItem
                Item {
                    anchors.fill: parent

                    GameMetadata {
                        id: gameMetadata
                        anchors { left: parent.left; right: parent.right; top: parent.top; }
                        game: root.game
                        height: parent.height * 0.75
                        width: parent.width
                    }

                    GameDetailsButtons {
                        id: buttons

                        game: root.game

                        focus: gameDetails.selected

                        Layout.fillWidth: true
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; }
                        // ADD BOTTOM MARGIN SETTING
                        anchors.bottomMargin: vpx(api.memory.get('settings.general.leftMargin'))
                    }
                }


                Keys.onPressed: {
                    if (api.keys.isDetails(event) && !event.isAutoRepeat) {
                        if (gameDetails.selected) {
                            event.accepted = true;
                            gameMetadata.showDetails = !gameMetadata.showDetails;

                            sfxAccept.play();
                        }
                    }
                }
            }
        }

        DelegateChoice {
            roleValue: 'media'

            FocusScope {
                id: mediaScope

                width: root.width
                height: vpx(150)

                Column {
                    anchors.fill: parent
                    spacing: vpx(8) * uiScale

                    Text {
                        text: 'Media'

                        font.family: subtitleFont.name
                        // font.pixelSize: vpx(18) * uiScale
                        font.pixelSize: vpx(32) * uiScale

                        color: api.memory.get('settings.general.textColor')
                        opacity: root.focus ? 1 : 0.2

                        layer.enabled: true
                        layer.effect: DropShadowLow { cached: true }
                    }

                    ListView {
                        id: mediaListView

                        DelegateBorder {
                            parent: mediaListView.contentItem
                            currentItem: mediaListView.currentItem

                            visible: mediaScope.focus
                        }

                        width: root.width;
                        height: root.height;

                        focus: mediaScope.focus
                        orientation: ListView.Horizontal

                        model: gameMedia

                        highlightResizeDuration: 0
                        highlightMoveDuration: 300
                        highlightRangeMode: ListView.ApplyRange
                        highlightFollowsCurrentItem: true

                        displayMarginBeginning: width * 2
                        displayMarginEnd: width * 2

                        Keys.onLeftPressed: { sfxNav.play(); event.accepted = false; }
                        Keys.onRightPressed: { sfxNav.play(); event.accepted = false; }

                        delegate: MediaDelegate {
                            asset: modelData
                            height: vpx(200)

                            onActivated: {
                                mediaView.currentIndex = mediaListView.currentIndex
                                mediaView.focus = true;
                            }
                        }
                    }
                }
            }
        }
    }

    ListView {
        id: listView
        

        focus: true
        opacity: focus ? 1 : 0
        Behavior on opacity { OpacityAnimator { duration: 200 } }

        anchors.fill: parent

        anchors.leftMargin: vpx(api.memory.get('settings.general.leftMargin'));
        anchors.rightMargin: vpx(api.memory.get('settings.general.rightMargin'));
        anchors.bottomMargin: proxyModel.count > 1 ? vpx(75) : vpx(0)

        // displayMarginBeginning: root.height
        // displayMarginEnd: root.height

        preferredHighlightBegin: 0
        preferredHighlightEnd: vpx(175)

        highlightResizeDuration: 0
        highlightMoveDuration: 300
        highlightRangeMode: ListView.StrictlyEnforceRange


        model: proxyModel
        delegate: listViewDelegate
    }
}