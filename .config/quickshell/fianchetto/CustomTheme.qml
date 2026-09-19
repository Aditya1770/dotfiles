pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
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
        path: ShellSettings.themeFile !== "" ? ShellSettings.themeFile : Quickshell.shellPath("theme.json")
        watchChanges: true
        blockLoading: true
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
