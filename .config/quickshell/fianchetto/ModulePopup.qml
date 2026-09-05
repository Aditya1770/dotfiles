import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: root
    required property Item anchorItem
    default property alias content: surface.data
    property bool presented: false
    property double openedAt: 0
    property Item focusTarget: null

    anchor.item: anchorItem
    // Explicit point below the pill: centered horizontally with a fixed gap.
    anchor.rect.x: Math.round(anchorItem.width / 2)
    anchor.rect.y: anchorItem.height + 10
    anchor.rect.width: 1
    anchor.rect.height: 1
    anchor.edges: Edges.Top
    anchor.gravity: Edges.Bottom
    color: "transparent"

    onVisibleChanged: {
        if (visible) {
            openedAt = Date.now()
            PopupManager.opened(root)
            presented = false
            Qt.callLater(function() {
                root.presented = true
                if (root.focusTarget) root.focusTarget.forceActiveFocus()
                else surface.forceActiveFocus()
                dismissGrab.active = true
            })
        } else {
            PopupManager.closed(root)
            dismissGrab.active = false
            presented = false
        }
    }

    HyprlandFocusGrab {
        id: dismissGrab
        windows: [root]
        onCleared: root.visible = false
    }

    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut
        enabled: root.visible
        onActivated: root.visible = false
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (root.visible && Date.now() - root.openedAt > 200
                    && (event.name === "activewindow" || event.name === "activewindowv2"))
                root.visible = false
        }
    }

    Rectangle {
        id: surface
        anchors.fill: parent
        focus: root.visible
        opacity: root.presented ? 1 : 0
        scale: root.presented ? 1 : 0.985
        transform: Translate {
            y: root.presented ? 0 : -8
            Behavior on y { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }
        }
        transformOrigin: Item.Top
        radius: Theme.popupRadius
        color: Theme.surface
        border.width: 0

        Keys.onEscapePressed: event => {
            root.visible = false
            event.accepted = true
        }

        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    }
}
