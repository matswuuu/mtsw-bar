import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.element.osd as Osd
import qs.services.sound
import qs.utils

Osd.DisplayIndicator {
    id: soundIndicator
    Layout.alignment: Qt.AlignHCenter
    title: "Volume"
    icon: Sound.getOutputSymbol()

    Connections {
        target: Sound

        function onOutputUpdated(volume: int, muted: bool) {
            soundIndicator.value = volume;
            soundIndicator.icon = Sound.getOutputSymbol();
            soundIndicator.show();
        }
    }
}
