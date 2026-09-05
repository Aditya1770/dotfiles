import QtQuick
import QtQuick.Layouts
import Quickshell

Pill {
    id: root
    horizontalPadding: 7
    IconText { text: ""; color: Theme.red }
    onClicked: popup.visible = !popup.visible

    function run(command) {
        popup.visible = false
        Quickshell.execDetached(command)
    }

    ModulePopup {
        id: popup
        anchorItem: root
        implicitWidth: 250
        implicitHeight: 184

        GridLayout {
            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            columns: 2
            columnSpacing: 9
            rowSpacing: 9

            Repeater {
                model: [
                    { label: "Logout", icon: "󰍃", color: Theme.blue, command: ["hyprctl", "dispatch", "exit"] },
                    { label: "Sleep", icon: "󰒲", color: Theme.purple, command: ["systemctl", "suspend"] },
                    { label: "Reboot", icon: "󰜉", color: Theme.orange, command: ["systemctl", "reboot"] },
                    { label: "Power Off", icon: "", color: Theme.red, command: ["systemctl", "poweroff"] }
                ]
                delegate: Rectangle {
                    required property var modelData
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
                            text: modelData.icon
                            color: modelData.color
                            font.pixelSize: 22
                        }
                        BarText { text: modelData.label; font.pixelSize: 12 }
                    }
                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.run(modelData.command)
                    }
                }
            }
        }
    }
}
