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
    property var autoConnectAttempts: ({})

    function autoConnectEnabled(device) {
        const address = validAddress(device)
        const configured = ShellSettings.bluetoothAutoConnectDevices || []
        return address !== "" && configured.indexOf(address) !== -1
    }

    function setAutoConnect(device, enabled) {
        const address = validAddress(device)
        if (!address || !device || !device.paired) return

        let configured = (ShellSettings.bluetoothAutoConnectDevices || []).slice()
        const index = configured.indexOf(address)
        if (enabled && index === -1) configured.push(address)
        else if (!enabled && index !== -1) configured.splice(index, 1)
        ShellSettings.bluetoothAutoConnectDevices = configured

        if (enabled && !device.connected) {
            let attempts = Object.assign({}, autoConnectAttempts)
            attempts[address] = 0
            autoConnectAttempts = attempts
            Qt.callLater(root.tryAutoConnect)
        }
    }

    function tryAutoConnect() {
        if (!enabled || operationBusy) return
        const configured = ShellSettings.bluetoothAutoConnectDevices || []
        if (configured.length === 0) return

        const now = Date.now()
        for (let device of devices) {
            const address = validAddress(device)
            if (!device.paired || device.connected || configured.indexOf(address) === -1)
                continue
            if (now - (autoConnectAttempts[address] || 0) < 60000)
                continue

            let attempts = Object.assign({}, autoConnectAttempts)
            attempts[address] = now
            autoConnectAttempts = attempts
            runDeviceAction("autoconnect", device)
            return
        }
    }

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
        setAutoConnect(device, false)
        runDeviceAction("forget", device)
    }

    Timer {
        interval: 10000
        repeat: true
        running: root.enabled && (ShellSettings.bluetoothAutoConnectDevices || []).length > 0
        triggeredOnStart: true
        onTriggered: root.tryAutoConnect()
    }

    Process {
        id: bluetoothAction
        stdout: StdioCollector { id: bluetoothStdout }
        stderr: StdioCollector { id: bluetoothStderr }
        onExited: (exitCode, exitStatus) => {
            root.operationBusy = false
            root.operationError = exitCode === 0 || root.operationKind === "autoconnect" ? ""
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

    Connections {
        target: ShellSettings
        function onBluetoothAutoConnectDevicesChanged() { Qt.callLater(root.tryAutoConnect) }
    }

}
