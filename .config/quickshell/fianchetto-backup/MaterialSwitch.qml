import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property bool checked: false
    property color accent: Theme.pastelSky
    signal toggled(bool checked)
    implicitWidth: 46
    implicitHeight: 26
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: height / 2
    color: checked ? accent : Theme.border

    Rectangle {
        width: 20
        height: 20
        radius: 10
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? root.width - width - 3 : 3
        color: root.checked ? Theme.background : Theme.muted
        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
    Behavior on color { ColorAnimation { duration: 140 } }
}
