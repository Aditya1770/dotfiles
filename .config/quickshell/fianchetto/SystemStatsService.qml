pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property int cpuPercent: 0
    property int ramPercent: 0
    property int diskUsedGb: 0
    property int diskTotalGb: 0
    property int diskPercent: 0

    function refresh() {
        if (!reader.running) reader.running = true
    }

    Process {
        id: reader
        command: [Quickshell.shellPath("scripts/system-stats.sh")]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("\t")
                if (fields.length < 5) return
                root.cpuPercent = Number(fields[0]) || 0
                root.ramPercent = Number(fields[1]) || 0
                root.diskUsedGb = Number(fields[2]) || 0
                root.diskTotalGb = Number(fields[3]) || 0
                root.diskPercent = Number(fields[4]) || 0
            }
        }
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
