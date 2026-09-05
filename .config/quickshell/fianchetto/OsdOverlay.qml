import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: root
    required property var targetScreen
    screen: targetScreen
    anchors { bottom: true }
    margins { bottom: 58 }
    exclusiveZone: 0
    implicitWidth: 360
    implicitHeight: 70
    color: "transparent"
    visible: OsdState.shown

    Rectangle {
        anchors.fill: parent
        radius: 28
        color: "#0A1114"
        border.width: 0

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 18
            spacing: 13

            Rectangle {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                radius: 21
                color: "#232A2D"
                IconText {
                    anchors.centerIn: parent
                    text: OsdState.kind === "brightness" ? "󰃠"
                        : OsdState.muted || OsdState.value === 0 ? "󰖁" : "󰕾"
                    color: Theme.blue
                    font.pixelSize: 20
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 12
                radius: 6
                color: "#232A2D"
                Rectangle {
                    width: parent.width * OsdState.value
                    height: parent.height
                    radius: parent.radius
                    color: Theme.blue
                    Behavior on width { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
                }
            }

            BarText {
                Layout.preferredWidth: 38
                horizontalAlignment: Text.AlignRight
                text: Math.round(OsdState.value * 100) + "%"
                color: Theme.blue
                font.pixelSize: 13
            }
        }

        opacity: OsdState.shown ? 1 : 0
        scale: OsdState.shown ? 1 : 0.96
        Behavior on opacity { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
    }
}
