import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

Rectangle {
    id: root
    required property int notificationId
    required property string appName
    required property string summary
    required property string body
    required property string iconSource
    property string imageSource: ""
    property var receivedAt: new Date()
    property var notificationObject: null
    property bool toast: false
    property real slideOffset: toast ? width : 0
    signal closeRequested(int notificationId)
    signal actionRequested(int notificationId, var action)
    signal defaultActionRequested(int notificationId)

    readonly property bool hasDefaultAction: {
        if (!notificationObject) return false
        for (const action of notificationObject.actions)
            if (action.identifier === "default") return true
        return false
    }

    // Never derive this from a layout that fills us: that feedback loop caused
    // image-bearing Chromium notifications to grow into an almost full window.
    implicitHeight: Math.max(toast ? 96 : 80,
        24 + appLabel.implicitHeight + 2 + summaryLabel.implicitHeight
        + (root.body !== "" ? bodyText.implicitHeight + 2 : 0)
        + (actionsRow.visible ? actionsRow.implicitHeight + 5 : 0))
    radius: toast ? 12 : 14
    color: Theme.background
    border.width: 1
    border.color: Theme.border
    clip: true
    transform: Translate { x: root.slideOffset }

    Component.onCompleted: if (toast) enterAnimation.start()

    NumberAnimation {
        id: enterAnimation
        target: root
        property: "slideOffset"
        to: 0
        duration: 240
        easing.type: Easing.OutCubic
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.hasDefaultAction
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.defaultActionRequested(root.notificationId)
    }

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 38
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        spacing: 12

        ClippingRectangle {
            Layout.preferredWidth: root.toast ? 46 : 36
            Layout.preferredHeight: root.toast ? 46 : 36
            radius: root.toast ? 13 : 10
            color: Theme.background

            IconImage {
                anchors.fill: parent
                anchors.margins: 7
                source: root.iconSource
                visible: root.iconSource !== ""
            }
            IconText {
                anchors.centerIn: parent
                visible: root.iconSource === ""
                text: "󰂚"
                color: Theme.pastelRose
                font.pixelSize: root.toast ? 20 : 16
            }
        }

        ColumnLayout {
            id: textColumn
            Layout.fillWidth: true
            spacing: 2
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                BarText {
                    id: appLabel
                    Layout.fillWidth: true
                    text: root.appName !== "" ? root.appName : "Notification"
                    color: Theme.pastelRose
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }
                BarText {
                    id: timeLabel
                    text: root.toast ? "now" : Qt.formatTime(root.receivedAt, "HH:mm")
                    color: Theme.muted
                    font.pixelSize: 10
                    font.weight: Font.Normal
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                BarText {
                    id: summaryLabel
                    Layout.fillWidth: true
                    text: root.summary
                    font.pixelSize: 15
                    elide: Text.ElideRight
                }
            }
            BarText {
                id: bodyText
                Layout.fillWidth: true
                visible: root.body !== ""
                text: root.body
                color: Theme.muted
                font.pixelSize: 13
                font.weight: Font.Normal
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }
            RowLayout {
                id: actionsRow
                Layout.fillWidth: true
                Layout.topMargin: 5
                spacing: 6
                visible: root.notificationObject && root.notificationObject.actions.length > 0
                Repeater {
                    model: root.notificationObject ? root.notificationObject.actions : []
                    Rectangle {
                        required property var modelData
                        Layout.preferredHeight: 27
                        Layout.preferredWidth: Math.min(130, actionText.implicitWidth + 20)
                        radius: 999
                        color: actionMouse.containsMouse ? Theme.text : Theme.blue
                        BarText {
                            id: actionText
                            anchors.centerIn: parent
                            text: modelData.text
                            color: Theme.background
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.actionRequested(root.notificationId, modelData)
                        }
                    }
                }
            }
        }

        ClippingRectangle {
            Layout.preferredWidth: root.imageSource !== "" ? (root.toast ? 54 : 44) : 0
            Layout.preferredHeight: root.imageSource !== "" ? (root.toast ? 54 : 44) : 0
            visible: root.imageSource !== ""
            radius: 9
            color: Theme.background
            Image {
                anchors.fill: parent
                source: root.imageSource
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
            }
        }
    }

    IconText {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 11
        text: "󰅖"
        color: closeMouse.containsMouse ? Theme.red : Theme.muted
        MouseArea {
            id: closeMouse
            anchors.fill: parent
            anchors.margins: -8
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.closeRequested(root.notificationId)
        }
    }

    Rectangle {
        visible: root.toast
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: 3
        radius: 2
        color: Theme.blue
        NumberAnimation on width {
            from: root.width
            to: 0
            duration: 6000
            running: root.toast
        }
    }

    Timer {
        interval: 6000
        running: root.toast
        onTriggered: root.closeRequested(root.notificationId)
    }
}
