pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root
    property bool doNotDisturb: false
    property alias notifications: notificationModel
    property alias popups: popupModel
    readonly property int count: notificationModel.count
    readonly property int popupCount: popupModel.count

    function iconSource(notification) {
        const source = notification.image || notification.appIcon || ""
        if (!source) return ""
        if (source.startsWith("/")) return "file://" + source
        if (source.includes(":")) return source
        return Quickshell.iconPath(source, "dialog-information")
    }

    function record(notification) {
        return {
            object: notification,
            notificationId: notification.id,
            appName: notification.appName || "Notification",
            summary: notification.summary || "Notification",
            body: notification.body || "",
            icon: iconSource(notification),
            receivedAt: new Date()
        }
    }

    function removePopup(notificationId) {
        for (let i = 0; i < popupModel.count; ++i) {
            if (popupModel.get(i).notificationId === notificationId) {
                popupModel.remove(i)
                return
            }
        }
    }

    function remove(notificationId, dismiss) {
        removePopup(notificationId)
        for (let i = 0; i < notificationModel.count; ++i) {
            const item = notificationModel.get(i)
            if (item.notificationId === notificationId) {
                const object = item.object
                notificationModel.remove(i)
                if (dismiss && object) object.dismiss()
                return
            }
        }
    }

    function clear() {
        const objects = []
        for (let i = 0; i < notificationModel.count; ++i)
            objects.push(notificationModel.get(i).object)
        notificationModel.clear()
        popupModel.clear()
        for (const object of objects) if (object) object.dismiss()
    }

    function invokeAction(notificationId, action) {
        if (action) action.invoke()
        remove(notificationId, false)
    }

    ListModel { id: notificationModel }
    ListModel { id: popupModel }

    NotificationServer {
        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => {
            notification.tracked = true
            root.remove(notification.id, false)
            const item = root.record(notification)
            notificationModel.insert(0, item)
            if (!root.doNotDisturb) popupModel.append(item)
        }
    }
}
