import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: root
    required property var targetScreen
    screen: targetScreen
    readonly property bool vertical: ShellSettings.osdPosition === "left" || ShellSettings.osdPosition === "right"
    readonly property int cardWidth: root.vertical ? 70 : 360
    readonly property int cardHeight: root.vertical ? 300 : 70
    anchors {
        top: ShellSettings.osdPosition !== "bottom"
        bottom: ShellSettings.osdPosition === "bottom"
        left: ShellSettings.osdPosition !== "right"
        right: ShellSettings.osdPosition === "right"
    }
    margins {
        top: ShellSettings.osdPosition === "top" ? ShellSettings.osdVerticalOffset
            : root.vertical ? Math.max(0, (root.targetScreen.height - root.cardHeight) / 2 + ShellSettings.osdVerticalOffset) : 0
        bottom: ShellSettings.osdPosition === "bottom" ? ShellSettings.osdVerticalOffset : 0
        left: ShellSettings.osdPosition === "left" ? ShellSettings.osdHorizontalOffset
            : !root.vertical ? Math.max(0, (root.targetScreen.width - root.cardWidth) / 2 + ShellSettings.osdHorizontalOffset) : 0
        right: ShellSettings.osdPosition === "right" ? ShellSettings.osdHorizontalOffset : 0
    }
    exclusiveZone: 0
    implicitWidth: root.cardWidth
    implicitHeight: root.cardHeight
    color: "transparent"
    visible: OsdState.shown

    Rectangle {
        id: osdCard
        anchors.fill: parent
        radius: 28
        color: Theme.background
        border.width: 0

        RowLayout {
            visible: OsdState.kind !== "profile" && !root.vertical
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 18
            spacing: 13

            Rectangle {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                radius: 21
                color: Theme.border

                VectorIcon { anchors.centerIn: parent; path: OsdState.levelIconPath; iconColor: Theme.blue }
            }

            Rectangle {
                id: horizontalTrack
                Layout.fillWidth: true
                height: 12
                radius: 6
                color: Theme.border
                Rectangle {
                    width: parent.width * OsdState.value
                    height: parent.height
                    radius: parent.radius
                    color: Theme.blue
                    Behavior on width { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    function applyPosition(px) {
                        const value = Math.max(0, Math.min(1, px / width))
                        if (OsdState.kind === "brightness") BrightnessService.setBrightness(value)
                        else AudioService.setVolume(value)
                    }
                    onPressed: mouse => applyPosition(mouse.x)
                    onPositionChanged: mouse => { if (pressed) applyPosition(mouse.x) }
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

        ColumnLayout {
            visible: OsdState.kind !== "profile" && root.vertical
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.topMargin: 14
            anchors.bottomMargin: 14
            spacing: 12

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                radius: 21
                color: Theme.border
                VectorIcon { anchors.centerIn: parent; path: OsdState.levelIconPath; iconColor: Theme.blue }
            }

            Rectangle {
                id: verticalTrack
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: true
                width: 12
                radius: 6
                color: Theme.border
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height * OsdState.value
                    radius: parent.radius
                    color: Theme.blue
                    Behavior on height { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    function applyPosition(py) {
                        const value = Math.max(0, Math.min(1, 1 - py / height))
                        if (OsdState.kind === "brightness") BrightnessService.setBrightness(value)
                        else AudioService.setVolume(value)
                    }
                    onPressed: mouse => applyPosition(mouse.y)
                    onPositionChanged: mouse => { if (pressed) applyPosition(mouse.y) }
                }
            }

            BarText {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 54
                horizontalAlignment: Text.AlignHCenter
                text: Math.round(OsdState.value * 100) + "%"
                color: Theme.blue
                font.pixelSize: 12
            }
        }

        RowLayout {
            visible: OsdState.kind === "profile" && !root.vertical
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 18
            spacing: 13

            Rectangle {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                radius: 21
                color: Theme.border

                IconText {
                    id: profileIcon
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    transform: Translate { x: -2 }
                    text: OsdState.profileIcon
                    color: OsdState.profileAccent
                    font.pixelSize: 20
                }
            }

            BarText {
                Layout.fillWidth: true
                text: OsdState.profileLabel + " mode"
                color: OsdState.profileAccent
                font.pixelSize: 16
            }
        }

        ColumnLayout {
            visible: OsdState.kind === "profile" && root.vertical
            anchors.centerIn: parent
            spacing: 12
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 42; height: 42; radius: 21; color: Theme.border
                IconText {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: OsdState.profileIcon
                    color: OsdState.profileAccent
                    font.pixelSize: 20
                }
            }
            BarText {
                Layout.alignment: Qt.AlignHCenter
                text: OsdState.profileLabel
                color: OsdState.profileAccent
                font.pixelSize: 13
            }
        }

        opacity: OsdState.shown ? 1 : 0
        scale: OsdState.shown ? 1 : 0.96
        Behavior on opacity { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
    }
}
