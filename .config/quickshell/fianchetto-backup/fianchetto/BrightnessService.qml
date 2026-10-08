pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property real brightness: 0
    property real pendingBrightness: 0
    property bool initialized: false

    function setBrightness(value) {
        const clamped = Math.max(0.01, Math.min(1, value))
        brightness = clamped
        pendingBrightness = clamped
        OsdState.show("brightness", clamped, false)
        writeTimer.restart()
    }

    function readOutput(data) {
        const fields = data.trim().split(",")
        if (fields.length >= 4) {
            const percentage = Number(fields[3].replace("%", ""))
            if (!isNaN(percentage)) {
                const nextBrightness = percentage / 100
                if (initialized && Math.abs(nextBrightness - brightness) > 0.005)
                    OsdState.show("brightness", nextBrightness, false)
                brightness = nextBrightness
                initialized = true
            }
        }
    }

    Process {
        id: reader
        running: true
        command: ["brightnessctl", "-c", "backlight", "--machine-readable", "info"]
        stdout: SplitParser { onRead: data => root.readOutput(data) }
    }
    Process { id: setter; onExited: reader.running = true }
    Timer {
        id: writeTimer
        interval: 40
        onTriggered: {
            if (setter.running) { restart(); return }
            setter.command = ["brightnessctl", "-c", "backlight", "set", Math.round(root.pendingBrightness * 100) + "%"]
            setter.running = true
        }
    }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: if (!reader.running && !setter.running) reader.running = true }
}
