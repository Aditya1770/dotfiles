pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool enabled: false
    property int temperature: 4000

    function toggle() {
        enabled = !enabled
    }

    function setTemperature(value) {
        temperature = Math.round(Math.max(1000, Math.min(6500, value)))
        if (enabled)
            Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", String(temperature)])
    }

    Process {
        id: sunset
        command: ["hyprsunset", "-t", String(root.temperature)]
        running: root.enabled
        onExited: (exitCode, exitStatus) => {
            if (root.enabled && exitCode !== 0)
                root.enabled = false
        }
    }
}
