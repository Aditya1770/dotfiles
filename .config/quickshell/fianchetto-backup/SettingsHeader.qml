import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string icon
    property string title
    property string subtitle
    property bool active: false
    property bool toggleEnabled: true
    signal toggled()

    implicitHeight: 58
    radius: 12
    color: Theme.surfaceHover
    border.width: 0

    IconText {
        anchors.left: parent.left
        anchors.leftMargin: 13
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon
        color: root.active ? Theme.blue : Theme.muted
        font.pixelSize: 17
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.leftMargin: 43
        anchors.right: powerSwitch.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1
        BarText { text: root.title; font.pixelSize: 14 }
        BarText { text: root.subtitle; color: Theme.muted; font.pixelSize: 11; visible: text.length > 0 }
    }

    Rectangle {
        id: powerSwitch
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 38
        height: 22
        radius: 11
        opacity: root.toggleEnabled ? 1 : 0.45
        color: root.active ? Theme.blue : Theme.background
        border.width: 1
        border.color: root.active ? Theme.blue : Theme.border
        Rectangle {
            width: 16
            height: 16
            radius: 8
            y: 3
            x: root.active ? parent.width - width - 3 : 3
            color: root.active ? Theme.background : Theme.muted
            Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        }
        MouseArea { anchors.fill: parent; enabled: root.toggleEnabled; onClicked: root.toggled() }
        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
