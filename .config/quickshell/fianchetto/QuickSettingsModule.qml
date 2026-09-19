import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Pill {
    id: root
    horizontalPadding: compact ? 9 : 10
    property bool compact: false
    implicitHeight: compact ? statusGrid.implicitHeight + 12 : Theme.pillHeight
    property string page: "main"
    property string expandedNetwork: ""
    readonly property bool airplaneMode: !NetworkService.enabled && (!BluetoothService.available || !BluetoothService.enabled)
    readonly property bool powerProfilesVisible: PowerProfileService.supported && ShellSettings.showPowerProfiles
    readonly property int mainPopupHeight: {
        let height = 35 + 148
        if (ShellSettings.showQuickToggles) height += 10 + 42
        if (ShellSettings.showSliders) height += 10 + 118
        if (powerProfilesVisible) height += 10 + 58
        if (ShellSettings.showSystemStats) height += 10 + 72 + 10 + 55
        return height
    }

    function toggleAirplaneMode() {
        if (!root.airplaneMode) {
            if (NetworkService.enabled) NetworkService.toggleWifi()
            if (BluetoothService.enabled) BluetoothService.togglePower()
        } else {
            if (NetworkService.hardwareEnabled && !NetworkService.enabled) NetworkService.toggleWifi()
            if (BluetoothService.available && !BluetoothService.enabled) BluetoothService.togglePower()
        }
    }

    GridLayout {
        id: statusGrid
        columns: root.compact ? 1 : 3
        rowSpacing: root.compact ? 7 : 0
        columnSpacing: root.compact ? 0 : 9
        IconText { text: AudioService.muted || AudioService.volume === 0 ? "󰖁" : "󰕾"; color: Theme.pastelPeach }
        IconText { text: NetworkService.signalIcon; color: NetworkService.connectedNetwork ? Theme.pastelSky : Theme.muted }
        IconText { text: "󰂯"; color: BluetoothService.enabled ? Theme.pastelLilac : Theme.muted }
    }

    onClicked: {
        root.page = "main"
        popup.visible = !popup.visible
    }

    onWheel: delta => AudioService.setVolume(AudioService.volume + (delta > 0 ? 0.05 : -0.05))

    ModulePopup {
        id: popup
        anchorItem: root
        implicitWidth: 400
        implicitHeight: root.page === "main" ? root.mainPopupHeight
            : root.page === "notifications" ? 480
            : root.page === "nightlight" ? 210 : 420
        Behavior on implicitHeight {
            NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
        }
        onVisibleChanged: if (!visible) {
            root.page = "main"
            root.expandedNetwork = ""
            NetworkService.scanningRequested = false
            BluetoothService.scanningRequested = false
        }

        Item {
            anchors.fill: parent

            ColumnLayout {
                opacity: root.page === "main" ? 1 : 0
                visible: opacity > 0.01
                enabled: root.page === "main"
                anchors.fill: parent
                transform: Translate {
                    x: root.page === "main" ? 0 : -18
                    Behavior on x { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
                }
                anchors.margins: Theme.popupPadding
                spacing: 10

                GridLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 148
                    columns: 2
                    rowSpacing: 9
                    columnSpacing: 9

                    ColumnLayout {
                        Layout.column: ShellSettings.profileOnLeft ? 1 : 0
                        Layout.fillWidth: true
                        Layout.preferredWidth: 174
                        Layout.fillHeight: true
                        spacing: 8

                        QuickToggle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            icon: NetworkService.signalIcon
                            label: "Wi-Fi"
                            subtitle: !NetworkService.enabled ? "Off"
                                : NetworkService.connectedNetwork ? NetworkService.connectedNetwork.name : "Not connected"
                            active: NetworkService.enabled
                            accent: Theme.pastelSky
                            showArrow: true
                            onToggled: NetworkService.toggleWifi()
                            onDetailsRequested: { root.page = "wifi"; NetworkService.scanNow() }
                        }
                        QuickToggle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            icon: "󰂯"
                            label: "Bluetooth"
                            subtitle: !BluetoothService.enabled ? "Off"
                                : BluetoothService.connectedDevices.length > 0
                                    ? (BluetoothService.connectedDevices[0].name
                                        || BluetoothService.connectedDevices[0].deviceName || "Connected")
                                    : "Not connected"
                            active: BluetoothService.enabled
                            accent: Theme.pastelLilac
                            showArrow: true
                            onToggled: BluetoothService.togglePower()
                            onDetailsRequested: { root.page = "bluetooth"; BluetoothService.scanNow() }
                        }
                    }

                    GridLayout {
                        Layout.column: ShellSettings.profileOnLeft ? 0 : 1
                        Layout.fillWidth: true
                        Layout.preferredWidth: 174
                        Layout.fillHeight: true
                        columns: 2
                        rowSpacing: 9
                        columnSpacing: 9

                        Repeater {
                            model: [
                                { key: "mute", label: AudioService.microphoneMuted ? "Mic muted" : "Mute mic", icon: AudioService.microphoneMuted ? "󰍭" : "󰍬", accent: Theme.pastelButter },
                                { key: "settings", label: "Settings", icon: "󰒓", accent: Theme.pastelLilac },
                                { key: "airplane", label: "Airplane", icon: "󰀝", accent: Theme.pastelSky },
                                { key: "screenshot", label: "Screenshot", icon: "󰄀", accent: Theme.pastelMint }
                            ]
                            Rectangle {
                                required property var modelData
                                readonly property bool active: modelData.key === "mute" ? AudioService.microphoneMuted
                                    : modelData.key === "airplane" ? root.airplaneMode : false
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 18
                                color: active ? modelData.accent
                                    : actionMouse.containsMouse ? Theme.border : Theme.surfaceHover
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    IconText { Layout.alignment: Qt.AlignHCenter; text: modelData.icon; color: active ? Theme.background : modelData.accent; font.pixelSize: 18 }
                                    BarText { Layout.alignment: Qt.AlignHCenter; text: modelData.label; color: active ? Theme.background : Theme.text; font.pixelSize: 10 }
                                }
                                MouseArea {
                                    id: actionMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData.key === "mute") AudioService.toggleMicrophoneMute()
                                        else if (modelData.key === "airplane") root.toggleAirplaneMode()
                                        else if (modelData.key === "screenshot") {
                                            popup.visible = false
                                            Quickshell.execDetached(["grimblast", "copy", "area"])
                                        } else {
                                            popup.visible = false
                                            Qt.callLater(function() { SettingsWindow.showPage("control") })
                                        }
                                    }
                                }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }
                }

                GridLayout {
                    visible: ShellSettings.showQuickToggles
                    opacity: visible ? 1 : 0
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: 8
                    QuickToggle {
                        Layout.fillWidth: true
                        icon: "󰖔"
                        label: "Night Light"
                        active: NightLightService.enabled
                        accent: Theme.pastelButter
                        showArrow: true
                        onToggled: NightLightService.toggle()
                        onDetailsRequested: root.page = "nightlight"
                    }
                    QuickToggle {
                        Layout.fillWidth: true
                        icon: "󰂚"
                        label: "Notifications"
                        showArrow: true
                        accent: Theme.pastelRose
                        onToggled: root.page = "notifications"
                        onDetailsRequested: root.page = "notifications"
                    }
                    QuickToggle {
                        Layout.fillWidth: true
                        icon: "󰂛"
                        label: "DND"
                        active: NotificationService.doNotDisturb
                        accent: Theme.pastelLilac
                        onToggled: NotificationService.toggleDnd()
                    }
                }

                Rectangle {
                    visible: ShellSettings.showSliders
                    opacity: visible ? 1 : 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    implicitHeight: 118
                    radius: 15
                    color: Theme.surfaceHover
                    border.width: 0

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 0

                        SettingsSlider {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            showTitle: false
                            embedded: true
                            icon: AudioService.muted || AudioService.volume === 0 ? "󰖁" : "󰕾"
                            accent: Theme.pastelPeach
                            currentValue: AudioService.volume * 100
                            onValueMoved: newValue => AudioService.setVolume(newValue / 100)
                        }

                        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                        SettingsSlider {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            showTitle: false
                            embedded: true
                            icon: "󰃠"
                            accent: Theme.pastelButter
                            minimum: 1
                            currentValue: BrightnessService.brightness * 100
                            onValueMoved: newValue => BrightnessService.setBrightness(newValue / 100)
                        }
                    }
                }

                Rectangle {
                    visible: root.powerProfilesVisible
                    opacity: visible ? 1 : 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? 58 : 0
                    radius: 16
                    color: Theme.surfaceHover
                    border.width: 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 7
                        spacing: 6

                        Repeater {
                            model: PowerProfileService.availableProfiles
                            Rectangle {
                                required property string modelData
                                readonly property bool selected: PowerProfileService.currentProfile === modelData
                                readonly property color accent: PowerProfileService.accent(modelData)
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 12
                                color: selected ? accent : modeMouse.containsMouse ? Theme.surface : "transparent"
                                opacity: PowerProfileService.changing && !selected ? 0.62 : 1

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 1
                                    IconText {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: PowerProfileService.icon(modelData)
                                        color: selected ? Theme.background : accent
                                        font.pixelSize: 14
                                    }
                                    BarText {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: PowerProfileService.label(modelData)
                                        color: selected ? Theme.background : Theme.text
                                        font.pixelSize: 10
                                    }
                                }

                                MouseArea {
                                    id: modeMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    enabled: !PowerProfileService.changing
                                    onClicked: PowerProfileService.setProfile(modelData)
                                }
                            }
                        }
                    }
                }

                GridLayout {
                    visible: ShellSettings.showSystemStats
                    opacity: visible ? 1 : 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72
                    columns: 2
                    columnSpacing: 8

                    Repeater {
                        model: [
                            { label: "RAM", value: SystemStatsService.ramPercent, icon: "󰍛" },
                            { label: "CPU", value: SystemStatsService.cpuPercent, icon: "󰻠" }
                        ]
                        Rectangle {
                            required property int index
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 16
                            color: Theme.surfaceHover
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 5
                                RowLayout {
                                    Layout.fillWidth: true
                                    IconText { text: modelData.icon; color: index === 0 ? Theme.pastelLilac : Theme.pastelPeach }
                                    BarText { text: modelData.label; Layout.fillWidth: true; color: Theme.muted; font.pixelSize: 10 }
                                    BarText { text: modelData.value + "%"; color: Theme.blue }
                                }
                                Rectangle {
                                    Layout.fillWidth: true; height: 8; radius: 4; color: Theme.border
                                    Rectangle {
                                        width: parent.width * Math.max(0, Math.min(1, modelData.value / 100))
                                        height: parent.height; radius: parent.radius; color: Theme.blue
                                        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    visible: ShellSettings.showSystemStats
                    opacity: visible ? 1 : 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55
                    radius: 16
                    color: Theme.surfaceHover
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 11; anchors.rightMargin: 11
                        anchors.topMargin: 8; anchors.bottomMargin: 8
                        spacing: 4
                        RowLayout {
                            Layout.fillWidth: true
                            IconText { text: "󰋊"; color: Theme.pastelMint }
                            BarText { text: "Disk"; Layout.fillWidth: true; color: Theme.muted; font.pixelSize: 10 }
                            BarText {
                                text: SystemStatsService.diskUsedGb + " / " + SystemStatsService.diskTotalGb + " GB"
                                color: Theme.blue; font.pixelSize: 11
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true; height: 8; radius: 4; color: Theme.border
                            Rectangle {
                                width: parent.width * Math.max(0, Math.min(1, SystemStatsService.diskPercent / 100))
                                height: parent.height; radius: parent.radius; color: Theme.blue
                                Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                            }
                        }
                    }
                }

                Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            }

            ColumnLayout {
                opacity: root.page === "wifi" ? 1 : 0
                visible: opacity > 0.01
                enabled: root.page === "wifi"
                anchors.fill: parent
                transform: Translate {
                    x: root.page === "wifi" ? 0 : 18
                    Behavior on x { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
                }
                anchors.margins: Theme.popupPadding
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    IconText {
                        text: "󰁍"
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -7
                            onClicked: { NetworkService.scanningRequested = false; root.page = "main" }
                        }
                    }
                    BarText { text: "Network"; font.pixelSize: 15; Layout.fillWidth: true }
                    Pill {
                        horizontalPadding: 10
                        IconText {
                            text: "󰑐"
                            color: Theme.blue
                            RotationAnimator on rotation {
                                from: 0; to: 360; duration: 850
                                loops: Animation.Infinite
                                running: NetworkService.scanning
                            }
                        }
                        BarText { text: NetworkService.scanning ? "Scanning" : "Scan"; font.pixelSize: 11 }
                        onClicked: NetworkService.scanNow()
                    }
                }

                SettingsHeader {
                    Layout.fillWidth: true
                    icon: "󰖩"
                    title: NetworkService.enabled ? "Wi-Fi" : "Wi-Fi off"
                    subtitle: NetworkService.connectedNetwork ? NetworkService.connectedNetwork.name
                        : NetworkService.scanning ? "Scanning…" : "Not connected"
                    active: NetworkService.enabled
                    onToggled: NetworkService.toggleWifi()
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 3
                    visible: NetworkService.enabled && NetworkService.wifiDevice !== null
                    boundsBehavior: Flickable.StopAtBounds
                    model: NetworkService.networks
                    delegate: WifiNetworkCard {
                        width: ListView.view.width
                        passwordEditorExpanded: root.expandedNetwork === network.name
                        onPasswordEditorRequested: {
                            NetworkService.pauseScanning()
                            root.expandedNetwork = network.name
                        }
                        onPasswordEditorClosed: root.expandedNetwork = ""
                    }
                }

                Item { Layout.fillHeight: true; visible: !NetworkService.enabled }

                Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            }

            ColumnLayout {
                opacity: root.page === "bluetooth" ? 1 : 0
                visible: opacity > 0.01
                enabled: root.page === "bluetooth"
                anchors.fill: parent
                anchors.margins: Theme.popupPadding
                spacing: 8
                transform: Translate {
                    x: root.page === "bluetooth" ? 0 : 18
                    Behavior on x { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
                }

                RowLayout {
                    Layout.fillWidth: true
                    IconText {
                        text: "󰁍"
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -7
                            onClicked: { BluetoothService.scanningRequested = false; root.page = "main" }
                        }
                    }
                    BarText { text: "Devices"; font.pixelSize: 15; Layout.fillWidth: true }
                    Pill {
                        horizontalPadding: 10
                        IconText {
                            text: "󰑐"
                            color: Theme.purple
                            RotationAnimator on rotation {
                                from: 0; to: 360; duration: 850
                                loops: Animation.Infinite
                                running: BluetoothService.scanning
                            }
                        }
                        BarText { text: BluetoothService.scanning ? "Scanning" : "Scan"; font.pixelSize: 11 }
                        onClicked: BluetoothService.scanNow()
                    }
                }

                SettingsHeader {
                    Layout.fillWidth: true
                    icon: "󰂯"
                    title: BluetoothService.enabled ? "Bluetooth" : "Bluetooth off"
                    subtitle: !BluetoothService.available ? "No adapter"
                        : BluetoothService.scanning ? "Scanning for devices…" : "Ready"
                    active: BluetoothService.enabled
                    toggleEnabled: BluetoothService.available
                    onToggled: BluetoothService.togglePower()
                }

                Item { Layout.fillHeight: true; visible: !BluetoothService.enabled }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 3
                    visible: BluetoothService.enabled
                    boundsBehavior: Flickable.StopAtBounds
                    property var combinedDevices: BluetoothService.pairedDevices.concat(BluetoothService.availableDevices)
                    model: combinedDevices
                    delegate: BluetoothDeviceCard {
                        width: ListView.view.width
                        onActivationRequested: device => BluetoothService.activateDevice(device)
                        onForgetRequested: device => BluetoothService.forgetDevice(device)
                    }
                }

                Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            }

            ColumnLayout {
                opacity: root.page === "notifications" ? 1 : 0
                visible: opacity > 0.01
                enabled: root.page === "notifications"
                anchors.fill: parent
                anchors.margins: Theme.popupPadding
                spacing: 8
                transform: Translate {
                    x: root.page === "notifications" ? 0 : 18
                    Behavior on x { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
                }

                RowLayout {
                    Layout.fillWidth: true
                    IconText {
                        text: "󰁍"
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -7
                            onClicked: root.page = "main"
                        }
                    }
                    BarText {
                        text: "Notifications"
                        font.pixelSize: 15
                        Layout.fillWidth: true
                    }
                    Pill {
                        visible: NotificationService.count > 0
                        horizontalPadding: 10
                        IconText { text: "󰃢"; color: Theme.pastelRose }
                        BarText { text: "Clear"; font.pixelSize: 11 }
                        onClicked: NotificationService.clear()
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: NotificationService.notifications
                    spacing: 7
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    visible: NotificationService.count > 0

                    delegate: Item {
                        id: notificationDelegate
                        required property int notificationId
                        required property string appName
                        required property string summary
                        required property string body
                        required property string icon
                        required property string image
                        required property var object
                        required property var receivedAt
                        width: ListView.view.width
                        height: notificationCard.implicitHeight

                        NotificationCard {
                            id: notificationCard
                            anchors.fill: parent
                            notificationId: notificationDelegate.notificationId
                            appName: notificationDelegate.appName
                            summary: notificationDelegate.summary
                            body: notificationDelegate.body
                            iconSource: notificationDelegate.icon
                            imageSource: notificationDelegate.image
                            notificationObject: notificationDelegate.object
                            receivedAt: notificationDelegate.receivedAt
                            onCloseRequested: id => NotificationService.remove(id, true)
                            onActionRequested: (id, action) => NotificationService.invokeAction(id, action)
                            onDefaultActionRequested: id => NotificationService.invokeDefaultAction(id)
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: NotificationService.count === 0
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        IconText {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰂚"
                            color: Theme.muted
                            font.pixelSize: 30
                        }
                        BarText { text: "No notifications"; color: Theme.muted }
                    }
                }

                Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            }

            ColumnLayout {
                opacity: root.page === "nightlight" ? 1 : 0
                visible: opacity > 0.01
                enabled: root.page === "nightlight"
                anchors.fill: parent
                anchors.margins: Theme.popupPadding
                spacing: 10
                transform: Translate {
                    x: root.page === "nightlight" ? 0 : 18
                    Behavior on x { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
                }

                RowLayout {
                    Layout.fillWidth: true
                    IconText {
                        text: "󰁍"
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -7
                            onClicked: root.page = "main"
                        }
                    }
                    BarText {
                        Layout.fillWidth: true
                        text: "Night Light"
                        font.pixelSize: 15
                    }
                }

                SettingsHeader {
                    Layout.fillWidth: true
                    icon: "󰖔"
                    title: NightLightService.enabled ? "Night Light on" : "Night Light off"
                    subtitle: NightLightService.enabled
                        ? "Warm colour temperature active" : "Colours are unchanged"
                    active: NightLightService.enabled
                    onToggled: NightLightService.toggle()
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 62
                    radius: 18
                    color: Theme.surfaceHover
                    border.width: 0

                    SettingsSlider {
                        anchors.fill: parent
                        showTitle: false
                        embedded: true
                        icon: "󰖔"
                        accent: Theme.pastelButter
                        minimum: 1000
                        maximum: 6500
                        currentValue: NightLightService.temperature
                        onValueMoved: value => NightLightService.setTemperature(value)
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            }
        }
    }
}
