import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.element.osd as Osd
import qs.services.brightness
import qs.utils

Osd.DisplayIndicator {
    id: brightnessIndicator
    Layout.alignment: Qt.AlignHCenter
    title: "Brightness"
    icon: Brightness.getSymbol()

    Connections {
        target: Brightness

        function onBrightnessChanged(currentBrightness, maxBrightness) {
            brightnessIndicator.value = Math.floor(currentBrightness / maxBrightness * 100);
            brightnessIndicator.icon = Brightness.getSymbol();
            brightnessIndicator.show();
        }
    }
}
