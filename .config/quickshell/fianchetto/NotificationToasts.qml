import QtQuick
import Quickshell

PanelWindow {
    id: root
    required property var targetScreen
    screen: targetScreen
    anchors { top: true; right: true }
    // Layer-shell adds a small visual inset on this setup; compensate so the
    // card sits only a few pixels below the 36px bar.
    margins { top: Theme.barHeight - 6; right: 8 }
    exclusiveZone: 0
    implicitWidth: 390
    implicitHeight: Math.max(1, Math.min(520, toastList.contentHeight))
    color: "transparent"
    visible: NotificationService.popupCount > 0

    ListView {
        id: toastList
        anchors.fill: parent
        model: NotificationService.popups
        spacing: 8
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 160 }
        }
        remove: Transition {
            NumberAnimation { property: "x"; from: 0; to: 390; duration: 190; easing.type: Easing.InCubic }
        }
        displaced: Transition {
            NumberAnimation { property: "y"; duration: 190; easing.type: Easing.OutCubic }
        }

        delegate: Item {
            id: toastDelegate
            required property int notificationId
            required property string appName
            required property string summary
            required property string body
            required property string icon
            required property var object
            width: ListView.view.width
            height: toastCard.implicitHeight

            NotificationCard {
                id: toastCard
                anchors.fill: parent
                notificationId: toastDelegate.notificationId
                appName: toastDelegate.appName
                summary: toastDelegate.summary
                body: toastDelegate.body
                iconSource: toastDelegate.icon
                notificationObject: toastDelegate.object
                toast: true
                onCloseRequested: id => NotificationService.removePopup(id)
                onActionRequested: (id, action) => NotificationService.invokeAction(id, action)
            }
        }
    }
}
