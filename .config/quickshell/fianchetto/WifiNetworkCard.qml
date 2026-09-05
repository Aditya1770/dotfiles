import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

Rectangle {
    id: root
    required property var modelData
    readonly property var network: modelData
    property bool passwordEditorExpanded: false
    signal passwordEditorRequested()
    signal passwordEditorClosed()

    readonly property string signalIcon: network.signalStrength > 0.75 ? "󰤨"
        : network.signalStrength > 0.5 ? "󰤥"
        : network.signalStrength > 0.25 ? "󰤢" : "󰤟"
    readonly property string statusText: network.connected ? "Connected"
        : network.stateChanging ? "Connecting…"
        : network.known ? "Saved" : "Available"

    height: passwordEditorExpanded ? 104 : 52
    radius: 11
    color: network.connected ? Theme.surfaceHover : Theme.background
    border.width: 0
    clip: true

    Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 150 } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 9
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 9
            IconText { text: root.signalIcon; color: root.network.connected ? Theme.blue : Theme.muted }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                BarText { Layout.fillWidth: true; text: root.network.name; elide: Text.ElideRight }
                BarText { text: root.statusText; color: root.network.connected ? Theme.green : Theme.muted; font.pixelSize: 10 }
            }
            IconText {
                text: root.passwordEditorExpanded ? "󰅀" : "󰅂"
                color: Theme.muted
                visible: root.network.connected || root.network.known
            }
            IconText {
                text: "󰌾"
                color: Theme.muted
                visible: !root.network.connected && !root.network.known
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            visible: root.passwordEditorExpanded && (root.network.connected || root.network.known)
            spacing: 7

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: 92
                Layout.preferredHeight: 32
                radius: 9
                color: Theme.surface
                border.width: 0
                BarText {
                    anchors.centerIn: parent
                    text: root.network.connected ? "Disconnect" : "Connect"
                    color: root.network.connected ? Theme.red : Theme.green
                    font.pixelSize: 11
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.network.connected) root.network.disconnect()
                        else root.network.connect()
                        root.passwordEditorClosed()
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 70
                Layout.preferredHeight: 32
                radius: 9
                color: Theme.surface
                border.width: 0
                BarText { anchors.centerIn: parent; text: "Forget"; color: Theme.red; font.pixelSize: 11 }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.network.forget(); root.passwordEditorClosed() }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            visible: root.passwordEditorExpanded && !root.network.connected
            spacing: 7

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                radius: 9
                color: Theme.surface
                border.width: 1
                border.color: passwordInput.activeFocus ? Theme.blue : Theme.border
                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 38
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.text
                    font.family: Typography.textFamily
                    font.pixelSize: Typography.textSize
                    font.weight: Typography.textWeight
                    echoMode: reveal.show ? TextInput.Normal : TextInput.Password
                    passwordCharacter: "•"
                    onAccepted: { root.network.connectWithPsk(text); root.passwordEditorClosed() }
                    onVisibleChanged: if (visible) forceActiveFocus()
                }
                IconText {
                    id: reveal
                    property bool show: false
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: show ? "󰈈" : "󰈉"
                    color: Theme.muted
                    MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: reveal.show = !reveal.show }
                }
            }
            Rectangle {
                Layout.preferredWidth: 34; Layout.preferredHeight: 34; radius: 9; color: Theme.surface
                IconText { anchors.centerIn: parent; text: "󰅖"; color: Theme.red }
                MouseArea { anchors.fill: parent; onClicked: root.passwordEditorClosed() }
            }
            Rectangle {
                Layout.preferredWidth: 34; Layout.preferredHeight: 34; radius: 9; color: Theme.surface
                IconText { anchors.centerIn: parent; text: "󰄬"; color: Theme.green }
                MouseArea { anchors.fill: parent; onClicked: { root.network.connectWithPsk(passwordInput.text); root.passwordEditorClosed() } }
            }
        }
    }

    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 52
        onClicked: {
            if (root.network.connected || root.network.known) {
                if (root.passwordEditorExpanded) root.passwordEditorClosed()
                else root.passwordEditorRequested()
            } else if (root.network.security === WifiSecurityType.None) {
                root.network.connect()
                root.passwordEditorClosed()
            } else root.passwordEditorRequested()
        }
    }

    NumberAnimation on opacity { from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
    Connections {
        target: root.network
        function onConnectionFailed(reason) { root.passwordEditorRequested() }
    }
}
