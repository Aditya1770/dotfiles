import QtQuick
import QtQuick.Layouts
import Quickshell

Pill {
    id: root
    horizontalPadding: 7
    IconText { text: ""; color: Theme.pastelPowerRed }
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

            PowerAction {
                label: "Logout"
                icon: "󰍃"
                accent: Theme.pastelPowerRed
                onTriggered: root.run(["hyprctl", "dispatch", "exit"])
            }
            PowerAction {
                label: "Sleep"
                icon: "󰒲"
                accent: Theme.pastelPowerRed
                onTriggered: root.run(["systemctl", "suspend"])
            }
            PowerAction {
                label: "Reboot"
                icon: "󰜉"
                accent: Theme.pastelPowerRed
                onTriggered: root.run(["systemctl", "reboot"])
            }
            PowerAction {
                label: "Power Off"
                icon: ""
                accent: Theme.pastelPowerRed
                onTriggered: root.run(["systemctl", "poweroff"])
            }
        }
    }
}
