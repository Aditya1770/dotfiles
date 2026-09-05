import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Widgets

Pill {
    id: root

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
    implicitWidth: Math.min(350, mediaRow.implicitWidth + horizontalPadding * 2)

    RowLayout {
        id: mediaRow
        IconText { text: ""; color: Theme.green }
        BarText {
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
        implicitWidth: 440
        implicitHeight: 126

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.topMargin: 9
            anchors.bottomMargin: 9
            spacing: 12

            ClippingRectangle {
                Layout.preferredWidth: 92
                Layout.preferredHeight: 92
                radius: 12
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
                    WaveProgress {
                        id: progressTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24
                        progress: root.player && root.player.length > 0
                            ? root.player.position / root.player.length : 0
                        accent: Theme.green
                        onSeekRequested: ratio => root.seekFromRatio(ratio)
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
