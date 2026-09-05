import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Pill {
    id: root
    horizontalPadding: 12
    interactive: false
    property int revision: 0

    function occupied(workspaceId) {
        revision
        return Hyprland.toplevels.values.some(toplevel =>
            toplevel.workspace && toplevel.workspace.id === workspaceId
        )
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) { root.revision++ }
    }

    RowLayout {
        spacing: 10

        Repeater {
            model: 10

            Rectangle {
                required property int index
                readonly property bool active: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === index + 1
                readonly property bool hasWindows: root.occupied(index + 1)
                implicitWidth: active ? 17 : 7
                implicitHeight: 7
                width: implicitWidth
                height: implicitHeight
                radius: 4
                color: hasWindows || active ? (active ? Theme.text : Theme.muted) : "transparent"
                border.width: hasWindows || active ? 0 : 1
                border.color: Theme.muted

                Behavior on implicitWidth { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = "' + String(index + 1) + '" })')
                }

                Behavior on color { ColorAnimation { duration: 140 } }
            }
        }
    }

    onWheel: delta => Hyprland.dispatch('hl.dsp.focus({ workspace = "' + (delta > 0 ? "e-1" : "e+1") + '" })')
}
