pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var themes: []
    property string error: ""
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

    Component.onCompleted: refresh()

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
}
