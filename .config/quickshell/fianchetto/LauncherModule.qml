import QtQuick

Pill {
    horizontalPadding: 7
    IconText { text: ShellSettings.launcherIcon || "󰊠"; color: Theme.pastelLilac }
    onClicked: LauncherState.toggle()
}
