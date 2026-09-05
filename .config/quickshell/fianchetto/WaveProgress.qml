import QtQuick

Item {
    id: root
    property real progress: 0
    property color accent: Theme.green
    property color inactive: Theme.border
    signal seekRequested(real ratio)

    implicitHeight: 24

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        function drawPlayedWave(context, colour, limit) {
            context.beginPath()
            for (let x = 0; x <= limit; x += 2) {
                const amplitude = 3.5 + 2.2 * Math.sin(x * 0.045)
                const y = height / 2 + Math.sin(x * 0.16) * amplitude
                if (x === 0) context.moveTo(x, y)
                else context.lineTo(x, y)
            }
            context.lineWidth = 2.5
            context.lineCap = "round"
            context.lineJoin = "round"
            context.strokeStyle = colour
            context.stroke()
        }

        onPaint: {
            const context = getContext("2d")
            context.clearRect(0, 0, width, height)
            const markerX = width * Math.max(0, Math.min(1, root.progress))

            context.beginPath()
            context.moveTo(markerX, height / 2)
            context.lineTo(width, height / 2)
            context.lineWidth = 2.5
            context.lineCap = "round"
            context.strokeStyle = root.inactive
            context.stroke()

            drawPlayedWave(context, root.accent, markerX)

            context.beginPath()
            context.moveTo(markerX, 3)
            context.lineTo(markerX, height - 3)
            context.lineWidth = 3
            context.lineCap = "round"
            context.strokeStyle = root.accent
            context.stroke()
        }
    }

    onProgressChanged: canvas.requestPaint()
    onAccentChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function seekAt(xPosition) {
            root.seekRequested(Math.max(0, Math.min(1, xPosition / width)))
        }
        onPressed: mouse => seekAt(mouse.x)
        onPositionChanged: mouse => { if (pressed) seekAt(mouse.x) }
    }
}
