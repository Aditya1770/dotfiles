import QtQuick

Pill {
    horizontalPadding: 7
    IconText { text: "󰊠"; color: Theme.blue }
    onClicked: LauncherState.toggle()
}
