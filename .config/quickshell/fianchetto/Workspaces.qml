import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Pill {
    id: root
    interactive: false
    property int revision: 0
    property bool vertical: false
    readonly property real widthScale: Math.max(0.6, Math.min(1.6, ShellSettings.workspaceWidth / 100))
    horizontalPadding: vertical ? 9 : Math.round(8 * widthScale)
    implicitHeight: vertical ? workspaceGrid.implicitHeight + 14 : Theme.pillHeight

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

    GridLayout {
        id: workspaceGrid
        columns: root.vertical ? 1 : 10
        rowSpacing: root.vertical ? Math.round(5 * root.widthScale) : 0
        columnSpacing: root.vertical ? 0 : Math.round(6 * root.widthScale)

        Repeater {
            model: 10

            Rectangle {
                required property int index
                readonly property bool active: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === index + 1
                readonly property bool hasWindows: root.occupied(index + 1)
                implicitWidth: root.vertical ? 7 : Math.round(15 * root.widthScale)
                implicitHeight: root.vertical ? Math.round(15 * root.widthScale) : 7
                width: implicitWidth
                height: implicitHeight
                color: "transparent"

                Rectangle {
                    anchors.centerIn: parent
                    width: root.vertical ? 7 : (parent.active ? Math.round(15 * root.widthScale) : 7)
                    height: root.vertical ? (parent.active ? Math.round(15 * root.widthScale) : 7) : 7
                    radius: 4
                    color: parent.hasWindows || parent.active ? (parent.active ? Theme.blue : Theme.muted) : "transparent"
                    border.width: parent.hasWindows || parent.active ? 0 : 1
                    border.color: Theme.muted
                    Behavior on width { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 140 } }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = "' + String(index + 1) + '" })')
                }

            }
        }
    }

    onWheel: delta => Hyprland.dispatch('hl.dsp.focus({ workspace = "' + (delta > 0 ? "e-1" : "e+1") + '" })')
}
