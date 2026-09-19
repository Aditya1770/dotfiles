pragma Singleton
import QtQuick

QtObject {
    readonly property bool custom: ShellSettings.scheme === "custom"
    readonly property color background: custom ? CustomTheme.background : ShellSettings.scheme === "oled" ? "#000000"
        : ShellSettings.scheme === "slate" ? "#0B1013" : "#070B0D"
    readonly property color surface: background
    readonly property color surfaceHover: custom ? CustomTheme.surfaceHover : ShellSettings.scheme === "oled" ? "#0B0F11"
        : ShellSettings.scheme === "slate" ? "#151E22" : "#11191B"
    readonly property color border: custom ? CustomTheme.border : ShellSettings.scheme === "oled" ? "#182025"
        : ShellSettings.scheme === "slate" ? "#223038" : "#1A272B"
    readonly property color text: custom ? CustomTheme.text : "#DADADA"
    readonly property color muted: custom ? CustomTheme.muted : "#B3B9B8"
    readonly property color cyan: "#6CBFBF"
    readonly property color blue: custom ? CustomTheme.accent : ShellSettings.scheme === "oled" ? "#7BC8F6"
        : ShellSettings.scheme === "slate" ? "#8AB4D6" : "#67B0E8"
    readonly property color green: "#8CCF7E"
    readonly property color purple: "#C47FD5"
    readonly property color orange: "#E5C76B"
    readonly property color red: "#E57474"

    // Soft Material-inspired icon palette. These stay bright enough against
    // the near-black surfaces without making the bar look neon.
    readonly property color pastelSky: custom ? CustomTheme.sky : "#8FCDF4"
    readonly property color pastelMint: custom ? CustomTheme.mint : "#79BFE5"
    readonly property color pastelLilac: custom ? CustomTheme.lilac : "#A8C8F2"
    readonly property color pastelPeach: custom ? CustomTheme.peach : "#70AEDD"
    readonly property color pastelRose: custom ? CustomTheme.rose : "#88B7E3"
    readonly property color pastelButter: custom ? CustomTheme.butter : "#B5D9F5"
    readonly property color pastelPowerRed: custom ? CustomTheme.powerRed : "#F19AA3"

    readonly property int barHeight: ShellSettings.barHeight
    readonly property int sideBarWidth: Math.max(46, barHeight)
    readonly property int pillHeight: 26
    readonly property int radius: 10
    readonly property int gap: 8
    readonly property int popupRadius: 14
    readonly property int popupPadding: 14
}
