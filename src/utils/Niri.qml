pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    property var translations: {
        "us": "eng",
        "ru": "ru"
    }
    property var fullTranslations: {
        "us": "English",
        "ru": "Russian"
    }

    property string activeLayout: ""
    property var layouts: []
    property string translatedLayout: activeLayout in translations ? translations[activeLayout] : activeLayout

    function nextLanguage() {
        nextLanguage.running = true;
    }

    Process {
        id: fetchLayoutsProc
        running: true
        command: ["niir", "msg", "--json", "keyboard-layouts"]
        stdout: StdioCollector {
            onStreamFinished: {
                const json = JSON.parse(this.text);
                layouts = json["names"]
                const currentIndex = parseInt(json["current_idx"])
                activeLayout = names[layouts]
            }
        }
    }

    Process {
        id: nextLanguage
        command: ["niri", "msg", "action", "switch-layout", "next"]
    }

    Process {
        running: true
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: StdioCollector {
            onRunningChanged: {
                const json = JSON.parse(this.text);
                print(json)
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout") {
                fetchLayoutsProc.running = true;
            }
        }
    }
}