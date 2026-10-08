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
    readonly property string barEdge: ShellSettings.barPosition
    readonly property bool verticalBar: barEdge === "left" || barEdge === "right"
    // Compact vertical modules have different widths but are centered in the
    // same bar. Include the unused half-width so every popup begins exactly
    // 10px beyond the visible bar edge rather than 10px beyond its pill.
    readonly property real verticalEdgeInset: verticalBar
        ? Math.max(0, (Theme.sideBarWidth - anchorItem.width) / 2) : 0

    anchor.item: anchorItem
    anchor.rect.x: barEdge === "left" ? anchorItem.width + verticalEdgeInset + 10
        : barEdge === "right" ? -verticalEdgeInset - 10 : Math.round(anchorItem.width / 2)
    anchor.rect.y: barEdge === "top" ? anchorItem.height + 10
        : barEdge === "bottom" ? -10 : Math.round(anchorItem.height / 2)
    anchor.rect.width: 1
    anchor.rect.height: 1
    anchor.edges: barEdge === "bottom" ? Edges.Bottom
        : barEdge === "left" ? Edges.Left
        : barEdge === "right" ? Edges.Right : Edges.Top
    anchor.gravity: barEdge === "bottom" ? Edges.Top
        : barEdge === "left" ? Edges.Right
        : barEdge === "right" ? Edges.Left : Edges.Bottom
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
            x: root.presented ? 0 : root.barEdge === "left" ? -8 : root.barEdge === "right" ? 8 : 0
            y: root.presented ? 0 : root.barEdge === "top" ? -8 : root.barEdge === "bottom" ? 8 : 0
            Behavior on x { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }
            Behavior on y { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }
        }
        transformOrigin: root.barEdge === "bottom" ? Item.Bottom
            : root.barEdge === "left" ? Item.Left
            : root.barEdge === "right" ? Item.Right : Item.Top
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
