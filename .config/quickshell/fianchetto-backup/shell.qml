//@ pragma UseQApplication
//@ pragma IconTheme Papirus-Dark

import Quickshell
import QtQuick

ShellRoot {
    // Instantiate the D-Bus owner before per-screen UI so applications can
    // immediately resolve org.freedesktop.Notifications.
    readonly property var notificationDaemon: NotificationService
    readonly property var settingsWindow: SettingsWindow
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }
}
