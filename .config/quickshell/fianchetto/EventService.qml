pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property alias events: eventModel
    readonly property int count: eventModel.count
    property int revision: 0

    function refresh() {
        if (loader.running) return
        eventModel.clear()
        revision++
        loader.running = true
    }

    function add(dateKey, title) {
        const clean = title.trim()
        if (!dateKey || !clean) return
        Quickshell.execDetached([Quickshell.shellPath("scripts/event-store.sh"), "add", dateKey, clean])
        eventModel.append({ dateKey: dateKey, title: clean })
        revision++
    }

    function remove(dateKey, title) {
        Quickshell.execDetached([Quickshell.shellPath("scripts/event-store.sh"), "remove", dateKey, title])
        for (let i = 0; i < eventModel.count; ++i) {
            const item = eventModel.get(i)
            if (item.dateKey === dateKey && item.title === title) {
                eventModel.remove(i)
                revision++
                return
            }
        }
    }

    function forDate(dateKey) {
        const revisionDependency = revision
        const result = []
        for (let i = 0; i < eventModel.count; ++i) {
            const item = eventModel.get(i)
            if (item.dateKey === dateKey) result.push({ dateKey: item.dateKey, title: item.title })
        }
        return result
    }

    function countFor(dateKey) { return forDate(dateKey).length }

    function nextEvent() {
        const today = Qt.formatDate(new Date(), "yyyy-MM-dd")
        let best = null
        for (let i = 0; i < eventModel.count; ++i) {
            const item = eventModel.get(i)
            if (item.dateKey >= today && (!best || item.dateKey < best.dateKey))
                best = { dateKey: item.dateKey, title: item.title }
        }
        return best
    }

    ListModel { id: eventModel }
    Process {
        id: loader
        command: [Quickshell.shellPath("scripts/event-store.sh"), "list"]
        stdout: SplitParser {
            onRead: line => {
                const separator = line.indexOf("\t")
                if (separator < 0) return
                eventModel.append({ dateKey: line.slice(0, separator), title: line.slice(separator + 1) })
                root.revision++
            }
        }
    }
    Component.onCompleted: refresh()
}
