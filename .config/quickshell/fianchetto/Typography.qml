pragma Singleton
import QtQuick

// Edit only this file to change fonts throughout the shell.
QtObject {
    readonly property string textFamily: ShellSettings.fontFamily
    readonly property int textWeight: Font.DemiBold
    readonly property string iconFamily: "Symbols Nerd Font Mono"
    readonly property int textSize: Math.round(14 * ShellSettings.fontScale)
    readonly property int iconSize: Math.round(14 * ShellSettings.fontScale)
}
