pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string location: UserConfig.weatherLocation
    property string temperature: "--"
    property string condition: "Weather unavailable"
    property string feelsLike: "--"
    property string icon: "󰖐"
    property bool loading: false

    function iconFor(code) {
        const value = Number(code)
        if (value === 113) return "󰖙"
        if (value === 116) return "󰖕"
        if ([176, 263, 266, 293, 296, 299, 302, 305, 308].includes(value)) return "󰖗"
        if ([200, 386, 389, 392, 395].includes(value)) return "󰖓"
        if ([227, 230, 323, 326, 329, 332, 335, 338].includes(value)) return "󰖘"
        if ([143, 248, 260].includes(value)) return "󰖑"
        return "󰖐"
    }

    function refresh() {
        if (request.running) return
        loading = true
        request.command = ["curl", "-fsSL", "--max-time", "7",
            "https://wttr.in/" + encodeURIComponent(location) + "?format=j1"]
        request.running = true
    }

    Process {
        id: request
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)
                    const current = data.current_condition[0]
                    root.temperature = current.temp_C + "°"
                    root.feelsLike = current.FeelsLikeC + "°"
                    root.condition = current.weatherDesc[0].value
                    root.icon = root.iconFor(current.weatherCode)
                } catch (error) {
                    root.condition = "Weather unavailable"
                }
                root.loading = false
            }
        }
        onRunningChanged: if (!running) root.loading = false
    }

    Timer {
        interval: 900000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
