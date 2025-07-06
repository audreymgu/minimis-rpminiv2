import QtQuick 2.6
import QtMultimedia 5.15
import QtGraphicalEffects 1.0

Item {
    id: root

    property var item
    property bool muted: false

    width: item ? item.width : undefined
    height: item ? item.height : undefined 

    scale: item ? item.scale : 0

    z: item ? item.z - 1 : -1

    visible: item

    Component {
        id: videoComponent

        Video {
            id: video

            anchors.fill: parent
            source: root.item ? root.item.game.assets.videoList[0] || '' : ''
            fillMode: VideoOutput.PreserveAspectCrop
            muted: root.muted
            loops: MediaPlayer.Infinite
            autoPlay: true
            volume: api.memory.get('settings.cardTheme.previewVolume')

            Connections {
                target: Qt.application
                onStateChanged: Qt.application.state == Qt.ApplicationSuspended ? video.pause() : video.play()
            }
        }
    }

    Rectangle {
        id: loaderContainer

        anchors.fill: parent
        color: 'black'

        Loader {
            id: loader

            anchors.fill: parent
            asynchronous: true

            sourceComponent: videoComponent

            active: videoPreviewDebouncer.enabled && !videoPreviewDebouncer.running && root.visible && root.item && root.item.game.assets.videoList.length > 0
        }

        radius: vpx(api.memory.get('settings.cardTheme.cornerRadius'))
        visible: loader.active
    }
}