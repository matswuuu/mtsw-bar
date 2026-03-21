pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.i18n

Singleton
{
    function formatKBtoGB(kb: int): string {
        return (kb / 1024 / 1024).toFixed(1).replace(/([^.])0+$/, "$1") + I18n.t("units.gb");
    }

    function formatTime(totalSeconds) {
        const hours = Math.floor(totalSeconds / 3600);
        const minutes = Math.floor((totalSeconds % 3600) / 60);
        const seconds = Math.floor(totalSeconds % 60);

        const hDisplay = hours < 10 ? "0" + hours : hours;
        const mDisplay = minutes < 10 ? "0" + minutes : minutes;
        const sDisplay = seconds < 10 ? "0" + seconds : seconds;

        return `${hDisplay}:${mDisplay}:${sDisplay}`;
    }
}
