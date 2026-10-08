pragma Singleton
import QtQuick

QtObject {
    id: root

    // Fixed-date Indian national days and widely observed international days.
    readonly property var holidays: [
        { day: "01-01", title: "New Year's Day", scope: "International" },
        { day: "01-12", title: "National Youth Day", scope: "India" },
        { day: "01-26", title: "Republic Day", scope: "India" },
        { day: "03-08", title: "International Women's Day", scope: "International" },
        { day: "04-07", title: "World Health Day", scope: "International" },
        { day: "04-22", title: "Earth Day", scope: "International" },
        { day: "05-01", title: "International Workers' Day", scope: "International" },
        { day: "06-05", title: "World Environment Day", scope: "International" },
        { day: "06-21", title: "International Yoga Day", scope: "International" },
        { day: "08-15", title: "Independence Day", scope: "India" },
        { day: "09-05", title: "Teachers' Day", scope: "India" },
        { day: "10-02", title: "Gandhi Jayanti", scope: "India" },
        { day: "10-24", title: "United Nations Day", scope: "International" },
        { day: "11-14", title: "Children's Day", scope: "India" },
        { day: "12-25", title: "Christmas Day", scope: "International" }
    ]

    function forDate(dateKey) {
        const suffix = dateKey.slice(5)
        return holidays.filter(item => item.day === suffix).map(item => ({
            dateKey: dateKey,
            title: item.title,
            scope: item.scope,
            holiday: true
        }))
    }

    function nextHoliday() {
        const today = Qt.formatDate(new Date(), "yyyy-MM-dd")
        const year = Number(today.slice(0, 4))
        for (let yearOffset = 0; yearOffset < 2; ++yearOffset) {
            const candidateYear = year + yearOffset
            for (const holiday of holidays) {
                const dateKey = candidateYear + "-" + holiday.day
                if (dateKey >= today)
                    return { dateKey: dateKey, title: holiday.title, scope: holiday.scope, holiday: true }
            }
        }
        return null
    }
}
