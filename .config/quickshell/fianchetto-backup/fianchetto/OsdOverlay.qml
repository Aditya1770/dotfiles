import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: root
    required property var targetScreen
    screen: targetScreen
    readonly property bool vertical: ShellSettings.osdPosition === "left" || ShellSettings.osdPosition === "right"
    readonly property int cardWidth: root.vertical ? 70 : (OsdState.volumeBoosted ? 471 : 360)
    readonly property int cardHeight: root.vertical ? (OsdState.volumeBoosted ? 395 : 300) : 70
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

                VectorIcon { anchors.centerIn: parent; path: OsdState.levelIconPath; iconColor: OsdState.levelAccent }
            }

            Rectangle {
                id: horizontalTrack
                Layout.fillWidth: true
                height: 12
                radius: 6
                color: Theme.border
                Rectangle {
                    width: parent.width * OsdState.value / OsdState.levelMaximum
                    height: parent.height
                    radius: parent.radius
                    color: OsdState.levelAccent
                    Behavior on width { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
                }
                Rectangle {
                    visible: OsdState.volumeBoosted
                    x: parent.width / 1.5 - width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 2
                    height: parent.height + 6
                    radius: 1
                    color: Theme.foreground
                    opacity: 0.55
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    function applyPosition(px) {
                        const maximum = OsdState.kind === "volume" ? OsdState.levelMaximum : 1
                        const value = Math.max(0, Math.min(maximum, px / width * maximum))
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
                color: OsdState.levelAccent
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
                VectorIcon { anchors.centerIn: parent; path: OsdState.levelIconPath; iconColor: OsdState.levelAccent }
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
                    height: parent.height * OsdState.value / OsdState.levelMaximum
                    radius: parent.radius
                    color: OsdState.levelAccent
                    Behavior on height { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
                }
                Rectangle {
                    visible: OsdState.volumeBoosted
                    y: parent.height / 3 - height / 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width + 6
                    height: 2
                    radius: 1
                    color: Theme.foreground
                    opacity: 0.55
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    function applyPosition(py) {
                        const maximum = OsdState.kind === "volume" ? OsdState.levelMaximum : 1
                        const value = Math.max(0, Math.min(maximum, (1 - py / height) * maximum))
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
                color: OsdState.levelAccent
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
