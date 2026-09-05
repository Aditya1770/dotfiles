import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: root
    required property var targetScreen
    screen: targetScreen
    anchors { top: true; right: true; bottom: true; left: true }
    exclusiveZone: 0
    color: "transparent"
    visible: ClipboardState.shown
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property bool presented: false
    property string emojiArea: "all"
    property var emojis: root.parseEmojiData(emojiFile.text())
    property string contextEmoji: ""

    FileView {
        id: emojiFile
        path: Quickshell.shellPath("data/emojis.txt")
        blockLoading: true
        printErrors: false
    }

    function parseEmojiData(contents) {
        const output = []
        const lines = contents.split("\n")
        for (const rawLine of lines) {
            const line = rawLine.trim()
            if (!line) continue
            const separator = line.indexOf(" ")
            if (separator < 1) continue
            output.push({
                glyph: line.slice(0, separator),
                name: line.slice(separator + 1).toLowerCase()
            })
        }
        return output
    }

    function moveSelection(horizontal, vertical) {
        if (ClipboardState.page === "clipboard") {
            if (clipboardList.count === 0) return
            let next = clipboardList.currentIndex + vertical
            next = Math.max(0, Math.min(clipboardList.count - 1, next))
            clipboardList.currentIndex = next
            clipboardList.positionViewAtIndex(next, ListView.Contain)
        } else {
            if (root.favoritesVisible && root.emojiArea === "favorites") {
                if (favoriteGrid.count === 0) return
                let favoriteNext = favoriteGrid.currentIndex + horizontal
                if (vertical > 0) {
                    root.emojiArea = "all"
                    emojiGrid.currentIndex = Math.min(Math.max(0, favoriteGrid.currentIndex), emojiGrid.count - 1)
                    emojiGrid.positionViewAtIndex(emojiGrid.currentIndex, GridView.Contain)
                    return
                }
                favoriteNext = Math.max(0, Math.min(favoriteGrid.count - 1, favoriteNext))
                favoriteGrid.currentIndex = favoriteNext
                return
            }
            if (emojiGrid.count === 0) return
            const columns = 8
            if (vertical < 0 && root.favoritesVisible && emojiGrid.currentIndex < columns) {
                root.emojiArea = "favorites"
                favoriteGrid.currentIndex = Math.min(emojiGrid.currentIndex, favoriteGrid.count - 1)
                return
            }
            let next = emojiGrid.currentIndex + horizontal + vertical * columns
            next = Math.max(0, Math.min(emojiGrid.count - 1, next))
            emojiGrid.currentIndex = next
            emojiGrid.positionViewAtIndex(next, GridView.Contain)
        }
    }

    function activateCurrent() {
        if (ClipboardState.page === "clipboard") {
            if (!clipboardList.currentItem) return
            ClipboardService.restore(clipboardList.currentItem.entry.entryId)
            ClipboardState.hide()
        } else {
            const grid = root.emojiArea === "favorites" && root.favoritesVisible
                ? favoriteGrid : emojiGrid
            if (!grid.currentItem) return
            root.copyEmoji(grid.currentItem.emoji.glyph)
        }
    }

    function emojiByGlyph(glyph) {
        for (const emoji of emojis)
            if (emoji.glyph === glyph) return emoji
        return { glyph: glyph, name: "Favorite emoji" }
    }

    function openEmojiMenu(glyph) {
        root.contextEmoji = glyph
        emojiMenu.popup()
    }

    readonly property var filteredEmojis: {
        const needle = searchInput.text.trim().toLowerCase()
        return needle ? emojis.filter(item => item.name.includes(needle)) : emojis
    }
    readonly property var favoriteEmojis: {
        const revision = EmojiFavorites.revision
        const output = []
        for (let i = 0; i < EmojiFavorites.count; ++i)
            output.push(root.emojiByGlyph(EmojiFavorites.items.get(i).glyph))
        return output
    }
    readonly property bool favoritesVisible: searchInput.text.length === 0
        && favoriteEmojis.length > 0
    readonly property var clipboardResults: {
        const revision = ClipboardService.revision
        const count = ClipboardService.count
        const needle = searchInput.text.trim().toLowerCase()
        const output = []
        for (let i = 0; i < count; ++i) {
            const item = ClipboardService.entries.get(i)
            if (!needle || item.entryType === "image" || item.preview.toLowerCase().includes(needle))
                output.push(item)
        }
        return output
    }

    function copyEmoji(glyph) {
        Quickshell.execDetached(["wl-copy", glyph])
        ClipboardState.hide()
    }

    mask: Region { Region { item: panel } }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [root]
        onCleared: ClipboardState.hide()
    }

    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut
        enabled: root.visible
        onActivated: ClipboardState.hide()
    }

    Menu {
        id: emojiMenu
        MenuItem {
            text: EmojiFavorites.isFavorite(root.contextEmoji)
                ? "Remove from Favorites" : "Add to Favorites"
            onTriggered: EmojiFavorites.toggle(root.contextEmoji)
        }
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: Math.min(620, root.width - 48)
        height: Math.min(610, root.height - 72)
        radius: 24
        color: Theme.surface
        border.width: 0
        opacity: root.presented ? 1 : 0
        scale: root.presented ? 1 : 0.96

        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 190; easing.type: Easing.OutBack } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Pill {
                    horizontalPadding: 13
                    color: ClipboardState.page === "clipboard" ? Theme.blue : Theme.surfaceHover
                    IconText { text: "󰅍"; color: ClipboardState.page === "clipboard" ? Theme.background : Theme.text }
                    BarText { text: "Clipboard"; color: ClipboardState.page === "clipboard" ? Theme.background : Theme.text }
                    onClicked: { ClipboardState.page = "clipboard"; searchInput.clear(); ClipboardService.refresh() }
                }
                Pill {
                    horizontalPadding: 13
                    color: ClipboardState.page === "emoji" ? Theme.blue : Theme.surfaceHover
                    BarText { text: "😀  Emoji"; color: ClipboardState.page === "emoji" ? Theme.background : Theme.text }
                    onClicked: { ClipboardState.page = "emoji"; searchInput.clear() }
                }
                Item { Layout.fillWidth: true }
                Pill {
                    visible: ClipboardState.page === "clipboard" && ClipboardService.count > 0
                    horizontalPadding: 10
                    IconText { text: "󰃢"; color: Theme.red }
                    BarText { text: "Clear"; font.pixelSize: 11 }
                    onClicked: ClipboardService.clear()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 48
                radius: 16
                color: Theme.surfaceHover
                IconText {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰍉"
                    color: Theme.blue
                }
                TextInput {
                    id: searchInput
                    anchors.left: parent.left
                    anchors.leftMargin: 46
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.text
                    font.family: Typography.textFamily
                    font.weight: Typography.textWeight
                    font.pixelSize: 15
                    onTextChanged: {
                        clipboardList.currentIndex = clipboardList.count > 0 ? 0 : -1
                        emojiGrid.currentIndex = emojiGrid.count > 0 ? 0 : -1
                        root.emojiArea = "all"
                    }
                    Keys.onUpPressed: event => { root.moveSelection(0, -1); event.accepted = true }
                    Keys.onDownPressed: event => { root.moveSelection(0, 1); event.accepted = true }
                    Keys.onLeftPressed: event => { root.moveSelection(-1, 0); event.accepted = true }
                    Keys.onRightPressed: event => { root.moveSelection(1, 0); event.accepted = true }
                    Keys.onReturnPressed: root.activateCurrent()
                    Keys.onEnterPressed: root.activateCurrent()
                    Keys.onEscapePressed: ClipboardState.hide()
                }
                BarText {
                    anchors.left: searchInput.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: searchInput.text.length === 0
                    text: ClipboardState.page === "clipboard" ? "Search clipboard" : "Search emoji"
                    color: Theme.muted
                    font.pixelSize: 15
                }
            }

            ListView {
                id: clipboardList
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: ClipboardState.page === "clipboard"
                model: root.clipboardResults
                spacing: 8
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                currentIndex: count > 0 ? 0 : -1
                highlightMoveDuration: 100
                highlight: Rectangle { radius: 16; color: Theme.border }

                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    property var entry: modelData
                    width: ListView.view.width
                    height: entry.entryType === "image" ? 180 : 70
                    radius: 16
                    color: ListView.isCurrentItem || itemMouse.containsMouse ? Theme.border : Theme.surfaceHover
                    border.width: 0

                    Image {
                        anchors.fill: parent
                        anchors.margins: 10
                        visible: entry.entryType === "image"
                        source: entry.imageSource
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        cache: false
                    }
                    BarText {
                        anchors.fill: parent
                        anchors.margins: 14
                        visible: entry.entryType === "text"
                        text: entry.preview
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 8
                        width: 28; height: 28; radius: 10
                        color: Theme.background
                        IconText { anchors.centerIn: parent; text: "󰆴"; color: Theme.red; font.pixelSize: 12 }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ClipboardService.remove(parent.parent.entry.entryId)
                        }
                    }
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 8
                        anchors.rightMargin: 44
                        width: 28; height: 28; radius: 10
                        color: entry.pinned ? Theme.blue : Theme.background
                        IconText {
                            anchors.centerIn: parent
                            text: "󰐃"
                            color: entry.pinned ? Theme.background : Theme.muted
                            font.pixelSize: 12
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ClipboardService.togglePin(parent.parent.entry.entryId,
                                parent.parent.entry.entryType)
                        }
                    }
                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        anchors.rightMargin: 76
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: clipboardList.currentIndex = index
                        onClicked: {
                            ClipboardService.restore(parent.entry.entryId)
                            ClipboardState.hide()
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: ClipboardState.page === "emoji"
                spacing: 6

                BarText {
                    visible: root.favoritesVisible
                    Layout.preferredHeight: visible ? 20 : 0
                    text: "Favorites"
                    color: Theme.blue
                    font.pixelSize: 12
                }

                GridView {
                    id: favoriteGrid
                    visible: root.favoritesVisible
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? Math.ceil(count / 8) * 64 : 0
                    model: root.favoriteEmojis
                    cellWidth: width / 8
                    cellHeight: 64
                    interactive: false
                    currentIndex: count > 0 ? 0 : -1
                    highlightMoveDuration: 90
                    highlight: Rectangle {
                        visible: root.emojiArea === "favorites"
                        radius: 18
                        color: Theme.surfaceHover
                    }
                    delegate: Item {
                        required property var modelData
                        required property int index
                        property var emoji: modelData
                        width: favoriteGrid.cellWidth
                        height: favoriteGrid.cellHeight
                        Rectangle {
                            anchors.centerIn: parent
                            width: 60; height: 60; radius: 18
                            color: favoriteMouse.containsMouse ? Theme.surfaceHover : "transparent"
                            BarText { anchors.centerIn: parent; text: modelData.glyph; font.pixelSize: 30 }
                            MouseArea {
                                id: favoriteMouse
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: { root.emojiArea = "favorites"; favoriteGrid.currentIndex = index }
                                onClicked: event => {
                                    if (event.button === Qt.RightButton) root.openEmojiMenu(modelData.glyph)
                                    else root.copyEmoji(modelData.glyph)
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    visible: root.favoritesVisible
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? 1 : 0
                    color: Theme.border
                }

                GridView {
                    id: emojiGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: root.filteredEmojis
                    cellWidth: width / 8
                    cellHeight: 70
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    currentIndex: count > 0 ? 0 : -1
                    highlightMoveDuration: 90
                    highlight: Rectangle {
                        visible: root.emojiArea === "all"
                        radius: 18
                        color: Theme.surfaceHover
                    }

                    delegate: Item {
                        required property var modelData
                        required property int index
                        property var emoji: modelData
                        width: emojiGrid.cellWidth
                        height: emojiGrid.cellHeight
                        Rectangle {
                            anchors.centerIn: parent
                            width: 60; height: 60; radius: 18
                            color: emojiMouse.containsMouse ? Theme.surfaceHover : "transparent"
                            BarText { anchors.centerIn: parent; text: modelData.glyph; font.pixelSize: 30 }
                            MouseArea {
                                id: emojiMouse
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: { root.emojiArea = "all"; emojiGrid.currentIndex = index }
                                onClicked: event => {
                                    if (event.button === Qt.RightButton) root.openEmojiMenu(modelData.glyph)
                                    else root.copyEmoji(modelData.glyph)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            searchInput.clear()
            if (ClipboardState.page === "clipboard") ClipboardService.refresh()
            root.presented = false
            Qt.callLater(function() {
                root.presented = true
                searchInput.forceActiveFocus()
                focusGrab.active = true
            })
        } else {
            root.presented = false
            focusGrab.active = false
        }
    }
}
