import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string title
    property string icon
    property color accent: Theme.blue
    property real currentValue: 0
    property real minimum: 0
    property real maximum: 100
    property bool showTitle: true
    property bool embedded: false
    signal valueMoved(real newValue)

    implicitHeight: 54
    radius: 15
    color: embedded ? "transparent" : Theme.surfaceHover
    border.width: 0

    property bool dragging: false
    property real displayValue: currentValue
    onCurrentValueChanged: if (!dragging) displayValue = currentValue

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: 34
        height: 34
        radius: 17
        color: Theme.border
        IconText {
            anchors.centerIn: parent
            text: root.icon
            color: root.accent
            font.pixelSize: 16
        }
    }
    BarText {
        id: sliderTitle
        anchors.left: parent.left
        anchors.leftMargin: 52
        anchors.verticalCenter: parent.verticalCenter
        width: root.showTitle ? 76 : 0
        text: root.title
        visible: root.showTitle
    }
    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.leftMargin: root.showTitle ? 127 : 56
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        height: 12
        radius: 6
        color: "#232A2D"
        Rectangle {
            width: Math.max(0, Math.min(parent.width, parent.width * (root.displayValue - root.minimum) / (root.maximum - root.minimum)))
            height: parent.height
            radius: parent.radius
            color: root.accent
            Behavior on width { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function setFromX(px) {
            root.displayValue = Math.max(root.minimum, Math.min(root.maximum,
                root.minimum + (px - track.x) / track.width * (root.maximum - root.minimum)))
            root.valueMoved(root.displayValue)
        }
        onPressed: mouse => { root.dragging = true; setFromX(mouse.x) }
        onPositionChanged: mouse => { if (pressed) setFromX(mouse.x) }
        onReleased: root.dragging = false
        onCanceled: root.dragging = false
    }
}
