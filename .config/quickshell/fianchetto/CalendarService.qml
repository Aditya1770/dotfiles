pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    property date displayedMonth: new Date()
    property date today: new Date()
    property string selectedDate: Qt.formatDate(new Date(), "yyyy-MM-dd")
    property alias daysModel: days
    readonly property string monthYear: Qt.formatDate(displayedMonth, "MMMM yyyy")

    function previousMonth() { displayedMonth = new Date(displayedMonth.getFullYear(), displayedMonth.getMonth() - 1, 1); rebuild() }
    function nextMonth() { displayedMonth = new Date(displayedMonth.getFullYear(), displayedMonth.getMonth() + 1, 1); rebuild() }
    function reset() {
        displayedMonth = new Date()
        today = new Date()
        selectedDate = Qt.formatDate(today, "yyyy-MM-dd")
        rebuild()
    }
    function rebuild() {
        const year = displayedMonth.getFullYear()
        const month = displayedMonth.getMonth()
        const firstWeekday = new Date(year, month, 1).getDay()
        const previousMonthDays = new Date(year, month, 0).getDate()
        const currentMonthDays = new Date(year, month + 1, 0).getDate()
        days.clear()
        for (let cell = 0; cell < 42; cell++) {
            const offset = cell - firstWeekday + 1
            let number = offset
            let relative = 0
            if (offset <= 0) { number = previousMonthDays + offset; relative = -1 }
            else if (offset > currentMonthDays) { number = offset - currentMonthDays; relative = 1 }
            const cellDate = new Date(year, month + relative, number)
            days.append({ dayNumber: number, currentMonth: relative === 0,
                dateKey: Qt.formatDate(cellDate, "yyyy-MM-dd"),
                today: relative === 0 && number === today.getDate()
                    && month === today.getMonth() && year === today.getFullYear() })
        }
    }
    ListModel { id: days }
    Component.onCompleted: rebuild()
}
