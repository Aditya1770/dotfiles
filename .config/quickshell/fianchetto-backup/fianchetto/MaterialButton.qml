import QtQuick

Rectangle {
    id: root
    property string label: ""
    property color accent: Theme.pastelSky
    signal clicked()
    implicitWidth: labelText.implicitWidth + 28
    implicitHeight: 36
    radius: 18
    color: buttonMouse.containsMouse ? accent : Theme.border
    BarText {
        id: labelText
        anchors.centerIn: parent
        text: root.label
        color: buttonMouse.containsMouse ? Theme.background : Theme.text
        font.pixelSize: 12
    }
    MouseArea {
        id: buttonMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
