pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import qs.config

Singleton {
    readonly property list<var> players: Mpris.players.values
    readonly property MprisPlayer activePlayer: players.length >= 1 ? players[0] : null
    readonly property string title: activePlayer ? activePlayer.trackTitle ?? "" : ""
    readonly property string artist: activePlayer ? activePlayer.trackArtist?.toString() ?? "" : ""
    readonly property string image: activePlayer ? activePlayer.trackArtUrl : null

    readonly property string shortTitle: substringOr(title, Config.config.bar.sound.titleLength, "?")
    readonly property string shortArtist: substringOr(artist, Config.config.bar.sound.artistLength, "?")

    function substringOr(s: string, length: int, ifNull: string): string {
        return s ? s.substring(0, length + 1) || ifNull : ifNull
    }

    function getPlayedSeconds() {
        if (!activePlayer) return 0;

        const pos = activePlayer.position;
        const total = getTotalSeconds();
        return pos > total ? pos - total : pos;
    }

    function getTotalSeconds() {
        return activePlayer ? activePlayer.length : 0;
    }

    Timer {
        running: activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing
        interval: 1000
        repeat: true
        onTriggered: activePlayer.positionChanged()
    }
}