pragma Singleton

import Quickshell
import Quickshell.Io
import QtCore
import QtQuick

Singleton {
    readonly property string homeDir: StandardPaths.writableLocation(
        StandardPaths.HomeLocation
    )
    property var config: JSON.parse(configFile.text())

    FileView {
        id: configFile
        path: homeDir + "/.config/mtsw-bar/config.json"
    }

    Timer {
        running: true
        onTriggered: {
            print(Qt.application)
            print(homeDir)
        }
    }
}
