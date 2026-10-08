pragma Singleton
import QtQuick

QtObject {
    property var currentPopup: null

    function opened(popup) {
        if (currentPopup && currentPopup !== popup)
            currentPopup.visible = false
        currentPopup = popup
    }

    function closed(popup) {
        if (currentPopup === popup)
            currentPopup = null
    }
}
