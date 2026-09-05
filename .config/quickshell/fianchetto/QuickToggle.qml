import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string icon
    property string label
    property string subtitle: ""
    property bool active: false
    property bool showArrow: false
    property bool expanded: false
    property bool embedded: false
    property bool hovered: toggleMouse.containsMouse
    signal toggled()
    signal detailsRequested()

    implicitHeight: 42
    implicitWidth: 145
    radius: 21
    color: embedded ? "transparent" : (active ? Theme.blue : (hovered ? Theme.border : Theme.surfaceHover))
    border.width: 0

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 13
        anchors.rightMargin: 8
        spacing: 8

        IconText { text: root.icon; color: root.active ? Theme.background : Theme.text }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            BarText {
                Layout.fillWidth: true
                text: root.label
                color: root.active ? Theme.background : Theme.text
                elide: Text.ElideRight
            }
            BarText {
                Layout.fillWidth: true
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: root.active ? Theme.background : Theme.muted
                opacity: root.active ? 0.72 : 1
                font.pixelSize: 10
                font.weight: Font.Normal
                elide: Text.ElideRight
            }
        }
        IconText {
            visible: root.showArrow
            text: root.expanded ? "󰅀" : "󰅂"
            color: root.active ? Theme.background : Theme.muted
            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                onClicked: root.detailsRequested()
            }
        }
    }

    MouseArea {
        id: toggleMouse
        anchors.fill: parent
        anchors.rightMargin: root.showArrow ? 30 : 0
        hoverEnabled: true
        onClicked: root.toggled()
    }

    Behavior on color { ColorAnimation { duration: 130 } }
    Behavior on scale { NumberAnimation { duration: 100 } }
}
