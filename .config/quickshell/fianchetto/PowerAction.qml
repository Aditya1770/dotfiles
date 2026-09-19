import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property string label
    required property string icon
    required property color accent
    signal triggered()

    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 18
    color: actionMouse.containsMouse ? Theme.border : Theme.surfaceHover
    border.width: 0

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 6
        IconText {
            Layout.alignment: Qt.AlignHCenter
            text: root.icon
            color: root.accent
            font.pixelSize: 22
        }
        BarText {
            Layout.alignment: Qt.AlignHCenter
            text: root.label
            font.pixelSize: 12
        }
    }

    MouseArea {
        id: actionMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.triggered()
    }
}
