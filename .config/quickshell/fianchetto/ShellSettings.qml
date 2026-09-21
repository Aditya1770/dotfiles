pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias scheme: data.scheme
    property alias fontFamily: data.fontFamily
    property alias fontScale: data.fontScale
    property alias profileOnLeft: data.profileOnLeft
    property alias showQuickToggles: data.showQuickToggles
    property alias showSliders: data.showSliders
    property alias showPowerProfiles: data.showPowerProfiles
    property alias showSystemStats: data.showSystemStats
    property alias animatedEqualizer: data.animatedEqualizer
    property alias equalizerSpeed: data.equalizerSpeed
    property alias barWidth: data.barWidth
    property alias launcherIcon: data.launcherIcon
    property alias barHeight: data.barHeight
    property alias barRadius: data.barRadius
    property alias barCornerMode: data.barCornerMode
    property alias workspaceWidth: data.workspaceWidth
    property alias barFloating: data.barFloating
    property alias barPosition: data.barPosition
    property alias osdPosition: data.osdPosition
    property alias osdHorizontalOffset: data.osdHorizontalOffset
    property alias osdVerticalOffset: data.osdVerticalOffset
    property alias notificationPosition: data.notificationPosition
    property alias notificationHorizontalOffset: data.notificationHorizontalOffset
    property alias notificationVerticalOffset: data.notificationVerticalOffset
    property alias notificationShadow: data.notificationShadow
    property alias barShadow: data.barShadow
    property alias shadowOpacity: data.shadowOpacity
    property alias shadowBlur: data.shadowBlur
    property alias nightLightEnabled: data.nightLightEnabled
    property alias nightLightTemperature: data.nightLightTemperature
    property alias themeFile: data.themeFile

    signal settingsRequested(string page)

    function open(page) {
        settingsRequested(page || "appearance")
    }

    function reset() {
        scheme = "fianchetto"
        fontFamily = "SF Pro Display"
        fontScale = 1.0
        profileOnLeft = false
        showQuickToggles = true
        showSliders = true
        showPowerProfiles = true
        showSystemStats = true
        animatedEqualizer = true
        equalizerSpeed = 1.0
        barWidth = 100
        launcherIcon = "󰊠"
        barHeight = 36
        barRadius = 12
        barCornerMode = "always"
        workspaceWidth = 100
        barFloating = false
        barPosition = "top"
        osdPosition = "bottom"
        osdHorizontalOffset = 0
        osdVerticalOffset = 58
        notificationPosition = "top-right"
        notificationHorizontalOffset = 8
        notificationVerticalOffset = 8
        notificationShadow = true
        barShadow = true
        shadowOpacity = 42
        shadowBlur = 70
        nightLightEnabled = false
        nightLightTemperature = 4000
        themeFile = ""
    }

    Timer {
        id: saveTimer
        interval: 120
        onTriggered: settingsFile.writeAdapter()
    }

    FileView {
        id: settingsFile
        path: Quickshell.env("HOME") + "/.local/share/fianchetto/settings.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: saveTimer.restart()

        adapter: JsonAdapter {
            id: data
            property string scheme: "fianchetto"
            property string fontFamily: "SF Pro Display"
            property real fontScale: 1.0
            property bool profileOnLeft: false
            property bool showQuickToggles: true
            property bool showSliders: true
            property bool showPowerProfiles: true
            property bool showSystemStats: true
            property bool animatedEqualizer: true
            property real equalizerSpeed: 1.0
            property int barWidth: 100
            property string launcherIcon: "󰊠"
            property int barHeight: 36
            property int barRadius: 12
            property string barCornerMode: "always"
            property int workspaceWidth: 100
            property bool barFloating: false
            property string barPosition: "top"
            property string osdPosition: "bottom"
            property int osdHorizontalOffset: 0
            property int osdVerticalOffset: 58
            property string notificationPosition: "top-right"
            property int notificationHorizontalOffset: 8
            property int notificationVerticalOffset: 8
            property bool notificationShadow: true
            property bool barShadow: true
            property int shadowOpacity: 42
            property int shadowBlur: 70
            property bool nightLightEnabled: false
            property int nightLightTemperature: 4000
            property string themeFile: ""
        }
    }
}
