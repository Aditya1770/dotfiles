pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
    id: root
    readonly property var wifiDevice: Networking.devices.values.find(device => device.type === DeviceType.Wifi) || null
    readonly property var networks: wifiDevice ? wifiDevice.networks.values : []
    readonly property var connectedNetwork: networks.find(network => network.connected) || null
    readonly property real signalStrength: {
        if (!connectedNetwork || connectedNetwork.signalStrength === undefined)
            return 0
        const raw = connectedNetwork.signalStrength
        return raw <= 1 ? raw * 100 : raw
    }
    readonly property string signalIcon: !enabled ? "󰤮"
        : !connectedNetwork ? "󰤯"
        : signalStrength >= 80 ? "󰤨"
        : signalStrength >= 60 ? "󰤥"
        : signalStrength >= 40 ? "󰤢"
        : signalStrength >= 20 ? "󰤟" : "󰤯"
    readonly property bool enabled: Networking.wifiEnabled
    readonly property bool hardwareEnabled: Networking.wifiHardwareEnabled
    // scannerEnabled owns the live access-point model. It must remain enabled
    // for as long as the Wi-Fi page is open or NetworkManager removes the rows.
    readonly property bool scannerActive: wifiDevice ? wifiDevice.scannerEnabled : false
    property bool scanning: false
    property bool scanningRequested: false
    property bool enterpriseConnecting: false
    property string enterpriseNetworkName: ""
    property string enterpriseError: ""
    property string pendingEnterprisePassword: ""
    signal enterpriseConnectionFinished(string networkName, bool success)

    function isEnterprise(network) {
        return network && (network.security === WifiSecurityType.WpaEap
            || network.security === WifiSecurityType.Wpa2Eap
            || network.security === WifiSecurityType.Wpa3SuiteB192)
    }

    function connectEnterprise(network, identity, password) {
        const cleanIdentity = identity.trim()
        if (!network || !wifiDevice || !cleanIdentity || !password || enterpriseConnector.running)
            return false

        enterpriseNetworkName = network.name
        enterpriseError = ""
        enterpriseConnecting = true
        pendingEnterprisePassword = password
        enterpriseConnector.command = ["/bin/sh", Quickshell.shellPath("scripts/connect-enterprise-wifi.sh"),
            wifiDevice.name, network.name, cleanIdentity]
        enterpriseConnector.running = true
        return true
    }

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
        // Keep the backing model alive until the Wi-Fi page closes. The timer
        // below only controls the visual "Scanning" state.
        scanningRequested = true
        scanning = true
        scanStop.restart()
        updateScanner()
    }

    function pauseScanning() {
        // Credential editors must not tear down the model they are editing.
        // Stop only the spinner; the page's backing scanner remains enabled.
        scanning = false
    }

    Timer {
        id: scanStop
        interval: 2200
        onTriggered: root.scanning = false
    }

    Process {
        id: enterpriseConnector
        stdinEnabled: true
        stderr: StdioCollector { id: enterpriseStderr }
        onStarted: {
            // The helper reads exactly one line, so it does not need stdin to be
            // closed before it can continue. Avoid placing secrets in argv.
            write(root.pendingEnterprisePassword.replace(/[\r\n]/g, "") + "\n")
            root.pendingEnterprisePassword = ""
        }
        onExited: (exitCode, exitStatus) => {
            const name = root.enterpriseNetworkName
            root.pendingEnterprisePassword = ""
            root.enterpriseConnecting = false
            root.enterpriseError = exitCode === 0 ? "" : (enterpriseStderr.text.trim() || "Could not connect")
            root.enterpriseConnectionFinished(name, exitCode === 0)
        }
    }

    onWifiDeviceChanged: updateScanner()
    onScanningRequestedChanged: {
        if (!scanningRequested) {
            scanStop.stop()
            scanning = false
        }
        updateScanner()
    }
}
