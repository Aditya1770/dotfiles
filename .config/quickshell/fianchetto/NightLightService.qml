pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property bool enabled: ShellSettings.nightLightEnabled
    readonly property int temperature: ShellSettings.nightLightTemperature

    function toggle() {
        ShellSettings.nightLightEnabled = !enabled
    }

    function setTemperature(value) {
        ShellSettings.nightLightTemperature = Math.round(Math.max(1000, Math.min(6500, value)))
        if (enabled)
            Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", String(temperature)])
    }

    Process {
        id: sunset
        command: ["hyprsunset", "-t", String(root.temperature)]
        running: root.enabled
        onExited: (exitCode, exitStatus) => {
            if (root.enabled && exitCode !== 0)
                ShellSettings.nightLightEnabled = false
        }
    }
}
