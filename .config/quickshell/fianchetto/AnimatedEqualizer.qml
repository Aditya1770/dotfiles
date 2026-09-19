import QtQuick
import QtQuick.Layouts

GridLayout {
    id: root
    property bool playing: false
    property bool vertical: false
    property color accent: Theme.pastelMint
    property real phase: 0
    columns: vertical ? 1 : 3
    columnSpacing: vertical ? 0 : 2
    rowSpacing: vertical ? 2 : 0
    implicitWidth: vertical ? 14 : 13
    implicitHeight: vertical ? 13 : 14

    FrameAnimation {
        running: root.playing && ShellSettings.animatedEqualizer
        onTriggered: root.phase += frameTime
    }

    Repeater {
        model: 3
        Item {
            required property int index
            // Close to the original ~0.5 second pulse, with a distinct speed per bar.
            readonly property real frequency: [12.4, 15.1, 10.9][index] * ShellSettings.equalizerSpeed
            readonly property real offset: [0.25, 2.35, 4.6][index]
            readonly property real wave: 0.5 + 0.5 * Math.sin(root.phase * frequency + offset)
            width: root.vertical ? root.width : 3
            height: root.vertical ? 3 : root.height

            Rectangle {
                id: animatedBar
                anchors.centerIn: parent
                width: root.vertical
                    ? (root.playing && ShellSettings.animatedEqualizer ? root.width * (0.25 + parent.wave * 0.75) : root.width * 0.34)
                    : 3
                height: root.vertical ? 3
                    : (root.playing && ShellSettings.animatedEqualizer ? root.height * (0.25 + parent.wave * 0.75) : root.height * 0.34)
                radius: 2
                color: root.accent
            }
        }
    }
}
