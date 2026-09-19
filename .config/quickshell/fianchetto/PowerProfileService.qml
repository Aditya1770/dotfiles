pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    property string currentProfile: "balanced"
    property bool changing: false
    property bool initialized: false
    property bool supported: false

    readonly property var availableProfiles: !supported ? [] : UPower.onBattery
        ? ["low-power", "balanced"]
        : ["quiet", "balanced", "balanced-performance", "performance"]

    function label(profile) {
        if (profile === "low-power") return "Eco"
        if (profile === "quiet") return "Quiet"
        if (profile === "balanced-performance") return "Performance"
        if (profile === "performance") return "Turbo"
        return "Balanced"
    }

    function icon(profile) {
        if (profile === "low-power") return "󰌪"
        if (profile === "quiet") return "󰒲"
        if (profile === "balanced-performance") return "󰓅"
        if (profile === "performance") return "󰓅"
        return "󰾅"
    }

    function accent(profile) {
        if (profile === "low-power") return Theme.green
        if (profile === "quiet") return Theme.text
        if (profile === "balanced-performance") return Theme.orange
        if (profile === "performance") return Theme.red
        return Theme.blue
    }

    function observeProfile(profile) {
        if (!profile) return
        if (initialized && profile !== currentProfile)
            OsdState.showProfile(label(profile), icon(profile), accent(profile))
        currentProfile = profile
        initialized = true
    }

    function setProfile(profile) {
        if (!supported || availableProfiles.indexOf(profile) < 0 || setter.running) return
        changing = true
        setter.command = [Quickshell.shellPath("scripts/power-profile.sh"), "set", profile]
        setter.running = true
    }

    Process {
        id: detector
        running: true
        command: [Quickshell.shellPath("scripts/power-profile.sh"), "detect"]
        stdout: StdioCollector {
            onStreamFinished: root.supported = text.trim() === "1"
        }
    }

    Process {
        id: watcher
        running: root.supported
        // Invoke through sh so installs remain reliable even when an archive or
        // copy operation drops the executable bit from the watcher script.
        command: ["/bin/sh", Quickshell.shellPath("scripts/power-profile-watch.sh")]
        stdout: SplitParser { onRead: data => root.observeProfile(data.trim()) }
    }

    Process {
        id: setter
        onExited: root.changing = false
    }
}
