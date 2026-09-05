import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    default property alias content: contents.data
    property int horizontalPadding: 10
    property color hoverColor: Theme.surfaceHover
    property bool hovered: mouse.containsMouse
    property bool interactive: true
    signal clicked(int button)
    signal wheel(int delta)

    implicitWidth: contents.implicitWidth + horizontalPadding * 2
    implicitHeight: Theme.pillHeight
    radius: Theme.radius
    color: hovered ? hoverColor : Theme.surface
    border.width: 0

    RowLayout {
        id: contents
        anchors.centerIn: parent
        spacing: 6
    }

    Behavior on color { ColorAnimation { duration: 120 } }

    MouseArea {
        id: mouse
        enabled: root.interactive
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        hoverEnabled: true
        onClicked: event => root.clicked(event.button)
        onWheel: event => root.wheel(event.angleDelta.y)
    }
}
