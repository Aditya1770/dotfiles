pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    // Quickshell returns an undefined value rather than an empty string for
    // unset environment variables on some builds. Test truthiness before
    // using XDG_DATA_HOME so the fallback cannot collapse to `/fianchetto`.
    readonly property string xdgDataHome: Quickshell.env("XDG_DATA_HOME") || ""
    readonly property string dataHome: xdgDataHome.length > 0
        ? xdgDataHome : Quickshell.env("HOME") + "/.local/share"
    readonly property string matugenPath: dataHome + "/fianchetto/matugen.json"
    property alias background: data.background
    property alias surfaceHover: data.surfaceHover
    property alias border: data.border
    property alias text: data.text
    property alias muted: data.muted
    property alias accent: data.accent
    property alias sky: data.sky
    property alias mint: data.mint
    property alias lilac: data.lilac
    property alias peach: data.peach
    property alias rose: data.rose
    property alias butter: data.butter
    property alias powerRed: data.powerRed

    FileView {
        id: themeFile
        path: ShellSettings.scheme === "matugen" ? matugenPath
            : ShellSettings.themeFile !== "" ? ShellSettings.themeFile
            : Quickshell.shellPath("theme.json")
        watchChanges: true
        preload: true
        // Matugen replaces its output file when rendering a new wallpaper.
        // Explicitly reload on that filesystem event; watchChanges alone does
        // not cause JsonAdapter properties to be reparsed on every QS build.
        onFileChanged: reload()
        adapter: JsonAdapter {
            id: data
            property string background: "#070B0D"
            property string surfaceHover: "#11191B"
            property string border: "#1A272B"
            property string text: "#DADADA"
            property string muted: "#B3B9B8"
            property string accent: "#67B0E8"
            property string sky: "#8FCDF4"
            property string mint: "#79BFE5"
            property string lilac: "#A8C8F2"
            property string peach: "#70AEDD"
            property string rose: "#88B7E3"
            property string butter: "#B5D9F5"
            property string powerRed: "#F19AA3"
        }
    }
}
