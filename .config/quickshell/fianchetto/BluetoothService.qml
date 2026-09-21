pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
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
    property bool scanningRequested: false
    property bool operationBusy: false
    property string operationAddress: ""
    property string operationKind: ""
    property string operationError: ""

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

    function validAddress(device) {
        if (!device) return ""
        const address = String(device.address || "").trim().toUpperCase()
        return /^([0-9A-F]{2}:){5}[0-9A-F]{2}$/.test(address) ? address : ""
    }

    function runDeviceAction(action, device) {
        const address = validAddress(device)
        if (!address || bluetoothAction.running)
            return false

        operationAddress = address
        operationKind = action
        operationError = ""
        operationBusy = true
        bluetoothAction.command = ["/bin/sh", Quickshell.shellPath("scripts/bluetooth-device.sh"), action, address]
        bluetoothAction.running = true
        return true
    }

    function activateDevice(device) {
        if (!device) return
        runDeviceAction(device.connected ? "disconnect" : device.paired ? "connect" : "pair", device)
    }

    function forgetDevice(device) {
        if (!device) return

        runDeviceAction("forget", device)
    }

    Process {
        id: bluetoothAction
        stdout: StdioCollector { id: bluetoothStdout }
        stderr: StdioCollector { id: bluetoothStderr }
        onExited: (exitCode, exitStatus) => {
            root.operationBusy = false
            root.operationError = exitCode === 0 ? ""
                : (bluetoothStderr.text.trim() || bluetoothStdout.text.trim() || "Bluetooth operation failed")
            if (root.enabled)
                root.scanNow()
        }
    }

    onScanningRequestedChanged: updateScanner()

    Connections {
        target: Bluetooth
        function onDefaultAdapterChanged() { root.updateScanner() }
    }

}
