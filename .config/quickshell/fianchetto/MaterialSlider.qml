import QtQuick

Item {
    id: root
    property real from: 0
    property real to: 100
    property real value: 0
    property color accent: Theme.pastelSky
    signal moved(real value)
    implicitHeight: 26
    readonly property real ratio: Math.max(0, Math.min(1, (value - from) / (to - from)))

    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 8
        radius: 4
        color: Theme.border
        Rectangle { width: parent.width * root.ratio; height: parent.height; radius: 4; color: root.accent }
    }
    Rectangle {
        width: 18; height: 18; radius: 9
        x: Math.max(0, Math.min(root.width - width, root.ratio * root.width - width / 2))
        anchors.verticalCenter: parent.verticalCenter
        color: root.accent
        border.width: 3
        border.color: Theme.background
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function update(px) {
            const next = root.from + Math.max(0, Math.min(1, px / width)) * (root.to - root.from)
            root.moved(next)
        }
        onPressed: event => update(event.x)
        onPositionChanged: event => { if (pressed) update(event.x) }
    }
}
