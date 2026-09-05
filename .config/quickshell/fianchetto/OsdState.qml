pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    property bool shown: false
    property string kind: "volume"
    property real value: 0
    property bool muted: false

    function show(nextKind, nextValue, nextMuted) {
        kind = nextKind
        value = Math.max(0, Math.min(1, nextValue))
        muted = Boolean(nextMuted)
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
