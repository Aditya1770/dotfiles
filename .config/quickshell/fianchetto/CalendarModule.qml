import QtQuick
import QtQuick.Layouts
import Quickshell

Pill {
    id: root
    SystemClock { id: clock; precision: SystemClock.Seconds }
    BarText { text: Qt.formatDateTime(clock.date, "HH:mm") }

    readonly property var nextEvent: {
        const revision = EventService.revision
        const personal = EventService.nextEvent()
        const holiday = HolidayService.nextHoliday()
        if (!personal) return holiday
        if (!holiday) return personal
        return personal.dateKey <= holiday.dateKey ? personal : holiday
    }
    readonly property var selectedEvents: {
        const revision = EventService.revision
        return HolidayService.forDate(CalendarService.selectedDate)
            .concat(EventService.forDate(CalendarService.selectedDate))
    }

    function addEvent() {
        if (!eventInput.text.trim()) return
        EventService.add(CalendarService.selectedDate, eventInput.text)
        eventInput.clear()
    }

    onClicked: {
        if (!popup.visible) {
            CalendarService.reset()
            WeatherService.refresh()
        }
        popup.visible = !popup.visible
    }

    ModulePopup {
        id: popup
        anchorItem: root
        implicitWidth: 390
        implicitHeight: 555
        focusTarget: eventInput

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            spacing: 9

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 68
                ColumnLayout {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom; right: weatherCard.left; rightMargin: 12 }
                    spacing: 0
                    BarText { text: Qt.formatDateTime(clock.date, "HH:mm"); font.pixelSize: 31 }
                    BarText {
                        text: Qt.formatDate(clock.date, "dddd, d MMMM")
                        color: Theme.muted; font.pixelSize: 12; font.weight: Font.Normal
                    }
                }
                Rectangle {
                    id: weatherCard
                    anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                    width: 154
                    radius: 18
                    color: Theme.surfaceHover
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 11
                        layoutDirection: Qt.RightToLeft
                        IconText { text: WeatherService.icon; color: Theme.blue; font.pixelSize: 25 }
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 0
                            BarText {
                                Layout.fillWidth: true
                                text: WeatherService.temperature
                                font.pixelSize: 18
                                horizontalAlignment: Text.AlignRight
                            }
                            BarText {
                                Layout.fillWidth: true
                                text: WeatherService.loading ? "Updating…" : WeatherService.condition
                                color: Theme.muted; font.pixelSize: 10; font.weight: Font.Normal
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: WeatherService.refresh() }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                radius: 14
                color: Theme.surfaceHover
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 9
                    IconText { text: "󰃭"; color: Theme.blue }
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 0
                        BarText { text: root.nextEvent ? root.nextEvent.title : "No upcoming events"; elide: Text.ElideRight }
                        BarText {
                            visible: root.nextEvent !== null
                            text: root.nextEvent ? root.nextEvent.dateKey : ""
                            color: Theme.muted; font.pixelSize: 9; font.weight: Font.Normal
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                BarText {
                    Layout.fillWidth: true
                    text: CalendarService.monthYear
                    font.pixelSize: 16
                    MouseArea { anchors.fill: parent; onClicked: CalendarService.reset() }
                }
                Repeater {
                    model: [
                        {icon: "󰅁", action: () => CalendarService.previousMonth()},
                        {icon: "󰅂", action: () => CalendarService.nextMonth()}
                    ]
                    Rectangle {
                        required property var modelData
                        Layout.preferredWidth: 28; Layout.preferredHeight: 28
                        radius: 8
                        color: navMouse.containsMouse ? Theme.surfaceHover : "transparent"
                        IconText { anchors.centerIn: parent; text: modelData.icon }
                        MouseArea { id: navMouse; anchors.fill: parent; hoverEnabled: true; onClicked: modelData.action() }
                    }
                }
            }

            GridLayout {
                columns: 7; columnSpacing: 2; Layout.fillWidth: true
                Repeater {
                    model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                    BarText {
                        required property string modelData
                        text: modelData; color: Theme.muted
                        Layout.preferredWidth: 47
                        horizontalAlignment: Text.AlignHCenter; font.pixelSize: 10
                    }
                }
            }

            GridLayout {
                columns: 7; rows: 6; columnSpacing: 2; rowSpacing: 2
                Layout.fillWidth: true; Layout.preferredHeight: 218
                Repeater {
                    model: CalendarService.daysModel
                    Rectangle {
                        required property int dayNumber
                        required property bool currentMonth
                        required property bool today
                        required property string dateKey
                        Layout.fillWidth: true; Layout.fillHeight: true
                        radius: 10
                        color: currentMonth && CalendarService.selectedDate === dateKey ? Theme.blue
                            : dayMouse.containsMouse && currentMonth ? Theme.surfaceHover : "transparent"
                        Column {
                            anchors.centerIn: parent; spacing: 1
                            BarText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: dayNumber
                                color: currentMonth && CalendarService.selectedDate === dateKey ? Theme.background
                                    : currentMonth ? Theme.text : Theme.muted
                                font.pixelSize: 11
                                opacity: currentMonth ? 1 : 0.32
                            }
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 4; height: 4; radius: 2
                                visible: EventService.countFor(dateKey) + HolidayService.forDate(dateKey).length > 0
                                color: currentMonth && CalendarService.selectedDate === dateKey ? Theme.background : Theme.orange
                                opacity: currentMonth ? 1 : 0.32
                            }
                        }
                        MouseArea {
                            id: dayMouse; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: currentMonth
                            onClicked: CalendarService.selectedDate = dateKey
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true; Layout.preferredHeight: 24
                BarText {
                    text: Qt.formatDate(new Date(CalendarService.selectedDate + "T12:00:00"), "d MMMM")
                    color: Theme.blue; Layout.fillWidth: true
                }
                BarText {
                    text: root.selectedEvents.length + (root.selectedEvents.length === 1 ? " event" : " events")
                    color: Theme.muted; font.pixelSize: 10
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: root.selectedEvents.length > 0 ? 40 : 0
                visible: root.selectedEvents.length > 0
                orientation: ListView.Horizontal; spacing: 6; clip: true
                model: root.selectedEvents
                delegate: Rectangle {
                    required property var modelData
                    width: Math.min(170, eventLabel.implicitWidth + 42); height: 36
                    radius: 12; color: Theme.surfaceHover
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 8
                        BarText {
                            id: eventLabel
                            text: modelData.holiday ? modelData.scope + " · " + modelData.title : modelData.title
                            color: modelData.holiday ? Theme.orange : Theme.text
                            Layout.maximumWidth: 125
                            elide: Text.ElideRight
                        }
                        IconText {
                            visible: !modelData.holiday
                            text: "󰅖"; color: Theme.red
                            MouseArea {
                                anchors.fill: parent; anchors.margins: -5
                                onClicked: EventService.remove(modelData.dateKey, modelData.title)
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 42
                radius: 14; color: Theme.surfaceHover
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 8
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.IBeamCursor
                            onClicked: eventInput.forceActiveFocus()
                        }
                        TextInput {
                            id: eventInput
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            color: Theme.text
                            font.family: Typography.textFamily
                            font.weight: Typography.textWeight
                            font.pixelSize: 13
                            Keys.onReturnPressed: root.addEvent()
                        }
                        BarText {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            visible: eventInput.text.length === 0
                            text: "Add event for selected date"
                            color: Theme.muted
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 30; Layout.preferredHeight: 30
                        radius: 10; color: Theme.blue
                        IconText { anchors.centerIn: parent; text: "󰐕"; color: Theme.background }
                        MouseArea { anchors.fill: parent; onClicked: root.addEvent() }
                    }
                }
            }
        }
    }
}
