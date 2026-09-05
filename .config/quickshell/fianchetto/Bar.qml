import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: root
    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: Theme.background

    // A soft shadow kept inside the panel exclusive zone, so it never
    // paints over a maximized or tiled window below the bar.
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 4
        opacity: 0.22
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#000000" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    RowLayout {
        anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 8 }
        spacing: Theme.gap

        LauncherModule {}
        Workspaces {}
    }

    SpotifyModule {
        anchors.centerIn: parent
    }

    LauncherOverlay { targetScreen: root.screen }
    NotificationToasts { targetScreen: root.screen }
    OsdOverlay { targetScreen: root.screen }
    ClipboardOverlay { targetScreen: root.screen }

    RowLayout {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 8 }
        spacing: Theme.gap

        Tray { hostWindow: root }
        BatteryModule {}
        CalendarModule {}
        QuickSettingsModule {}

        PowerModule {}
    }
}
