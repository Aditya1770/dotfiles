import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

Pill {
    id: root
    property bool compact: false
    horizontalPadding: compact ? 6 : 10
    readonly property var battery: UPower.displayDevice
    readonly property int percent: Math.round(battery.percentage * 100)
    readonly property bool full: battery.state === UPowerDeviceState.FullyCharged
        || percent >= 100
    readonly property bool charging: battery.state === UPowerDeviceState.Charging
        || battery.state === UPowerDeviceState.PendingCharge
    readonly property bool externallyPowered: !UPower.onBattery

    function batteryIcon() {
        if (charging || full) return "󰂄"
        if (percent > 90) return "󰁹"
        if (percent > 70) return "󰂁"
        if (percent > 50) return "󰁿"
        if (percent > 30) return "󰁽"
        if (percent > 10) return "󰁻"
        return "󰁺"
    }

    function formatDuration(seconds) {
        const total = Math.max(0, Math.round(Number(seconds) || 0))
        if (total === 0) return "Estimating…"
        const hours = Math.floor(total / 3600)
        const minutes = Math.floor((total % 3600) / 60)
        return (hours > 0 ? hours + " hr " : "") + minutes + " min"
    }

    RowLayout {
        IconText { text: root.batteryIcon(); color: root.externallyPowered ? Theme.green : Theme.text }
        BarText { visible: !root.compact; text: root.percent + "%"; color: root.externallyPowered ? Theme.green : Theme.text }
    }

    onClicked: popup.visible = !popup.visible

    ModulePopup {
        id: popup
        anchorItem: root
        implicitWidth: 300
        implicitHeight: 180

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 7
                IconText {
                    text: root.batteryIcon()
                    color: root.externallyPowered ? Theme.green : Theme.text
                    font.pixelSize: 13
                }
                BarText { text: "Battery"; font.pixelSize: 13 }
                Item { Layout.fillWidth: true }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 9
                BarText {
                    text: root.percent + "%"
                    color: root.externallyPowered ? Theme.green : Theme.text
                    font.pixelSize: 28
                }
                BarText {
                    text: root.full ? "Fully charged"
                        : root.charging ? "Charging"
                        : UPower.onBattery ? "On battery" : "Plugged in"
                    color: Theme.muted
                    font.pixelSize: 12
                    font.weight: Font.Normal
                    Layout.alignment: Qt.AlignVCenter
                }
                Item { Layout.fillWidth: true }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 10
                radius: 5
                color: Theme.surfaceHover
                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, root.battery.percentage))
                    height: parent.height
                    radius: parent.radius
                    color: root.externallyPowered ? Theme.green : Theme.text
                    Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                BarText { text: "Power draw"; color: Theme.muted; font.pixelSize: 11; Layout.fillWidth: true }
                BarText { text: Math.abs(root.battery.changeRate).toFixed(1) + " W"; font.pixelSize: 11 }
            }
            RowLayout {
                Layout.fillWidth: true
                visible: root.battery.healthSupported
                BarText { text: "Battery health"; color: Theme.muted; font.pixelSize: 11; Layout.fillWidth: true }
                BarText { text: Math.round(root.battery.healthPercentage * 100) + "%"; font.pixelSize: 11 }
            }
        }
    }
}
