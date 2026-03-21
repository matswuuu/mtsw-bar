pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.i18n

Singleton
{
    property var translations: {
        "us": "eng",
        "ru": "ru"
    }
    property var fullTranslations: {
        "us": I18n.t("language.english"),
        "ru": I18n.t("language.russian")
    }

    // Json object with keyboard properties 
    property var keyboard
    property string activeLayout: ""
    property var layouts: []
    property string translatedLayout: activeLayout in translations ? translations[activeLayout] : activeLayout

    function nextLanguage() {
        nextLanguage.running = true;
    }

    Process {
        id: fetchLayoutsProc
        command: ["hyprctl", "-j", "devices"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parsedOutput = JSON.parse(this.text);
                keyboard = parsedOutput["keyboards"].find(kb => kb.main === true);
                layouts = keyboard["layout"].split(",");
                activeLayout = layouts[keyboard.active_layout_index];
            }
        }
    }

    Process {
        id: nextLanguage
        command: [
            "hyprctl",
            "switchxkblayout",
            keyboard ? keyboard["name"] : "",
            "next"
        ]
    }

    Connections {
        target: Hyprland
        enabled: Session.hyprland

        function onRawEvent(event) {
            if (event.name === "activelayout") {
                fetchLayoutsProc.running = true;
            }
        }
    }
}
