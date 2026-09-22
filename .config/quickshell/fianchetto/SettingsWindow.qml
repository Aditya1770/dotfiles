pragma Singleton
import QtQuick
import QtQuick.Layouts
import Quickshell

FloatingWindow {
    id: root
    property string page: "appearance"
    property string expandedWifi: ""
    property string expandedBluetooth: ""
    property bool fontPickerOpen: false
    property bool showAllFonts: false
    property var installedFonts: []
    property string pendingNotificationKey: ""
    property var pendingNotificationValue
    visible: false
    title: "Fianchetto Settings"
    color: Theme.surface
    implicitWidth: 920
    implicitHeight: 620
    minimumSize.width: 720
    minimumSize.height: 520

    function matchingFonts(query) {
        const needle = query.trim().toLowerCase()
        const families = installedFonts
        if (showAllFonts || needle.length === 0) return families
        return families.filter(name => name.toLowerCase().includes(needle))
    }

    Component.onCompleted: Qt.callLater(function() { root.installedFonts = Qt.fontFamilies() })

    function showPage(nextPage) {
        page = nextPage || "appearance"
        visible = true
    }

    function scheduleOsdGeometry(key, value) {
        ShellSettings[key] = value
        // Keep the existing OSD mapped while dragging. show() only refreshes
        // its value and auto-hide timer, so the card follows the offset
        // without replaying its entrance fade for every slider event.
        OsdState.show("volume", 0.68, false)
    }

    function scheduleNotificationGeometry(key, value) {
        NotificationService.beginPreviewChange()
        pendingNotificationKey = key
        pendingNotificationValue = value
        notificationGeometryTimer.restart()
    }

    Timer {
        id: notificationGeometryTimer
        interval: 60
        onTriggered: ShellSettings[root.pendingNotificationKey] = root.pendingNotificationValue
    }

    onPageChanged: {
        ThemeManager.watching = visible && page === "appearance"
        if (ThemeManager.watching) ThemeManager.refresh()
        if (page === "wifi") NetworkService.scanNow()
        else if (page === "bluetooth") BluetoothService.scanNow()
        else {
            NetworkService.scanningRequested = false
            BluetoothService.scanningRequested = false
        }
    }
    onVisibleChanged: {
        ThemeManager.watching = visible && page === "appearance"
        if (ThemeManager.watching) ThemeManager.refresh()
        if (!visible) {
            NetworkService.scanningRequested = false
            BluetoothService.scanningRequested = false
            expandedWifi = ""
            expandedBluetooth = ""
            fontPickerOpen = false
            showAllFonts = false
        }
    }
    onClosed: visible = false

    Connections {
        target: ShellSettings
        function onSettingsRequested(page) { root.showPage(page) }
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.visible
        onActivated: root.visible = false
    }

    Rectangle {
        anchors.fill: parent
        radius: 0
        color: Theme.surface
        border.width: 0

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 205
                Layout.fillHeight: true
                color: Theme.background
                radius: 22

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 6
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 12
                        IconText { text: "󰒓"; color: Theme.pastelLilac; font.pixelSize: 22 }
                        ColumnLayout {
                            spacing: 0
                            BarText { text: "Fianchetto"; font.pixelSize: 17 }
                            BarText { text: "Settings"; color: Theme.muted; font.pixelSize: 11 }
                        }
                    }
                    Repeater {
                        model: [
                            { key: "appearance", label: "Appearance", icon: "󰏘" },
                            { key: "control", label: "Control Center", icon: "󰒓" },
                            { key: "bar", label: "Bar", icon: "󰍜" },
                            { key: "osd", label: "OSD", icon: "󰕾" },
                            { key: "notifications", label: "Notifications", icon: "󰂚" },
                            { key: "wifi", label: "Wi‑Fi", icon: "󰤨" },
                            { key: "bluetooth", label: "Bluetooth", icon: "󰂯" },
                            { key: "nightlight", label: "Night Light", icon: "󰖔" },
                            { key: "media", label: "Media", icon: "󰎆" }
                        ]
                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 40
                            radius: 12
                            color: root.page === modelData.key ? Theme.surfaceHover : navMouse.containsMouse ? Theme.border : "transparent"
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 13
                                anchors.rightMargin: 13
                                IconText {
                                    text: modelData.icon
                                    color: root.page !== modelData.key ? Theme.muted
                                        : modelData.key === "appearance" ? Theme.pastelLilac
                                        : modelData.key === "control" || modelData.key === "wifi" ? Theme.pastelSky
                                        : modelData.key === "bluetooth" ? Theme.pastelLilac
                                        : modelData.key === "nightlight" ? Theme.pastelButter : Theme.pastelMint
                                }
                                BarText { Layout.fillWidth: true; text: modelData.label; font.pixelSize: 13 }
                            }
                            MouseArea {
                                id: navMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.page = modelData.key
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 38
                        radius: 12
                        color: resetMouse.containsMouse ? Theme.border : "transparent"
                        BarText { anchors.centerIn: parent; text: "Reset defaults"; color: Theme.red; font.pixelSize: 12 }
                        MouseArea { id: resetMouse; anchors.fill: parent; hoverEnabled: true; onClicked: ShellSettings.reset() }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 24
                    contentHeight: pageColumn.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: pageColumn
                        width: parent.width
                        spacing: 12

                        BarText {
                            text: root.page === "appearance" ? "Theme and Appearance"
                                : root.page === "control" ? "Control Center"
                                : root.page === "bar" ? "Bar"
                                : root.page === "osd" ? "OSD"
                                : root.page === "notifications" ? "Notifications"
                                : root.page === "wifi" ? "Wi‑Fi"
                                : root.page === "bluetooth" ? "Bluetooth"
                                : root.page === "nightlight" ? "Night Light"
                                : "Media"
                            font.pixelSize: 28
                        }
                        BarText {
                            text: root.page === "appearance" ? "Colours, typography and scale across the shell"
                                : root.page === "control" ? "Choose what appears and where the action panel sits"
                                : root.page === "bar" ? "Size and launcher presentation"
                                : root.page === "osd" ? "Position, spacing and interaction"
                                : root.page === "notifications" ? "Toast position and distance from the screen edge"
                                : root.page === "wifi" ? "Wireless status and controls"
                                : root.page === "bluetooth" ? "Adapter and connected-device status"
                                : root.page === "nightlight" ? "Reduce blue light and tune screen warmth"
                                : "Playback presentation and animation"
                            color: Theme.muted
                            font.pixelSize: 13
                            Layout.bottomMargin: 8
                        }

                        ColumnLayout {
                            visible: root.page === "appearance"
                            Layout.fillWidth: true
                            spacing: 14
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: themeGrid.implicitHeight + 70
                                radius: 20
                                color: Theme.surfaceHover
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    BarText { text: "Colour scheme"; font.pixelSize: 16 }
                                    GridLayout {
                                        id: themeGrid
                                        Layout.fillWidth: true
                                        columns: 4
                                        columnSpacing: 10
                                        rowSpacing: 10
                                        Repeater {
                                            model: [
                                                { id: "fianchetto", name: "Fianchetto", bg: "#070B0D", accent: "#67B0E8" },
                                                { id: "oled", name: "OLED", bg: "#000000", accent: "#7BC8F6" },
                                                { id: "slate", name: "Slate", bg: "#0B1013", accent: "#8AB4D6" },
                                                { id: "matugen", name: "Matugen", bg: "#101418", accent: "#8FCDF4" }
                                            ].concat(ThemeManager.themes)
                                            Rectangle {
                                                required property var modelData
                                                Layout.fillWidth: true
                                                Layout.minimumWidth: 128
                                                implicitHeight: 62
                                                radius: 15
                                                color: modelData.bg
                                                readonly property bool selected: modelData.path
                                                    ? ShellSettings.scheme === "custom" && ShellSettings.themeFile === modelData.path
                                                    : ShellSettings.scheme === modelData.id
                                                border.width: selected ? 2 : 1
                                                border.color: selected ? modelData.accent : Theme.border
                                                RowLayout {
                                                    anchors.centerIn: parent
                                                    Rectangle { width: 15; height: 15; radius: 8; color: modelData.accent }
                                                    BarText { text: modelData.name; font.pixelSize: 12 }
                                                }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (modelData.path) ThemeManager.applyTheme(modelData.path)
                                                        else {
                                                            ShellSettings.themeFile = ""
                                                            ShellSettings.scheme = modelData.id
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.minimumWidth: 128
                                            implicitHeight: 62
                                            radius: 15
                                            color: importThemeMouse.containsMouse ? Theme.border : Theme.background
                                            border.width: 1
                                            border.color: Theme.pastelSky
                                            RowLayout {
                                                anchors.centerIn: parent
                                                IconText { text: "󰉋"; color: Theme.pastelSky; font.pixelSize: 16 }
                                                BarText { text: "Import JSON"; font.pixelSize: 12 }
                                            }
                                            MouseArea {
                                                id: importThemeMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: ThemeManager.chooseFile()
                                            }
                                        }
                                    }
                                    BarText { visible: ThemeManager.error !== ""; text: ThemeManager.error; color: Theme.red; font.pixelSize: 11 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 104
                                radius: 20
                                color: Theme.surfaceHover
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 14
                                    IconText { text: "󰏘"; color: Theme.pastelSky; font.pixelSize: 22 }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 3
                                        BarText { text: "Wallpaper colours"; font.pixelSize: 16 }
                                        BarText {
                                            Layout.fillWidth: true
                                            text: "Install the template once, then enable Matugen command and Matugen colour source in skwd-wall."
                                            color: Theme.muted
                                            font.pixelSize: 11
                                            wrapMode: Text.WordWrap
                                        }
                                        BarText {
                                            visible: ThemeManager.matugenStatus !== ""
                                            text: ThemeManager.matugenStatus
                                            color: Theme.pastelMint
                                            font.pixelSize: 11
                                        }
                                    }
                                    MaterialButton {
                                        label: ThemeManager.installingMatugen ? "Installing…" : "Install Matugen setup"
                                        accent: Theme.pastelSky
                                        onClicked: ThemeManager.installMatugen()
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 202
                                radius: 20
                                color: Theme.surfaceHover
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 8
                                    RowLayout {
                                        Layout.fillWidth: true
                                        BarText { text: "Application themes"; font.pixelSize: 16; Layout.fillWidth: true }
                                        MaterialButton {
                                            label: ThemeManager.syncingApps ? "Applying…" : "Apply now"
                                            accent: Theme.pastelSky
                                            onClicked: ThemeManager.syncIntegrations()
                                        }
                                    }
                                    BarText {
                                        text: "Keep supported applications on the selected Fianchetto palette."
                                        color: Theme.muted
                                        font.pixelSize: 11
                                    }
                                    Repeater {
                                        model: [
                                            { label: "Kitty", key: "syncKittyTheme", accent: Theme.pastelSky },
                                            { label: "Hyprland", key: "syncHyprlandTheme", accent: Theme.pastelLilac },
                                            { label: "Spicetify Text", key: "syncSpicetifyTheme", accent: Theme.pastelMint }
                                        ]
                                        RowLayout {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            BarText { text: modelData.label; Layout.fillWidth: true; font.pixelSize: 13 }
                                            MaterialSwitch {
                                                checked: ShellSettings[modelData.key]
                                                accent: modelData.accent
                                                onToggled: value => ShellSettings[modelData.key] = value
                                            }
                                        }
                                    }
                                    BarText {
                                        visible: ThemeManager.integrationStatus !== ""
                                        text: ThemeManager.integrationStatus
                                        color: Theme.muted
                                        font.pixelSize: 10
                                    }
                                }
                            }
                            Rectangle {
                                id: fontCard
                                Layout.fillWidth: true
                                implicitHeight: 208
                                radius: 20
                                color: Theme.surfaceHover
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 10
                                    BarText { text: "Shell font"; font.pixelSize: 16 }
                                    Rectangle {
                                        id: fontField
                                        Layout.fillWidth: true
                                        implicitHeight: 40
                                        radius: 12
                                        color: Theme.background
                                        TextInput {
                                            id: fontInput
                                            anchors.fill: parent
                                            anchors.leftMargin: 13; anchors.rightMargin: 42
                                            verticalAlignment: Text.AlignVCenter
                                            text: ShellSettings.fontFamily
                                            color: Theme.text
                                            selectionColor: Theme.pastelLilac
                                            font.family: Typography.textFamily
                                            font.pixelSize: 13
                                            selectByMouse: true
                                            onActiveFocusChanged: if (activeFocus) root.fontPickerOpen = true
                                            onTextEdited: {
                                                root.showAllFonts = false
                                                root.fontPickerOpen = true
                                            }
                                            onEditingFinished: if (text.trim().length > 0) ShellSettings.fontFamily = text.trim()
                                        }
                                        IconText {
                                            anchors.right: parent.right
                                            anchors.rightMargin: 13
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: root.fontPickerOpen ? "󰅀" : "󰅂"
                                            color: Theme.pastelSky
                                            font.pixelSize: 15
                                            MouseArea {
                                                anchors.fill: parent
                                                anchors.margins: -10
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (root.fontPickerOpen && root.showAllFonts) {
                                                        root.fontPickerOpen = false
                                                        root.showAllFonts = false
                                                    } else {
                                                        root.showAllFonts = true
                                                        root.fontPickerOpen = true
                                                    }
                                                    fontInput.forceActiveFocus()
                                                }
                                            }
                                        }
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        BarText { text: "Scale"; Layout.fillWidth: true; color: Theme.muted }
                                        BarText { text: Math.round(ShellSettings.fontScale * 100) + "%"; color: Theme.blue }
                                    }
                                    SettingsSlider {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 54
                                        showTitle: false
                                        embedded: true
                                        icon: "󰛖"
                                        accent: Theme.pastelLilac
                                        minimum: 80
                                        maximum: 130
                                        currentValue: ShellSettings.fontScale * 100
                                        onValueMoved: value => ShellSettings.fontScale = Math.round(value / 5) * 0.05
                                    }
                                }

                                Rectangle {
                                    id: fontSuggestions
                                    property var matches: root.matchingFonts(fontInput.text)
                                    visible: root.fontPickerOpen && matches.length > 0
                                    x: 18
                                    y: 92
                                    width: fontCard.width - 36
                                    height: Math.min(204, matches.length * 34 + 8)
                                    z: 50
                                    radius: 12
                                    color: Theme.background
                                    border.width: 1
                                    border.color: Theme.border
                                    clip: true

                                    ListView {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        model: fontSuggestions.matches
                                        spacing: 0
                                        clip: true
                                        boundsBehavior: Flickable.StopAtBounds
                                        cacheBuffer: 240
                                        delegate: Rectangle {
                                            required property string modelData
                                            width: ListView.view.width
                                            height: 34
                                            radius: 9
                                            color: fontChoiceMouse.containsMouse ? Theme.surfaceHover : "transparent"
                                            BarText {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 10
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData
                                                font.family: modelData
                                                font.pixelSize: 13
                                            }
                                            MouseArea {
                                                id: fontChoiceMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    fontInput.text = modelData
                                                    ShellSettings.fontFamily = modelData
                                                    root.fontPickerOpen = false
                                                    root.showAllFonts = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            visible: root.page === "osd"
                            Layout.fillWidth: true
                            spacing: 12

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 112
                                radius: 18
                                color: Theme.surfaceHover
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 10
                                    BarText { text: "Screen position"; font.pixelSize: 14 }
                                    GridLayout {
                                        Layout.fillWidth: true
                                        columns: 4
                                        columnSpacing: 8
                                        Repeater {
                                            model: ["Top", "Bottom", "Left", "Right"]
                                            Rectangle {
                                                required property string modelData
                                                readonly property string value: modelData.toLowerCase()
                                                Layout.fillWidth: true
                                                implicitHeight: 46
                                                radius: 12
                                                color: osdPositionMouse.containsMouse ? Theme.border : Theme.background
                                                border.width: ShellSettings.osdPosition === value ? 2 : 1
                                                border.color: ShellSettings.osdPosition === value ? Theme.pastelSky : Theme.border
                                                BarText { anchors.centerIn: parent; text: modelData; font.pixelSize: 11 }
                                                MouseArea {
                                                    id: osdPositionMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        root.scheduleOsdGeometry("osdPosition", parent.value)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Repeater {
                                model: [
                                    { label: "Horizontal offset", key: "osdHorizontalOffset", icon: "󰁍" },
                                    { label: "Vertical offset", key: "osdVerticalOffset", icon: "󰁅" }
                                ]
                                Rectangle {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 102
                                    radius: 18
                                    color: Theme.surfaceHover
                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 2
                                        RowLayout {
                                            Layout.fillWidth: true
                                            BarText { text: modelData.label; font.pixelSize: 14 }
                                            Item { Layout.fillWidth: true }
                                            BarText {
                                                text: Math.round(ShellSettings[modelData.key]) + " px"
                                                color: Theme.pastelSky
                                                font.pixelSize: 12
                                            }
                                        }
                                        SettingsSlider {
                                            Layout.fillWidth: true
                                            title: ""
                                            icon: modelData.icon
                                            showTitle: false
                                            embedded: true
                                            minimum: 0
                                            maximum: 240
                                            currentValue: ShellSettings[modelData.key]
                                            onValueMoved: value => {
                                                root.scheduleOsdGeometry(modelData.key, Math.round(value))
                                            }
                                        }
                                    }
                                }
                            }

                            BarText {
                                text: "Offsets move independently on each axis. The OSD preview follows while dragging."
                                color: Theme.muted
                                font.pixelSize: 11
                            }
                        }

                        ColumnLayout {
                            visible: root.page === "notifications"
                            Layout.fillWidth: true
                            spacing: 12

                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 58; radius: 17; color: Theme.surfaceHover
                                BarText { anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter; text: "Notification shadow"; font.pixelSize: 14 }
                                MaterialSwitch {
                                    anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter
                                    checked: ShellSettings.notificationShadow; accent: Theme.pastelSky
                                    onToggled: checked => ShellSettings.notificationShadow = checked
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 184
                                radius: 18
                                color: Theme.surfaceHover
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 10
                                    BarText { text: "Toast position"; font.pixelSize: 14 }
                                    GridLayout {
                                        Layout.fillWidth: true
                                        columns: 3
                                        columnSpacing: 8
                                        rowSpacing: 8
                                        Repeater {
                                            model: [
                                                { label: "Top left", value: "top-left" },
                                                { label: "Top center", value: "top-center" },
                                                { label: "Top right", value: "top-right" },
                                                { label: "Bottom left", value: "bottom-left" },
                                                { label: "Bottom right", value: "bottom-right" }
                                            ]
                                            Rectangle {
                                                required property var modelData
                                                Layout.fillWidth: true
                                                implicitHeight: 54
                                                radius: 12
                                                color: notificationPositionMouse.containsMouse ? Theme.border : Theme.background
                                                border.width: ShellSettings.notificationPosition === modelData.value ? 2 : 1
                                                border.color: ShellSettings.notificationPosition === modelData.value ? Theme.pastelSky : Theme.border
                                                Column {
                                                    anchors.centerIn: parent
                                                    spacing: 5
                                                    Rectangle {
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        width: 30
                                                        height: 14
                                                        radius: 5
                                                        color: Theme.border
                                                        Rectangle {
                                                            width: 9
                                                            height: 5
                                                            radius: 3
                                                            color: Theme.pastelSky
                                                            anchors.top: modelData.value.startsWith("top-") ? parent.top : undefined
                                                            anchors.bottom: modelData.value.startsWith("bottom-") ? parent.bottom : undefined
                                                            anchors.left: modelData.value.endsWith("-left") ? parent.left : undefined
                                                            anchors.right: modelData.value.endsWith("-right") ? parent.right : undefined
                                                            anchors.horizontalCenter: modelData.value === "top-center" ? parent.horizontalCenter : undefined
                                                        }
                                                    }
                                                    BarText {
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: modelData.label
                                                        font.pixelSize: 10
                                                    }
                                                }
                                                MouseArea {
                                                    id: notificationPositionMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        root.scheduleNotificationGeometry("notificationPosition", parent.modelData.value)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Repeater {
                                model: [
                                    { label: "Horizontal offset", key: "notificationHorizontalOffset", icon: "󰁍" },
                                    { label: "Vertical offset", key: "notificationVerticalOffset", icon: "󰁅" }
                                ]
                                Rectangle {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 102
                                    radius: 18
                                    color: Theme.surfaceHover
                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 2
                                        RowLayout {
                                            Layout.fillWidth: true
                                            BarText { text: modelData.label; font.pixelSize: 14 }
                                            Item { Layout.fillWidth: true }
                                            BarText {
                                                text: Math.round(ShellSettings[modelData.key]) + " px"
                                                color: Theme.pastelSky
                                                font.pixelSize: 12
                                            }
                                        }
                                        SettingsSlider {
                                            Layout.fillWidth: true
                                            title: ""
                                            icon: modelData.icon
                                            showTitle: false
                                            embedded: true
                                            minimum: 0
                                            maximum: 240
                                            currentValue: ShellSettings[modelData.key]
                                            onValueMoved: value => {
                                                root.scheduleNotificationGeometry(modelData.key, Math.round(value))
                                            }
                                        }
                                    }
                                }
                            }

                            BarText {
                                text: "Offsets move independently on each axis. A preview notification follows while dragging."
                                color: Theme.muted
                                font.pixelSize: 11
                            }
                        }

                        ColumnLayout {
                            visible: root.page === "control"
                            Layout.fillWidth: true
                            spacing: 10
                            Repeater {
                                model: [
                                    { label: "Quick toggles", key: "showQuickToggles" },
                                    { label: "Volume and brightness", key: "showSliders" },
                                    { label: "Performance modes", key: "showPowerProfiles" },
                                    { label: "CPU, RAM and disk", key: "showSystemStats" }
                                ]
                                Rectangle {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 58
                                    radius: 17
                                    color: Theme.surfaceHover
                                    BarText { anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter; text: modelData.label; font.pixelSize: 14 }
                                        MaterialSwitch {
                                            anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter
                                            checked: ShellSettings[modelData.key]
                                            accent: Theme.pastelSky
                                            onToggled: checked => ShellSettings[modelData.key] = checked
                                        }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 76
                                radius: 17
                                color: Theme.surfaceHover
                                Item {
                                    anchors.fill: parent
                                    ColumnLayout {
                                        anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter
                                        BarText { text: "Action panel position"; font.pixelSize: 14 }
                                        BarText { text: "Swap the four shortcuts with the Wi‑Fi/Bluetooth column"; color: Theme.muted; font.pixelSize: 11 }
                                    }
                                    Row {
                                        anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter
                                        spacing: 8
                                        Repeater {
                                            model: [
                                                { label: "Left", left: true },
                                                { label: "Right", left: false }
                                            ]
                                            Rectangle {
                                                required property var modelData
                                                width: 84
                                                height: 48
                                                radius: 12
                                                color: placementMouse.containsMouse ? Theme.border : Theme.background
                                                border.width: ShellSettings.profileOnLeft === modelData.left ? 2 : 1
                                                border.color: ShellSettings.profileOnLeft === modelData.left ? Theme.pastelSky : Theme.border
                                                Column {
                                                    anchors.centerIn: parent
                                                    spacing: 4
                                                    Row {
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        spacing: 4
                                                        Rectangle { width: 24; height: 13; radius: 4; color: modelData.left ? Theme.pastelLilac : Theme.pastelSky }
                                                        Rectangle { width: 24; height: 13; radius: 4; color: modelData.left ? Theme.pastelSky : Theme.pastelLilac }
                                                    }
                                                    BarText { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.label; font.pixelSize: 10 }
                                                }
                                                MouseArea {
                                                    id: placementMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: ShellSettings.profileOnLeft = modelData.left
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            visible: root.page === "bar"
                            Layout.fillWidth: true
                            spacing: 12
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 58; radius: 17; color: Theme.surfaceHover
                                BarText { anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter; text: "Floating bar"; font.pixelSize: 14 }
                                MaterialSwitch { anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; checked: ShellSettings.barFloating; accent: Theme.pastelSky; onToggled: checked => ShellSettings.barFloating = checked }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 58; radius: 17; color: Theme.surfaceHover
                                BarText { anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter; text: "Bar shadow"; font.pixelSize: 14 }
                                MaterialSwitch {
                                    anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter
                                    checked: ShellSettings.barShadow; accent: Theme.pastelSky
                                    onToggled: checked => ShellSettings.barShadow = checked
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 118; radius: 17; color: Theme.surfaceHover
                                ColumnLayout {
                                    anchors.fill: parent; anchors.margins: 16; spacing: 8
                                    RowLayout {
                                        Layout.fillWidth: true
                                        BarText { text: "Shadow opacity"; Layout.fillWidth: true; font.pixelSize: 14 }
                                        BarText { text: ShellSettings.shadowOpacity + "%"; color: Theme.pastelSky; font.pixelSize: 12 }
                                    }
                                    SettingsSlider {
                                        Layout.fillWidth: true; Layout.preferredHeight: 54
                                        showTitle: false; embedded: true; icon: "󰃟"; accent: Theme.pastelSky
                                        minimum: 0; maximum: 80; currentValue: ShellSettings.shadowOpacity
                                        onValueMoved: value => ShellSettings.shadowOpacity = Math.round(value)
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 118; radius: 17; color: Theme.surfaceHover
                                ColumnLayout {
                                    anchors.fill: parent; anchors.margins: 16; spacing: 8
                                    RowLayout {
                                        Layout.fillWidth: true
                                        BarText { text: "Shadow softness"; Layout.fillWidth: true; font.pixelSize: 14 }
                                        BarText { text: ShellSettings.shadowBlur + "%"; color: Theme.pastelSky; font.pixelSize: 12 }
                                    }
                                    SettingsSlider {
                                        Layout.fillWidth: true; Layout.preferredHeight: 54
                                        showTitle: false; embedded: true; icon: "󰒋"; accent: Theme.pastelSky
                                        minimum: 10; maximum: 100; currentValue: ShellSettings.shadowBlur
                                        onValueMoved: value => ShellSettings.shadowBlur = Math.round(value)
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 118; radius: 17; color: Theme.surfaceHover
                                ColumnLayout {
                                    anchors.fill: parent; anchors.margins: 16; spacing: 8
                                    RowLayout {
                                        Layout.fillWidth: true
                                        BarText { text: "Bar width"; Layout.fillWidth: true; font.pixelSize: 14 }
                                        BarText { text: ShellSettings.barWidth + "%"; color: Theme.pastelSky; font.pixelSize: 12 }
                                    }
                                    SettingsSlider {
                                        Layout.fillWidth: true; Layout.preferredHeight: 54
                                        showTitle: false; embedded: true; icon: "󰍜"; accent: Theme.pastelSky
                                        minimum: 50; maximum: 100; currentValue: ShellSettings.barWidth
                                        onValueMoved: value => ShellSettings.barWidth = Math.round(value)
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 118; radius: 17; color: Theme.surfaceHover
                                ColumnLayout {
                                    anchors.fill: parent; anchors.margins: 16; spacing: 8
                                    RowLayout {
                                        Layout.fillWidth: true
                                        BarText { text: "Bar height"; Layout.fillWidth: true; font.pixelSize: 14 }
                                        BarText { text: ShellSettings.barHeight + " px"; color: Theme.pastelSky; font.pixelSize: 12 }
                                    }
                                    SettingsSlider {
                                        Layout.fillWidth: true; Layout.preferredHeight: 54
                                        showTitle: false; embedded: true; icon: "󰖶"; accent: Theme.pastelSky
                                        minimum: 30; maximum: 54; currentValue: ShellSettings.barHeight
                                        onValueMoved: value => ShellSettings.barHeight = Math.round(value)
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 118; radius: 17; color: Theme.surfaceHover
                                ColumnLayout {
                                    anchors.fill: parent; anchors.margins: 16; spacing: 8
                                    RowLayout {
                                        Layout.fillWidth: true
                                        BarText { text: "Workspace module width"; Layout.fillWidth: true; font.pixelSize: 14 }
                                        BarText { text: ShellSettings.workspaceWidth + "%"; color: Theme.pastelSky; font.pixelSize: 12 }
                                    }
                                    SettingsSlider {
                                        Layout.fillWidth: true; Layout.preferredHeight: 54
                                        showTitle: false; embedded: true; icon: "󰍹"; accent: Theme.pastelSky
                                        minimum: 60; maximum: 160; currentValue: ShellSettings.workspaceWidth
                                        onValueMoved: value => ShellSettings.workspaceWidth = Math.round(value)
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 132; radius: 17; color: Theme.surfaceHover
                                ColumnLayout {
                                    anchors.fill: parent; anchors.margins: 16; spacing: 8
                                    RowLayout {
                                        Layout.fillWidth: true
                                        BarText { text: "Corner radius"; Layout.fillWidth: true; font.pixelSize: 14 }
                                        BarText { text: ShellSettings.barRadius + " px"; color: Theme.pastelSky; font.pixelSize: 12 }
                                    }
                                    SettingsSlider {
                                        Layout.fillWidth: true; Layout.preferredHeight: 46
                                        showTitle: false; embedded: true; icon: "󰅲"; accent: Theme.pastelSky
                                        minimum: 0; maximum: 20; currentValue: ShellSettings.barRadius
                                        onValueMoved: value => ShellSettings.barRadius = Math.round(value)
                                    }
                                    Row {
                                        Layout.alignment: Qt.AlignRight; spacing: 8
                                        Repeater {
                                            model: [{ key: "always", label: "Always" }, { key: "no-windows", label: "Not with windows" }]
                                            Rectangle {
                                                required property var modelData
                                                width: modelData.key === "always" ? 76 : 126; height: 32; radius: 10
                                                color: cornerModeMouse.containsMouse ? Theme.border : Theme.background
                                                border.width: ShellSettings.barCornerMode === modelData.key ? 2 : 1
                                                border.color: ShellSettings.barCornerMode === modelData.key ? Theme.pastelSky : Theme.border
                                                BarText { anchors.centerIn: parent; text: modelData.label; font.pixelSize: 11 }
                                                MouseArea { id: cornerModeMouse; anchors.fill: parent; hoverEnabled: true; onClicked: ShellSettings.barCornerMode = modelData.key }
                                            }
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 82; radius: 17; color: Theme.surfaceHover
                                BarText { anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter; text: "Position"; font.pixelSize: 14 }
                                Row {
                                    anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; spacing: 7
                                    Repeater {
                                        model: ["top", "bottom", "left", "right"]
                                        Rectangle {
                                            required property string modelData
                                            width: 66; height: 40; radius: 11
                                            color: positionMouse.containsMouse ? Theme.border : Theme.background
                                            border.width: ShellSettings.barPosition === modelData ? 2 : 1
                                            border.color: ShellSettings.barPosition === modelData ? Theme.pastelSky : Theme.border
                                            BarText { anchors.centerIn: parent; text: modelData.charAt(0).toUpperCase() + modelData.slice(1); font.pixelSize: 11 }
                                            MouseArea { id: positionMouse; anchors.fill: parent; hoverEnabled: true; onClicked: ShellSettings.barPosition = modelData }
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 76; radius: 17; color: Theme.surfaceHover
                                BarText { anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter; text: "Launcher glyph"; font.pixelSize: 14 }
                                Rectangle {
                                    anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter
                                    width: 210; height: 42; radius: 12; color: Theme.background
                                    IconText { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: ShellSettings.launcherIcon; color: Theme.pastelLilac; font.pixelSize: 18 }
                                    TextInput {
                                        anchors.fill: parent; anchors.leftMargin: 48; anchors.rightMargin: 10
                                        verticalAlignment: Text.AlignVCenter; color: Theme.text; selectionColor: Theme.pastelSky
                                        font.family: Typography.iconFamily; font.pixelSize: 16; text: ShellSettings.launcherIcon
                                        onEditingFinished: if (text.length > 0) ShellSettings.launcherIcon = text
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            visible: root.page === "wifi"
                            Layout.fillWidth: true
                            spacing: 10
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 78; radius: 18; color: Theme.surfaceHover
                                RowLayout {
                                    anchors.fill: parent; anchors.margins: 15; spacing: 12
                                    IconText { text: NetworkService.signalIcon; color: Theme.pastelSky; font.pixelSize: 24 }
                                    ColumnLayout {
                                        Layout.fillWidth: true; spacing: 2
                                        BarText { text: "Wi‑Fi"; font.pixelSize: 16 }
                                        BarText { text: !NetworkService.hardwareEnabled ? "Blocked by hardware" : NetworkService.connectedNetwork ? "Connected to " + NetworkService.connectedNetwork.name : NetworkService.enabled ? "On, not connected" : "Off"; color: Theme.muted; font.pixelSize: 11 }
                                    }
                                    RowLayout {
                                        spacing: 10
                                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                        MaterialButton { label: NetworkService.scanning ? "Scanning…" : "Scan"; accent: Theme.pastelSky; onClicked: NetworkService.scanNow() }
                                        MaterialSwitch { checked: NetworkService.enabled; accent: Theme.pastelSky; onToggled: NetworkService.toggleWifi() }
                                    }
                                }
                            }
                            BarText { visible: NetworkService.connectedNetwork !== null; text: "Connected"; color: Theme.pastelSky; font.pixelSize: 11 }
                            Repeater {
                                model: NetworkService.networks.filter(network => network.connected)
                                WifiNetworkCard {
                                    Layout.fillWidth: true
                                    passwordEditorExpanded: root.expandedWifi === modelData.name
                                    onPasswordEditorRequested: root.expandedWifi = modelData.name
                                    onPasswordEditorClosed: root.expandedWifi = ""
                                }
                            }
                            BarText { visible: NetworkService.networks.some(network => network.known && !network.connected); text: "Saved"; color: Theme.muted; font.pixelSize: 11 }
                            Repeater {
                                model: NetworkService.networks.filter(network => network.known && !network.connected)
                                WifiNetworkCard {
                                    Layout.fillWidth: true
                                    passwordEditorExpanded: root.expandedWifi === modelData.name
                                    onPasswordEditorRequested: root.expandedWifi = modelData.name
                                    onPasswordEditorClosed: root.expandedWifi = ""
                                }
                            }
                            BarText { visible: NetworkService.networks.some(network => !network.known && !network.connected); text: "Nearby"; color: Theme.muted; font.pixelSize: 11 }
                            Repeater {
                                model: NetworkService.networks.filter(network => !network.known && !network.connected)
                                WifiNetworkCard {
                                    Layout.fillWidth: true
                                    passwordEditorExpanded: root.expandedWifi === modelData.name
                                    onPasswordEditorRequested: root.expandedWifi = modelData.name
                                    onPasswordEditorClosed: root.expandedWifi = ""
                                }
                            }
                            BarText { visible: NetworkService.enabled && NetworkService.networks.length === 0; text: NetworkService.scanning ? "Looking for networks…" : "No networks in range"; color: Theme.muted; Layout.alignment: Qt.AlignHCenter }
                        }

                        ColumnLayout {
                            visible: root.page === "bluetooth"
                            Layout.fillWidth: true
                            spacing: 10
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 78; radius: 18; color: Theme.surfaceHover
                                RowLayout {
                                    anchors.fill: parent; anchors.margins: 15; spacing: 12
                                    IconText { text: "󰂯"; color: Theme.pastelLilac; font.pixelSize: 24 }
                                    ColumnLayout {
                                        Layout.fillWidth: true; spacing: 2
                                        BarText { text: "Bluetooth"; font.pixelSize: 16 }
                                        BarText { text: !BluetoothService.available ? "No adapter found" : BluetoothService.connectedDevices.length > 0 ? BluetoothService.connectedDevices.length + " connected" : BluetoothService.enabled ? "On, no connected devices" : "Off"; color: Theme.muted; font.pixelSize: 11 }
                                    }
                                    RowLayout {
                                        spacing: 10
                                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                        MaterialButton { label: BluetoothService.scanning ? "Searching…" : "Search"; accent: Theme.pastelLilac; onClicked: BluetoothService.scanNow() }
                                        MaterialSwitch { checked: BluetoothService.enabled; accent: Theme.pastelLilac; onToggled: BluetoothService.togglePower() }
                                    }
                                }
                            }
                            BarText { visible: BluetoothService.connectedDevices.length > 0; text: "Connected"; color: Theme.pastelLilac; font.pixelSize: 11 }
                            Repeater {
                                model: BluetoothService.connectedDevices
                                BluetoothDeviceCard {
                                    Layout.fillWidth: true
                                    selectionManaged: true
                                    expanded: root.expandedBluetooth === (modelData.address || modelData.name)
                                    onExpansionRequested: (device, expand) => root.expandedBluetooth = expand ? (device.address || device.name) : ""
                                    onActivationRequested: device => BluetoothService.activateDevice(device)
                                    onForgetRequested: device => BluetoothService.forgetDevice(device)
                                }
                            }
                            BarText { visible: BluetoothService.pairedDevices.some(device => !device.connected); text: "Paired"; color: Theme.muted; font.pixelSize: 11 }
                            Repeater {
                                model: BluetoothService.pairedDevices.filter(device => !device.connected)
                                BluetoothDeviceCard {
                                    Layout.fillWidth: true
                                    selectionManaged: true
                                    expanded: root.expandedBluetooth === (modelData.address || modelData.name)
                                    onExpansionRequested: (device, expand) => root.expandedBluetooth = expand ? (device.address || device.name) : ""
                                    onActivationRequested: device => BluetoothService.activateDevice(device)
                                    onForgetRequested: device => BluetoothService.forgetDevice(device)
                                }
                            }
                            BarText { visible: BluetoothService.availableDevices.length > 0; text: "Nearby"; color: Theme.muted; font.pixelSize: 11 }
                            Repeater {
                                model: BluetoothService.availableDevices
                                BluetoothDeviceCard {
                                    Layout.fillWidth: true
                                    selectionManaged: true
                                    expanded: root.expandedBluetooth === (modelData.address || modelData.name)
                                    onExpansionRequested: (device, expand) => root.expandedBluetooth = expand ? (device.address || device.name) : ""
                                    onActivationRequested: device => BluetoothService.activateDevice(device)
                                    onForgetRequested: device => BluetoothService.forgetDevice(device)
                                }
                            }
                            BarText { visible: BluetoothService.enabled && BluetoothService.devices.length === 0; text: BluetoothService.scanning ? "Searching for devices…" : "No devices found"; color: Theme.muted; Layout.alignment: Qt.AlignHCenter }
                        }

                        Rectangle {
                            visible: root.page === "nightlight"
                            Layout.fillWidth: true
                            implicitHeight: 178
                            radius: 18
                            color: Theme.surfaceHover
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 18; spacing: 10
                                RowLayout {
                                    Layout.fillWidth: true
                                    IconText { text: "󰖔"; color: Theme.pastelButter; font.pixelSize: 25 }
                                    BarText { text: "Night Light"; Layout.fillWidth: true; font.pixelSize: 16 }
                                    BarText { text: NightLightService.temperature + " K"; color: Theme.pastelButter; font.pixelSize: 12 }
                                    MaterialSwitch { checked: NightLightService.enabled; accent: Theme.pastelButter; onToggled: NightLightService.toggle() }
                                }
                                SettingsSlider {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 54
                                    showTitle: false
                                    embedded: true
                                    icon: "󰖔"
                                    accent: Theme.pastelButter
                                    minimum: 1000
                                    maximum: 6500
                                    currentValue: NightLightService.temperature
                                    onValueMoved: value => NightLightService.setTemperature(value)
                                }
                            }
                        }

                        Rectangle {
                            visible: root.page === "media"
                            Layout.fillWidth: true
                            implicitHeight: 178
                            radius: 17
                            color: Theme.surfaceHover
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 12
                                Item {
                                    Layout.fillWidth: true; Layout.preferredHeight: 42
                                    ColumnLayout {
                                        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        BarText { text: "Animated playing indicator"; font.pixelSize: 14 }
                                        BarText { text: "Animate the small equalizer while music plays"; color: Theme.muted; font.pixelSize: 11 }
                                    }
                                    MaterialSwitch { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; checked: ShellSettings.animatedEqualizer; accent: Theme.pastelMint; onToggled: checked => ShellSettings.animatedEqualizer = checked }
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    BarText { text: "Animation speed"; Layout.fillWidth: true; color: Theme.muted; font.pixelSize: 12 }
                                    BarText { text: ShellSettings.equalizerSpeed.toFixed(1) + "×"; color: Theme.pastelSky; font.pixelSize: 12 }
                                }
                                SettingsSlider {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 54
                                    showTitle: false
                                    embedded: true
                                    icon: "󰓃"
                                    accent: Theme.pastelSky
                                    minimum: 0.4
                                    maximum: 2.0
                                    currentValue: ShellSettings.equalizerSpeed
                                    onValueMoved: value => ShellSettings.equalizerSpeed = Math.round(value * 10) / 10
                                }
                            }
                        }
                    }
                }
            }
        }

    }
}
