pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    property bool shown: false
    property string page: "clipboard"

    function toggleClipboard() {
        page = "clipboard"
        shown = !shown
    }
    function showClipboard() { page = "clipboard"; shown = true }
    function showEmoji() { page = "emoji"; shown = true }
    function hide() { shown = false }

    property IpcHandler ipc: IpcHandler {
        target: "picker"
        function toggle(): void { root.toggleClipboard() }
        function clipboard(): void { root.showClipboard() }
        function emoji(): void { root.showEmoji() }
        function hide(): void { root.hide() }
    }
}
