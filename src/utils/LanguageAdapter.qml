pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {

    readonly property string session: Quickshell.env("XDG_CURRENT_DESKTOP").toLowerCase()
    readonly property boolean hyprland: session === "hyprland"
    readonly property boolean niri: session === "niri"

    property string currentLanguage

    function getAdapter() {
        if (hyprland) {
            return Hyrpland;
        } else if (niri) {
            return Niri;
        }
    }

    function nextLanguage() {
        getAdapter().nextLanguage()
        // if (hyprland) {
        //     Hyrpland.nextLanguage();
        // } else if (niri) {
        //     Niri.nextLanguage();
        // }
    }

}