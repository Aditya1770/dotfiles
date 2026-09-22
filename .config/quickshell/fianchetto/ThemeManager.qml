pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var themes: []
    property string error: ""
    property string matugenStatus: ""
    property bool installingMatugen: false
    property bool syncingApps: false
    property bool syncAgain: false
    property string integrationStatus: ""
    property bool watching: false

    function refresh() {
        if (!scan.running) scan.running = true
    }

    function applyTheme(path) {
        if (!path) return
        ShellSettings.themeFile = path
        ShellSettings.scheme = "custom"
    }

    function chooseFile() {
        picker.running = false
        picker.running = true
    }

    function installMatugen() {
        if (installingMatugen) return
        matugenStatus = "Installing…"
        matugenInstaller.running = true
    }

    function scheduleIntegrationSync() {
        integrationTimer.restart()
    }

    function syncIntegrations() {
        if (syncingApps) {
            syncAgain = true
            return
        }
        if (!ShellSettings.syncKittyTheme && !ShellSettings.syncHyprlandTheme
                && !ShellSettings.syncSpicetifyTheme) {
            integrationStatus = "Enable an application first"
            return
        }
        integrationProcess.command = [
            "python3", Quickshell.shellPath("scripts/sync-app-themes.py"),
            "--scheme", ShellSettings.scheme,
            "--background", Theme.background.toString(),
            "--surface", Theme.surfaceHover.toString(),
            "--border", Theme.border.toString(),
            "--text", Theme.text.toString(),
            "--muted", Theme.muted.toString(),
            "--accent", Theme.blue.toString(),
            "--red", Theme.pastelPowerRed.toString(),
            "--kitty", ShellSettings.syncKittyTheme ? "1" : "0",
            "--hyprland", ShellSettings.syncHyprlandTheme ? "1" : "0",
            "--spicetify", ShellSettings.syncSpicetifyTheme ? "1" : "0"
        ]
        integrationStatus = "Applying…"
        integrationProcess.running = true
    }

    Component.onCompleted: {
        refresh()
        scheduleIntegrationSync()
    }

    // Collapse the many individual colour-change signals from a generated
    // palette into one application update.
    Timer {
        id: integrationTimer
        interval: 240
        onTriggered: root.syncIntegrations()
    }

    Connections {
        target: ShellSettings
        function onSchemeChanged() { root.scheduleIntegrationSync() }
        function onThemeFileChanged() { root.scheduleIntegrationSync() }
        function onSyncKittyThemeChanged() { root.scheduleIntegrationSync() }
        function onSyncHyprlandThemeChanged() { root.scheduleIntegrationSync() }
        function onSyncSpicetifyThemeChanged() { root.scheduleIntegrationSync() }
    }

    Connections {
        target: CustomTheme
        function onBackgroundChanged() { root.scheduleIntegrationSync() }
        function onSurfaceHoverChanged() { root.scheduleIntegrationSync() }
        function onBorderChanged() { root.scheduleIntegrationSync() }
        function onTextChanged() { root.scheduleIntegrationSync() }
        function onMutedChanged() { root.scheduleIntegrationSync() }
        function onAccentChanged() { root.scheduleIntegrationSync() }
    }

    // Keep the picker in sync when JSON files are added, renamed, or removed
    // while Settings is open. The directory is tiny, so a lightweight scan is
    // more reliable across Quickshell versions than watching a directory with
    // FileView.
    Timer {
        interval: 1200
        repeat: true
        running: root.watching
        onTriggered: root.refresh()
    }

    Process {
        id: scan
        command: ["python3", Quickshell.shellPath("scripts/theme-list.py"), Quickshell.shellPath("themes")]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.themes = JSON.parse(text || "[]")
                    root.error = ""
                } catch (e) {
                    root.error = "Could not read bundled themes"
                }
            }
        }
    }

    Process {
        id: picker
        command: ["sh", "-c", "if command -v zenity >/dev/null 2>&1; then zenity --file-selection --title='Import Fianchetto theme' --file-filter='JSON themes | *.json'; elif command -v kdialog >/dev/null 2>&1; then kdialog --getopenfilename ~ '*.json|JSON themes'; else printf '__NO_PICKER__'; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim()
                if (path === "__NO_PICKER__") root.error = "Install zenity or kdialog to choose a file"
                else if (path !== "") root.applyTheme(path)
            }
        }
    }


    Process {
        id: matugenInstaller
        command: ["sh", Quickshell.shellPath("scripts/install-matugen-theme.sh")]
        onRunningChanged: root.installingMatugen = running
        onExited: (exitCode, exitStatus) => root.matugenStatus = exitCode === 0
            ? "Ready — enable Matugen command and colour source in skwd-wall"
            : "Setup failed; run the installer from a terminal for details"
    }

    Process {
        id: integrationProcess
        stdout: StdioCollector {
            onStreamFinished: if (text.trim() !== "") root.integrationStatus = text.trim()
        }
        onRunningChanged: root.syncingApps = running
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) root.integrationStatus = "One or more integrations could not be updated"
            if (root.syncAgain) {
                root.syncAgain = false
                root.scheduleIntegrationSync()
            }
        }
    }
}
