pragma Singleton
import QtQuick

QtObject {
    function tonalAccent(value) {
        // Matugen's source colour can be very grey or dark. Keep its hue, but
        // raise saturation and lightness enough for small icons and text.
        if (value.hslHue < 0) return value
        return Qt.hsla(value.hslHue,
            Math.max(0.58, value.hslSaturation),
            Math.max(0.60, Math.min(0.72, value.hslLightness)), 1)
    }

    // Matugen uses the same JSON colour roles as imported themes. Its output
    // is watched by CustomTheme, so wallpaper changes apply without a restart.
    readonly property bool matugen: ShellSettings.scheme === "matugen"
    readonly property bool custom: ShellSettings.scheme === "custom" || matugen
    readonly property color background: custom ? CustomTheme.background : ShellSettings.scheme === "oled" ? "#000000"
        : ShellSettings.scheme === "slate" ? "#0B1013" : "#070B0D"
    readonly property color surface: background
    readonly property color rawAccent: custom ? CustomTheme.accent : ShellSettings.scheme === "oled" ? "#7BC8F6"
        : ShellSettings.scheme === "slate" ? "#8AB4D6" : "#67B0E8"
    readonly property color blue: matugen ? tonalAccent(rawAccent) : rawAccent
    readonly property color surfaceHover: custom ? CustomTheme.surfaceHover : ShellSettings.scheme === "oled" ? "#0B0F11"
        : ShellSettings.scheme === "slate" ? "#151E22" : "#11191B"
    readonly property color border: custom ? CustomTheme.border : ShellSettings.scheme === "oled" ? "#182025"
        : ShellSettings.scheme === "slate" ? "#223038" : "#1A272B"
    readonly property color text: custom ? CustomTheme.text : "#DADADA"
    readonly property color muted: custom ? CustomTheme.muted : "#B3B9B8"
    // Matugen is deliberately tonal; fixed and imported themes retain their
    // own semantic palette. Destructive actions always keep a red affordance.
    readonly property color cyan: matugen ? blue : "#6CBFBF"
    readonly property color green: matugen ? blue : "#8CCF7E"
    readonly property color purple: matugen ? blue : "#C47FD5"
    readonly property color orange: matugen ? blue : "#E5C76B"
    readonly property color red: "#E57474"

    readonly property color pastelSky: matugen ? blue : custom ? CustomTheme.sky : "#8FCDF4"
    readonly property color pastelMint: matugen ? blue : custom ? CustomTheme.mint : "#79BFE5"
    readonly property color pastelLilac: matugen ? blue : custom ? CustomTheme.lilac : "#A8C8F2"
    readonly property color pastelPeach: matugen ? blue : custom ? CustomTheme.peach : "#70AEDD"
    readonly property color pastelRose: matugen ? blue : custom ? CustomTheme.rose : "#88B7E3"
    readonly property color pastelButter: matugen ? blue : custom ? CustomTheme.butter : "#B5D9F5"
    readonly property color pastelPowerRed: custom ? CustomTheme.powerRed : "#F19AA3"

    readonly property int barHeight: ShellSettings.barHeight
    readonly property int sideBarWidth: Math.max(46, barHeight)
    readonly property int pillHeight: 26
    readonly property int radius: 10
    readonly property int gap: 8
    readonly property int popupRadius: 14
    readonly property int popupPadding: 14
}
