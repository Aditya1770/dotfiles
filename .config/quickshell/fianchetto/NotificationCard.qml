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
    property var notificationObject: null
    property bool toast: false
    property real slideOffset: toast ? width : 0
    signal closeRequested(int notificationId)
    signal actionRequested(int notificationId, var action)

    implicitHeight: Math.max(toast ? 92 : 72, content.implicitHeight + 24)
    radius: toast ? 12 : 14
    color: "#0A1114"
    border.width: 0
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
                color: Theme.blue
                font.pixelSize: root.toast ? 20 : 16
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            BarText {
                Layout.fillWidth: true
                visible: root.toast
                text: root.appName
                color: Theme.blue
                font.pixelSize: 10
                elide: Text.ElideRight
            }
            BarText {
                Layout.fillWidth: true
                text: root.summary
                font.pixelSize: 15
                elide: Text.ElideRight
            }
            BarText {
                Layout.fillWidth: true
                visible: root.body !== ""
                text: root.body
                color: Theme.muted
                font.pixelSize: 12
                font.weight: Font.Normal
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
            RowLayout {
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
                        radius: 10
                        color: actionMouse.containsMouse ? Theme.blue : Theme.surfaceHover
                        BarText {
                            id: actionText
                            anchors.centerIn: parent
                            text: modelData.text
                            color: actionMouse.containsMouse ? Theme.background : Theme.blue
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
