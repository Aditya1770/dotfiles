pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    property bool shown: false
    property string kind: "volume"
    property real value: 0
    property bool muted: false
    property string profileLabel: ""
    property string profileIcon: ""
    property color profileAccent: Theme.blue
    readonly property string levelIcon: {
        if (kind === "brightness") {
            if (value < 0.34) return "󰃞"
            if (value < 0.67) return "󰃟"
            return "󰃠"
        }
        if (muted || value <= 0.001) return "󰖁"
        if (value < 0.34) return "󰕿"
        if (value < 0.67) return "󰖀"
        return "󰕾"
    }
    readonly property string levelIconPath: {
        if (kind === "brightness") {
            if (value < 0.34) return "M12 6.5a5.5 5.5 0 1 0 0 11 5.5 5.5 0 0 0 0-11Z"
            if (value < 0.67) return "M12 6.5a5.5 5.5 0 1 0 0 11 5.5 5.5 0 0 0 0-11ZM12 1a1 1 0 0 1 1 1v1.5a1 1 0 1 1-2 0V2a1 1 0 0 1 1-1Zm0 18.5a1 1 0 0 1 1 1V22a1 1 0 1 1-2 0v-1.5a1 1 0 0 1 1-1ZM1 12a1 1 0 0 1 1-1h1.5a1 1 0 1 1 0 2H2a1 1 0 0 1-1-1Zm18.5 0a1 1 0 0 1 1-1H22a1 1 0 1 1 0 2h-1.5a1 1 0 0 1-1-1Z"
            return "M12 6.5a5.5 5.5 0 1 0 0 11 5.5 5.5 0 0 0 0-11ZM12 1a1 1 0 0 1 1 1v1.5a1 1 0 1 1-2 0V2a1 1 0 0 1 1-1Zm0 18.5a1 1 0 0 1 1 1V22a1 1 0 1 1-2 0v-1.5a1 1 0 0 1 1-1ZM4.22 4.22a1 1 0 0 1 1.41 0l1.06 1.06a1 1 0 1 1-1.41 1.41L4.22 5.63a1 1 0 0 1 0-1.41Zm12.6 12.6a1 1 0 0 1 1.41 0l1.06 1.06a1 1 0 0 1-1.41 1.41l-1.06-1.06a1 1 0 0 1 0-1.41ZM1 12a1 1 0 0 1 1-1h1.5a1 1 0 1 1 0 2H2a1 1 0 0 1-1-1Zm18.5 0a1 1 0 0 1 1-1H22a1 1 0 1 1 0 2h-1.5a1 1 0 0 1-1-1ZM4.22 19.78a1 1 0 0 1 0-1.41l1.06-1.06a1 1 0 1 1 1.41 1.41l-1.06 1.06a1 1 0 0 1-1.41 0Zm12.6-12.6a1 1 0 0 1 0-1.41l1.06-1.06a1 1 0 1 1 1.41 1.41l-1.06 1.06a1 1 0 0 1-1.41 0Z"
        }
        if (muted || value <= 0.001) return "M7 9v6h4l5 5V4l-5 5H7z"
        if (value < 0.5) return "M18.5 12c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM5 9v6h4l5 5V4L9 9H5z"
        return "M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z"
    }

    function show(nextKind, nextValue, nextMuted) {
        kind = nextKind
        value = Math.max(0, Math.min(1, nextValue))
        muted = Boolean(nextMuted)
        shown = true
        hideTimer.restart()
    }

    function showProfile(label, icon, accent) {
        kind = "profile"
        profileLabel = label
        profileIcon = icon
        profileAccent = accent
        shown = true
        hideTimer.restart()
    }

    property Timer hideTimer: Timer {
        interval: 1500
        onTriggered: root.shown = false
    }

    property IpcHandler ipc: IpcHandler {
        target: "osd"
        function volumeUp(): void { AudioService.setVolume(AudioService.volume + 0.05) }
        function volumeDown(): void { AudioService.setVolume(AudioService.volume - 0.05) }
        function volumeMute(): void { AudioService.toggleMute() }
        function brightnessUp(): void { BrightnessService.setBrightness(BrightnessService.brightness + 0.05) }
        function brightnessDown(): void { BrightnessService.setBrightness(BrightnessService.brightness - 0.05) }
    }
}
