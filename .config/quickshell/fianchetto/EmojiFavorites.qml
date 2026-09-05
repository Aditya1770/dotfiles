pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property alias items: favoritesModel
    readonly property int count: favoritesModel.count
    property int revision: 0

    function isFavorite(glyph) {
        for (let i = 0; i < favoritesModel.count; ++i)
            if (favoritesModel.get(i).glyph === glyph) return true
        return false
    }

    function toggle(glyph) {
        const removing = isFavorite(glyph)
        Quickshell.execDetached([
            Quickshell.shellPath("scripts/emoji-favorite.sh"), "toggle", glyph
        ])

        if (removing) {
            for (let i = 0; i < favoritesModel.count; ++i) {
                if (favoritesModel.get(i).glyph === glyph) {
                    favoritesModel.remove(i)
                    break
                }
            }
        } else {
            favoritesModel.append({ glyph: glyph })
        }
        revision++
    }

    function refresh() {
        if (loader.running) return
        favoritesModel.clear()
        revision++
        loader.running = true
    }

    ListModel { id: favoritesModel }

    Process {
        id: loader
        command: [Quickshell.shellPath("scripts/emoji-favorite.sh"), "list"]
        stdout: SplitParser {
            onRead: line => {
                if (!line) return
                favoritesModel.append({ glyph: line })
                root.revision++
            }
        }
    }

    Component.onCompleted: refresh()
}
