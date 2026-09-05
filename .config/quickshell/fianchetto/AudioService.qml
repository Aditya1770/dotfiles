pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property real volume: 0
    property bool muted: false
    property real pendingVolume: 0
    property bool initialized: false

    function setVolume(value) {
        const clamped = Math.max(0, Math.min(1, value))
        volume = clamped
        pendingVolume = clamped
        OsdState.show("volume", clamped, muted)
        writeTimer.restart()
    }

    function toggleMute() {
        muted = !muted
        OsdState.show("volume", volume, muted)
        muteSetter.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        muteSetter.running = true
    }

    function readOutput(data) {
        const match = data.match(/Volume:\s+([0-9.]+)/)
        if (match) {
            const nextVolume = Number(match[1])
            const nextMuted = data.includes("MUTED")
            if (initialized && (Math.abs(nextVolume - volume) > 0.005 || nextMuted !== muted))
                OsdState.show("volume", nextVolume, nextMuted)
            volume = nextVolume
            muted = nextMuted
            initialized = true
        }
    }

    Process {
        id: reader
        running: true
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser { onRead: data => root.readOutput(data) }
    }
    Process { id: setter; onExited: reader.running = true }
    Process { id: muteSetter; onExited: reader.running = true }
    Timer {
        id: writeTimer
        interval: 40
        onTriggered: {
            if (setter.running) { restart(); return }
            setter.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", root.pendingVolume.toFixed(2)]
            setter.running = true
        }
    }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: if (!reader.running) reader.running = true }
}
