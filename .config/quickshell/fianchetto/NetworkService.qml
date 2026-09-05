pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root
    readonly property var wifiDevice: Networking.devices.values.find(device => device.type === DeviceType.Wifi) || null
    readonly property var networks: wifiDevice ? wifiDevice.networks.values : []
    readonly property var connectedNetwork: networks.find(network => network.connected) || null
    readonly property bool enabled: Networking.wifiEnabled
    readonly property bool hardwareEnabled: Networking.wifiHardwareEnabled
    readonly property bool scanning: wifiDevice ? wifiDevice.scannerEnabled : false
    property bool scanningRequested: false

    function toggleWifi() {
        if (hardwareEnabled) {
            Networking.wifiEnabled = !Networking.wifiEnabled
            Qt.callLater(root.updateScanner)
        }
    }

    function updateScanner() {
        if (wifiDevice)
            wifiDevice.scannerEnabled = wifiDevice && enabled && scanningRequested
    }

    function scanNow() {
        scanningRequested = true
        scanStop.restart()
        updateScanner()
    }

    Timer {
        id: scanStop
        interval: 12000
        onTriggered: root.scanningRequested = false
    }

    onWifiDeviceChanged: updateScanner()
    onScanningRequestedChanged: updateScanner()
}
