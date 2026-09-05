import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root
    required property var modelData
    readonly property var device: modelData
    signal activationRequested(var device)
    signal forgetRequested(var device)
    property bool expanded: false

    height: expanded ? 104 : 54
    radius: 11
    color: device.connected ? Theme.surfaceHover : Theme.background
    border.width: 0

    clip: true
    Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 9
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            spacing: 9
            Rectangle {
                Layout.preferredWidth: 34; Layout.preferredHeight: 34; radius: 9; color: Theme.surface
                Image { anchors.fill: parent; anchors.margins: 7; source: Quickshell.iconPath(root.device.icon, "bluetooth") }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                BarText { Layout.fillWidth: true; text: root.device.name || root.device.deviceName || "Unknown device"; elide: Text.ElideRight }
                BarText { text: root.device.connected ? "Connected" : root.device.pairing ? "Pairing…" : root.device.paired ? "Paired" : "Available"; color: root.device.connected ? Theme.green : Theme.muted; font.pixelSize: 10 }
            }
            BarText { visible: root.device.batteryAvailable; text: Math.round(root.device.battery * 100) + "%"; color: Theme.muted; font.pixelSize: 10 }
            IconText { text: root.expanded ? "󰅀" : "󰅂"; color: Theme.muted }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 7
            visible: root.expanded
            Item { Layout.fillWidth: true }
            Rectangle {
                Layout.preferredWidth: 88; Layout.preferredHeight: 32; radius: 9
                color: Theme.surface; border.width: 0
                BarText {
                    anchors.centerIn: parent
                    text: root.device.connected ? "Disconnect" : root.device.paired ? "Connect" : "Pair"
                    color: root.device.connected ? Theme.red : Theme.green
                    font.pixelSize: 11
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.activationRequested(root.device); root.expanded = false }
                }
            }
            Rectangle {
                visible: root.device.paired
                Layout.preferredWidth: 70; Layout.preferredHeight: 32; radius: 9
                color: Theme.surface; border.width: 0
                BarText { anchors.centerIn: parent; text: "Forget"; color: Theme.red; font.pixelSize: 11 }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.forgetRequested(root.device); root.expanded = false }
                }
            }
        }
    }
    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 54
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
    }
    NumberAnimation on opacity { from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
}
