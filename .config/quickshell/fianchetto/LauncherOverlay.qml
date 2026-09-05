import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: root
    required property var targetScreen
    screen: targetScreen
    anchors { top: true; right: true; bottom: true; left: true }
    exclusiveZone: 0
    color: "transparent"
    visible: LauncherState.visible
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property bool presented: false
    property string query: ""
    property string calculation: calculate(query)
    property string lastCalculation: ""
    readonly property bool arithmeticQuery: {
        const expression = query.trim()
        return expression.length > 0 && /[0-9]/.test(expression)
            && /^[0-9+\-*/().%\s]+$/.test(expression)
    }
    readonly property string shownCalculation: calculation
        || (arithmeticQuery ? lastCalculation : "")

    function calculate(input) {
        const expression = input.trim()
        if (!expression || !/[0-9]/.test(expression)
                || !/^[0-9+\-*/().%\s]+$/.test(expression)) return ""
        try {
            const value = eval(expression)
            return typeof value === "number" && isFinite(value) ? String(value) : ""
        } catch (error) { return "" }
    }

    readonly property var results: {
        const needle = query.trim().toLowerCase()
        let applications = DesktopEntries.applications.values.filter(entry => {
            if (!needle) return true
            return [entry.name, entry.genericName, entry.comment, ...(entry.keywords || [])]
                .join(" ").toLowerCase().includes(needle)
        })
        applications.sort((a, b) => {
            const aStarts = a.name.toLowerCase().startsWith(needle) ? 0 : 1
            const bStarts = b.name.toLowerCase().startsWith(needle) ? 0 : 1
            return aStarts !== bStarts ? aStarts - bStarts : a.name.localeCompare(b.name)
        })
        let output = applications.map(entry => ({
            kind: "application", name: entry.name,
            subtitle: entry.genericName || entry.comment || "Application",
            icon: entry.icon, entry: entry
        }))
        if (arithmeticQuery && shownCalculation) output.unshift({
            kind: "calculator", name: shownCalculation,
            subtitle: calculation
                ? query.trim() + " = " + shownCalculation + " · Enter to copy"
                : query.trim() + "  · Continue typing",
            icon: "accessories-calculator"
        })
        return output
    }

    function activateCurrent() {
        if (!resultsList.currentItem) return
        const result = resultsList.currentItem.result
        if (result.kind === "calculator") Quickshell.execDetached(["wl-copy", result.name])
        else result.entry.execute()
        LauncherState.hide()
    }

    function moveSelection(delta) {
        if (resultsList.count === 0) return
        let next = resultsList.currentIndex + delta
        if (next < 0) next = resultsList.count - 1
        if (next >= resultsList.count) next = 0
        resultsList.currentIndex = next
        resultsList.positionViewAtIndex(next, ListView.Contain)
    }

    mask: Region { Region { item: panel } }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [root]
        onCleared: LauncherState.hide()
    }

    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut
        enabled: root.visible
        onActivated: LauncherState.hide()
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: Math.min(510, root.width - 48)
        // 32px margins + 55px search + 1px divider + 8px list inset.
        // Keeping this exact prevents the last result from clipping the
        // lower rounded corners of the panel.
        height: Math.min(604, 96 + root.results.length * 64)
        radius: 24
        color: Theme.surface
        border.width: 0
        opacity: root.presented ? 1 : 0
        scale: root.presented ? 1 : 0.96

        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 190; easing.type: Easing.OutBack } }
        Behavior on height { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 55

                IconText {
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰍉"
                    color: Theme.muted
                    font.pixelSize: 22
                }

                TextInput {
                    id: searchInput
                    anchors.left: parent.left
                    anchors.leftMargin: 42
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.text
                    selectionColor: Theme.surfaceHover
                    selectedTextColor: Theme.text
                    font.family: Typography.textFamily
                    font.pixelSize: 18
                    font.weight: Typography.textWeight
                    clip: true
                    onTextChanged: {
                        root.query = text
                        const nextCalculation = root.calculate(text)
                        if (nextCalculation) root.lastCalculation = nextCalculation
                        else if (!root.arithmeticQuery) root.lastCalculation = ""
                        resultsList.currentIndex = root.results.length > 0 ? 0 : -1
                    }
                    Keys.onDownPressed: event => {
                        root.moveSelection(1)
                        event.accepted = true
                    }
                    Keys.onUpPressed: event => {
                        root.moveSelection(-1)
                        event.accepted = true
                    }
                    Keys.onReturnPressed: root.activateCurrent()
                    Keys.onEnterPressed: root.activateCurrent()
                    Keys.onEscapePressed: LauncherState.hide()
                }

                BarText {
                    anchors.left: searchInput.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: searchInput.text.length === 0
                    text: "Search"
                    color: Theme.muted
                    font.pixelSize: 18
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

            ListView {
                id: resultsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                topMargin: 8
                clip: true
                model: root.results
                currentIndex: count > 0 ? 0 : -1
                keyNavigationWraps: true
                boundsBehavior: Flickable.StopAtBounds
                highlightMoveDuration: 100
                highlight: Rectangle { radius: 12; color: Theme.surfaceHover }

                delegate: Item {
                    required property var modelData
                    required property int index
                    property var result: modelData
                    width: ListView.view.width
                    height: 64

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 13

                        IconImage {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            implicitSize: 36
                            source: Quickshell.iconPath(result.icon, "application-x-executable")
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            BarText { Layout.fillWidth: true; text: result.name; font.pixelSize: 15; elide: Text.ElideRight }
                            BarText {
                                Layout.fillWidth: true
                                text: result.subtitle
                                color: Theme.muted
                                font.pixelSize: 12
                                font.weight: Font.Normal
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: resultsList.currentIndex = index
                        onClicked: root.activateCurrent()
                        onWheel: wheel => wheel.accepted = false
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            root.query = ""
            root.lastCalculation = ""
            searchInput.clear()
            root.presented = false
            Qt.callLater(function() {
                root.presented = true
                searchInput.forceActiveFocus()
                focusGrab.active = true
            })
        } else {
            root.presented = false
            focusGrab.active = false
        }
    }
}
