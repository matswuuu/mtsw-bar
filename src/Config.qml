pragma Singleton

import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick

Singleton {
    property string test: "123" 

    FileView {
        id: configFile
        path: Qt.resolvedUrl("/home/matswuuu/.config/mtsw-bar/config.json")
        watchChanges: true
        onFileChanged: {
            print(configFile.text)
        }
    }

    // JsonAdapter {
    //     id: config
    //     source: configFile.text
    // }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            print(configFile.text)
        }
    }
}
