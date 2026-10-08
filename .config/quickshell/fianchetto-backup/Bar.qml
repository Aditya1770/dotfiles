import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: root
    readonly property bool horizontal: ShellSettings.barPosition === "top" || ShellSettings.barPosition === "bottom"
    readonly property bool atTopOrLeft: ShellSettings.barPosition === "top" || ShellSettings.barPosition === "left"
    readonly property bool workspaceHasWindows: Hyprland.focusedWorkspace
        && Hyprland.toplevels.values.some(t => t.workspace && t.workspace.id === Hyprland.focusedWorkspace.id)
    readonly property bool cornersEnabled: ShellSettings.barRadius > 0
        && (ShellSettings.barCornerMode === "always" || !workspaceHasWindows)
    readonly property int edgeGap: ShellSettings.barFloating ? 10 : 0
    // Horizontal pills need more room when stacked vertically. Keeping the
    // side bar at the 36px horizontal height clips glyphs and popup anchors.
    readonly property int sideWidth: Theme.sideBarWidth
    readonly property int shadowExtent: ShellSettings.barShadow ? 16 : 0

    anchors {
        top: ShellSettings.barPosition !== "bottom"
        bottom: ShellSettings.barPosition !== "top"
        left: ShellSettings.barPosition !== "right"
        right: ShellSettings.barPosition !== "left"
    }
    margins {
        top: ShellSettings.barPosition === "top" ? root.edgeGap : 0
        bottom: ShellSettings.barPosition === "bottom" ? root.edgeGap : 0
        left: ShellSettings.barPosition === "left" ? root.edgeGap : 0
        right: ShellSettings.barPosition === "right" ? root.edgeGap : 0
    }
    implicitHeight: horizontal ? Theme.barHeight + root.shadowExtent : 0
    implicitWidth: horizontal ? 0 : root.sideWidth + root.shadowExtent
    // Layer-shell applies the anchored-edge margin to the reserved area. Adding
    // edgeGap here as well leaves an extra strip between tiled windows and the
    // visible bar, which looks like a compositor window border.
    // Hyprland draws a one-pixel tiled-window edge at the newly reserved
    // boundary. At the monitor edge it is clipped, but beside a layer-shell
    // bar it becomes visible as a false "gap". Reserve one pixel less so the
    // bar covers that edge without changing the user's gaps_in setting.
    exclusiveZone: Math.max(1, (root.horizontal ? Theme.barHeight : root.sideWidth) + root.shadowExtent
        - (ShellSettings.barFloating ? 0 : 1))
    color: "transparent"

    Item {
        id: strip
        visible: root.horizontal
        width: root.width
        height: Theme.barHeight
        anchors.top: ShellSettings.barPosition === "top" ? parent.top : undefined
        anchors.bottom: ShellSettings.barPosition === "bottom" ? parent.bottom : undefined

        readonly property real inset: width * (100 - Math.max(50, Math.min(100, ShellSettings.barWidth))) / 200
            + (ShellSettings.barFloating ? root.edgeGap : 0)
        readonly property real surfaceX: inset
        readonly property real surfaceWidth: width - inset * 2

        Rectangle {
            id: barSurface
            x: strip.surfaceX
            width: strip.surfaceWidth
            height: ShellSettings.barFloating || !root.cornersEnabled
                ? strip.height : strip.height + ShellSettings.barRadius
            y: ShellSettings.barFloating || !root.cornersEnabled
                ? 0 : root.atTopOrLeft ? -ShellSettings.barRadius : 0
            radius: root.cornersEnabled ? ShellSettings.barRadius : 0
            color: Theme.background
            border.width: ShellSettings.barFloating ? 1 : 0
            border.color: Theme.border
            Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on radius { NumberAnimation { duration: 150 } }
        }

        MultiEffect {
            anchors.fill: barSurface
            source: barSurface
            visible: ShellSettings.barShadow
            z: -1
            shadowEnabled: true
            shadowColor: "#000000"
            shadowOpacity: ShellSettings.shadowOpacity / 100
            shadowBlur: ShellSettings.shadowBlur / 100
            blurMax: 16
            shadowVerticalOffset: ShellSettings.barPosition === "top" ? 3 : -3
            autoPaddingEnabled: true
        }

        RowLayout {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: strip.inset + 8 }
            spacing: Theme.gap
            LauncherModule {}
            Workspaces {}
        }

        SpotifyModule { anchors.centerIn: parent }

        RowLayout {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: strip.inset + 8 }
            spacing: Theme.gap
            Tray { hostWindow: root }
            BatteryModule {}
            CalendarModule {}
            QuickSettingsModule {}
            PowerModule {}
        }
    }

    Item {
        id: sideStrip
        visible: !root.horizontal
        width: root.sideWidth
        height: root.height
        anchors.left: ShellSettings.barPosition === "left" ? parent.left : undefined
        anchors.right: ShellSettings.barPosition === "right" ? parent.right : undefined

        readonly property real inset: height * (100 - Math.max(50, Math.min(100, ShellSettings.barWidth))) / 200
            + (ShellSettings.barFloating ? root.edgeGap : 0)
        readonly property real surfaceHeight: height - inset * 2

        Rectangle {
            id: sideBarSurface
            x: ShellSettings.barFloating || !root.cornersEnabled
                ? 0 : ShellSettings.barPosition === "left" ? -ShellSettings.barRadius : 0
            y: sideStrip.inset
            width: ShellSettings.barFloating || !root.cornersEnabled
                ? sideStrip.width : sideStrip.width + ShellSettings.barRadius
            height: sideStrip.surfaceHeight
            radius: root.cornersEnabled ? ShellSettings.barRadius : 0
            color: Theme.background
            border.width: ShellSettings.barFloating ? 1 : 0
            border.color: Theme.border
            Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on radius { NumberAnimation { duration: 150 } }
        }


        MultiEffect {
            anchors.fill: sideBarSurface
            source: sideBarSurface
            visible: ShellSettings.barShadow
            z: -1
            shadowEnabled: true
            shadowColor: "#000000"
            shadowOpacity: ShellSettings.shadowOpacity / 100
            shadowBlur: ShellSettings.shadowBlur / 100
            blurMax: 16
            shadowHorizontalOffset: ShellSettings.barPosition === "left" ? 3 : -3
            autoPaddingEnabled: true
        }

        ColumnLayout {
            anchors.top: parent.top
            anchors.topMargin: sideStrip.inset + 6
            anchors.bottom: parent.bottom
            anchors.bottomMargin: sideStrip.inset + 6
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5

            LauncherModule { Layout.alignment: Qt.AlignHCenter }
            Workspaces { vertical: true; Layout.alignment: Qt.AlignHCenter }
            Item { Layout.fillHeight: true }
            SpotifyModule { compact: true; Layout.alignment: Qt.AlignHCenter }
            Item { Layout.fillHeight: true }
            Tray { hostWindow: root; vertical: true; Layout.alignment: Qt.AlignHCenter }
            BatteryModule { compact: true; Layout.alignment: Qt.AlignHCenter }
            CalendarModule { compact: true; Layout.alignment: Qt.AlignHCenter }
            QuickSettingsModule { compact: true; Layout.alignment: Qt.AlignHCenter }
            PowerModule { Layout.alignment: Qt.AlignHCenter }
        }
    }

    LauncherOverlay { targetScreen: root.screen }
    NotificationToasts { targetScreen: root.screen }
    OsdOverlay { targetScreen: root.screen }
    ClipboardOverlay { targetScreen: root.screen }
}
