import Quickshell
import QtQuick

Item {
    FileView {
        id: configFile
        path: Qt.resolvedUrl("../config.json")
        watchChanges: true
        onFileChanged: {
            print(configFile.text)
        }
    }

    JsonAdapter {
        id: config
        source: configFile.text
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            print("2 " + configFile.text)
        }
    }

    Text {
        anchors.centerIn: parent
        text: "Theme: " + config.theme
    }
}
