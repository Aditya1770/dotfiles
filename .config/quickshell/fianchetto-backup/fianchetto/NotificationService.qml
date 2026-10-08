pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root
    property bool doNotDisturb: false
    // Layer-shell windows must not be moved while mapped on some Qt/Wayland
    // combinations. Settings hides the toast window before changing geometry,
    // then this service remaps it after the bindings have settled.
    property bool geometryChangePending: false
    property bool previewVisible: false
    property alias notifications: notificationModel
    property alias popups: popupModel
    readonly property int count: notificationModel.count
    readonly property int popupCount: popupModel.count

    function toggleDnd() {
        doNotDisturb = !doNotDisturb
    }

    function beginPreviewChange() {
        geometryChangePending = true
        previewVisible = false
        previewDelay.restart()
    }

    function showPreview() {
        previewVisible = true
        previewTimer.restart()
    }

    Timer {
        id: previewDelay
        interval: 120
        onTriggered: {
            root.geometryChangePending = false
            root.showPreview()
        }
    }

    Timer {
        id: previewTimer
        interval: 2500
        onTriggered: root.previewVisible = false
    }

    function iconSource(notification) {
        const source = notification.image || notification.appIcon || ""
        if (!source) return ""
        if (source.startsWith("/")) return "file://" + source
        if (source.includes(":")) return source
        return Quickshell.iconPath(source, "dialog-information")
    }

    function plainNotificationText(value) {
        let text = String(value || "")

        // Notification bodies may contain the small HTML/Pango subset from
        // the freedesktop specification. Cards deliberately render plain text,
        // so preserve useful line breaks and link labels while removing tags.
        text = text
            .replace(/&amp;/gi, "&")
            .replace(/&lt;/gi, "<")
            .replace(/&gt;/gi, ">")
            .replace(/&quot;/gi, "\"")
            .replace(/&apos;|&#39;/gi, "'")
            .replace(/&#x([0-9a-f]+);/gi, function(_, value) {
                const code = parseInt(value, 16)
                return isFinite(code) && code >= 0 && code <= 0x10ffff
                    ? String.fromCodePoint(code) : ""
            })
            .replace(/&#([0-9]+);/g, function(_, value) {
                const code = parseInt(value, 10)
                return isFinite(code) && code >= 0 && code <= 0x10ffff
                    ? String.fromCodePoint(code) : ""
            })
            .replace(/<br\s*\/?>/gi, "\n")
            .replace(/<\/(p|div|li)>/gi, "\n")
            .replace(/<\/?[a-z][^>]*>/gi, "")
            .replace(/[ \t]+\n/g, "\n")
            .replace(/\n[ \t]+/g, "\n")
            .replace(/\n{3,}/g, "\n\n")

        return text.trim()
    }

    function record(notification) {
        return {
            object: notification,
            notificationId: notification.id,
            appName: plainNotificationText(notification.appName) || "Notification",
            summary: plainNotificationText(notification.summary) || "Notification",
            body: plainNotificationText(notification.body),
            icon: notification.appIcon ? iconSource({ image: "", appIcon: notification.appIcon }) : "",
            image: notification.image || "",
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

    function invokeDefaultAction(notificationId) {
        for (let i = 0; i < notificationModel.count; ++i) {
            const item = notificationModel.get(i)
            if (item.notificationId !== notificationId || !item.object)
                continue
            for (const action of item.object.actions) {
                if (action.identifier === "default") {
                    action.invoke()
                    remove(notificationId, false)
                    return
                }
            }
        }
    }

    ListModel { id: notificationModel }
    ListModel { id: popupModel }

    NotificationServer {
        id: server
        bodySupported: true
        // The cards render sanitized plain text. Do not invite applications to
        // rely on rich markup, hyperlinks, or inline images we cannot expose.
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        bodyImagesSupported: false
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true
        persistenceSupported: true
        keepOnReload: false

        onNotification: notification => {
            notification.tracked = true
            root.remove(notification.id, false)
            const item = root.record(notification)
            notificationModel.insert(0, item)
            if (!root.doNotDisturb) popupModel.append(item)
        }
    }
}
