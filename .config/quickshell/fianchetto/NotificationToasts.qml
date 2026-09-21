import QtQuick
import Quickshell

PanelWindow {
    id: root
    required property var targetScreen
    screen: targetScreen
    readonly property string position: ShellSettings.notificationPosition
    readonly property int horizontalOffset: ShellSettings.notificationHorizontalOffset
    readonly property int verticalOffset: ShellSettings.notificationVerticalOffset
    readonly property bool atTop: position.startsWith("top-")
    readonly property bool atBottom: position.startsWith("bottom-")
    readonly property bool atLeft: position.endsWith("-left")
    readonly property bool atRight: position.endsWith("-right")
    readonly property bool atCenter: position === "top-center"
    readonly property int shadowPadding: ShellSettings.notificationShadow ? 16 : 0
    readonly property int cardLeftPadding: root.atRight ? root.shadowPadding : 0
    readonly property int cardRightPadding: root.atLeft ? root.shadowPadding : root.atCenter ? root.shadowPadding : 0
    readonly property int cardTopPadding: root.atBottom ? root.shadowPadding : 0
    readonly property int cardBottomPadding: root.atTop ? root.shadowPadding : 0
    anchors {
        top: root.atTop
        bottom: root.atBottom
        left: root.atLeft || root.atCenter
        right: root.atRight
    }
    margins {
        // PanelWindow anchors already use the usable area left by the bar's
        // exclusive zone. Adding barHeight here counted the bar twice and made
        // the minimum visible gap roughly one extra bar tall.
        top: root.atTop ? root.verticalOffset : 0
        bottom: root.atBottom ? root.verticalOffset : 0
        left: root.atCenter ? Math.max(0, (root.targetScreen.width - root.implicitWidth) / 2 + root.horizontalOffset)
            : root.atLeft ? root.horizontalOffset : 0
        right: root.atRight ? root.horizontalOffset : 0
    }
    exclusiveZone: 0
    implicitWidth: 390 + root.cardLeftPadding + root.cardRightPadding
    implicitHeight: NotificationService.previewVisible ? 96 + root.cardTopPadding + root.cardBottomPadding
        : Math.max(1, Math.min(520, toastList.contentHeight))
    color: "transparent"
    visible: (NotificationService.popupCount > 0 || NotificationService.previewVisible)
        && !NotificationService.geometryChangePending

    ListView {
        id: toastList
        anchors.fill: parent
        model: NotificationService.popups
        visible: !NotificationService.previewVisible
        spacing: 8
        clip: false
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
            required property string image
            required property var object
            required property var receivedAt
            width: ListView.view.width
            height: toastCard.implicitHeight + root.cardTopPadding + root.cardBottomPadding

            NotificationCard {
                id: toastCard
                anchors.fill: parent
                anchors.leftMargin: root.cardLeftPadding
                anchors.rightMargin: root.cardRightPadding
                anchors.topMargin: root.cardTopPadding
                anchors.bottomMargin: root.cardBottomPadding
                notificationId: toastDelegate.notificationId
                appName: toastDelegate.appName
                summary: toastDelegate.summary
                body: toastDelegate.body
                iconSource: toastDelegate.icon
                imageSource: toastDelegate.image
                notificationObject: toastDelegate.object
                receivedAt: toastDelegate.receivedAt
                toast: true
                maximumHeight: Math.max(120, root.targetScreen.height * 0.35)
                dropShadow: ShellSettings.notificationShadow
                onCloseRequested: id => NotificationService.removePopup(id)
                onActionRequested: (id, action) => NotificationService.invokeAction(id, action)
                onDefaultActionRequested: id => NotificationService.invokeDefaultAction(id)
            }
        }
    }

    NotificationCard {
        anchors.fill: parent
        anchors.leftMargin: root.cardLeftPadding
        anchors.rightMargin: root.cardRightPadding
        anchors.topMargin: root.cardTopPadding
        anchors.bottomMargin: root.cardBottomPadding
        visible: NotificationService.previewVisible
        notificationId: -1
        appName: "Fianchetto"
        summary: "Notification preview"
        body: "Drag the sliders to position notifications."
        iconSource: ""
        imageSource: ""
        notificationObject: null
        receivedAt: new Date()
        toast: true
        maximumHeight: Math.max(120, root.targetScreen.height * 0.35)
        dropShadow: ShellSettings.notificationShadow
        onCloseRequested: NotificationService.previewVisible = false
    }
}
