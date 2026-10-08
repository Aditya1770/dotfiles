import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property bool mirrored: false
    property int size: 12
    property color fillColor: Theme.background
    implicitWidth: size
    implicitHeight: size

    Shape {
        anchors.fill: parent
        antialiasing: true
        transform: Scale {
            xScale: root.mirrored ? -1 : 1
            origin.x: root.width / 2
        }
        ShapePath {
            strokeWidth: 0
            fillColor: root.fillColor
            startX: root.size
            startY: root.size
            PathArc {
                x: 0; y: 0
                radiusX: root.size; radiusY: root.size
                direction: PathArc.Counterclockwise
            }
            PathLine { x: root.size; y: 0 }
            PathLine { x: root.size; y: root.size }
        }
    }
}
