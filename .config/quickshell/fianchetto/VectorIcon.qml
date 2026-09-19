import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property string path: ""
    property color iconColor: Theme.blue
    implicitWidth: 24
    implicitHeight: 24

    Shape {
        width: 24
        height: 24
        anchors.centerIn: parent
        ShapePath {
            fillColor: root.iconColor
            strokeWidth: -1
            PathSvg { path: root.path }
        }
    }
}
