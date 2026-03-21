import qs.theme
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

MouseArea {
    readonly property var theme: Themes.active

    id: root
    required property SystemTrayItem item

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: theme.itemSize
    implicitHeight: theme.itemSize
    onPressed: (event) => {
        switch (event.button) {
            case Qt.LeftButton:
                item.activate();
                break;
            case Qt.RightButton:
                if (item.hasMenu) menu.open();
                break;
        }
        event.accepted = true;
    }

    IconImage {
        id: trayIcon
        source: {
            const raw = root.item.icon
            if (raw.includes("?path=")) { // Fix JetBrains Toolbox icon
                const parts = raw.split("?path=")
                return "image://icon/" + parts[1] + "/" + parts[0].replace("image://icon/", "") + ".png"
            } else {
                return raw
            }
        }
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        layer.enabled: true
    }

    MultiEffect {
        source: trayIcon
        anchors.fill: trayIcon
        colorization: 1.0
        colorizationColor: "#ffffff"
    }
}
