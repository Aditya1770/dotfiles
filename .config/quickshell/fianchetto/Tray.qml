import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Rectangle {
    id: root
    required property var hostWindow
    implicitWidth: trayRow.implicitWidth + 14
    implicitHeight: Theme.pillHeight
    radius: Theme.radius
    color: trayHover.hovered ? Theme.surfaceHover : Theme.surface
    border.width: 0

    HoverHandler { id: trayHover }
    Behavior on color { ColorAnimation { duration: 120 } }

    RowLayout {
        id: trayRow
        anchors.centerIn: parent
        spacing: 7

        Repeater {
            model: SystemTray.items

            Item {
                id: trayItem
                required property var modelData
                implicitWidth: 17
                implicitHeight: 22

                IconImage {
                    anchors.centerIn: parent
                    width: 13
                    height: 13
                    implicitSize: 13
                    mipmap: true
                    source: modelData.icon
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: event => {
                        if (event.button === Qt.LeftButton) modelData.activate()
                        else if (event.button === Qt.MiddleButton) modelData.secondaryActivate()
                        else if (modelData.hasMenu) {
                            const pos = root.hostWindow.itemPosition(trayItem)
                            modelData.display(root.hostWindow, Math.round(pos.x + trayItem.width / 2), Math.round(pos.y + trayItem.height))
                        }
                    }
                }
            }
        }
    }
}
