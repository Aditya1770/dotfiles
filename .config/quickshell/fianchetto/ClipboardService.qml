pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property alias entries: entryModel
    readonly property int count: entryModel.count
    property int revision: 0

    function refresh() {
        if (loader.running) return
        entryModel.clear()
        revision++
        loader.running = true
    }

    function restore(entryId) {
        Quickshell.execDetached([Quickshell.shellPath("scripts/clipboard-action.sh"), "restore", String(entryId)])
    }

    function remove(entryId) {
        Quickshell.execDetached([Quickshell.shellPath("scripts/clipboard-action.sh"), "delete", String(entryId)])
        for (let i = 0; i < entryModel.count; ++i) {
            if (entryModel.get(i).entryId === entryId) {
                entryModel.remove(i)
                revision++
                break
            }
        }
    }

    function togglePin(entryId, entryType) {
        Quickshell.execDetached([Quickshell.shellPath("scripts/clipboard-action.sh"), "pin",
            String(entryId), String(entryType)])
        for (let i = 0; i < entryModel.count; ++i) {
            if (entryModel.get(i).entryId === entryId) {
                entryModel.setProperty(i, "pinned", !entryModel.get(i).pinned)
                revision++
                break
            }
        }
    }

    function clear() {
        Quickshell.execDetached([Quickshell.shellPath("scripts/clipboard-action.sh"), "wipe"])
        for (let i = entryModel.count - 1; i >= 0; --i)
            if (!entryModel.get(i).pinned) entryModel.remove(i)
        revision++
    }

    ListModel { id: entryModel }

    Process {
        id: loader
        command: [Quickshell.shellPath("scripts/clipboard-list.sh")]
        stdout: SplitParser {
            onRead: line => {
                const fields = line.split("\t")
                if (fields.length < 3) return
                entryModel.append({
                    entryId: Number(fields[0]),
                    entryType: fields[1],
                    preview: fields[2],
                    imageSource: fields.length > 3 ? fields[3] : "",
                    pinned: fields.length > 4 && fields[4] === "true"
                })
                root.revision++
            }
        }
    }
}
