pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    readonly property bool scanning: available && adapter.discovering
    readonly property var devices: Bluetooth.devices.values
    readonly property var connectedDevices: devices.filter(device => device.connected)
    readonly property var pairedDevices: devices.filter(device => device.paired)
    readonly property var availableDevices: devices.filter(device => {
        if (device.paired || device.connected) return false
        const name = (device.name || device.deviceName || "").trim()
        if (!name) return false
        // BlueZ uses a MAC address as the temporary name for devices that
        // have not supplied useful identity data yet. Hide those entries.
        return !/^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$/.test(name)
    })
    property var pendingPairDevice: null
    property bool scanningRequested: false

    function togglePower() {
        if (adapter) {
            adapter.enabled = !adapter.enabled
            Qt.callLater(root.updateScanner)
        }
    }

    function updateScanner() {
        if (adapter)
            adapter.discovering = adapter.enabled && scanningRequested
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

    function activateDevice(device) {
        if (device.connected) device.disconnect()
        else if (device.paired) device.connect()
        else {
            pendingPairDevice = device
            device.pair()
        }
    }

    onScanningRequestedChanged: updateScanner()

    Connections {
        target: Bluetooth
        function onDefaultAdapterChanged() { root.updateScanner() }
    }

    Connections {
        target: root.pendingPairDevice
        ignoreUnknownSignals: true
        function onPairedChanged() {
            if (root.pendingPairDevice && root.pendingPairDevice.paired) {
                root.pendingPairDevice.trusted = true
                root.pendingPairDevice.connect()
                root.pendingPairDevice = null
            }
        }
    }
}
