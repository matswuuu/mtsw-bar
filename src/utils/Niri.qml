pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property string activeLayout: ""
    property var layouts: []

    function nextLanguage() {
        nextLanguageProc.running = true;
    }

    Process {
        id: nextLanguageProc
        command: ["niri", "msg", "action", "switch-layout", "next"]
    }

    Process {
        running: true
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                if (data.trim() === "") return
                const json = JSON.parse(data)

                if (json.KeyboardLayoutsChanged) {
                    layouts = json.KeyboardLayoutsChanged.keyboard_layouts.names
                    activeLayout = layouts[json.KeyboardLayoutsChanged.keyboard_layouts.current_idx]
                }
                if (json.KeyboardLayoutSwitched) {
                    activeLayout = layouts[json.KeyboardLayoutSwitched.idx]
                }
            }
        }
    }
}
