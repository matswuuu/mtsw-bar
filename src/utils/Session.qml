pragma Singleton

import Quickshell

Singleton {
    readonly property string session: Quickshell.env("XDG_CURRENT_DESKTOP").toLowerCase()
    readonly property bool hyprland: session === "hyprland"
    readonly property bool niri: session === "niri"

    function getAdapter() {
        if (Session.hyprland) {
            return Hyprland;
        } else if (Session.niri) {
            return Niri;
        }
    }
}