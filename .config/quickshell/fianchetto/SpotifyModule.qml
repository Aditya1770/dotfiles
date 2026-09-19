import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Widgets

Pill {
    id: root
    property bool compact: false

    function findSpotify() {
        const players = Mpris.players.values
        for (let i = 0; i < players.length; i++) {
            const key = ((players[i].identity || "") + " " + (players[i].dbusName || "")).toLowerCase()
            if (key.includes("spotify")) return players[i]
        }
        return null
    }

    readonly property var player: findSpotify()
    function formatTime(seconds) {
        const safe = Math.max(0, Number(seconds) || 0)
        const minutes = Math.floor(safe / 60)
        const remainder = Math.floor(safe % 60)
        return minutes + ":" + (remainder < 10 ? "0" : "") + remainder
    }
    function seekFromRatio(ratio) {
        if (player && player.canSeek && player.positionSupported && player.length > 0)
            player.position = Math.max(0, Math.min(player.length, ratio * player.length))
    }
    visible: player !== null
    implicitWidth: compact ? Theme.pillHeight : Math.min(350, mediaRow.implicitWidth + horizontalPadding * 2)
    horizontalPadding: compact ? 6 : 10

    RowLayout {
        id: mediaRow
        AnimatedEqualizer {
            playing: root.player && root.player.isPlaying
            accent: Theme.pastelMint
            vertical: root.compact
        }
        BarText {
            visible: !root.compact
            Layout.maximumWidth: 300
            elide: Text.ElideRight
            text: root.player ? ((root.player.trackArtist || "Unknown") + " – " + (root.player.trackTitle || "Unknown")) : ""
        }
    }
    onClicked: button => {
        if (button === Qt.RightButton) {
            if (root.player && root.player.canTogglePlaying) root.player.togglePlaying()
        } else if (button === Qt.LeftButton) {
            popup.visible = !popup.visible
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: popup.visible && root.player && root.player.isPlaying
        onTriggered: if (root.player && root.player.positionSupported) root.player.positionChanged()
    }

    ModulePopup {
        id: popup
        anchorItem: root
        implicitWidth: 420
        implicitHeight: 104

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 9
            anchors.rightMargin: 9
            anchors.topMargin: 6
            anchors.bottomMargin: 6
            spacing: 10

            ClippingRectangle {
                Layout.preferredWidth: 82
                Layout.preferredHeight: 82
                radius: 11
                color: Theme.background

                Image {
                    anchors.fill: parent
                    source: root.player ? root.player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                BarText { Layout.fillWidth: true; text: root.player ? (root.player.trackTitle || "Unknown track") : ""; elide: Text.ElideRight }
                BarText { Layout.fillWidth: true; text: root.player ? (root.player.trackArtist || "Unknown artist") : ""; color: Theme.muted; elide: Text.ElideRight }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 7
                    BarText { text: root.formatTime(root.player ? root.player.position : 0); color: Theme.muted; font.pixelSize: 10 }
                    Rectangle {
                        id: progressTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 8
                        radius: 4
                        color: Theme.border
                        readonly property real progress: root.player && root.player.length > 0
                            ? Math.max(0, Math.min(1, root.player.position / root.player.length)) : 0
                        Rectangle {
                            width: parent.width * parent.progress
                            height: parent.height
                            radius: parent.radius
                            color: Theme.blue
                            Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: event => root.seekFromRatio(event.x / width)
                            onPositionChanged: event => { if (pressed) root.seekFromRatio(event.x / width) }
                        }
                    }
                    BarText { text: root.formatTime(root.player ? root.player.length : 0); color: Theme.muted; font.pixelSize: 10 }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 18
                    IconText {
                        text: "󰒮"
                        MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: if (root.player && root.player.canGoPrevious) root.player.previous() }
                    }
                    IconText {
                        text: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
                        font.pixelSize: 20
                        MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: if (root.player && root.player.canTogglePlaying) root.player.togglePlaying() }
                    }
                    IconText {
                        text: "󰒭"
                        MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: if (root.player && root.player.canGoNext) root.player.next() }
                    }
                }
            }
        }
    }
}
